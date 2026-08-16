// The fake stdout below owns no resources, so there is nothing to close.
// ignore_for_file: close_sinks

import 'dart:io';

import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/utils.dart';
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

    test('sets a stop after each distance in the list', () {
      final stdout = _FakeStdout(terminalColumns: 24);

      tabs(tabs: [8, 4, 4], stdout: stdout);

      expect(
        stdout.written,
        '\r${CSI}3$TBC'
        '${cursorRightN(8)}$HTS'
        '${cursorRightN(4)}$HTS'
        '${cursorRightN(4)}$HTS'
        '\r',
        reason: 'the stops land in columns 9, 13 and 17, and no stop is set '
            'in the first column — which is where the list differs from '
            'defaultTab',
      );
      expect(
        stdout.written,
        isNot(contains(' ')),
        reason: 'the cursor is moved rather than written over',
      );
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

    test('sets no stop past the width, however far past it lies', () {
      // The largest int there is, spelt out rather than written down:
      // `avoid_js_rounded_ints` is on, and this is the value the running
      // total has to survive being added to.
      final beyond = int.parse('9223372036854775807');

      final calls = <String, void Function(Stdout stdout)>{
        'tabs: [4, beyond]': (stdout) =>
            tabs(tabs: [4, beyond], stdout: stdout),
        'tabs: [4, beyond], defaultTab: 4': (stdout) =>
            tabs(tabs: [4, beyond], defaultTab: 4, stdout: stdout),
        'tabs: [beyond], defaultTab: 1': (stdout) =>
            tabs(tabs: [beyond], defaultTab: 1, stdout: stdout),
      };

      for (final MapEntry(key: what, value: call) in calls.entries) {
        final stdout = _FakeStdout(terminalColumns: 20);

        expect(
          () => call(stdout),
          returnsNormally,
          reason: '$what: a total that wraps around goes negative, and a '
              'negative one never reaches the width to stop at',
        );
        expect(
          stdout.written,
          isNot(contains('$beyond')),
          reason: '$what: a stop that far out is no stop this terminal has',
        );
      }
    });

    test('a stop past the width ends the run, as one just past it does', () {
      final beyond = int.parse('9223372036854775807');
      final far = _FakeStdout(terminalColumns: 20);
      final near = _FakeStdout(terminalColumns: 20);

      tabs(tabs: [4, beyond], defaultTab: 4, stdout: far);
      tabs(tabs: [4, 100], defaultTab: 4, stdout: near);

      expect(far.written, near.written);
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
