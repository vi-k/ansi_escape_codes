import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:meta/meta.dart';

import '../../../values/sgr/sgr.dart';
import '../parsers.dart';

sealed class AnsiPrinter implements StringSink {
  final AnsiPlainState defaultState;

  @visibleForTesting
  bool debugForTest;

  factory AnsiPrinter.print({
    AnsiPlainState? defaultState,
    void Function(String line)? output,
    @visibleForTesting bool? debugForTest,
  }) = _AnsiPrintPrinter;

  factory AnsiPrinter.stdout(
    Stdout stdout, {
    AnsiPlainState? defaultState,
    @visibleForTesting bool? debugForTest,
  }) = _AnsiStdoutPrinter;

  AnsiPrinter._({
    AnsiPlainState? defaultState,
    bool? debugForTest,
  })  : defaultState = defaultState ?? AnsiPlainState.defaults,
        debugForTest = debugForTest ?? false;

  void print(Object? object) => writeln(object);

  FutureOr<void> flush();
}

final class _AnsiPrintPrinter extends AnsiPrinter {
  final void Function(String line) _output;
  final StringBuffer _lineBuf = StringBuffer();

  _AnsiPrintPrinter({
    super.defaultState,
    void Function(String line)? output,
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
    var lastState = defaultState;

    final parser = AnsiParser(_lineBuf.toString());
    final buf = StringBuffer()
      ..write(reset)
      ..write(
        AnsiPlainState.defaults.transitTo(
          lastState.changeDefaultsTo(defaultState),
        ),
      );

    for (final m in parser.matches) {
      final entity = m.entity;
      if (entity is AnsiPlainText) {
        buf
          ..write(lastState.transitTo(m.state.changeDefaultsTo(defaultState)))
          ..write(entity.string);
        lastState = m.state;
      }
    }

    buf.write(reset);

    final output = buf.toString();
    _output(output);
    if (debugForTest) {
      _output(
        AnsiParser(output).replaceAll((e) => '[${e.id}]'),
      );
    }

    _lineBuf.clear();
  }
}

final class _AnsiStdoutPrinter extends AnsiPrinter {
  final Stdout stdout;

  _AnsiStdoutPrinter(
    this.stdout, {
    super.defaultState,
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
    stdout.writeln();
  }

  void _writeBuf(String buf) {
    var pos = 0;
    var endIndex = buf.indexOf('\n');
    while (endIndex != -1) {
      final line = buf.substring(pos, endIndex);
      _writeLine(line);
      stdout.writeln();

      pos = endIndex + 1;
      endIndex = buf.indexOf('\n', pos);
    }

    final line = buf.substring(pos);
    _writeLine(line);
  }

  void _writeLine(String line) {
    var lastState = defaultState;

    final parser = AnsiParser(line);
    final buf = StringBuffer()
      ..write(reset)
      ..write(
        AnsiPlainState.defaults.transitTo(
          lastState.changeDefaultsTo(defaultState),
        ),
      );

    for (final m in parser.matches) {
      final entity = m.entity;
      if (entity is AnsiPlainText) {
        buf
          ..write(lastState.transitTo(m.state.changeDefaultsTo(defaultState)))
          ..write(entity.string);
        lastState = m.state;
      }
    }

    buf.write(reset);

    final output = buf.toString();
    stdout.write(output);
    if (debugForTest) {
      stdout.write(
        AnsiParser(output).replaceAll((e) => '[${e.id}]'),
      );
    }
  }

  @override
  FutureOr<void> flush() => stdout.flush();
}

R ansiPrinter<R>(
  R Function() run, {
  AnsiPlainState defaultState = AnsiPlainState.defaults,
  @visibleForTesting bool debugForTest = false,
}) {
  final printer = AnsiPrinter.print(
    defaultState: defaultState,
    output: (line) => Zone.current.parent!.print(line),
    // ignore: invalid_use_of_visible_for_testing_member
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
