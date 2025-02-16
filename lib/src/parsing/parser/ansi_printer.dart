part of 'ansi_parser.dart';

sealed class AnsiPrinter implements StringSink {
  factory AnsiPrinter.print({
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
    io.IOSink sink, {
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

  FutureOr<void> flush();
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
    flush();
  }

  @override
  void flush() {
    final output = prepare(_lineBuf.toString());
    _output(output);
    if (debugForTest) {
      _output(AnsiParser(output).showControlFunctions());
    }

    _lineBuf.clear();
  }

  @override
  String prepare(String string) {
    if (!ansiCodesEnabled) {
      return string.removeEscapeCodes();
    }

    var lastState = defaultState;

    final parser = _ParserBase<S>._(string, stateDefaults);
    final buf = StringBuffer()
      ..write(reset)
      ..write(
        stateDefaults.transitTo(
          lastState.changeDefaultsTo(stateDefaults),
        ),
      );

    for (final m in parser.matches) {
      final entity = m.entity;
      if (entity is Text) {
        // For debug:
        // log('"${entity.string}" ${m.state}');
        final newState = m.state.changeDefaultsTo(defaultState);
        buf
          ..write(lastState.transitTo(newState))
          ..write(entity.string);
        lastState = newState;
      }
    }

    buf.write(reset);

    return buf.toString();
  }
}

base class _IOPrinterBase<S extends SgrState<S>> extends _PrinterBase<S> {
  final io.IOSink sink;

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
      sink.writeln();

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

  @override
  String prepare(String string) {
    if (!ansiCodesEnabled) {
      return string.removeEscapeCodes();
    }

    var lastState = defaultState;

    final parser = _ParserBase<S>._(string, stateDefaults);
    final buf = StringBuffer()
      ..write(reset)
      ..write(
        stateDefaults.transitTo(
          lastState.changeDefaultsTo(stateDefaults),
        ),
      );

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

    buf.write(reset);

    return buf.toString();
  }

  @override
  FutureOr<void> flush() => sink.flush();
}

R runZonedAnsiPrinter<R>(
  R Function() run, {
  SgrPlainState defaultState = SgrPlainState.defaults,
  void Function(String s)? output,
  bool stacked = false,
  bool ansiCodesEnabled = true,
  @visibleForTesting bool debugForTest = false,
}) {
  final printer = AnsiPrinter.print(
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
