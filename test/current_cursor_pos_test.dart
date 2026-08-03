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

    test('reads a reply that arrives in pieces', () async {
      final stdin = _FakeStdin(
        Stream.fromIterable([
          '\x1B['.codeUnits,
          '12;'.codeUnits,
          '34R'.codeUnits,
        ]),
      );

      expect(await currentCursorPos(_FakeStdout(), stdin), (12, 34));
    });

    test('ignores what was typed before the reply', () async {
      final stdin = _FakeStdin(
        Stream.fromIterable([
          'q'.codeUnits,
          '\x1B[12;34R'.codeUnits,
        ]),
      );

      expect(await currentCursorPos(_FakeStdout(), stdin), (12, 34));
    });

    test('can be asked again when the input is shared', () async {
      final controller = StreamController<List<int>>.broadcast();
      addTearDown(controller.close);
      final stdin = _FakeStdin(const Stream<List<int>>.empty());
      final stdout = _FakeStdout();

      Future<(int, int)> ask(String reply) async {
        final answer = currentCursorPos(
          stdout,
          stdin,
          input: controller.stream,
        );
        await Future<void>.delayed(Duration.zero);
        controller.add(reply.codeUnits);

        return answer;
      }

      expect(await ask('\x1B[1;2R'), (1, 2));
      expect(await ask('\x1B[3;4R'), (3, 4));
    });

    test('looks past a sequence the user typed before the answer', () async {
      final stdin = _FakeStdin(
        Stream.value('${CSI}A$CSI' '12;34R'.codeUnits),
      );

      expect(
        await currentCursorPos(_FakeStdout(), stdin),
        (12, 34),
        reason: 'an arrow key is a CSI too, and it is not the report',
      );
    });

    test('and past several of them', () async {
      final stdin = _FakeStdin(
        Stream.value('${CSI}A${CSI}B q$CSI' '1;2R'.codeUnits),
      );

      expect(await currentCursorPos(_FakeStdout(), stdin), (1, 2));
    });

    test('refuses an answer too short to be a report', () async {
      final stdin = _FakeStdin(Stream.value('${CSI}12R'.codeUnits));

      await expectLater(
        currentCursorPos(_FakeStdout(), stdin),
        throwsA(isA<UnsupportedError>()),
      );
      expect(stdin.echoMode, isTrue, reason: 'and puts the terminal back');
    });

    test('refuses an answer carrying something that is not a number', () async {
      final stdin = _FakeStdin(Stream.value('${CSI}1;2aR'.codeUnits));

      await expectLater(
        currentCursorPos(_FakeStdout(), stdin),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('refuses an answer that names no column', () async {
      final stdin = _FakeStdin(Stream.value('${CSI}1234R'.codeUnits));

      await expectLater(
        currentCursorPos(_FakeStdout(), stdin),
        throwsA(isA<UnsupportedError>()),
        reason: 'a report without a semicolon is half an answer',
      );
    });

    test('refuses when the input ends before the answer comes', () async {
      final stdin = _FakeStdin(Stream.value('typed'.codeUnits));

      await expectLater(
        currentCursorPos(_FakeStdout(), stdin),
        throwsA(isA<UnsupportedError>()),
      );
      expect(stdin.lineMode, isTrue, reason: 'and puts the terminal back');
    });

    test('refuses when the input fails', () async {
      final stdin = _FakeStdin(Stream<List<int>>.error(StateError('gone')));

      await expectLater(
        currentCursorPos(_FakeStdout(), stdin),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('restores the terminal modes when there is no answer', () async {
      final controller = StreamController<List<int>>();
      addTearDown(controller.close);
      final stdin = _FakeStdin(controller.stream);
      final stdout = _FakeStdout();

      await expectLater(
        currentCursorPos(
          stdout,
          stdin,
          timeout: const Duration(milliseconds: 10),
        ),
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
