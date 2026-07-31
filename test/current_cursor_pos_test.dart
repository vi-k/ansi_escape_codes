import 'dart:async';
import 'dart:io';

import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/utils.dart';
import 'package:test/test.dart';

void main() {
  group('currentCursorPos:', () {
    test('returns the position reported by the terminal', () async {
      final stdin = _FakeStdin(Stream.value('${CSI}12;34R'.codeUnits));
      final stdout = _FakeStdout();

      expect(await currentCursorPos(stdout, stdin), (12, 34));
      expect(stdout.written, '${CSI}6$DSR');
      expect(stdin.echoMode, isTrue);
      expect(stdin.lineMode, isTrue);
    });

    test('restores the terminal modes when there is no answer', () async {
      final controller = StreamController<List<int>>();
      addTearDown(controller.close);
      final stdin = _FakeStdin(controller.stream);
      final stdout = _FakeStdout();

      await expectLater(
        currentCursorPos(stdout, stdin),
        throwsA(isA<UnsupportedError>()),
      );

      expect(stdin.echoMode, isTrue);
      expect(stdin.lineMode, isTrue);
    });
  });
}

final class _FakeStdin implements Stdin {
  _FakeStdin(this._stream);

  final Stream<List<int>> _stream;

  @override
  bool echoMode = true;

  @override
  bool lineMode = true;

  @override
  Stream<List<int>> asBroadcastStream({
    void Function(StreamSubscription<List<int>> subscription)? onListen,
    void Function(StreamSubscription<List<int>> subscription)? onCancel,
  }) =>
      _stream.asBroadcastStream(onListen: onListen, onCancel: onCancel);

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

final class _FakeStdout implements Stdout {
  final StringBuffer _buf = StringBuffer();

  String get written => _buf.toString();

  @override
  void write(Object? object) => _buf.write(object);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
