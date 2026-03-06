part of 'parser.dart';

@Deprecated('Use Printer instead')
typedef AnsiPrinter = Printer;

/// A printer that processes ANSI escape codes and replaces the default text
/// style.
///
/// This printer buffers strings line by line and outputs them using the
/// provided `output` function, or `Zone.current.print` by default. It uses
/// [Parser] to track the current [Style] across multiple prints.
///
/// See also [runZonedPrinter] for usage within a zone.
final class Printer extends _PrintPrinterBase<Style> {
  /// Creates a printer that processes ANSI escape codes and replaces the
  /// default text style.
  Printer({
    super.defaultStyle = Style.defaults,
    super.output,
    super.ansiCodesEnabled = true,
    @visibleForTesting super.debugForTest,
  }) : super(stateDefaults: Style.defaults);
}

/// A printer that processes ANSI escape codes, replaces the default text
/// style, and tracks the [Stack] of styles.
///
/// Similar to [Printer], but instead of maintaining only the currently active
/// [Style], [StackedPrinter] tracks the full history of applied styles using a
/// [Stack]. This is useful for complex formatting where styles might be
/// applied and reverted hierarchically across multiple print statements.
///
/// See also [runZonedStackedPrinter] for usage within a zone.
final class StackedPrinter extends _PrintPrinterBase<Stack> {
  /// Creates a printer that processes ANSI escape codes, replaces the default
  /// text style, and tracks the [Stack] of styles.
  StackedPrinter({
    super.defaultStyle = Style.defaults,
    super.output,
    super.ansiCodesEnabled = true,
    @visibleForTesting super.debugForTest,
  }) : super(stateDefaults: Stack.defaults);
}

/// A printer that processes ANSI escape codes and writes the output to
/// a [StringSink].
///
/// Unlike [Printer], which delegates to a print function, [SinkPrinter] writes
/// directly to the provided `sink`. It continuous tracks the current [Style]
/// across multiple write operations.
final class SinkPrinter extends _SinkPrinterBase<Style> {
  /// Creates a printer that processes ANSI escape codes and writes the output
  /// to a [StringSink].
  SinkPrinter(
    super.sink, {
    super.defaultStyle = Style.defaults,
    super.ansiCodesEnabled = true,
    @visibleForTesting super.debugForTest,
  }) : super(stateDefaults: Style.defaults);
}

/// A printer that processes ANSI escape codes, writes the output to
/// a [StringSink], and tracks the [Stack] of styles.
///
/// Similar to [SinkPrinter], but it tracks the full history of applied styles
/// using a [Stack], which allows for nested style applications and reversions
/// across multiple write operations.
final class StackedSinkPrinter extends _SinkPrinterBase<Stack> {
  /// Creates a printer that processes ANSI escape codes, writes the output to
  /// a [StringSink], and tracks the [Stack] of styles.
  StackedSinkPrinter(
    super.sink, {
    super.defaultStyle = Style.defaults,
    super.ansiCodesEnabled = true,
    @visibleForTesting super.debugForTest,
  }) : super(stateDefaults: Stack.defaults);
}

sealed class _PrinterBase<S extends State<S>> implements StringSink {
  final S stateDefaults;
  final Style defaultStyle;
  final bool ansiCodesEnabled;
  S? lastState;

  bool debugForTest;

  _PrinterBase({
    required this.stateDefaults,
    required this.defaultStyle,
    required this.ansiCodesEnabled,
    bool? debugForTest,
  }) : debugForTest = debugForTest ?? false;

  /// Prints the given object to the output.
  void print(Object? object) => writeln(object);

  /// Prepares the given line for printing.
  String prepare(String line) {
    if (line.isEmpty) {
      return '';
    }

    if (!ansiCodesEnabled) {
      return line.ansiRemoveEscapeCodes();
    }

    var lastState = stateDefaults.toStyle();

    final parser = _ParserBase<S>(line, this.lastState ?? stateDefaults);
    final buf = StringBuffer(reset);

    for (final m in parser.matches) {
      final entity = m.entity;
      if (entity is Text) {
        final newState = m.state.changeDefaultsTo(defaultStyle);
        buf
          ..write(lastState.transitTo(newState))
          ..write(entity.string);
        lastState = newState;
      }
    }

    buf.write(lastState.transitTo(stateDefaults));
    this.lastState = parser.finalState;

    return buf.toString();
  }
}

final class _PrintPrinterBase<S extends State<S>> extends _PrinterBase<S> {
  final void Function(String line) _output;
  final StringBuffer _lineBuf = StringBuffer();

  _PrintPrinterBase({
    required super.stateDefaults,
    required super.defaultStyle,
    void Function(String line)? output,
    required super.ansiCodesEnabled,
    super.debugForTest,
  }) : _output = output ?? Zone.current.print;

  /// Writes the given object to the buffer.
  @override
  void write(Object? object) {
    _lineBuf.write(object);
  }

  /// Writes the given objects to the buffer.
  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) {
    var isFirst = true;
    for (final object in objects) {
      if (isFirst) {
        isFirst = false;
      } else {
        _lineBuf.write(separator);
      }

      _lineBuf.write(object);
    }
  }

  /// Writes the given character code to the buffer.
  @override
  void writeCharCode(int charCode) {
    _lineBuf.writeCharCode(charCode);
  }

  /// Writes the given object to the buffer and flush buffer.
  @override
  void writeln([Object? object = '']) {
    _lineBuf.write(object);
    _writeBuf();
  }

  /// Flushes the buffer.
  void _writeBuf() {
    final buf = _lineBuf.toString();
    _lineBuf.clear();

    for (final line in buf.split('\n')) {
      final output = prepare(line);
      _output(output);
      if (debugForTest) {
        _output(Parser(output).showControlFunctions());
      }
    }
  }
}

final class _SinkPrinterBase<S extends State<S>> extends _PrinterBase<S> {
  final StringSink sink;

  _SinkPrinterBase(
    this.sink, {
    required super.stateDefaults,
    required super.defaultStyle,
    required super.ansiCodesEnabled,
    super.debugForTest,
  });

  /// Writes the given object to the buffer.
  @override
  void write(Object? object) {
    _writeBuf(object.toString());
  }

  /// Writes the given objects to the buffer.
  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) {
    var isFirst = true;
    final buf = StringBuffer();
    for (final object in objects) {
      if (isFirst) {
        isFirst = false;
      } else {
        buf.write(separator);
      }

      buf.write(object);
    }

    _writeBuf(buf.toString());
  }

  /// Writes the given character code to the buffer.
  @override
  void writeCharCode(int charCode) {
    _writeBuf(String.fromCharCode(charCode));
  }

  /// Writes the given object to the buffer and flush buffer.
  @override
  void writeln([Object? object = '']) {
    _writeBuf(object.toString());
    sink.writeln();
  }

  /// Flushes the buffer.
  void _writeBuf(String buf) {
    var pos = 0;
    var endIndex = buf.indexOf('\n');
    while (endIndex != -1) {
      final line = buf.substring(pos, endIndex);
      _writeLine(line);
      sink.write('\n');

      pos = endIndex + 1;
      endIndex = buf.indexOf('\n', pos);
    }

    final line = buf.substring(pos);
    _writeLine(line);
  }

  /// Writes the given line to the sink.
  void _writeLine(String line) {
    final output = prepare(line);
    sink.write(output);
    if (debugForTest) {
      sink.write(Parser(output).showControlFunctions());
    }
  }
}

@Deprecated('Use runZonedPrinter instead')
R runZonedAnsiPrinter<R>(
  R Function() run, {
  Style defaultStyle = Style.defaults,
  void Function(String s)? output,
  bool ansiCodesEnabled = true,
  @visibleForTesting bool debugForTest = false,
}) =>
    runZonedPrinter(
      run,
      defaultStyle: defaultStyle,
      output: output,
      ansiCodesEnabled: ansiCodesEnabled,
      debugForTest: debugForTest,
    );

/// Runs the given function in a zone where all print statements are processed
/// by the printer.
R runZonedPrinter<R>(
  R Function() run, {
  Style defaultStyle = Style.defaults,
  void Function(String s)? output,
  bool ansiCodesEnabled = true,
  @visibleForTesting bool debugForTest = false,
}) {
  Printer? printer;

  return runZoned(
    run,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        (printer ??= Printer(
          defaultStyle: defaultStyle,
          output: output ?? (line) => parent.print(zone, line),
          ansiCodesEnabled: ansiCodesEnabled,
          debugForTest: debugForTest,
        ))
            .print(line);
      },
    ),
  );
}

/// Runs the given function in a zone where all print statements are processed
/// by the stacked printer.
R runZonedStackedPrinter<R>(
  R Function() run, {
  Style defaultStyle = Style.defaults,
  void Function(String s)? output,
  bool ansiCodesEnabled = true,
  @visibleForTesting bool debugForTest = false,
}) {
  StackedPrinter? printer;

  return runZoned(
    run,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        printer ??= StackedPrinter(
          defaultStyle: defaultStyle,
          output: output ?? (line) => parent.print(zone, line),
          ansiCodesEnabled: ansiCodesEnabled,
          debugForTest: debugForTest,
        )..print(line);
      },
    ),
  );
}
