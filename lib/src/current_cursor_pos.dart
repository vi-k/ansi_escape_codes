import 'dart:io';

import 'escape_sequences/escape_sequences.dart';

/// Returns the current cursor position if possible.
///
/// This is Device Status Report.
Future<(int, int)> currentCursorPos(Stdout stdout, Stdin stdin) async {
  const errorText = 'Device Status Report not supported';
  List<int> cursorSeq;

  try {
    final keepEchoMode = stdin.echoMode;
    final keepLineMode = stdin.lineMode;
    stdin
      ..echoMode = false
      ..lineMode = false;

    final stream = stdin.asBroadcastStream(
      onCancel: (subscription) {
        subscription.cancel();
      },
    );

    final cursorSeqF = stream.first.timeout(const Duration(milliseconds: 100));

    // By sending the CSI 6n command to stdout, we get the coordinates in stdin
    // as CSI {n};{m} R.
    stdout.write('${csi}6n');
    cursorSeq = await cursorSeqF;

    stdin
      ..echoMode = keepEchoMode
      ..lineMode = keepLineMode;
  } on Object catch (_, stacktrace) {
    Error.throwWithStackTrace(
      UnsupportedError(errorText),
      stacktrace,
    );
  }

  // ESC [n;mR
  if (cursorSeq.length < 6 ||
          cursorSeq[0] != 27 || // ESC
          cursorSeq[1] != 91 || // [
          cursorSeq.last != 82 // R
      ) {
    throw UnsupportedError(errorText);
  }

  var row = 0;
  var col = 0;
  var isRow = true;
  var pos = 2;
  while (true) {
    final n = cursorSeq[pos++];
    if (n == 82) {
      break;
    } else if (n == 59) {
      isRow = false;
    } else if (isRow) {
      row = row * 10 + (n - 48);
    } else {
      col = col * 10 + (n - 48);
    }
  }

  return (row, col);
}
