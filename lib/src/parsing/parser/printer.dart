part of 'parser.dart';

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
    super.defaultStyle = Style.terminalColors,
    super.output,
    super.ansiCodesEnabled = true,
    @visibleForTesting super.debugForTest,
  }) : super(stateDefaults: Style.terminalColors);
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
    super.defaultStyle = Style.terminalColors,
    super.output,
    super.ansiCodesEnabled = true,
    @visibleForTesting super.debugForTest,
  }) : super(stateDefaults: Stack.terminalColors);
}

/// A printer that processes ANSI escape codes and writes the output to
/// a [StringSink].
///
/// Unlike [Printer], which delegates to a print function, [SinkPrinter] writes
/// directly to the provided `sink`. It continuous tracks the current [Style]
/// across multiple write operations.
///
/// A hyperlink is tracked the same way: one opened by a write stays open
/// across the writes that follow, so a link may be composed of several of
/// them. It is closed where the line ends — at a [writeln] or a `'\n'` in
/// what is written — and, unlike the style, is not reopened on the next line.
final class SinkPrinter extends _SinkPrinterBase<Style> {
  /// Creates a printer that processes ANSI escape codes and writes the output
  /// to a [StringSink].
  SinkPrinter(
    super.sink, {
    super.defaultStyle = Style.terminalColors,
    super.ansiCodesEnabled = true,
    @visibleForTesting super.debugForTest,
  }) : super(stateDefaults: Style.terminalColors);
}

/// A printer that processes ANSI escape codes, writes the output to
/// a [StringSink], and tracks the [Stack] of styles.
///
/// Similar to [SinkPrinter], but it tracks the full history of applied styles
/// using a [Stack], which allows for nested style applications and reversions
/// across multiple write operations.
///
/// A hyperlink is carried across writes and closed at the end of the line,
/// the way [SinkPrinter] does it.
final class StackedSinkPrinter extends _SinkPrinterBase<Stack> {
  /// Creates a printer that processes ANSI escape codes, writes the output to
  /// a [StringSink], and tracks the [Stack] of styles.
  StackedSinkPrinter(
    super.sink, {
    super.defaultStyle = Style.terminalColors,
    super.ansiCodesEnabled = true,
    @visibleForTesting super.debugForTest,
  }) : super(stateDefaults: Stack.terminalColors);
}

sealed class _PrinterBase<S extends State<S>> implements StringSink {
  /// The state a line is closed back to: the terminal's own colours.
  final S stateDefaults;

  /// The style the text is given where it asks for none of its own.
  ///
  /// A [NoStyle] here keeps the printer's hands off entirely: the line
  /// goes out as it came, its own codes included. That is the other
  /// half of [ansiCodesEnabled] — a [NoStyle] leaves the text's codes
  /// alone, `ansiCodesEnabled: false` takes them out.
  final Style defaultStyle;

  /// Whether escape codes are written at all.
  ///
  /// With this off the text goes out bare — the codes it carried included —
  /// which is what output that is not a terminal wants.
  final bool ansiCodesEnabled;

  /// The state the last prepared line ended in, carried into the next one —
  /// and null where no line has been read, as it stays for a printer whose
  /// [defaultStyle] is a [NoStyle]: imposing nothing, it carries nothing.
  /// It stays null with [ansiCodesEnabled] off as well — the line is
  /// stripped and handed back before there is a state to keep.
  ///
  /// Setting it from outside puts the printer out of step with what the
  /// terminal has already been sent.
  @visibleForTesting
  S? lastState;

  /// Whether each line is followed by the same line with its codes named,
  /// which is how the tests read what was written.
  @visibleForTesting
  bool debugForTest;

  _PrinterBase({
    required this.stateDefaults,
    required this.defaultStyle,
    required this.ansiCodesEnabled,
    bool? debugForTest,
  }) : debugForTest = debugForTest ?? false;

  /// Prints the given object to the output.
  void print(Object? object) => writeln(object);

  /// Whether a string handed to [prepare] is a whole line, so that a
  /// hyperlink it left open is closed at its end.
  ///
  /// A printer that takes a line at a time closes as it goes; one that takes
  /// a write at a time cannot, and waits for the line to end.
  bool get _closesLinkAtEnd;

  /// Whether what has been prepared so far left a hyperlink open.
  ///
  /// It is false again by the time a whole line has been prepared, and only
  /// carries anything between the writes that make up one line.
  bool _linkIsOpen = false;

  /// Prepares the given line for printing.
  ///
  /// A [Printer] and a [StackedPrinter] are handed a whole line here, and a
  /// line that opens a hyperlink and does not close it gets the close
  /// written at its end, the way a slice does. A link, unlike the style, is
  /// not reopened on the next line.
  ///
  /// A [SinkPrinter] and a [StackedSinkPrinter] are handed one write, and a
  /// line may be composed of several: there an open link is carried to the
  /// write that follows, and the close waits for the line to really end —
  /// for a [writeln], or for a `'\n'` in what is written.
  String prepare(String line) => _prepare(line, closeLink: _closesLinkAtEnd);

  /// Prepares [line], closing a hyperlink it leaves open where [closeLink]
  /// says the line ends here.
  String _prepare(String line, {required bool closeLink}) {
    if (!ansiCodesEnabled) {
      return line.ansiRemoveEscapeCodes();
    }

    // A NoStyle imposes nothing: no reset, no default, no unwinding —
    // the line goes out exactly as it came, its own codes included.
    // Taking those out is what `ansiCodesEnabled: false` is for.
    if (defaultStyle is NoStyle) {
      return line;
    }

    if (line.isEmpty) {
      // Nothing of its own to prepare — but a line that ends here still owes
      // the close for a link an earlier write of the same line left open.
      if (closeLink && _linkIsOpen) {
        _linkIsOpen = false;

        return linkClose;
      }

      return '';
    }

    var lastState = stateDefaults.toStyle();

    final parser = _ParserBase<S>(line, this.lastState ?? stateDefaults);
    final buf = StringBuffer(reset);

    var linkIsOpen = _linkIsOpen;

    for (final m in parser.matches) {
      // An SGR sequence says what the style is, and the style is written by
      // the transition below instead of being passed on. Everything else —
      // the text, and the codes that move the cursor or clear the screen —
      // is the line's own and goes through as it came.
      if (m.entity case Sgr()) {
        continue;
      }

      // A hyperlink passes through as it came, but not unnoticed: a line
      // that opens one and does not close it would make everything printed
      // after it part of the link, so the close is written where the line
      // ends — the way a slice closes the link it opened. Unlike the style,
      // a link is not reopened afterwards.
      if (m.entity case Link(:final url)) {
        linkIsOpen = url.isNotEmpty;
      }

      // The style is put on before the code that reads it: erasing and
      // scrolling take the background colour of the moment.
      final newState = m.state.changeDefaultsTo(defaultStyle);
      buf
        ..write(lastState.transitTo(newState))
        ..write(m.entity.string);
      lastState = newState;
    }

    if (linkIsOpen && closeLink) {
      buf.write(linkClose);
      linkIsOpen = false;
    }
    _linkIsOpen = linkIsOpen;

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

  /// A line is buffered whole and handed to [prepare] whole, so a link it
  /// leaves open is closed at its end.
  @override
  bool get _closesLinkAtEnd => true;

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
  /// Where the output goes.
  final StringSink sink;

  _SinkPrinterBase(
    this.sink, {
    required super.stateDefaults,
    required super.defaultStyle,
    required super.ansiCodesEnabled,
    super.debugForTest,
  });

  /// A write goes to the sink as it comes, and one line may be composed of
  /// several: [prepare] is handed a piece, not a line, so a link it leaves
  /// open is carried to the next write instead of being closed here. The
  /// close is written where the line really ends — see [_writeBuf].
  @override
  bool get _closesLinkAtEnd => false;

  /// Prepares the given piece and hands it back without sending it anywhere.
  ///
  /// The carry of an open hyperlink belongs to the writes that reach the
  /// sink, so a piece prepared here and not written leaves it as it was: a
  /// link opened in what was only asked about is not one the sink would ever
  /// be owed a close for.
  @override
  String prepare(String line) {
    final keepLinkIsOpen = _linkIsOpen;
    final prepared = super.prepare(line);
    _linkIsOpen = keepLinkIsOpen;

    return prepared;
  }

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
    _writeBuf(object.toString(), endsLine: true);
    sink.writeln();
  }

  /// Flushes the buffer.
  ///
  /// Everything before a `'\n'` is a line the sink has seen the end of, and
  /// [endsLine] says the same of what is left after the last one — which is
  /// true of a [writeln] and false of a [write], where the line goes on into
  /// the write that follows.
  void _writeBuf(String buf, {bool endsLine = false}) {
    var pos = 0;
    var endIndex = buf.indexOf('\n');
    while (endIndex != -1) {
      final line = buf.substring(pos, endIndex);
      _writeLine(line, endsLine: true);
      sink.write('\n');

      pos = endIndex + 1;
      endIndex = buf.indexOf('\n', pos);
    }

    final line = buf.substring(pos);
    _writeLine(line, endsLine: endsLine);
  }

  /// Writes the given line to the sink.
  void _writeLine(String line, {required bool endsLine}) {
    final output = _prepare(line, closeLink: endsLine);
    sink.write(output);
    if (debugForTest) {
      sink.write(Parser(output).showControlFunctions());
    }
  }
}

/// Runs the given function in a zone where all print statements are processed
/// by the printer.
///
/// [output] takes each line once the printer is done with it, and goes to the
/// print outside the zone when it is left out. Do not pass `print` itself: the
/// zone catches it, hands it back to the printer, and the two go round until
/// the stack runs out.
R runZonedPrinter<R>(
  R Function() run, {
  Style defaultStyle = Style.terminalColors,
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
///
/// See [runZonedPrinter] for [output], which must not be `print` itself.
R runZonedStackedPrinter<R>(
  R Function() run, {
  Style defaultStyle = Style.terminalColors,
  void Function(String s)? output,
  bool ansiCodesEnabled = true,
  @visibleForTesting bool debugForTest = false,
}) {
  StackedPrinter? printer;

  return runZoned(
    run,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        (printer ??= StackedPrinter(
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
