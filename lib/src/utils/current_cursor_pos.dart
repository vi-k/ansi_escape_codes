import 'dart:async';
import 'dart:io';

import '../ansi/c1.dart';
import '../ansi/csi.dart';
import '../parsing/control_functions/control_sequences.dart';

/// Returns the current cursor position if possible.
///
/// This is Device Status Report.
///
/// By sending the CSI 6 n ([ControlSequencesFunctions.DSR]) command to
/// stdout, we get the coordinates in stdin as CSI n;m R
/// ([ControlSequencesFunctions.CPR]).
///
/// [timeout] is how long the terminal is given to answer.
///
/// [input] is where the answer is read from, [stdin] by default. A [Stdin] can
/// only be listened to once, so to ask more than once — or to keep reading the
/// input afterwards — pass a broadcast stream over it here.
///
/// Throws an [UnsupportedError] naming what stopped it wherever no report can
/// be had: [stdout] is no terminal to ask — a redirected output is asked
/// nothing at all, rather than sent a request into a file — the terminal
/// stayed silent for [timeout], what came back was not a report, or [stdin] is
/// no terminal to read the answer from.
Future<(int, int)> currentCursorPos(
  Stdout stdout,
  Stdin stdin, {
  Duration timeout = const Duration(milliseconds: 100),
  Stream<List<int>>? input,
}) async {
  const errorText = 'Device Status Report not supported';
  List<int> report;

  if (!stdout.hasTerminal) {
    // `tabs` answers this same question by writing nothing; this one owes an
    // answer back and has nowhere to get one, so it refuses instead. Asking
    // anyway would put a CSI 6 n into whatever the output really is — a log
    // file, a pipe — and hold the terminal out of its modes for the whole
    // timeout, waiting on a reply that has nowhere to come from.
    throw UnsupportedError('$errorText: the output is not a terminal');
  }

  try {
    final keepEchoMode = stdin.echoMode;
    final keepLineMode = stdin.lineMode;
    var echoModeOff = false;
    var lineModeOff = false;
    StreamSubscription<List<int>>? subscription;

    try {
      stdin.echoMode = false;
      echoModeOff = true;
      stdin.lineMode = false;
      lineModeOff = true;

      report = await _readReport(
        input ?? stdin,
        (taken) => subscription = taken,
        () => stdout.write('${CSI}6$DSR'),
        timeout,
      );
    } finally {
      // The modes go back before the input is let go of, and that order is
      // the whole of it: cancelling a subscription to the real stdin closes
      // the descriptor the modes are set through, so a restore written
      // behind the cancel throws instead of landing. The caller would be
      // left at a terminal with no echo and told that the terminal cannot
      // report its cursor — while it just had.
      //
      // Line mode first, mirroring the way they were turned off: Windows
      // lets echo come back only once line mode is on. Nested, so a throw
      // restoring one does not keep the other from being restored, and
      // only what actually changed is put back — a stdin that refused a
      // change is not asked to undo it. The cancel is nested outside both,
      // so the input is let go of even where a restore throws.
      try {
        try {
          if (lineModeOff) {
            stdin.lineMode = keepLineMode;
          }
        } finally {
          if (echoModeOff) {
            stdin.echoMode = keepEchoMode;
          }
        }
      } finally {
        await subscription?.cancel();
      }
    }
  } on Object catch (error, stacktrace) {
    // The reason travels in the message. Everything that can go wrong in
    // here comes back as the same refusal --- a terminal that will not
    // answer, a stdin that is not a terminal at all, an input already
    // listened to somewhere else --- and a refusal naming no reason reads
    // as the first of those whichever of them it was.
    Error.throwWithStackTrace(
      UnsupportedError('$errorText: $error'),
      stacktrace,
    );
  }

  if (report.length < 6) {
    throw UnsupportedError(errorText);
  }

  var row = 0;
  var col = 0;
  var isRow = true;

  // CPR = CSI n;m R, so the numbers lie between the CSI and the final R.
  for (var i = 2; i < report.length - 1; i++) {
    final char = report[i];

    if (char == 0x3B) {
      isRow = false;
    } else if (char >= 0x30 && char <= 0x39) {
      final digit = char - 0x30;
      if (isRow) {
        row = row * 10 + digit;
      } else {
        col = col * 10 + digit;
      }
    } else {
      throw UnsupportedError(errorText);
    }
  }

  if (isRow) {
    throw UnsupportedError(errorText);
  }

  return (row, col);
}

/// Asks for the report and waits for it, passing over anything else that
/// arrives — typed characters, and the sequences a pressed key sends.
///
/// The subscription is handed to [taking] as soon as it is taken, and letting
/// it go is the caller's to do rather than this function's: cancelling it
/// closes the real stdin, and that has to happen behind the caller putting the
/// terminal modes back, not in front of it.
Future<List<int>> _readReport(
  Stream<List<int>> input,
  void Function(StreamSubscription<List<int>> subscription) taking,
  void Function() request,
  Duration timeout,
) {
  final completer = Completer<List<int>>();
  final buf = <int>[];

  taking(
    input.listen(
      (chunk) {
        buf.addAll(chunk);

        final report = _extractReport(buf);
        if (report != null && !completer.isCompleted) {
          completer.complete(report);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(StateError('The input is closed'));
        }
      },
    ),
  );

  request();

  return completer.future.timeout(timeout);
}

/// The Cursor Position Report inside [buf], once all of it has arrived.
///
/// The answer may be split across reads, and whatever the user typed in the
/// meantime arrives on the same input, so the report is looked for rather than
/// expected to be the whole of it.
List<int>? _extractReport(List<int> buf) {
  for (var start = 0; start + 1 < buf.length; start++) {
    if (buf[start] != 0x1B || buf[start + 1] != 0x5B) {
      continue;
    }

    // Between the CSI and the R a report carries nothing but digits and the
    // semicolon between them. Anything else and this was some other sequence
    // — an arrow key is a CSI as well — so the search goes on past it.
    var isReport = true;

    for (var end = start + 2; end < buf.length; end++) {
      final char = buf[end];

      if (char == 0x52) {
        return buf.sublist(start, end + 1);
      }

      if (char != 0x3B && (char < 0x30 || char > 0x39)) {
        isReport = false;
        break;
      }
    }

    // The bytes so far are a report that has not arrived whole; the rest of
    // it is still to come.
    if (isReport) {
      return null;
    }
  }

  return null;
}
