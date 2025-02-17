part of 'ansi_parser.dart';

/// Printer for replacing the default text style.
sealed class AnsiPrinter implements StringSink {
  factory AnsiPrinter({
    SgrPlainState defaultState = SgrPlainState.defaults,
    void Function(String)? output,
    bool stacked = false,
    bool ansiCodesEnabled = true,
    @visibleForTesting bool? debugForTest,
  }) =>
      !stacked
          ? _PrintPrinterBase(
              stateDefaults: SgrPlainState.defaults,
              defaultState: defaultState,
              output: output,
              ansiCodesEnabled: ansiCodesEnabled,
              debugForTest: debugForTest,
            )
          : _PrintPrinterBase(
              stateDefaults: SgrStackedState.defaults,
              defaultState: defaultState,
              output: output,
              ansiCodesEnabled: ansiCodesEnabled,
              debugForTest: debugForTest,
            );

  factory AnsiPrinter.sink(
    StringSink sink, {
    SgrPlainState defaultState = SgrPlainState.defaults,
    bool stacked = false,
    bool ansiCodesEnabled = true,
    @visibleForTesting bool? debugForTest,
  }) =>
      !stacked
          ? _IOPrinterBase(
              sink,
              stateDefaults: SgrPlainState.defaults,
              defaultState: defaultState,
              ansiCodesEnabled: ansiCodesEnabled,
              debugForTest: debugForTest,
            )
          : _IOPrinterBase(
              sink,
              stateDefaults: SgrStackedState.defaults,
              defaultState: defaultState,
              ansiCodesEnabled: ansiCodesEnabled,
              debugForTest: debugForTest,
            );

  AnsiPrinter._();

  void print(Object? object);

  @visibleForTesting
  String prepare(String string);
}

sealed class _PrinterBase<S extends SgrState<S>> extends AnsiPrinter {
  final S stateDefaults;
  final SgrPlainState defaultState;
  final bool ansiCodesEnabled;
  S? lastState;

  bool debugForTest;

  _PrinterBase._({
    required this.stateDefaults,
    required this.defaultState,
    required this.ansiCodesEnabled,
    bool? debugForTest,
  })  : debugForTest = debugForTest ?? false,
        super._();

  @override
  void print(Object? object) => writeln(object);

  @override
  String prepare(String line) {
    if (line.isEmpty) {
      return '';
    }

    if (!ansiCodesEnabled) {
      return line.removeEscapeCodes();
    }

    var lastState = stateDefaults.toPlainState();

    final parser = _ParserBase<S>._(line, this.lastState ?? stateDefaults);
    final buf = StringBuffer(reset);

    for (final m in parser.matches) {
      final entity = m.entity;
      if (entity is Text) {
        final newState = m.state.changeDefaultsTo(defaultState);
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

base class _PrintPrinterBase<S extends SgrState<S>> extends _PrinterBase<S> {
  final void Function(String line) _output;
  final StringBuffer _lineBuf = StringBuffer();

  _PrintPrinterBase({
    required super.stateDefaults,
    required super.defaultState,
    void Function(String line)? output,
    required super.ansiCodesEnabled,
    super.debugForTest,
  })  : _output = output ?? Zone.current.print,
        super._();

  @override
  void write(Object? object) {
    _lineBuf.write(object);
  }

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

  @override
  void writeCharCode(int charCode) {
    _lineBuf.writeCharCode(charCode);
  }

  @override
  void writeln([Object? object = '']) {
    _lineBuf.write(object);
    _writeBuf();
  }

  void _writeBuf() {
    final buf = _lineBuf.toString();
    _lineBuf.clear();

    for (final line in buf.split('\n')) {
      final output = prepare(line);
      _output(output);
      if (debugForTest) {
        _output(AnsiParser(output).showControlFunctions());
      }
    }
  }
}

base class _IOPrinterBase<S extends SgrState<S>> extends _PrinterBase<S> {
  final StringSink sink;

  _IOPrinterBase(
    this.sink, {
    required super.stateDefaults,
    required super.defaultState,
    required super.ansiCodesEnabled,
    super.debugForTest,
  }) : super._();

  @override
  void write(Object? object) {
    _writeBuf(object.toString());
  }

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

  @override
  void writeCharCode(int charCode) {
    _writeBuf(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = '']) {
    _writeBuf(object.toString());
    sink.writeln();
  }

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

  void _writeLine(String line) {
    final output = prepare(line);
    sink.write(output);
    if (debugForTest) {
      sink.write(AnsiParser(output).showControlFunctions());
    }
  }
}

R runZonedAnsiPrinter<R>(
  R Function() run, {
  SgrPlainState defaultState = SgrPlainState.defaults,
  void Function(String s)? output,
  bool stacked = false,
  bool ansiCodesEnabled = true,
  @visibleForTesting bool debugForTest = false,
}) {
  final printer = AnsiPrinter(
    defaultState: defaultState,
    output: output ?? (line) => Zone.current.parent!.print(line),
    stacked: stacked,
    ansiCodesEnabled: ansiCodesEnabled,
    debugForTest: debugForTest,
  );

  return runZoned(
    run,
    zoneSpecification: ZoneSpecification(
      print: (_, __, ___, line) {
        printer.print(line);
      },
    ),
  );
}
