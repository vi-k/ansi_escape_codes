part of 'parser.dart';

/// A printer that processes ANSI escape codes and replaces the default text
/// style.
///
/// This printer buffers strings line by line and outputs them using the
/// provided `output` function, or `Zone.current.print` by default. It uses
/// [Parser] to track the current [Style] across multiple prints.
///
/// A hyperlink is carried the same way. A line closes the one it leaves open
/// — what is printed after it must not stay clickable on that URL — and the
/// line after opens it again, so a link a line break falls inside of goes on
/// being one link.
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
/// A hyperlink is carried from one line to the next the way [Printer] carries
/// it: links do not nest, so there is no stack of them to keep.
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
/// what is written — and, the text being inside it still, opened again on the
/// line after, the way the style is.
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
/// A hyperlink is carried across writes, closed at the end of the line and
/// opened again on the next, the way [SinkPrinter] does it.
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

  /// The hyperlink open in what has been written of the current line, or null
  /// where none is.
  ///
  /// This is what the close at the end of the line is owed to, and what says
  /// whether the opening has to be written again. It is null again by the time
  /// a whole line has been prepared, and only carries anything between the
  /// writes that make up one line.
  Link? _writtenLink;

  /// The hyperlink open in the text, whether or not it is open in the output,
  /// or null where none is.
  ///
  /// The link channel's half of [lastState]: the line before closed the link
  /// in what it sent to the terminal, and left this behind to say the text
  /// goes on inside it. The next line is read as beginning inside it and
  /// opens it again, the way the style is reopened, so that a link a line
  /// break cuts in two goes on being one link.
  ///
  /// It survives the close at the end of the line and dies where the text
  /// itself closes the link.
  Link? _ambientLink;

  /// Prepares the given line for printing.
  ///
  /// A [Printer] and a [StackedPrinter] are handed a whole line here, and a
  /// line that opens a hyperlink and does not close it gets the close
  /// written at its end, the way a slice does — and, as there, the close is
  /// the `ST`-terminated one whatever form the opening took: see
  /// [Parser.substring].
  ///
  /// That close is written for the terminal, which must not make what comes
  /// after clickable on a URL it has nothing to do with; the text goes on
  /// inside the link, and the line after opens it again in front of the first
  /// text it shows, in the bytes the link was opened with. The style is
  /// carried over the same way. A link the text itself closes is carried no
  /// further, and a line with nothing to show inside the link writes no
  /// opening at all and hands it on.
  ///
  /// What the line carries goes through as it stands, its link codes
  /// included: a close for a link nothing has open, or a second opening of
  /// the link that is open already, is passed on rather than dropped, where
  /// [Parser.substring] writes neither. The difference is in the bytes and
  /// not in what they say — after the line the terminal stands in the same
  /// link either way — and a printer is for text that is to reach the screen
  /// as its author wrote it.
  ///
  /// A line holding an `ESC 8` loses a link, and by the same mechanism a
  /// slice does: the opening is held back until there is text to show inside
  /// it, so a save standing in front of that text saves no link and the
  /// restore behind it gives none back. In
  /// `OSC 8;;url ST one \n ESC 7 two ESC 8 three` the second line writes the
  /// `two` inside the link and the `three` outside it, where the string has
  /// both inside. The bytes are copied as they stand and neither a save nor a
  /// restore is rewritten; [Parser.substring] says the whole of what is
  /// accepted here.
  ///
  /// A [SinkPrinter] and a [StackedSinkPrinter] are handed a piece rather
  /// than a line, and this only prepares it: nothing is written, and the
  /// link is left as it was — both what is open in the output and what is
  /// open in the text. The carry belongs to their [write] and [writeln]
  /// instead — a line there may be composed of several writes, an open link
  /// is carried into the write that follows, and the close waits for the line
  /// to really end, for a [writeln] or for a `'\n'` in what is written. The
  /// line after that one opens the link again.
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
      // the close for a link an earlier write of the same line left open. The
      // link stays open in the text, and the line after reopens it.
      if (closeLink && _writtenLink != null) {
        _writtenLink = null;

        return linkClose;
      }

      return '';
    }

    var lastState = stateDefaults.toStyle();

    // Read from where the line before ended, in the style as in the link: a
    // line that touches neither goes out as it came and hands both on.
    final parser = _ParserBase<S>(
      line,
      this.lastState ?? stateDefaults,
      initialLink: _ambientLink,
    );
    final buf = StringBuffer(reset);

    var writtenLink = _writtenLink;

    // An opening of the line's own that never terminated, held back until
    // what comes after it is known. In the line it was ended by the `ESC` of
    // whatever stood behind it, and that may have been an `SGR` — which this
    // loop does not copy but writes again as a transition, and a transition
    // that changes nothing writes nothing. See [_terminatedIfTextFollows].
    var heldOpening = '';

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
      // ends — the way a slice closes the link it opened.
      if (m.entity case Link()) {
        writtenLink = m.link;
      }

      // A line that begins inside a link — one the line before left open and
      // closed at its end — opens it again itself, in front of the first text
      // it shows and in the bytes the link was opened with. The style is
      // reopened the same way, by the transition below. A line with nothing
      // to show inside the link writes no opening at all and hands the link
      // on to the line after.
      //
      // An opening the line before never terminated is terminated here: the
      // text of this line follows it now, and would otherwise be read as part
      // of the url — see [Link._reopening].
      var reopening = '';
      if (m.entity is Text && writtenLink == null) {
        if (m.link case final link?) {
          reopening = link._reopening;
          writtenLink = link;
        }
      }

      // The style is put on before the code that reads it: erasing and
      // scrolling take the background colour of the moment.
      final newState = m.state.changeDefaultsTo(defaultStyle);
      final transit = lastState.transitTo(newState);
      final string = m.entity.string;

      if (heldOpening.isNotEmpty) {
        buf.write(
          _terminatedIfTextFollows(heldOpening, '$reopening$transit$string'),
        );
        heldOpening = '';
      }

      buf
        ..write(reopening)
        ..write(transit);

      // An opening with no terminator waits to see what it is written in
      // front of; everything else goes out where it stands.
      if (m.entity is Link && !_oscTerminated(string)) {
        heldOpening = string;
      } else {
        buf.write(string);
      }
      lastState = newState;
    }

    // The line is over: an `ESC` follows the opening held back — the close
    // below, or the unwinding of the style — or nothing does, and either way
    // it goes out as it came.
    buf.write(heldOpening);

    if (closeLink && writtenLink != null) {
      buf.write(linkClose);
      writtenLink = null;
    }
    _writtenLink = writtenLink;

    // What the text leaves open outlives the close written above: the close
    // is for the terminal, which must not make the next line clickable by
    // accident, and this is for the next line, which opens the link again.
    _ambientLink = parser.finalLink;

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
  /// leaves open is closed at its end — and opened again on the line after,
  /// which is handed the link the same way it is handed the style.
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
  /// several, so a piece on its own is never known to end one and no close
  /// is owed at its end. Where the line really ends the write path says for
  /// itself, and it is there that a link left open is carried into the write
  /// that follows — see [_writeBuf] and [_writeLine]. [prepare], which reads
  /// this, hands the piece back without a close and without touching either
  /// carry: the one inside the line or the one across it.
  @override
  bool get _closesLinkAtEnd => false;

  /// Prepares the given piece and hands it back without sending it anywhere.
  ///
  /// The carry of an open hyperlink belongs to the writes that reach the
  /// sink, so a piece prepared here and not written leaves it as it was — in
  /// the output and in the text alike: a link opened in what was only asked
  /// about is not one the sink would ever be owed a close for, nor one a
  /// later line should open again.
  @override
  String prepare(String line) {
    final keepWrittenLink = _writtenLink;
    final keepAmbientLink = _ambientLink;
    final prepared = super.prepare(line);
    _writtenLink = keepWrittenLink;
    _ambientLink = keepAmbientLink;

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
