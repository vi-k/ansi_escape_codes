import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:meta/meta.dart';

import '../../../values/sgr/sgr.dart';
import '../parsers.dart';

sealed class AnsiStackedPrinter implements StringSink {
  final AnsiPlainState defaultState;

  @visibleForTesting
  bool debugForTest;

  factory AnsiStackedPrinter.print({
    AnsiPlainState? defaultState,
    void Function(String line)? output,
    @visibleForTesting bool? debugForTest,
  }) = _AnsiPrintStackedPrinter;

  factory AnsiStackedPrinter.stdout(
    Stdout stdout, {
    AnsiPlainState? defaultState,
    @visibleForTesting bool? debugForTest,
  }) = _AnsiStdoutStackedPrinter;

  AnsiStackedPrinter._({
    AnsiPlainState? defaultState,
    bool? debugForTest,
  })  : defaultState = defaultState ?? AnsiPlainState.defaults,
        debugForTest = debugForTest ?? false;

  void print(Object? object) => writeln(object);

  FutureOr<void> flush();
}

final class _AnsiPrintStackedPrinter extends AnsiStackedPrinter {
  final void Function(String line) _output;
  final StringBuffer _lineBuf = StringBuffer();

  _AnsiPrintStackedPrinter({
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

    final parser = AnsiStackedParser(_lineBuf.toString());
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
        final nextState = m.state.changeDefaultsTo(defaultState);
        buf
          ..write(lastState.transitTo(nextState))
          ..write(entity.string);
        lastState = nextState;
      }
    }

    buf.write(reset);

    final output = buf.toString();
    _output(output);
    if (debugForTest) {
      _output(
        AnsiStackedParser(output).replaceAll((e) => '[${e.id}]'),
      );
    }

    _lineBuf.clear();
  }
}

final class _AnsiStdoutStackedPrinter extends AnsiStackedPrinter {
  final Stdout stdout;

  _AnsiStdoutStackedPrinter(
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
    // final scopedFgDefault = foregroundColor.string;
    // final scopedBgDefault = backgroundColor.string;
    // final scopedUnderlineDefault = underlineColor.string;
    // final scopedReset =
    //     '$reset$scopedFgDefault$scopedBgDefault$scopedUnderlineDefault';

    // var lastState = AnsiPlainState.defaults.copyWith(
    //   foreground: foregroundColor,
    //   background: backgroundColor,
    //   underlineColor: underlineColor,
    // );

    // // line = '${lastState.asStringOnlyNonDefaults}$line';
    // final parser = AnsiParser(line);
    // final buf = StringBuffer(reset);

    // if (lastState.foreground is AnsiForegroundDefault) {
    //   buf.write(scopedFgDefault);
    // }
    // if (lastState.background is AnsiBackgroundDefault) {
    //   buf.write(scopedBgDefault);
    // }

    // buf
    //   ..write(
    //     parser.replaceAll(
    //       (m) => switch (m) {
    //         AnsiForegroundDefault() => scopedFgDefault,
    //         AnsiBackgroundDefault() => scopedBgDefault,
    //         AnsiReset() => scopedReset,
    //         _ => m.string,
    //       },
    //     ),
    //   )
    //   ..write(reset);

    // lastState = parser.endState;

    // final output = buf.toString();

    // stdout.write(output);

    // if (debugForTest) {
    //   stdout.write(AnsiParser(output).replaceAll((e) => '[${e.id}]'));
    // }
  }

  @override
  FutureOr<void> flush() => stdout.flush();
}

R ansiStackedPrinter<R>(
  R Function() run, {
  AnsiPlainState defaultState = AnsiPlainState.defaults,
  @visibleForTesting bool debugForTest = false,
}) {
  final printer = AnsiStackedPrinter.print(
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
