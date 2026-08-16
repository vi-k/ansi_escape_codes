import 'dart:async';
import 'dart:io';

import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/utils.dart';
import 'package:test/test.dart';

void main() {
  group('currentCursorPos against a Windows console:', () {
    test('comes back with the modes restored', () async {
      final stdin = _FakeWindowsStdin(Stream.value('${CSI}12;34R'.codeUnits));

      expect(await currentCursorPos(_FakeStdout(), stdin), (12, 34));
      expect(stdin.echoMode, isTrue);
      expect(stdin.lineMode, isTrue);
    });

    test('restores the modes when there is no answer', () async {
      final controller = StreamController<List<int>>();
      addTearDown(controller.close);
      final stdin = _FakeWindowsStdin(controller.stream);

      await expectLater(
        currentCursorPos(
          _FakeStdout(),
          stdin,
          timeout: const Duration(milliseconds: 10),
        ),
        throwsA(isA<UnsupportedError>()),
      );

      expect(stdin.echoMode, isTrue);
      expect(stdin.lineMode, isTrue);
    });

    test('puts echo back when line mode refuses to turn off', () async {
      final stdin = _NoRawModeStdin();

      await expectLater(
        currentCursorPos(_FakeStdout(), stdin),
        throwsA(isA<UnsupportedError>()),
      );

      expect(stdin.echoMode, isTrue);
    });
  });
}

/// A [Stdin] with the rules the SDK documents for a Windows console: echo
/// only comes on while line mode is on, and line mode only goes off while
/// echo is off.
final class _FakeWindowsStdin implements Stdin {
  _FakeWindowsStdin(this._stream);

  final Stream<List<int>> _stream;

  bool _echoMode = true;
  bool _lineMode = true;

  @override
  bool get echoMode => _echoMode;

  @override
  set echoMode(bool value) {
    if (value && !_lineMode) {
      throw const StdinException(
        'echo mode cannot be enabled while line mode is disabled',
      );
    }
    _echoMode = value;
  }

  @override
  bool get lineMode => _lineMode;

  @override
  set lineMode(bool value) {
    if (!value && _echoMode) {
      throw const StdinException(
        'line mode cannot be disabled while echo mode is enabled',
      );
    }
    _lineMode = value;
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A stdin whose line mode cannot be turned off — the shape of an input
/// that is not a console. Echo goes off first, so if the refusal is not
/// guarded, echo stays off for good.
final class _NoRawModeStdin implements Stdin {
  bool _echoMode = true;

  @override
  bool get echoMode => _echoMode;

  @override
  set echoMode(bool value) => _echoMode = value;

  @override
  bool get lineMode => true;

  @override
  set lineMode(bool value) {
    if (!value) {
      throw const StdinException('line mode cannot be disabled');
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeStdout implements Stdout {
  @override
  bool get hasTerminal => true;

  @override
  void write(Object? object) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
