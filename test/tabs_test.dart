// The fake stdout below owns no resources, so there is nothing to close.
// ignore_for_file: close_sinks

import 'dart:io';

import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('tabs:', () {
    test('sets a stop every `defaultTab` columns', () {
      final stdout = _FakeStdout(terminalColumns: 20);

      tabs(defaultTab: 8, stdout: stdout);

      expect(
        stdout.written,
        '\r${CSI}3$TBC'
        '$HTS'
        '${cursorRightN(8)}$HTS'
        '${cursorRightN(8)}$HTS'
        '\r',
      );
    });

    test('moves the cursor instead of writing over the line', () {
      final stdout = _FakeStdout(terminalColumns: 20);

      tabs(tabs: [4, 4], stdout: stdout);

      expect(stdout.written, isNot(contains(' ')));
    });

    test('without arguments it only clears the stops', () {
      final stdout = _FakeStdout(terminalColumns: 20);

      tabs(stdout: stdout);

      expect(stdout.written, '\r${CSI}3$TBC\r');
    });

    test('does nothing when there is no terminal', () {
      final stdout = _FakeStdout(terminalColumns: 20, hasTerminal: false);

      tabs(defaultTab: 8, stdout: stdout);

      expect(stdout.written, isEmpty);
    });

    test('rejects a `defaultTab` that would never advance the cursor', () {
      for (final defaultTab in [0, -1]) {
        final stdout = _FakeStdout(terminalColumns: 20);

        expect(
          () => tabs(defaultTab: defaultTab, stdout: stdout),
          throwsA(isA<RangeError>()),
          reason: 'defaultTab: $defaultTab',
        );
        expect(stdout.written, isEmpty, reason: 'defaultTab: $defaultTab');
      }
    });

    test('rejects a stop that would never advance the cursor', () {
      final stdout = _FakeStdout(terminalColumns: 20);

      expect(
        () => tabs(tabs: [4, 0], stdout: stdout),
        throwsA(isA<RangeError>()),
      );
      expect(stdout.written, isEmpty);
    });
  });
}

final class _FakeStdout implements Stdout {
  _FakeStdout({required this.terminalColumns, this.hasTerminal = true});

  @override
  final int terminalColumns;

  @override
  final bool hasTerminal;

  final StringBuffer _buf = StringBuffer();
  int _writes = 0;

  String get written => _buf.toString();

  /// Fails loudly instead of hanging when the caller loops without end.
  @override
  void write(Object? object) {
    if (++_writes > 1000) {
      throw StateError('runaway output: write called $_writes times');
    }

    _buf.write(object);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
