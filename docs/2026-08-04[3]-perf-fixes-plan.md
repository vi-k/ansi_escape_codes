# Перформанс-фиксы 4.0.0 — план реализации

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Устранить четыре перформанс-находки ревью (H3, M4, M7, M5) без изменения публичного API и семантики, с доказательствами в виде бенчмарк-чисел и гардов.

**Architecture:** Префильтр `indexOf(ESC)` в итераторе парсера и extensions; общий резюмируемый курсор для `stateAt`/`substring`/`_seamAt`; диспетчеризация сущностей по байту и кэш `SgrSimpleFunction`; ленивые `Text.string` и `UnmodifiableListView` вместо копий. Спека: `docs/2026-08-04[2]-perf-fixes-design.md`.

**Tech Stack:** Dart ≥ 3.6.0 (нижняя граница SDK — новее языковые фичи нельзя), `package:test`, `dart:collection` (`UnmodifiableListView`), git worktree для утилиты сравнения.

## Global Constraints

- Публичный API и наблюдаемая семантика не меняются; версия остаётся `4.0.0`.
- Существующие тест-файлы **не редактируются**; новые тесты — только новыми файлами.
- Перед каждым коммитом: `dart format .`, `dart analyze --fatal-infos` (0 замечаний), `dart test` (все зелёные).
- Ветка: `perf/review-findings` от `main`. Каждая задача — один коммит; сообщения в стиле репозитория (строчные, повествовательные, prefix `perf:`/`test:`/`feat:`/`docs:`), с трейлером `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.
- В коммиты задач 4–7 включаются числа `benchmark/compare.dart` против тега `perf-baseline` (ставится в задаче 3).
- Стиль кода — как в соседних файлах: строгий линт-сет проекта (80 колонок, `prefer_final_locals`, `public_member_api_docs` для публичного и т. д.).

---

### Task 1: Ветка и страховочная сетка — инвариант-тесты

**Files:**
- Create: `test/round_trip_invariant_test.dart`
- Create: `test/parser_substring_differential_test.dart`

**Interfaces:**
- Consumes: публичный API пакета (`Parser`, `StackedParser`, extensions).
- Produces: два тест-файла, зелёные ДО и ПОСЛЕ всех фиксов — страховочная сетка для задач 4–7. Корпус `adversarialInputs` используется задачами 4 и 7 (имена см. код).

- [ ] **Step 1: Создать ветку**

```bash
git checkout -b perf/review-findings main
```

- [ ] **Step 2: Написать round-trip-инвариант**

Файл `test/round_trip_invariant_test.dart` целиком:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// Входы, на которых парсер ломался бы, если бы округлял углы: обрывки,
/// суррогатные пары, восьмибитный C1, управляющие байты.
const adversarialInputs = <String>[
  '',
  'plain text, no codes at all',
  '\x1B',
  'ends with a lone escape\x1B',
  '\x1B[',
  'a\x1B[31',
  'a\x1B[31;',
  '\x1B[31mred\x1B[0m',
  '\x1B[999999999999999999999m',
  '\x1B]8;;http://example.com\x1B\\link\x1B]8;;\x1B\\',
  '\x1B]0;title without terminator',
  '\x1B]0;title\x07',
  '\x1B[38:2::255:0:0mcolon rgb\x1B[m',
  '\x1B[38;5mtruncated 256\x1B[m',
  '\x1B[38;2;1;2mtruncated rgb\x1B[m',
  '\x9B31mnot a CSI in a Dart string',
  'emoji \u{1F600} around \x1B[1m codes \u{1D11E}\x1B[m',
  'combining á\x1B[4mb́\x1B[24m',
  '\x00\x07\x7F control bytes\t\r\n',
  'crlf\r\n\x1B[31mline\x1B[m\r\n',
  '\x1B7saved\x1B8restored',
  '\x1B(Bcharset',
];

void main() {
  group('the pieces of a parsed string give the string back', () {
    for (final (i, input) in adversarialInputs.indexed) {
      test('input #$i', () {
        final buf = StringBuffer();
        for (final m in Parser(input).matches) {
          buf.write(m.entity.string);
        }

        expect(
          buf.toString(),
          input,
          reason: 'concatenated entities must equal the input byte for byte',
        );
      });

      test('input #$i, stacked', () {
        final buf = StringBuffer();
        for (final m in StackedParser(input).matches) {
          buf.write(m.entity.string);
        }

        expect(buf.toString(), input);
      });

      test('input #$i, removeAll agrees with the extension', () {
        expect(
          Parser(input).removeAll(),
          input.ansiRemoveEscapeCodes(),
          reason: 'the parser and the regex must drop the same bytes',
        );
      });
    }
  });
}
```

- [ ] **Step 3: Написать дифференциальный тест `substring`**

Последовательные срезы на ОДНОМ парсере обязаны совпадать со срезами на
свежих парсерах. Сегодня это выполняется тривиально (обход всегда с нуля);
после задачи 5 этот тест докажет, что резюмирование ничего не изменило.

Файл `test/parser_substring_differential_test.dart` целиком:

```dart
import 'dart:math';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  const text = '\x1B[1m\x1B[31mERROR\x1B[22m\x1B[39m '
      '\x1B]8;;http://u\x1B\\link\x1B]8;;\x1B\\ '
      'plain middle \x1B[4munderlined\x1B[24m tail\x1B[0m trailing';

  group('sequential slices equal fresh-parser slices', () {
    test('forward line-by-line', () {
      final reused = Parser(text);
      final total = reused.length;

      var start = 0;
      while (start <= total) {
        final expected = Parser(text).substring(start, maxLength: 7);
        expect(
          reused.substring(start, maxLength: 7),
          expected,
          reason: 'slice at $start diverged on the reused parser',
        );
        start += 7;
      }
    });

    test('randomized starts, lengths and close, fixed seed', () {
      final random = Random(20260804);
      final reused = Parser(text);
      final total = reused.length;

      for (var i = 0; i < 300; i++) {
        final start = random.nextInt(total + 1);
        final maxLength =
            random.nextBool() ? null : random.nextInt(total + 1);
        final close = random.nextBool();

        final expected = Parser(text)
            .substring(start, maxLength: maxLength, close: close);
        expect(
          reused.substring(start, maxLength: maxLength, close: close),
          expected,
          reason: 'start: $start, maxLength: $maxLength, close: $close',
        );
      }
    });

    test('sequential inserts equal fresh-parser inserts', () {
      final random = Random(20260804);
      final reused = Parser(text);
      final total = reused.length;

      for (var i = 0; i < 100; i++) {
        final pos = random.nextInt(total + 1);
        final after = random.nextBool();

        final expected = after
            ? Parser(text).insertAfter(pos, 'x')
            : Parser(text).insertBefore(pos, 'x');
        final actual =
            after ? reused.insertAfter(pos, 'x') : reused.insertBefore(pos, 'x');
        expect(actual, expected, reason: 'pos: $pos, after: $after');
      }
    });

    test('stateAt interleaved with substring stays consistent', () {
      final random = Random(20260804);
      final reused = Parser(text);
      final total = reused.length;

      for (var i = 0; i < 200; i++) {
        final pos = random.nextInt(total);
        if (random.nextBool()) {
          expect(reused.stateAt(pos), Parser(text).stateAt(pos));
        } else {
          expect(
            reused.substring(pos, maxLength: 5),
            Parser(text).substring(pos, maxLength: 5),
          );
        }
      }
    });
  });
}
```

- [ ] **Step 4: Прогнать новые тесты — зелёные (это сетка, не red-green)**

```bash
dart test test/round_trip_invariant_test.dart \
  test/parser_substring_differential_test.dart
```

Expected: PASS (все).

- [ ] **Step 5: Полная проверка и коммит**

```bash
dart format . && dart analyze --fatal-infos && dart test
git add test/round_trip_invariant_test.dart \
  test/parser_substring_differential_test.dart
git commit -m "test: the safety net the performance work will stand on

Round-trip fidelity on an adversarial corpus, and differential tests
pinning that a reused parser answers substring, insert and stateAt
exactly as a fresh one does.

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 2: Бенчмарк — новые сценарии, `--json`, `compare.dart`

**Files:**
- Modify: `benchmark/parser_benchmark.dart`
- Create: `benchmark/compare.dart`
- Modify: `.pubignore`

**Interfaces:**
- Consumes: существующие `_bench`/`_measure`/`_group` бенчмарка.
- Produces: `parser_benchmark.dart --json` печатает JSON-строки вида `{"scenario":"<group> / <what>","us":<double>}`; `compare.dart <baseRef> [--runs]` рендерит цветную таблицу. Задачи 4–7 запускают `dart run benchmark/compare.dart perf-baseline`.

- [ ] **Step 1: Добавить json-режим и группу-трекер в `parser_benchmark.dart`**

К глобалам (рядом с `_inColour`, строка ~191):

```dart
/// Whether the numbers go out as JSON lines instead of the pages.
bool _asJson = false;

/// The group the current [_bench] belongs to, for the JSON scenario name.
String _currentGroup = '';
```

В `_readArguments` — новая ветка `case '--json': _asJson = true;` и строка
в usage: `'  --json      write every number as a JSON line, for tooling.'`.
Импорт `dart:convert` добавить к `dart:io`.

В `_group` первой строкой: `_currentGroup = title;` — и ранний выход из
печати в json-режиме:

```dart
void _group(String title) {
  _currentGroup = title;
  _baseline = null;
  if (_asJson) {
    return;
  }
  print('');
  print(_paint(title, '$bold$fgCyan'));
}
```

В `_bench` сразу после `final best = _measure(body);`:

```dart
  if (_asJson) {
    print(jsonEncode({'scenario': '$_currentGroup / $what', 'us': best}));

    return;
  }
```

В `_title` и `_growth` — ранний выход `if (_asJson) return;` первой
строкой (страницы роста и заголовок остаются человекочитаемыми только).

- [ ] **Step 2: Добавить сценарии «чистый текст», «нарезка», «память»**

В `main` после группы `'The same, by the shape of the input'`:

```dart
  _group('A page with no codes at all');
  _bench('matches, to the end', () {
    for (final _ in Parser(_plain).matches) {}
  });
  _bench('removeAll', () => Parser(_plain).removeAll());
  _bench('ansiRemoveEscapeCodes', () {
    _sink = _plain.ansiRemoveEscapeCodes();
  });
  _bench('ansiHasEscapeCodes', () => _sink = _plain.ansiHasEscapeCodes);

  _group('Slicing a document line by line');
  final lineWidth = _plainLine.length;
  _bench('substring, all 200 lines, one parser', () {
    final parser = Parser(_coloured)..prepare();
    for (var i = 0; i < 200; i++) {
      _sink = parser.substring(i * (lineWidth + 1), maxLength: lineWidth);
    }
  });
```

В `main` перед `_growth();` — страница памяти:

```dart
  _memory();
```

И сама страница (после `_growth` в файле):

```dart
/// What a full parse keeps: the matches and the bytes retained around them.
///
/// RSS is noisy and JIT keeps its own counsel, so the figure is a landmark
/// rather than a measurement — compare it between two runs, not to zero.
void _memory() {
  final big = _pageOf(_line, 5000);
  final before = ProcessInfo.currentRss;
  final parser = Parser(big)..prepare();
  final after = ProcessInfo.currentRss;
  final count = parser.matches.length;
  final deltaMb = (after - before) / (1024 * 1024);

  if (_asJson) {
    print(jsonEncode({'scenario': 'Memory / rss delta, mb', 'us': deltaMb}));
    print(
      jsonEncode({'scenario': 'Memory / matches', 'us': count.toDouble()}),
    );

    return;
  }

  print('');
  print(_paint('Memory: a full parse of ${big.length} characters', '$bold$fgCyan'));
  print('  matches: $count, rss: +${deltaMb.toStringAsFixed(1)} MB');
}
```

- [ ] **Step 3: Проверить оба режима руками**

```bash
dart run benchmark/parser_benchmark.dart --no-color | tail -20
dart run benchmark/parser_benchmark.dart --json | head -5
```

Expected: страницы как раньше плюс новые группы; в json-режиме — только
строки `{"scenario":...,"us":...}`, ничего человекочитаемого.

- [ ] **Step 4: Написать `benchmark/compare.dart`**

Файл целиком:

```dart
// Compares the benchmark numbers of two versions of this package.
//
// ```bash
// dart run benchmark/compare.dart <baseRef> [headRef]
// ```
//
// Each side is checked out as it was (`git worktree`), runs its own
// `benchmark/parser_benchmark.dart --json`, and the two sets of numbers
// are laid side by side, the delta painted by the package itself. With no
// headRef the working tree as it stands is the head side.
//
// The tool needs git and a second checkout, so it stays out of the
// published archive; see .pubignore.

import 'dart:convert';
import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.length > 2) {
    stderr.writeln('Usage: dart run benchmark/compare.dart <baseRef> [headRef]');
    exitCode = 64;

    return;
  }

  final base = await _numbersOf(args[0]);
  if (base == null) {
    return;
  }

  final head = args.length == 2 ? await _numbersOf(args[1]) : _numbersHere();
  if (head == null) {
    return;
  }

  _render(args[0], base, args.length == 2 ? args[1] : 'working tree', head);
}

/// The benchmark numbers of [ref], run in a worktree of it, or null where
/// that version cannot answer (no benchmark, no --json).
Future<Map<String, double>?> _numbersOf(String ref) async {
  final verify = Process.runSync('git', ['rev-parse', '--verify', ref]);
  if (verify.exitCode != 0) {
    stderr.writeln('not a git ref: $ref');
    exitCode = 64;

    return null;
  }

  final dir = Directory.systemTemp.createTempSync('ansi_bench_');
  try {
    final add = Process.runSync(
      'git',
      ['worktree', 'add', '--detach', dir.path, ref],
    );
    if (add.exitCode != 0) {
      stderr.writeln('git worktree add failed:\n${add.stderr}');
      exitCode = 70;

      return null;
    }

    Process.runSync('dart', ['pub', 'get'], workingDirectory: dir.path);

    final run = Process.runSync(
      'dart',
      ['run', 'benchmark/parser_benchmark.dart', '--json'],
      workingDirectory: dir.path,
    );
    if (run.exitCode != 0) {
      stderr.writeln(
        '$ref cannot report json '
        '(no benchmark or no --json at that version):\n${run.stderr}',
      );
      exitCode = 65;

      return null;
    }

    return _parse(run.stdout as String);
  } finally {
    Process.runSync('git', ['worktree', 'remove', '--force', dir.path]);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }
}

/// The numbers of the working tree as it stands.
Map<String, double>? _numbersHere() {
  final run = Process.runSync(
    'dart',
    ['run', 'benchmark/parser_benchmark.dart', '--json'],
  );
  if (run.exitCode != 0) {
    stderr.writeln('the working tree failed to run:\n${run.stderr}');
    exitCode = 70;

    return null;
  }

  return _parse(run.stdout as String);
}

Map<String, double> _parse(String jsonLines) => {
      for (final line in LineSplitter.split(jsonLines))
        if (line.startsWith('{'))
          if (jsonDecode(line) case {
            'scenario': final String scenario,
            'us': final num us,
          })
            scenario: us.toDouble(),
    };

/// The threshold under which a delta is noise rather than news.
const _noise = 0.05;

void _render(
  String baseName,
  Map<String, double> base,
  String headName,
  Map<String, double> head,
) {
  final styles = stdout.supportsAnsiEscapes;
  String paint(String text, Style style) => styles ? style(text) : text;

  print(paint('$baseName  →  $headName', Styles.bold));

  final shared = [
    for (final scenario in base.keys)
      if (head.containsKey(scenario)) scenario,
  ];
  if (shared.isEmpty) {
    print('no scenarios in common — nothing to compare');

    return;
  }

  for (final scenario in shared) {
    final was = base[scenario]!;
    final now = head[scenario]!;
    final delta = was == 0 ? 0.0 : (now - was) / was;

    final verdict = switch (delta) {
      < -_noise => paint(
          '${(-delta * 100).toStringAsFixed(0)} % faster',
          Styles.green,
        ),
      > _noise => paint(
          '${(delta * 100).toStringAsFixed(0)} % slower',
          Styles.red,
        ),
      _ => paint('the same', Styles.dim),
    };

    print('${scenario.padRight(56)} '
        '${_us(was).padLeft(11)} ${_us(now).padLeft(11)}  $verdict');
  }

  final missing = head.keys.where((s) => !base.containsKey(s)).length;
  if (missing > 0) {
    print(paint('$missing scenario(s) are new and have no base', Styles.dim));
  }
}

String _us(double us) => switch (us) {
      < 1 => '${(us * 1000).toStringAsFixed(0)} ns',
      < 1000 => '${us.toStringAsFixed(1)} µs',
      _ => '${(us / 1000).toStringAsFixed(2)} ms',
    };
```

Примечание для исполнителя: если анализатор потребует dartdoc или
поругается на что-то в этом файле — чинить код, не отключать линты; файл
проходит тот же `--fatal-infos`, что и всё остальное.

- [ ] **Step 5: Исключить утилиту из публикации**

В `.pubignore` после строки `doc/api/`:

```
benchmark/compare.dart
```

- [ ] **Step 6: Проверить утилиту end-to-end (ожидаемый отказ базы)**

```bash
dart run benchmark/compare.dart v3.1.2
```

Expected: сообщение `v3.1.2 cannot report json …`, exit code 65 — у
v3.1.2 нет `--json`; это честный отказ, а не падение.

- [ ] **Step 7: Полная проверка и коммит**

```bash
dart format . && dart analyze --fatal-infos && dart test \
  && dart pub publish --dry-run
git add benchmark/parser_benchmark.dart benchmark/compare.dart .pubignore
git commit -m "feat: the benchmark learns the scenarios the fixes will be measured by

A page with no codes, slicing a document line by line, and what a full
parse keeps in memory; a --json mode for tooling; and compare.dart,
which runs two versions of the package side by side out of git and
paints the delta with the package's own styles. The tool needs git, so
it stays out of the published archive.

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

- [ ] **Step 8: Поставить тег базовой линии**

```bash
git tag perf-baseline
```

Тег локальный, не пушится; после слияния PR удаляется
(`git tag -d perf-baseline`).

---

### Task 3: H3 — префильтр `indexOf(ESC)` в итераторе парсера

**Files:**
- Modify: `lib/src/parsing/parser/matches/parser_iterator.dart:9,55-121`

**Interfaces:**
- Consumes: `escapeCodesRe` из `patterns.dart` (каждая альтернатива начинается с `\x1B`; `escPattern` матчит и одинокий `ESC`, поэтому `matchAsPrefix` на позиции `ESC` всегда успешен — null-ветка защитная).
- Produces: тот же `Iterator<Match<S>>`; поле `_regExpIterator` исчезает, `_next` остаётся lookahead'ом.

- [ ] **Step 1: Заменить `allMatches` на `indexOf` + `matchAsPrefix`**

В `_ParserIterator` удалить поле `_regExpIterator` (строки 6–9) вместе с
его doc-комментарием. В `moveNext` убрать строку `_regExpIterator = null;`
(комментарий над ней сократить до объяснения `_next = null`).

`_read` (строки 86–121) заменить на:

```dart
  /// Reads the next match of the string, or `null` at the end of it.
  Match<S>? _read() {
    final string = _parent._input;
    final pos = _pos;

    // End of string.
    if (pos == string.length) {
      return null;
    }

    // There's the next escape code.
    final next = _next;
    if (next != null) {
      _next = null;

      return _escapeCode(next);
    }

    // Between escape codes the string is scanned by indexOf, which walks
    // bytes two orders of magnitude faster than the regex engine would:
    // every alternative of [escapeCodesRe] begins with ESC, so ESC is the
    // only place a match can start.
    var searchFrom = pos;
    while (true) {
      final escIndex = string.indexOf('\x1B', searchFrom);

      // No escape at all: the rest of the string is plain text.
      if (escIndex < 0) {
        return _text(pos, string.length);
      }

      final m = escapeCodesRe.matchAsPrefix(string, escIndex) as RegExpMatch?;

      // The patterns as they stand match any ESC, so this is for a pattern
      // grown narrower than its scanner: an ESC none of them took stays in
      // the text, exactly as allMatches would have left it.
      if (m == null) {
        searchFrom = escIndex + 1;
        continue;
      }

      // There is plain text before the escape code.
      if (pos != m.start) {
        _next = m;

        return _text(pos, m.start);
      }

      return _escapeCode(m);
    }
  }
```

- [ ] **Step 2: Прогнать всю сетку и все тесты**

```bash
dart test
```

Expected: PASS (все, включая round-trip-корпус задачи 1).

- [ ] **Step 3: Снять числа против базы**

```bash
dart run benchmark/compare.dart perf-baseline
```

Expected: «A page with no codes at all / matches …» и
«… ansiRemoveEscapeCodes» — кратно быстрее; «Reading a page of coloured
log» — заметно быстрее; плотная страница — не хуже. Числа записать для
сообщения коммита.

- [ ] **Step 4: Полная проверка и коммит (числа — из шага 3)**

```bash
dart format . && dart analyze --fatal-infos && dart test
git add lib/src/parsing/parser/matches/parser_iterator.dart
git commit -m "perf: the scanner finds the next ESC by indexOf, not by regex

Between escape codes the regex engine walked the text at tens of
megabytes a second; String.indexOf walks it at gigabytes. Every
alternative of the pattern begins with ESC, so nothing changes in what
is matched — the safety-net corpus agrees byte for byte.

compare against perf-baseline:
<вставить строки таблицы compare.dart>

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 4: H3 — fast-path в extensions и гард линейности

**Files:**
- Modify: `lib/src/extensions/has.dart`
- Modify: `lib/src/extensions/remove.dart`
- Create: `test/performance_guards_test.dart` (первый гард; файл дополняется в задаче 5)

**Interfaces:**
- Consumes: `ESC` из `lib/src/ansi/c0.dart` (строковая константа `'\x1B'`).
- Produces: те же публичные extensions; `test/performance_guards_test.dart` с функцией-помощником `bestOf` (используется и задачей 5).

- [ ] **Step 1: Fast-path в `has.dart`**

Добавить импорт `import '../ansi/c0.dart';` (по алфавиту). Заменить тела —
только ESC-якорные (у `ansiHasControlCodes` fast-path НЕ появляется):

```dart
  /// Whether there any escape codes in the text.
  bool get ansiHasEscapeCodes => contains(ESC);

  /// Whether there control sequences (CSI) in the text.
  bool get ansiHasCsi => contains(ESC) && csiRe.hasMatch(this);

  /// Whether there SGR (Select Graphic Rendition) codes in the text.
  bool get ansiHasSgr => contains(ESC) && sgrRe.hasMatch(this);

  /// Whether the foreground color in the text changes.
  bool get ansiHasForeground =>
      contains(ESC) && hasSgrFunction(this, isForegroundFunction);

  /// Whether the background color in the text changes.
  bool get ansiHasBackground =>
      contains(ESC) && hasSgrFunction(this, isBackgroundFunction);

  /// Whether the color of the underline in the text changes.
  bool get ansiHasUnderlineColor =>
      contains(ESC) && hasSgrFunction(this, isUnderlineColorFunction);
```

`ansiHasEscapeCodes == contains(ESC)` — точное равенство: `escPattern`
матчит и одинокий `ESC`, так что любая `\x1B` в строке — это escape-код по
паттерну. Остальным `contains` служит префильтром.

- [ ] **Step 2: Fast-path в `remove.dart`**

Добавить импорт `import '../ansi/c0.dart';`. Ранний выход в ESC-якорных
функциях (у `ansiRemoveControlCodes` НЕ появляется):

```dart
  String ansiRemoveEscapeCodes() =>
      contains(ESC) ? replaceAll(escapeCodesRe, '') : this;
```

```dart
  String ansiRemoveCsi() => contains(ESC) ? replaceAll(csiRe, '') : this;
```

```dart
  String ansiRemoveSgr() => contains(ESC) ? replaceAll(sgrRe, '') : this;
```

```dart
  String ansiRemoveForeground() =>
      contains(ESC) ? removeSgrFunction(this, isForegroundFunction) : this;
```

```dart
  String ansiRemoveBackground() =>
      contains(ESC) ? removeSgrFunction(this, isBackgroundFunction) : this;
```

```dart
  String ansiRemoveUnderlineColor() =>
      contains(ESC) ? removeSgrFunction(this, isUnderlineColorFunction) : this;
```

`lengthWithoutEscapeCodes` не трогать: он зовёт `ansiRemoveEscapeCodes`,
fast-path которого возвращает `this` без копии. Существующие dartdoc
оставить как есть (менять только выражения-тела).

- [ ] **Step 3: Прогнать все тесты**

```bash
dart test
```

Expected: PASS — включая `extensions_test.dart` и дифф-фаззинг
`remove_agrees_with_parser_test.dart`, которые закрепляют, что fast-path
ничего не менял.

- [ ] **Step 4: Написать гард линейности чистого текста**

Файл `test/performance_guards_test.dart` (создать; дополняется в задаче 5):

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The best of [runs] timings of [body], in microseconds: the run least
/// disturbed by whatever else the machine was doing.
double bestOf(void Function() body, {int runs = 3}) {
  var best = double.infinity;
  for (var i = 0; i < runs; i++) {
    final watch = Stopwatch()..start();
    body();
    watch.stop();
    final us = watch.elapsedMicroseconds.toDouble();
    if (us < best) {
      best = us;
    }
  }

  return best;
}

/// A page of [lines] plain lines, ESC-free.
String plainPage(int lines) =>
    List.filled(lines, 'an ordinary line of an ordinary log, no codes').join('\n');

void main() {
  group('complexity guards', () {
    test('parsing plain text stays linear', () {
      final small = plainPage(2000);
      final large = plainPage(4000);

      // Warm-up, so the JIT settles before anything is timed.
      Parser(small).removeAll();
      Parser(large).removeAll();

      final tSmall = bestOf(() => Parser(small).removeAll());
      final tLarge = bestOf(() => Parser(large).removeAll());

      expect(
        tLarge / tSmall,
        lessThan(2.5),
        reason: 'doubling the input must not much more than double the cost '
            '(${tSmall.toStringAsFixed(0)} µs → ${tLarge.toStringAsFixed(0)} µs)',
      );
    });
  });
}
```

- [ ] **Step 5: Прогнать гард**

```bash
dart test test/performance_guards_test.dart
```

Expected: PASS (линейность была и осталась; гард закрепляет класс).

- [ ] **Step 6: Числа, полная проверка, коммит**

```bash
dart run benchmark/compare.dart perf-baseline
dart format . && dart analyze --fatal-infos && dart test
git add lib/src/extensions/has.dart lib/src/extensions/remove.dart \
  test/performance_guards_test.dart
git commit -m "perf: a string with no ESC answers the extensions without the regex

ansiHasEscapeCodes is contains(ESC) outright — the pattern matches any
lone ESC, so the two were already the same question. The rest of the
ESC-anchored extensions get contains(ESC) as a doorman; the control-code
functions keep their own counsel, their pattern owes ESC nothing. A
complexity guard pins the linear class.

compare against perf-baseline:
<вставить строки таблицы compare.dart>

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 5: M4 — общий резюмируемый курсор для `stateAt`/`substring`/`_seamAt`

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart:92-231,289-360,438-466`
- Modify: `test/performance_guards_test.dart` (добавить гард нарезки)

**Interfaces:**
- Consumes: `Match<S>` (`.entity`, `.state`, `.start`), кэш `Matches._parsed`; `bestOf`/`plainPage` из задачи 4.
- Produces: приватный класс `_Walk<S>` в `parser.dart`; публичное поведение `stateAt`/`substring`/`insertBefore`/`insertAfter` не меняется (закреплено дифф-тестами задачи 1).

- [ ] **Step 1: Написать гард нарезки — RED на текущем коде**

В `test/performance_guards_test.dart`, внутрь `group('complexity guards')`:

```dart
    test('slicing a document line by line stays linear', () {
      const line = '\x1B[1m\x1B[31mtag\x1B[22m\x1B[39m '
          'a sentence of ordinary words to slice';
      String page(int lines) => List.filled(lines, line).join('\n');
      final width = Parser(line).length;

      double sliceAll(String text, int lines) {
        final parser = Parser(text)..prepare();

        return bestOf(() {
          for (var i = 0; i < lines; i++) {
            parser.substring(i * (width + 1), maxLength: width);
          }
        });
      }

      // Warm-up.
      sliceAll(page(50), 50);

      final tSmall = sliceAll(page(400), 400);
      final tLarge = sliceAll(page(800), 800);

      expect(
        tLarge / tSmall,
        lessThan(2.5),
        reason: 'twice the lines must not cost near four times the walk '
            '(${tSmall.toStringAsFixed(0)} µs → ${tLarge.toStringAsFixed(0)} µs)',
      );
    });
```

- [ ] **Step 2: Убедиться, что гард ПАДАЕТ на текущем коде**

```bash
dart test test/performance_guards_test.dart
```

Expected: FAIL нового теста с отношением около ×3 (замер ревью: 400→800
строк — ×2,97). Если тест внезапно прошёл — размеры малы, поднять до
800/1600 и убедиться в падении, прежде чем идти дальше.

- [ ] **Step 3: Ввести `_Walk` и перевести на него `stateAt`**

В `parser.dart` заменить поля `_cursor`, `_cursorEnd`, `_cursorStart`,
`_cursorState` (строки 96–110) одним полем:

```dart
  /// Where the last positional question stopped, so that the next can carry
  /// on from there rather than walk the string from the beginning.
  _Walk<S>? _walk;
```

В конец файла — класс:

```dart
/// A resumable walk over the matches: the iterator, how much plain text it
/// has passed, and the piece of text it stopped in.
///
/// [stateAt], `substring` and the insert seams all walk the same matches
/// forward; sharing the walk makes a run of forward questions cost one pass
/// in all. A question about an earlier position starts a fresh walk.
final class _Walk<S extends State<S>> {
  final Iterator<Match<S>> iterator;

  /// Plain-text position where the piece [current] stands for begins.
  int pieceStart = 0;

  /// Plain text passed so far, the current piece included.
  int passed = 0;

  /// The last [Text] match handed out, or null before the first.
  Match<S>? current;

  _Walk(this.iterator);

  /// Moves to the next [Text] piece; false at the end of the string.
  bool nextPiece() {
    while (iterator.moveNext()) {
      final m = iterator.current;
      if (m.entity is Text) {
        pieceStart = passed;
        passed += m.entity.string.length;
        current = m;

        return true;
      }
    }

    return false;
  }
}
```

`stateAt` (строки 196–231) переписать через него — семантика и
`RangeError` в точности прежние:

```dart
  S stateAt(int pos) {
    RangeError.checkNotNegative(pos, 'pos');

    // The piece the last question was answered from may hold this one too.
    var walk = _walk;
    if (walk?.current case final match?
        when pos >= walk!.pieceStart && pos < walk.passed) {
      return match.state;
    }

    // Anything else already passed means going back, and the walk starts
    // over.
    if (walk == null || pos < walk.passed) {
      walk = _walk = _Walk(matches.iterator);
    }

    while (walk.nextPiece()) {
      if (pos < walk.passed) {
        return walk.current!.state;
      }
    }

    RangeError.checkValidIndex(pos, null, 'pos', walk.passed + 1);

    return finalState;
  }
```

- [ ] **Step 4: Прогнать тесты после первого перевода**

```bash
dart test test/parser_state_at_test.dart \
  test/parser_substring_differential_test.dart
```

Expected: PASS.

- [ ] **Step 5: Перевести `substring` на резюмирование**

Заменить начало `substring` (строки 303–307, объявления перед циклом) и
сам цикл так, что источником кусков становится walk; правило
резюмирования **строгое** `start > walk.pieceStart` — срез, начинающийся
ровно на границе куска, обязан увидеть escape-коды, стоящие перед куском,
и потому идёт свежим обходом:

```dart
    final buf = StringBuffer();
    var currentState = initialState.toStyle();
    Match<S>? lastMatch;

    var walk = _walk;
    int pos;
    Match<S>? piece;
    if (walk?.current != null && start > walk!.pieceStart) {
      // The walk already stands in a piece the slice begins in or after:
      // pick that piece up and read on, one pass for a run of slices.
      pos = walk.pieceStart;
      piece = walk.current;
    } else {
      walk = _walk = _Walk(matches.iterator);
      pos = 0;
    }

    while (true) {
      final Match<S> m;
      if (piece != null) {
        m = piece;
        piece = null;
      } else if (walk.iterator.moveNext()) {
        m = walk.iterator.current;
        if (m.entity is Text) {
          walk
            ..pieceStart = pos
            ..passed = pos + m.entity.string.length
            ..current = m;
        }
      } else {
        break;
      }

      final entity = m.entity;

      switch (entity) {
        case Text():
          final string = entity.string;
          pos += string.length;
          if (pos >= start) {
            final substring = string.substring(
              math.max(string.length - (pos - start), 0),
              end == null
                  ? string.length
                  : math.min(string.length - (pos - end), string.length),
            );
            if (substring.isNotEmpty) {
              buf
                ..write(currentState.transitTo(m.state))
                ..write(substring);
              currentState = m.state.toStyle();
              lastMatch = m;
            }
          }

        case EscapeCode():
          if (entity is! Sgr && pos >= start && (end == null || pos <= end)) {
            buf
              ..write(currentState.transitTo(m.state))
              ..write(entity.string);
            currentState = m.state.toStyle();
          }
          lastMatch = m;
      }

      if (end != null && pos > end) {
        break;
      }
    }
```

Хвост метода (проверка `start > pos`, закрывающий `transitTo`, `return`)
не меняется, КРОМЕ одного: `if (start > pos)` в резюмированном обходе
сравнивает с pos, который начал не с нуля, но к концу строки равен полной
длине — семантика `RangeError` та же. Тонкость с `walk.passed` при
резюмировании: до первого нового куска `passed` остаётся от прошлого
вызова и совпадает с `pos` после обработки подхваченного `piece` —
инвариант «passed = конец текущего куска» сохраняется присваиваниями в
ветке `m.entity is Text`.

- [ ] **Step 6: Перевести `_seamAt` тем же правилом**

В `_seamAt` (строки 438–466) перед циклом — то же резюмирование со
строгим `pos > walk.pieceStart` (для обоих значений `after` — правило
консервативное, но всегда корректное), цикл — по `walk` как в шаге 5,
с прежним телом (`if (after ? pos < end : pos > plainPos && pos <= end)`,
где `plainPos` — это `pieceStart` куска, а `end` — его конец).

- [ ] **Step 7: Гард и дифф-тесты — GREEN**

```bash
dart test test/performance_guards_test.dart \
  test/parser_substring_differential_test.dart \
  test/parser_state_at_test.dart test/parser_insert_test.dart
```

Expected: PASS все; гард нарезки — отношение ~×2.

- [ ] **Step 8: Числа, полная проверка, коммит**

```bash
dart run benchmark/compare.dart perf-baseline
dart format . && dart analyze --fatal-infos && dart test
git add lib/src/parsing/parser/parser.dart test/performance_guards_test.dart
git commit -m "perf: substring and the seams keep their place, as stateAt always did

One resumable walk serves stateAt, substring and the insert seams: a
run of forward slices costs one pass in all instead of one walk each,
which on a document cut line by line is the difference between linear
and quadratic. A slice starting exactly on a piece boundary still walks
fresh — the codes standing before the piece belong to it. Differential
tests pin that a reused parser answers exactly as a fresh one.

compare against perf-baseline:
<вставить строки таблицы compare.dart>

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 6: M7 — диспетчеризация по байту, кэш функций, обёртки вместо копий

**Files:**
- Modify: `lib/src/parsing/parser/entities/entity.dart:57-74`
- Modify: `lib/src/parsing/parser/entities/sgr.dart:19-25,207,420-426`

**Interfaces:**
- Consumes: `_MatchingState.string` (весь матч), `Csi._parse`/`Osc._parse`/`Esc._parse`, `ControlFunctionsSGR.values` (108 значений, порядок фиксирован тестами констант).
- Produces: то же дерево сущностей; `SgrSimpleFunction.of(code)` — статический доступ к кэшу (приватность: `SgrSimpleFunction._cache` — деталь реализации).

- [ ] **Step 1: Диспетчеризация в `EscapeCode._parse`**

Заменить тело (строки 57–74):

```dart
  static EscapeCode _parse<S extends State<S>>(_MatchingState<S> state) {
    final string = state.string;

    // Every match begins with ESC; the byte after it says which of the
    // three kinds this is, without asking the regex for its groups.
    if (string.length > 1) {
      switch (string.codeUnitAt(1)) {
        case 0x5B: // [
          return Csi._parse(state);
        case 0x5D: // ]
          return Osc._parse(state);
      }
    }

    return Esc._parse(state);
  }
```

Обоснование эквивалентности: группы `csi`/`osc`/`esc` регулярного
выражения взаимоисключающие и различаются ровно вторым байтом
(`ESC[`, `ESC]`, прочее — включая одинокий `ESC`, у которого длина 1).

- [ ] **Step 2: Кэш `SgrSimpleFunction`**

В `sgr.dart` (строки 420–426) добавить в класс:

```dart
final class SgrSimpleFunction extends SgrFunctionWithCode {
  /// The function [code] stands for.
  const SgrSimpleFunction(super.code);

  /// The cached instance for [code]: one function per code, not one per
  /// time the code is read.
  static SgrSimpleFunction of(ControlFunctionsSGR code) => _cache[code.index];

  static final List<SgrSimpleFunction> _cache = List.unmodifiable([
    for (final code in ControlFunctionsSGR.values) SgrSimpleFunction(code),
  ]);

  @override
  String toString() => code.id;
}
```

На строке 207 заменить `..commitFunction(SgrSimpleFunction(code));` на
`..commitFunction(SgrSimpleFunction.of(code));`. Проверить grep'ом
остальные места конструирования:
`grep -n 'SgrSimpleFunction(' lib/ -r` — вызовы в горячем пути перевести
на `.of`, публичный const-конструктор оставить (API не сужаем).

- [ ] **Step 3: `UnmodifiableListView` вместо копий в `Sgr._`**

В `sgr.dart` (строки 19–25):

```dart
  Sgr._(
    super.string,
    List<CsiParam> params,
    List<SgrFunction> functions,
  )   : params = UnmodifiableListView(params),
        functions = UnmodifiableListView(functions),
        super._();
```

Импорт `dart:collection` — первым в файле `parser.dart` (sgr.dart —
part). Перед заменой проверить вызовы `Sgr._` (grep) и убедиться, что
передаваемые списки после конструирования никем не мутируются — иначе
оставить копию в том месте и зафиксировать причину комментарием.

- [ ] **Step 4: Тесты и числа**

```bash
dart test
dart run benchmark/compare.dart perf-baseline
```

Expected: PASS все; «more code than text» и «Reading a page of coloured
log» быстрее относительно результата задачи 4 (сверить также прямым
`dart run benchmark/compare.dart HEAD~1`).

- [ ] **Step 5: Полная проверка и коммит**

```bash
dart format . && dart analyze --fatal-infos && dart test
git add lib/src/parsing/parser/entities/entity.dart \
  lib/src/parsing/parser/entities/sgr.dart \
  lib/src/parsing/parser/parser.dart
git commit -m "perf: an escape code is told apart by its second byte

The kind was asked of the regex through named groups, four lookups a
code; the byte after ESC answers the same question outright. Simple SGR
functions come from a table of 108 rather than an allocation apiece,
and the SGR lists are wrapped once instead of copied twice.

compare against perf-baseline:
<вставить строки таблицы compare.dart>

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 7: M5 — память: обёртка результата, ленивый `Text.string`, дартдок

**Files:**
- Modify: `lib/src/parsing/parser/matches/matches_result.dart`
- Modify: `lib/src/parsing/parser/entities/entity.dart:8-43`
- Modify: `lib/src/parsing/parser/matches/parser_iterator.dart` (`_text`)
- Modify: `lib/src/parsing/parser/parser.dart:37-64` (дартдок `Parser`)
- Modify: `test/performance_guards_test.dart` (пин ленивости)

**Interfaces:**
- Consumes: `Match.start`/`end` уже несут границы куска во входной строке.
- Produces: `Entity.string` становится абстрактным геттером; `Text` создаётся как `Text._(input, start, end)`. `EscapeCode` и наследники не меняются снаружи.

- [ ] **Step 1: `_MatchesResult` — обёртка вместо копии**

`matches_result.dart`, конструктор:

```dart
  _MatchesResult._({
    required List<Match<S>> matches,
    required this.finalState,
  }) : matches = UnmodifiableListView(matches);
```

Список `_parsed` после завершения разбора больше не растёт (итераторы
берут из кэша), так что живая обёртка равна снимку; второй полный список
не строится.

- [ ] **Step 2: Ленивый `Text.string`**

В `entity.dart` перестроить вершину иерархии (строки 8–43):

```dart
/// A piece of a parsed string: either [Text] or an [EscapeCode].
///
/// A string is nothing but these, one after another, and writing them all out
/// in order gives the string back exactly as it came in.
@immutable
sealed class Entity {
  /// The piece of the string this stands for, as it was written.
  String get string;

  const Entity._();

  @override
  int get hashCode => string.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Entity && string == other.string;
}
```

`EscapeCode` получает хранимое поле (наследники не меняются — их
`super._(string)` остаётся):

```dart
sealed class EscapeCode extends Entity {
  @override
  final String string;

  const EscapeCode._(this.string) : super._();
```

`Text` хранит вход и границы; копия подстроки появляется при первом
чтении и один раз:

```dart
final class Text extends Entity {
  final String _input;
  final int _start;
  final int _end;

  /// The piece of the string this stands for, cut out on first use: a
  /// piece nobody reads keeps no copy of itself.
  @override
  late final String string = _input.substring(_start, _end);

  Text._(this._input, this._start, this._end);
```

(`toString` не меняется; `const Text._` уходит — конструктор и так
приватный, снаружи это не наблюдаемо. Проверить grep'ом
`grep -rn 'Text._(' lib/ test/` — единственный вызов в `_text`.)

- [ ] **Step 3: Обновить `_text` в `parser_iterator.dart`**

```dart
  Match<S> _text(int start, int end) {
    _pos = end;

    return Match<S>._(
      state: currentState,
      entity: Text._(_parent._input, start, end),
      start: start,
      end: end,
    );
  }
```

- [ ] **Step 4: Дартдок `Parser` — итераторный режим**

В класс-доку `Parser` (parser.dart, после списка строковых методов,
строка ~64) добавить абзац:

```dart
/// On a large input, prefer walking `matches` with a `for` and taking what
/// the loop needs as it goes: the walk parses lazily, and what it has read
/// it keeps. `prepare`, `length` and the string methods read the whole
/// string and keep every piece, which on megabytes of input is megabytes
/// of parse tree.
```

- [ ] **Step 5: Пин ленивости**

В `test/performance_guards_test.dart`, новый группой:

```dart
  group('memory pins', () {
    test('a Text piece materializes its string once', () {
      final parser = Parser('\x1B[31mred\x1B[0m and plain');
      final texts = [
        for (final m in parser.matches)
          if (m.entity case final Text text) text,
      ];

      expect(texts, isNotEmpty);
      for (final text in texts) {
        expect(
          identical(text.string, text.string),
          isTrue,
          reason: 'string must be built once and kept, not rebuilt per read',
        );
      }
    });
  });
```

- [ ] **Step 6: Тесты, числа памяти, решение по откату**

```bash
dart test
dart run benchmark/compare.dart perf-baseline
```

Expected: PASS все. В сравнении: «Memory / rss delta, mb» — заметно
ниже базы; «more code than text» и «Reading a page of coloured log» —
не хуже результата задачи 6 более чем на 5 % (принтер читает
`entity.string` каждого куска — ленивость там материализуется всегда и
стоить должна копейки). **Если плотная страница просела больше 5 %** —
откат шага 2–3 и 5 (`git checkout -- <files>`), остаются шаги 1 и 4,
коммит-сообщение соответственно сокращается; это предусмотренная спекой
точка отката.

- [ ] **Step 7: Полная проверка и коммит**

```bash
dart format . && dart analyze --fatal-infos && dart test \
  && dart pub publish --dry-run
git add lib/src/parsing/parser/matches/matches_result.dart \
  lib/src/parsing/parser/entities/entity.dart \
  lib/src/parsing/parser/matches/parser_iterator.dart \
  lib/src/parsing/parser/parser.dart test/performance_guards_test.dart
git commit -m "perf: a parse keeps the pieces, not three copies of the string

The finished result wraps the match list instead of copying it, and a
Text piece cuts its substring out on first use — a piece nobody reads
keeps no copy of itself. The class doc now says plainly: on megabytes
of input, walk the matches and take what you need.

compare against perf-baseline:
<вставить строки таблицы compare.dart, включая Memory>

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 8: CHANGELOG и финальная сверка

**Files:**
- Modify: `CHANGELOG.md` (запись 4.0.0)

**Interfaces:**
- Consumes: итоговая таблица `dart run benchmark/compare.dart perf-baseline`.
- Produces: подраздел Performance в записи 4.0.0.

- [ ] **Step 1: Подраздел Performance**

В запись `## 4.0.0` после блока `Added:` добавить блок (числа — из
финального прогона compare, формулировки сверить с фактическими):

```markdown
Performance:

- The scanner finds the next escape code by `indexOf` rather than by the
  regex engine: text with no codes at all is parsed and stripped orders
  of magnitude faster, and `ansiHasEscapeCodes` and friends answer a
  clean string without touching a pattern. (<числа>)
- `substring` and the insert seams keep their place the way `stateAt`
  always did: slicing a document line by line is linear now, not
  quadratic. (<числа>)
- An escape code is told apart by its second byte instead of four named
  groups, simple SGR functions come from a table, and the SGR lists are
  wrapped once instead of copied twice: pages that are more code than
  text parse about twice as fast. (<числа>)
- A full parse retains the match list once, not twice, and a `Text`
  piece cuts its substring out on first use. (<числа памяти>)
```

- [ ] **Step 2: Финальная сверка всего**

```bash
dart format . && dart analyze --fatal-infos && dart test \
  && dart pub publish --dry-run
dart run benchmark/compare.dart perf-baseline
dart run benchmark/parser_benchmark.dart --no-color | tail -30
```

Expected: всё чисто; growth-секция бенчмарка — «linear» по всем строкам.

- [ ] **Step 3: Коммит**

```bash
git add CHANGELOG.md
git commit -m "docs: the changelog tells what the performance work bought

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 9: PR, CI, слияние, уборка

**Files:** нет (git/GitHub).

- [ ] **Step 1: Пуш и PR**

```bash
git push -u origin perf/review-findings
gh pr create --title "perf: the four findings of the 4.0.0 review" \
  --body "$(cat <<'EOF'
Implements docs/2026-08-04[2]-perf-fixes-design.md: the indexOf prefilter,
the resumable walk for substring and the seams, byte dispatch with the
SGR function table, and the memory work. Each commit carries its own
compare-against-baseline numbers; complexity classes are pinned by
ratio guards in test/performance_guards_test.dart.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] **Step 2: Дождаться CI (матрица 3.6.0 + stable), слить, прибрать**

После зелёного CI: merge PR, `git checkout main && git pull`,
`git branch -d perf/review-findings`,
`git push origin --delete perf/review-findings`, `git tag -d perf-baseline`.

---

## Self-Review (выполнен)

- **Spec coverage:** шаг 0 спеки → задача 2; H3 → задачи 3–4; M4 → задача 5; M7 → задача 6; M5 → задача 7 (с точкой отката из спеки, шаг 6); эквивалентность → задача 1; гарды → задачи 4/5/7; CHANGELOG → задача 8; PR-процесс → задача 9. Разрыв не найден.
- **Placeholder scan:** маркеры `<вставить …>` в сообщениях коммитов — это данные, которые появляются только при исполнении (числа замеров); всё остальное — конкретный код.
- **Type consistency:** `_Walk` (задача 5) согласован между `stateAt`/`substring`/`_seamAt`; `bestOf`/`plainPage` объявлены в задаче 4 и переиспользованы в 5; `SgrSimpleFunction.of` объявлен и использован в задаче 6; `Text._(input, start, end)` согласован между задачами 7 (entity) и 7 (iterator).
