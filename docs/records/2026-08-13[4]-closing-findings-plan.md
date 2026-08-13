# План: закрыть открытые находки перед публикацией

> **Состояние документа**
>
> - **Тип:** план, 2026-08-13, база `main` @ `1e4dc63`, ветка
>   `fix/closing-findings`
> - **Статус:** написан, реализация не начата
> - **Актуальность:** реализует
>   `docs/records/2026-08-13[3]-closing-findings-design.md` вместе с
>   поправкой к пункту B в его шапке
> - **Чему не верить:** ожидания в заданиях сняты пробниками и прогонами
>   на копии пакета от `1e4dc63`. Если при исполнении что-то разошлось —
>   **объяснить расхождение, а не подогнать ожидание под код**

> **Исполнителю:** пять заданий по порядку, шаги помечены `- [ ]`. Каждое
> кончается зелёными тестами и одним коммитом. Весь код заданий прогонялся
> на копии; тесты, которые обязаны краснеть до правки, помечены прямо в
> шагах, и их краснота снимается выводом, а не словами.

**Цель.** Ни одной открытой находки в `docs/handoff.md` к моменту, когда
владелец решит публиковать.

**Как.** Четыре независимых пункта: правка поведения на шве в конце входа
(A), страж-пол на серию вставок (B), три связывающих теста для набора
открывателей (C), правка неточного обещания в четырёх местах (D).

## Общие ограничения

- **Версию не бампать**, `pubspec.yaml` остаётся на `4.0.0`.
- **CHANGELOG правится только в задании 4** и только там, где стоит
  неточная фраза. Пункт A отдельной записи не требует: он чинит
  поведение, заведённое в том же неизданном цикле. Задание 5 проверяет
  это чтением.
- **`README.md` и `README.ru.md` правятся одним коммитом.**
- **Публичный API не меняется.**
- **Языки:** код, dartdoc, README, CHANGELOG, коммиты — по-английски;
  `docs/` — по-русски.
- **Тесты, которые обязаны краснеть, пишутся до правки.**

## Файлы

| файл | что с ним |
|---|---|
| `lib/src/parsing/parser/parser.dart` | ветка исчерпанного обхода и дартдок `beforeRun` (задание 1); фраза дартдока `insertAfter` (задание 4) |
| `test/insert_keeps_ambient_test.dart` | создаётся (задание 1) |
| `test/parser_insert_test.dart` | два именованных теста (задание 1) |
| `test/performance_guards_test.dart` | страж-пол (задание 2) |
| `test/parser_control_string_test.dart` | два связывающих теста (задание 3) |
| `test/sgr_pattern_link_test.dart` | создаётся (задание 3) |
| `README.md`, `README.ru.md`, `CHANGELOG.md` | фраза про место (задание 4) |
| `docs/handoff.md` | четыре находки закрыты (задание 5) |

---

### Задание 1: состояние и ссылка на шве в конце входа

- [ ] **Шаг 1: базовая отметка**

```bash
dart test 2>&1 | tail -1
```

Ожидается `All tests passed!`, `+608`.

- [ ] **Шаг 2: написать инвариант, который краснеет**

Создать `test/insert_keeps_ambient_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// Inputs whose last code cannot be finished, so that the seam of an
/// insertion is the place in front of the run rather than the end of the
/// string — with something finished standing between that run and the text
/// before it, which is what tells the seam's own state and link apart from
/// the ones the piece of text leaves behind.
const _inputs = <String>[
  'aa\x1B[31m\x1B]8;;http://u/\x1B[',
  'aa\x1B]8;;http://o/\x1B\\\x1BPpay',
  'aa\x1BPpay\x1B',
  'aa\x1B[31m\x1BPpay\x1B',
  'aa\x1B[31\x1B[31\x1BPpay\x1B',
  '\x1BPpay\x1B',
  'aa\x1B]8;;http://u/\x1B\\bb\x1BPpay',
  'aa\x1B[1m\x1B(B\x1B[',
  'aa\x1B[31mbb\x1B[0m\x1B[',
  'aabb\x1B[',
  '\x1B[31maa\x1B[',
  'aa\x1B]8;;http://u/\x1B\\\x1B[32m\x1BPpay\x1B',
];

/// Texts that leave the two channels in every state they can be left in:
/// untouched, restyled and closed, a link closed, a link opened.
const _texts = <String>[
  '@',
  '\x1B[32m@\x1B[0m',
  '@\x1B]8;;\x1B\\',
  '\x1B]8;;http://n/\x1B\\@',
];

void main() {
  test('an insertion leaves the string ending where it ended', () {
    for (final input in _inputs) {
      final before = Parser(input);
      final wasState = before.finalState;
      final wasLink = before.finalLink;

      for (var pos = 0; pos <= Parser(input).length; pos++) {
        for (final text in _texts) {
          for (final after in [true, false]) {
            final String result;
            try {
              final parser = Parser(input);
              result = after
                  ? parser.insertAfter(pos, text)
                  : parser.insertBefore(pos, text);
            } on UnfinishedSequenceException {
              continue;
            }

            final now = Parser(result);
            final reason = 'input ${input.ansiShowEscapeSequences()}, '
                'pos $pos, after: $after, '
                'text ${text.ansiShowEscapeSequences()}';

            expect(now.finalState, wasState, reason: reason);
            expect(now.finalLink, wasLink, reason: reason);
          }
        }
      }
    }
  });
}
```

- [ ] **Шаг 3: убедиться, что он красный**

```bash
dart test test/insert_keeps_ambient_test.dart 2>&1 | tail -5
```

Ожидается падение с сообщением вида
`Expected: Style:<Style(foreground: Color16.red)>  Actual: Style:<Style()>`
на входе `aa[CSI 31 SGR][OSC 8;;http://u/ ][ESC []`, `pos 2, after: true`.
Вывод — в отчёт.

- [ ] **Шаг 4: два именованных теста**

В `test/parser_insert_test.dart`, в группу про шов перед чередой:

```dart
    test('a seam in front of a run carries the ambient of its own place', () {
      // A finished code between the text and the run moves the seam past it,
      // and what is in force there is what that code left behind rather than
      // what the piece of text did. The tail must come back to it.
      const styled = 'aa\x1B[31m\x1B]8;;http://u/\x1B[';

      expect(
        Parser(styled).insertAfter(2, '\x1B[32m@\x1B[0m'),
        'aa\x1B[31m\x1B[32m@\x1B[0m\x1B[31m\x1B]8;;http://u/\x1B[',
        reason: 'the red the finished SGR left is written back after the '
            'insertion, the way insertBefore writes it back',
      );

      // The same on the link channel: the seam stands inside the terminated
      // link, so an insertion that closes a link of its own owes the seam
      // its link back.
      const linked = 'aa\x1B]8;;http://o/\x1B\\\x1BPpay';

      expect(
        Parser(linked).insertAfter(2, '@\x1B]8;;\x1B\\'),
        'aa\x1B]8;;http://o/\x1B\\@\x1B]8;;\x1B\\'
            '\x1B]8;;http://o/\x1B\\\x1BPpay',
      );
    });
```

- [ ] **Шаг 5: убедиться, что и они красные**

```bash
dart test test/parser_insert_test.dart 2>&1 | tail -4
```

- [ ] **Шаг 6: правка**

В `_seamAt`, ветка исчерпанного обхода (`parser.dart:1000-1004`). Было:

```dart
      return (
        walk.unfinishedRunStart ?? code.start,
        walk.current?.state ?? initialState,
        walk.current?.link ?? initialLink,
      );
```

Стало:

```dart
      // What is in force at the seam is what stood in front of the run, the
      // way the branch above reads it: the piece of text reads what the run
      // leaves behind, and a finished code between the two makes the
      // difference visible. `??` on the link is not the same question — a
      // seam standing in no link answers null, and null is an answer.
      final before = walk.beforeRun;

      return (
        walk.unfinishedRunStart ?? code.start,
        before?.state ?? initialState,
        before == null ? initialLink : before.link,
      );
```

**Подстраховки `?? walk.current` быть не должно:** `beforeRun` равен
`null` ровно тогда, когда череда начинает строку, и тогда верны
`initialState` и `initialLink`.

- [ ] **Шаг 7: поправить дартдок `beforeRun`**

`parser.dart:1229-1235` сейчас говорит, что вторая ветка читает состояние
из куска и что расхождение ждёт владельца. Было:

```dart
  /// Only the branch of `_seamAt` that stopped inside a piece of text reads
  /// this. The branch for a walk that has run out — the string ending inside
  /// the run — still reads its state and its link off the last piece, which
  /// agrees with this while the run follows the piece directly and does not
  /// where a finished code stands between the two. That disagreement is a
  /// defect older than the field, it moves `finalState` and `finalLink`, and
  /// it waits on the owner in `docs/handoff.md` rather than being quietly
  /// fixed here.
```

Стало:

```dart
  /// Both branches of `_seamAt` read this: the one that stopped inside a
  /// piece of text, and the one for a walk that has run out — the string
  /// ending inside the run. They used to disagree, the second reading its
  /// state and its link off the last piece, which is the same thing only
  /// while the run follows the piece directly; a finished code between the
  /// two made an insertion drop the style and the link the tail stood in.
```

- [ ] **Шаг 8: всё зелёное**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test 2>&1 | tail -1
```

Ожидается `+610`: 608 базовых, инвариант и именованный тест.

- [ ] **Шаг 9: коммит**

```bash
git add lib/src/parsing/parser/parser.dart test/
git commit -m "fix: the seam at the end of the input carries its own ambient"
```

---

### Задание 2: страж-пол на серию вставок

Находка была про отсутствие стража. Страж роста здесь невозможен —
причины в поправке к шапке спеки, — поэтому заводится пол: серия вставок
по одному парсеру не перечитывает строку заново.

- [ ] **Шаг 1: добавить страж**

В `test/performance_guards_test.dart`, в группу `complexity guards`,
последним:

```dart
    test('a run of insertions does not read the string again each time', () {
      // A floor rather than a growth ratio. Every insertion builds a whole
      // new string, so a run of them is quadratic in the input however the
      // parser behaves, and a doubling says nothing; and the two things that
      // keep a run cheap — the walk carried between the questions and the
      // matches already read — stand in for each other, so neither shows on
      // its own. Measured by mutation: dropping the walk leaves this at 17,
      // dropping the cache of matches leaves it at 21, dropping both puts it
      // at 1.0. This is the floor under both.
      const line = '\x1B[1m\x1B[31mtag\x1B[22m\x1B[39m '
          'a sentence of ordinary words to insert into';
      const lines = 400;
      final page = List.filled(lines, line).join('\n');
      final width = Parser(line).length;

      // Warm-up, so the JIT settles before anything is timed.
      Parser(page).insertAfter(0, '@');

      final shared = bestOf(() {
        final parser = Parser(page);
        for (var i = 0; i < lines; i++) {
          parser.insertAfter(i * (width + 1), '@');
        }
      });
      final fresh = bestOf(() {
        for (var i = 0; i < lines; i++) {
          Parser(page).insertAfter(i * (width + 1), '@');
        }
      });

      expect(
        fresh / shared,
        greaterThan(4),
        reason: 'a parser asked one insertion after another must not read the '
            'string from the beginning every time '
            '(${shared.toStringAsFixed(0)} µs against '
            '${fresh.toStringAsFixed(0)} µs)',
      );
    });
```

- [ ] **Шаг 2: прогнать**

```bash
dart test test/performance_guards_test.dart 2>&1 | tail -1
```

Ожидается зелёный; на копии отношение выходило 21.5 при пороге 4.

- [ ] **Шаг 3: доказать мутацией, что страж не декоративен**

Две правки сразу, обе в `lib/src/parsing/parser/parser.dart`:

```
_matches ??= Matches._(...)        →  Matches._(...)
when resumable.codesStopAtPiece && →  when false &&
```

Ожидание — **красный**, отношение около 1.0. Прогнать, записать вывод,
откатить обе. Каждая по отдельности оставляет страж зелёным, и это в
комментарии теста уже сказано; проверять их порознь не нужно, но если
проверите — числа 17 и 21 обязаны подтвердиться, иначе расхождение в
отчёт.

- [ ] **Шаг 4: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test 2>&1 | tail -1
git add test/performance_guards_test.dart
git commit -m "test: a run of insertions does not read the string again"
```

Ожидается `+611`.

---

### Задание 3: три связывающих теста для набора открывателей

- [ ] **Шаг 1: сканер и оба быстрых выхода**

В `test/parser_control_string_test.dart`, в группу
`control strings, the opener set:`:

```dart
    test('no pattern opens a match on anything but ESC', () {
      // Three places live on this one assumption. The scanner looks for a
      // single byte — `string.indexOf(ESC)` — and applies the pattern only
      // where it finds one; the shortcuts in `has.dart` and `remove.dart`
      // refuse a string carrying no ESC before the pattern is reached at
      // all. Widen a pattern to some other opener and the parse does not
      // change, because the scanner never offers it the place — so nothing
      // but this notices, and the change looks like it did nothing.
      const patterns = {
        'csiPattern': csiPattern,
        'oscPattern': oscPattern,
        'escPattern': escPattern,
        'sgrPattern': sgrPattern,
        'controlStringPattern': controlStringPattern,
      };
      const bodies = ['31m', '[31m', ']0;t$ST', 'Ppay$ST', '7', '(B', '#8'];

      for (final MapEntry(key: name, value: pattern) in patterns.entries) {
        final re = RegExp(pattern);
        for (var byte = 0x00; byte <= 0xFF; byte++) {
          if (byte == 0x1B) {
            continue;
          }
          for (final body in bodies) {
            expect(
              re.matchAsPrefix('${String.fromCharCode(byte)}$body'),
              isNull,
              reason: '$name matched '
                  '0x${byte.toRadixString(16).toUpperCase()} + $body: the '
                  'scanner searches for ESC and will never offer it here',
            );
          }
        }
      }
    });
```

Проверено на копии: зелёный сегодня; расширение `csiPattern` до
`[$ESC\x9B]\[?` даёт красный с сообщением
`csiPattern matched 0x9b + 31m`.

- [ ] **Шаг 2: страховка в `show_escape_codes`**

Туда же:

```dart
    test('every ESC Fe pair has a name, so the fallback stays out of reach',
        () {
      // `show_escape_codes.dart` writes the opener's bytes as they came
      // where it cannot name them. That arm is unreachable while every pair
      // in the range has a name — which is what this asks — and an opener
      // taken from outside the range would wake it.
      for (var byte = 0x40; byte <= 0x5F; byte++) {
        expect(
          ControlFunctionsC1.byCode('$ESC${String.fromCharCode(byte)}'),
          isNotNull,
          reason: 'ESC 0x${byte.toRadixString(16).toUpperCase()}',
        );
      }

      for (final unit in controlStringOpeners.codeUnits) {
        expect(
          ControlFunctionsC1.byCode('$ESC${String.fromCharCode(unit)}'),
          isNotNull,
          reason: 'opener 0x${unit.toRadixString(16).toUpperCase()}',
        );
      }
    });
```

**`byCode` принимает пару `ESC X`, а не байт.** Пробник, звавший его
байтом, отвечает «пробелы по всему диапазону» и однажды едва не стал
находкой.

- [ ] **Шаг 3: `sgrPattern`**

Создать `test/sgr_pattern_link_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
// The pattern the SGR shortcuts read. Not exported by any entry point — it
// is an implementation detail — but a test that ties it to the parser has to
// read the real one, or it would only be a third copy.
import 'package:ansi_escape_codes/src/parsing/patterns/patterns.dart';
import 'package:test/test.dart';

void main() {
  test('sgrPattern and the parser agree on what an SGR is', () {
    // `sgrPattern` writes the two opening bytes itself, apart from
    // `csiPattern`, and `ansiHasSgr`, `ansiRemoveSgr` and
    // `sgr_functions.dart` read it. A copy that drifts answers where the
    // parser sees nothing: loosen the `[` to optional and
    // `ansiHasSgr('aa\x1B31mbb')` turns true with the whole suite green.
    const openers = ['\x1B[', '\x1B', '[', '\x9B', '\x1B[['];
    const bodies = [
      '31m',
      '0m',
      'm',
      ';m',
      '1;31m',
      '38;5;9m',
      '38;2;1;2;3m',
      '4:3m',
      '31',
      '31x',
      '?5m',
      '>4;1m',
      '<35;10;2m',
    ];

    for (final opener in openers) {
      for (final body in bodies) {
        final input = 'aa$opener${body}bb';

        expect(
          RegExp(sgrPattern).allMatches(input).isNotEmpty,
          Parser(input).matches.any((m) => m.entity is Sgr),
          reason: 'on ${input.codeUnits}',
        );
      }
    }
  });
}
```

Проверено на копии: зелёный сегодня; `(?<csi>$ESC\[?)` даёт красный на
`[97, 97, 27, 51, 49, 109, 98, 98]`.

- [ ] **Шаг 4: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test 2>&1 | tail -1
git add test/
git commit -m "test: the four places the opener set is copied to are tied down"
```

Ожидается `+614`.

---

### Задание 4: обещание про место

Фраза читается так, будто незавершённый код вставка не проходит никогда.
Проходит: первый же законченный код завершает череду и проходится вместе
с ней.

- [ ] **Шаг 1: дартдок**

`parser.dart:806-808`. Было:

```dart
  /// The codes it goes behind are the finished ones. A sequence the parser
  /// could not finish is not passed but stood in front of, and a run of them is
  /// stood in front of whole.
```

Стало:

```dart
  /// The codes it goes behind are the finished ones. A sequence the parser
  /// could not finish is stood in front of rather than passed, and a run of
  /// them is stood in front of whole — but a finished code ends the run, and
  /// what stands before that code is passed with it:
  /// `Parser('aa\x1B]0;title\x1B(B').insertAfter(2, '@')` puts the marker
  /// behind the `ESC ( B`, outside the string that never closed.
```

- [ ] **Шаг 2: оба README, одним коммитом с шагом 1**

`README.md` около 976-977 и `README.ru.md` около 973-974 — абзац
«Where several of them stand in a row…» и его перевод. К нему
добавляется предложение о том, что законченный код завершает череду и
проходится вместе с ней, с тем же примером. **Порядок разделов и код
примеров в переводе те же; переводится проза.**

- [ ] **Шаг 3: CHANGELOG**

`CHANGELOG.md:245-252`, фраза «Both insertions now stand in front of such
a sequence rather than inside it» — дописать ту же оговорку. Запись
неизданная, правится на месте.

- [ ] **Шаг 4: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart doc --dry-run
dart test 2>&1 | tail -1
git add lib/ README.md README.ru.md CHANGELOG.md
git commit -m "docs: a finished code ends the run, and is passed with it"
```

---

### Задание 5: ворота и пустой список находок

- [ ] **Шаг 1: полные ворота**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
dart run tool/generate.dart && git diff --exit-code -- lib/
dart test
dart run benchmark/memory_guard.dart
dart doc --dry-run
dart pub publish --dry-run
```

Ожидается: чисто везде, `+614`, `memory_guard` в полосе 159…332,
`dart doc` 0/0, `publish --dry-run` 0 предупреждений.

- [ ] **Шаг 2: проверить CHANGELOG чтением**

Убедиться, что пункт A отдельной записи не требует: отказ и шов описаны в
неизданной секции `## 4.0.0`, а правка A чинит поведение внутри того же
неизданного цикла. **Если окажется, что запись описывает поведение,
которое волна изменила, — дописать одну фразу и сказать об этом в
отчёте.**

- [ ] **Шаг 3: закрыть все четыре находки**

В `docs/handoff.md` раздел «Найдено волнами» становится **пустым** — это
первый раз, когда он пуст; оставить в нём одну фразу об этом. Четыре
строки уходят в таблицу закрытых:

```markdown
| состояние и ссылка на шве в конце входа брались из куска текста | `2026-08-13[3]` |
| серию вставок не держал ни один страж | `2026-08-13[3]` |
| четыре из шести мест набора открывателей не были связаны тестом | `2026-08-13[3]` |
| дартдок `insertAfter` обещал про место больше, чем код делает | `2026-08-13[3]` |
```

Про стража — записать **почему** он вышел таким: таймерный страж роста
здесь лжёт (числа в поправке к шапке спеки), заведён пол, краснеющий при
потере обоих кэшей сразу.

- [ ] **Шаг 4: строка про волну**

```markdown
| Закрытие находок перед публикацией | `2026-08-13[3]`, `[4]` | — |
```

Хеш мержа проставляется после мержа.

- [ ] **Шаг 5: коммит**

```bash
git add docs/handoff.md
git commit -m "docs: the open list is empty"
```

---

## Самопроверка плана против спеки

| требование спеки | где закрыто |
|---|---|
| A: `beforeRun` в ветке исчерпанного обхода, без `?? current` | задание 1, шаг 6 |
| A: ловушка `?? initialLink` уходит | задание 1, шаг 6 |
| A: дартдок `beforeRun` переписан | задание 1, шаг 7 |
| A: именованный тест и инвариант, красные до правки | задание 1, шаги 2-5 |
| B: находка закрыта записью с числами | задание 5, шаг 3 |
| B: страж-пол, доказанный мутацией | задание 2 |
| C: сканер и оба быстрых выхода | задание 3, шаг 1 |
| C: страховка `?? controlString` | задание 3, шаг 2 |
| C: `sgrPattern` | задание 3, шаг 3 |
| D: дартдок, оба README, CHANGELOG одним коммитом | задание 4 |
| ворота, включая `publish --dry-run` | задание 5, шаг 1 |
| версия, публичный API, полнота перечня — не трогать | ни одно задание их не касается |

## Порядок после заданий

1. Финальное ревью всей ветки по дифу `1e4dc63..HEAD`.
2. `git push -u origin fix/closing-findings`, зелёный CI на обеих ногах.
3. `merge --no-ff` в `main`, `git push origin main`.
4. Хеш мержа в `docs/handoff.md`, handoff переписан под новое состояние.
5. **Публикация — отдельное решение владельца.** План её не делает.
