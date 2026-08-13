# План: прогретый обход отвечает как свежий

> **Состояние документа**
>
> - **Тип:** план, 2026-08-13, база `main` @ `8496255`, ветка
>   `fix/warm-walk-seam`
> - **Статус:** исполнен, влит в `main` мержем `0f0080b`
> - **Актуальность:** реализует
>   `docs/records/2026-08-13[1]-warm-walk-seam-design.md` вместе с
>   поправкой в его шапке
> - **Переписан 2026-08-13 до начала реализации.** Первая редакция
>   просила поле `codesPastPiece` со сбросом; мутация, которую требовал
>   её собственный шаг, показала, что сброс не держит ни один тест.
>   Владелец принял замену на производный геттер, и план переписан целиком
>   — исполнителю нужен читаемый текст, а не текст с поправкой
> - **Чему не верить:** все числа и все ожидания в заданиях сняты
>   пробником на живом коде базы `8496255` и приведены с корпусом. Если
>   при исполнении что-то разошлось — **объяснить расхождение, а не
>   подогнать ожидание под код**

> **Исполнителю:** задания идут по порядку, шаги помечены `- [ ]`. Каждое
> задание кончается зелёными тестами и одним коммитом. Правило волны:
> ожидаемые значения снимаются пробником с живого кода, а не выводятся
> рассуждением — за три последние волны оно сработало тринадцать раз, и
> все тринадцать раз неправ оказывался автор плана, а не код.

**Цель.** Прогретый парсер отвечает на позиционный вопрос то же, что
свежий: сегодня после `substring`, `stateAt` или `linkAt` вставка теряет
байты входа и молча пропускает отказ, обещанный дартдоком.

**Как.** `_Walk` заводит геттер `codesStopAtPiece` — «то, что обход знает
о кодах, говорит о месте перед текущим куском». Он выводится из
`lastCode` и `current` в момент чтения, поэтому разойтись с ними не
может. `_seamAt` поднимает обход только при истинном геттере, иначе идёт
с начала — и отвечает как свежий парсер по построению. Отдельно, как
уборка рядом: два места, где кусок становится текущим, сводятся в один
метод `_Walk.takePiece`.

**Инструменты.** Dart SDK `^3.6.0`, `package:test`, `dart format` в
коротком стиле, `dart analyze --fatal-infos`.

## Общие ограничения

Действуют для каждого задания, повторно в них не пишутся.

- **Версию не бампать**, `pubspec.yaml` остаётся на `4.0.0`.
- **CHANGELOG не править.** Отказ `UnfinishedSequenceException` заведён
  в неизданном цикле 4.0.0; на pub.dev 3.1.2, где его нет. Задание 5
  обязано проверить это чтением файла, а не памятью.
- **README и `README.ru.md` не трогать**: наблюдаемое поведение не
  меняется, меняется его соблюдение.
- **Публичный API не меняется.** Ни одной новой публичной сигнатуры;
  `codesStopAtPiece` и `takePiece` — члены приватного `_Walk`.
- **Языки:** код, dartdoc и сообщения коммитов — по-английски; этот план
  и `docs/handoff.md` — по-русски.
- **Коммиты:** conventional-префикс, тело повествовательное, «почему», а
  не «что». Один коммит на задание.
- **Зона `BEGIN`/`END` в `lib/`** генерируется `tool/generate.dart` и
  руками не правится. Задания её не касаются.

## Файлы

| файл | что с ним |
|---|---|
| `lib/src/parsing/parser/parser.dart` | правится: `_Walk.takePiece` (задание 1), `_Walk.codesStopAtPiece` и охранник в `_seamAt` (задание 2) |
| `test/parser_insert_test.dart` | дополняется двумя именованными тестами (задание 2) |
| `test/warm_walk_invariant_test.dart` | создаётся (задание 3) |
| `docs/handoff.md` | правится: две находки закрыты (задание 5) |

---

### Задание 1: одна дверь, через которую кусок становится текущим

Чистый рефакторинг: поведение не меняется ни в одной клетке. Починки он
не несёт — та живёт в задании 2 и без него обошлась бы, — но два места,
присваивающих одни и те же три поля, стоят рядом с правкой, и свести их
дешевле сейчас, чем читать оба каждый следующий раз.

**Файлы:**
- Правится: `lib/src/parsing/parser/parser.dart` — новый метод в `_Walk`
  (перед `nextPiece`, `parser.dart:1293`), `nextPiece`
  (`parser.dart:1294-1314`), цикл `substring` (`parser.dart:503-513`)

**Интерфейс:**
- `void _Walk.takePiece(Match<S> m, int plainStart)` — принимает кусок
  текста `m`, начинающийся в плоском тексте на позиции `plainStart`;
  выставляет `pieceStart`, `passed` и `current`.

- [ ] **Шаг 1: снять базовую отметку**

```bash
dart test 2>&1 | tail -1
```

Ожидается: `All tests passed!`, счётчик `+605`. Число записать — им
меряются все следующие задания.

- [ ] **Шаг 2: добавить `takePiece` в `_Walk`**

Вставить непосредственно перед `nextPiece` (`parser.dart:1293`):

```dart
  /// Takes in the piece of text [m], which begins at the plain text position
  /// [plainStart].
  ///
  /// The one door a piece becomes [current] through. Two walks are driven
  /// over the same matches — [nextPiece] steps to the next piece and stops
  /// there, `substring` steps over every match itself, to write out what it
  /// passes — and what a piece brings up to date is written here once for
  /// both of them rather than twice.
  void takePiece(Match<S> m, int plainStart) {
    pieceStart = plainStart;
    // Same as entity.string.length, without reading the text: a Text piece is
    // cut from exactly [m.start, m.end), so the length is there in the match
    // already.
    passed = plainStart + (m.end - m.start);
    current = m;
  }
```

- [ ] **Шаг 3: провести `nextPiece` через новую дверь**

Было (`parser.dart:1294-1306`):

```dart
  bool nextPiece() {
    while (iterator.moveNext()) {
      final m = iterator.current;
      final entity = m.entity;
      if (entity is Text) {
        pieceStart = passed;
        // Same as entity.string.length, without reading the text — see the
        // matching comment in substring.
        passed += m.end - m.start;
        current = m;

        return true;
      }
```

Стало:

```dart
  bool nextPiece() {
    while (iterator.moveNext()) {
      final m = iterator.current;
      final entity = m.entity;
      if (entity is Text) {
        takePiece(m, passed);

        return true;
      }
```

`pieceStart = passed; passed += m.end - m.start;` и
`takePiece(m, passed)` дают одно и то же: старое `passed` уходит в
`pieceStart`, новое становится суммой. Комментарий про длину переехал в
`takePiece` и здесь не повторяется.

- [ ] **Шаг 4: провести `substring` через ту же дверь**

Было (`parser.dart:503-513`):

```dart
      if (entity is Text) {
        walk
          ..pieceStart = pos
          // Same as entity.string.length, without reading the text: a Text
          // piece is cut from exactly [m.start, m.end), so the length is
          // there in the match already.
          ..passed = pos + (m.end - m.start)
          ..current = m;
      } else {
        walk.takeCode(m);
      }
```

Стало:

```dart
      if (entity is Text) {
        walk.takePiece(m, pos);
      } else {
        walk.takeCode(m);
      }
```

- [ ] **Шаг 5: убедиться, что не изменилось ничего**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test 2>&1 | tail -1
```

Ожидается: формат чист, анализ чист, `+605` зелёных — **то же число, что
на шаге 1**. Рефакторинг, меняющий число, рефакторингом не был.

- [ ] **Шаг 6: коммит**

```bash
git add lib/src/parsing/parser/parser.dart
git commit -m "refactor: a piece becomes current through one door"
```

Тело коммита — почему: два места держали одно состояние, а правка,
которая идёт следом, читает это состояние и заслуживает одного места
вместо двух.

---

### Задание 2: обход отвечает, знает ли он про коды за своим куском

Здесь чинится сам дефект. Тесты пишутся до правки и обязаны краснеть.

**Файлы:**
- Правится: `lib/src/parsing/parser/parser.dart` — геттер в `_Walk`
  (перед дартдоком `isSpent`, `parser.dart:1244`), охранник в `_seamAt`
  (`parser.dart:890-900`), дартдок `lastCode` (`parser.dart:1171-1177`)
- Дополняется: `test/parser_insert_test.dart` — два теста после
  `a slice leaves the walk answering as a fresh parser would`
  (заканчивается на `test/parser_insert_test.dart:486`)

**Интерфейс:**
- Потребляет: `_Walk.takePiece` из задания 1 — только тем, что не ломает
  его; правка задания 2 его не трогает.
- Даёт: `bool get _Walk.codesStopAtPiece` — читает только `_seamAt`.

- [ ] **Шаг 1: написать два падающих теста**

Вставить в `test/parser_insert_test.dart` сразу после теста `a slice
leaves the walk answering as a fresh parser would`, внутри той же
группы:

```dart
    test('a slice does not let an insertion into the sequence it read past',
        () {
      // There is nothing behind the last piece of this input but codes, and
      // the slice reads them all: the walk it leaves behind names a code that
      // stands past the piece rather than the one in front of it. Read that
      // way, the seam falls among the parameters of the truncated CSI, the
      // marker becomes the final byte the CSI was waiting for, and the input
      // comes back shorter than it went in.
      const input = 'aa\x1B[31\x1B[31\x1BPpay\x1B';

      for (final after in [true, false]) {
        final parser = Parser(input)..substring(5, maxLength: 1);

        expect(
          () => after
              ? parser.insertAfter(5, '@')
              : parser.insertBefore(5, '@'),
          throwsA(
            isA<UnfinishedSequenceException>()
                .having((e) => e.offset, 'offset', 6),
          ),
          reason: 'the same refusal a fresh parser gives, after: $after',
        );
      }
    });

    test('a spent walk does not lose the refusal a fresh one gives', () {
      // Three ways to spend a walk on the same string: a slice of the whole
      // of it reads to the end by definition, and stateAt or linkAt asked
      // about the position behind the last piece of text walk the rest of the
      // string looking for one more piece and find none.
      const input = '\x1B[31\x1B]0;title';

      for (final warm in <void Function(Parser)>[
        (parser) => parser.substring(0),
        (parser) => parser.stateAt(2),
        (parser) => parser.linkAt(2),
      ]) {
        for (final after in [true, false]) {
          final parser = Parser(input);
          warm(parser);

          expect(
            () => after
                ? parser.insertAfter(1, '@')
                : parser.insertBefore(1, '@'),
            throwsA(
              isA<UnfinishedSequenceException>()
                  .having((e) => e.offset, 'offset', 0),
            ),
            reason: 'text inside the parameters of a CSI that never got its '
                'final byte, after: $after',
          );
        }
      }
    });
```

Ожидания сняты пробником на базе `8496255`: свежий парсер отказывает на
`offset 6` в первом входе (обе вставки, `pos 5`) и на `offset 0` во
втором (обе вставки, `pos 1`); прогретый на базе возвращает
`aa\x1B[31\x1B[3@1\x1BPpay\x1B` и `\x1B[3@1\x1B]0;title` соответственно,
одинаково для всех трёх прогревов.

- [ ] **Шаг 2: убедиться, что оба падают**

```bash
dart test test/parser_insert_test.dart 2>&1 | tail -3
```

Ожидается: `-2` — оба теста красные, и красные тем, что вместо
исключения вернулась строка. Вывод падения записать в отчёт: это замер,
а не формальность.

- [ ] **Шаг 3: завести геттер в `_Walk`**

Вставить перед дартдоком поля `isSpent` (`parser.dart:1244`, сразу за
полем `beforeRun`):

```dart
  /// Whether what the walk knows of escape codes speaks of the place in front
  /// of [current], rather than of somewhere it has since gone on to.
  ///
  /// [lastCode] and the fields of the run it ends are kept for two readers,
  /// and only one of them is served by every walk. Two callers take a walk
  /// past its piece: `substring` steps over the matches itself and reads on
  /// past the piece it stops in — a slice of the whole string reads to the
  /// end of them — and `stateAt` asked about the position behind the last
  /// piece of text walks the rest of the string looking for one more.
  ///
  /// A seam read off such a walk is read off nothing. The guard in `_seamAt`
  /// asks whether [lastCode] ends where the piece begins, and a code taken
  /// past the piece begins at or after the end of it; matches tile the input,
  /// so that equality cannot come out true. The guard does not fire, and the
  /// insertion lands among bytes a terminal is still reading instead of being
  /// refused.
  ///
  /// Asked here rather than kept in a field of its own on purpose. A field
  /// would have to be cleared wherever a piece becomes current, and a
  /// clearing forgotten there costs nothing but speed — the walk stops being
  /// picked up at all — which no test of this package would notice: measured
  /// by mutation, all 605 of them stay green.
  bool get codesStopAtPiece {
    final piece = current;
    final code = lastCode;

    return piece == null || code == null || code.end <= piece.start;
  }
```

- [ ] **Шаг 4: поставить охранник в `_seamAt`**

Было (`parser.dart:890-895`):

```dart
    // A seam is looked for in the pieces of text and nowhere else, so a walk
    // that has run out of matches is picked up as readily as one standing in
    // the middle of the string.
    final _Walk<S> walk;
    var standing = false;
    if (_walk case final resumable? when resumable.resumesAt(pos)) {
```

Стало:

```dart
    // A seam is looked for in the pieces of text and nowhere else, so a walk
    // that has run out of matches is picked up as readily as one standing in
    // the middle of the string — so long as what it knows of the codes still
    // speaks of the place in front of its piece. Where it does not, the seam
    // would be read off it silently: see [_Walk.codesStopAtPiece]. Such a
    // walk is dropped and the string walked again, which is what a parser
    // asked nothing before this does anyway.
    final _Walk<S> walk;
    var standing = false;
    if (_walk case final resumable?
        when resumable.codesStopAtPiece && resumable.resumesAt(pos)) {
```

- [ ] **Шаг 5: поправить дартдок `lastCode`**

Было (`parser.dart:1171-1177`):

```dart
  /// The last escape code standing in front of [current], where one does.
  ///
  /// A walk picked up at [current] never sees what came before it, and
  /// `substring` closes the slice on the last match it went past. That match
  /// is this one, kept so that resuming answers as walking from the start
  /// would.
  Match<S>? lastCode;
```

Стало:

```dart
  /// The last escape code the walk went past.
  ///
  /// Two things are read off it, and only one of them is true of every walk.
  /// `substring` closes a slice on the last match it went past and picks the
  /// slice up again on it — that is this one, wherever it stands. `_seamAt`
  /// asks it what stands in front of [current], which holds only while the
  /// walk has gone past nothing else: see [codesStopAtPiece], which says why
  /// the difference cannot be seen without asking for it.
  Match<S>? lastCode;
```

- [ ] **Шаг 6: убедиться, что оба теста позеленели**

```bash
dart test test/parser_insert_test.dart 2>&1 | tail -1
```

Ожидается: `All tests passed!`.

- [ ] **Шаг 7: весь набор и ворота**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test 2>&1 | tail -1
```

Ожидается: `+607` зелёных — 605 базовых плюс два новых. Ни один
существующий тест падать не должен: обе проверенные на копии формы
починки оставляли набор зелёным.

- [ ] **Шаг 8: коммит**

```bash
git add lib/src/parsing/parser/parser.dart test/parser_insert_test.dart
git commit -m "fix: a walk that read past its piece is not picked up for a seam"
```

Тело — почему: одно поле несло две повинности, охранник сравнивал не с
тем кодом, равенство было недостижимо арифметически, и потому отказ
пропадал молча.

---

### Задание 3: инвариант, который поймает следующую дыру того же рода

Точечные тесты держат две клетки, которые мы уже нашли. Инвариант держит
свойство.

**Файлы:**
- Создаётся: `test/warm_walk_invariant_test.dart`

- [ ] **Шаг 1: написать файл целиком**

Корпус свой, а не общий с `insert_unfinished_invariant_test.dart`: этому
инварианту нужны входы, где коды стоят **за** последним куском текста —
именно они уводят обход за свой кусок. Файл прогонялся на копии пакета:
зелёный с починкой, красный без неё.

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// Inputs with escape codes standing behind the last piece of text, which is
/// what takes a walk past the piece it stands in: a slice reads on to the end
/// of the matches, and `stateAt` asked about the position behind the text
/// walks the rest of the string looking for one more piece. Ordinary strings
/// stand beside them for company.
const _inputs = <String>[
  'aa\x1B[31\x1B[31\x1BPpay\x1B',
  '\x1B[31\x1B]0;title',
  'aa\x1B[31\x1B]0;title',
  'aa\x1B]0;title',
  'aa\x1B',
  'aa\x1B[31',
  'aa\x1B[31mbb',
  'aa\x1B[31m\x1B[0mbb\x1B[',
  'aa\x1BPpay\x1B[31cc',
  'aa\x1B[31cc\x1BPpay',
  'aa\x1B[31\x1B(Bcc\x1B[',
  'aa\x1B]0;title\x1B(Bcc',
  'aa\x1B\n\x1BPpay\x1B',
  'aa\x1B(я\x1B[31',
  'aa\x1B[31m\x1B]8;;http://u/\x1B[',
  'aa\x1B]8;;http://o/\x1B\\\x1BPpay',
  'aa\x1B]8;;http://u/\x1B\\bb\x1B]8;;\x1B\\cc',
  '\x1BPpay\x1Baa\x1B[31',
  'aabb',
  '',
];

/// The text the insertions put in.
///
/// `X` opens an `SOS` where it lands behind an `ESC`, and would fuse with the
/// inputs instead of marking a place in them; `@` opens nothing. See
/// `insert_unfinished_invariant_test.dart`, which says the whole of it.
const _marker = '@';

/// The questions a parser is asked about a position.
const _questions = <String>[
  'substring',
  'substring maxLength: 1',
  'substring close: false',
  'stateAt',
  'linkAt',
  'insertBefore',
  'insertAfter',
];

/// The questions that leave a walk behind for the next one to pick up.
const _warmups = <String>[
  'substring',
  'substring maxLength: 1',
  'stateAt',
  'linkAt',
];

/// The answer [parser] gives to [question] at [pos], or the refusal it gives
/// instead, in a form two parsers can be compared and told apart by.
///
/// Strings are read out as code units on purpose: a raw C1 byte is one a
/// terminal does not draw, and a failure printing the strings as they are
/// would show two different answers looking the same. Links are read out by
/// their bytes for the same reason — two links on one url are told apart by
/// the parameters and the terminator they were written with, and by nothing
/// else.
String _ask(String question, Parser parser, int pos) {
  try {
    return switch (question) {
      'substring' => 'ok ${parser.substring(pos).codeUnits}',
      'substring maxLength: 1' =>
        'ok ${parser.substring(pos, maxLength: 1).codeUnits}',
      'substring close: false' =>
        'ok ${parser.substring(pos, close: false).codeUnits}',
      'stateAt' => 'ok ${parser.stateAt(pos)}',
      'linkAt' => 'ok ${parser.linkAt(pos)?.string.codeUnits}',
      'insertBefore' => 'ok ${parser.insertBefore(pos, _marker).codeUnits}',
      'insertAfter' => 'ok ${parser.insertAfter(pos, _marker).codeUnits}',
      _ => throw StateError('unknown question: $question'),
    };
  } on UnfinishedSequenceException catch (e) {
    return 'refused at ${e.offset}';
  } on RangeError {
    return 'out of range';
  }
}

void main() {
  test('a warmed parser answers as a fresh one would', () {
    for (final input in _inputs) {
      final plain = Parser(input).removeAll();

      for (final question in _questions) {
        for (var pos = 0; pos <= plain.length; pos++) {
          final fresh = _ask(question, Parser(input), pos);

          for (final warmup in _warmups) {
            for (var at = 0; at <= plain.length; at++) {
              final parser = Parser(input);
              if (_ask(warmup, parser, at) == 'out of range') {
                continue;
              }

              expect(
                _ask(question, parser, pos),
                fresh,
                reason: 'input ${input.ansiShowEscapeSequences()}: '
                    '$question at $pos, asked after $warmup at $at',
              );
            }
          }
        }
      }
    }
  });
}
```

- [ ] **Шаг 2: прогнать — должен быть зелёным**

```bash
dart test test/warm_walk_invariant_test.dart 2>&1 | tail -1
```

Ожидается: `All tests passed!`. Починка уже стоит, инвариант её застаёт.

- [ ] **Шаг 3: две мутации — доказать, что инвариант не декоративен**

Тест, написанный после починки, обязан доказать, что он её держит.
Каждую мутацию внести, прогнать **только этот файл**, записать вывод и
откатить. **Мутация, описанная прозой, может не мутировать** — сперва
убедиться, что тест покраснел, и только потом судить о тесте.

Обе мутации проверены на копии пакета, ожидания ниже — замеренные.

| мутация | что править | ожидание |
|---|---|---|
| A: охранник снят | в `_seamAt` убрать `resumable.codesStopAtPiece && ` | **красный**: `Expected: 'refused at 6'`, вход `aa[ESC []31[ESC []31[DCS pay ][ESC]`, `insertBefore at 5, asked after substring at 0` |
| B: условие вывернуто | в геттере заменить `code.end <= piece.start` на `code.end >= piece.start` | **красный** |

- [ ] **Шаг 4: записать, чего инвариант не ловит**

Третья мутация проверена и **зелёная**: замена `piece.start` на
`pieceStart` — смещение в строке на позицию в плоском тексте. Она делает
условие строже (плоская позиция не больше смещения, коды только
добавляют байты), обход перезапускается чаще нужного, и это медленнее,
но не неверно.

Это честная граница инварианта, а не его дыра: тест на согласие
прогретого со свежим не может поймать лишнюю осторожность, потому что
лишняя осторожность даёт тот же ответ. Записать в отчёт одной строкой и
не пытаться закрыть здесь.

- [ ] **Шаг 5: восстановить код и прогнать всё**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test 2>&1 | tail -1
```

Ожидается: `+608` зелёных.

- [ ] **Шаг 6: коммит**

```bash
git add test/warm_walk_invariant_test.dart
git commit -m "test: a warmed parser answers as a fresh one would"
```

Тело — почему инвариант шире вставок: прозрачность прогрева есть
свойство всех позиционных вопросов, и сеть, растянутая на все семь,
поймает следующую дыру того же рода, а не только эту.

---

### Задание 4: ворота и замер

Коммита у задания нет, если ворота ничего не потребовали. Его продукт —
числа в отчёте.

**Файлы:** ни один не правится (кроме случая, когда ворота потребуют).

- [ ] **Шаг 1: полный список ворот**

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

Ожидается: формат и анализ чисты; входы на месте; генератор не даёт
дифа; `+608`; `memory_guard` в полосе 159…332 (на базе 259.4);
`dart doc` 0 ошибок и 0 предупреждений; `publish --dry-run` 0
предупреждений.

- [ ] **Шаг 2: замерить, чего стоит перезапуск обхода**

```bash
dart run benchmark/parser_benchmark.dart
```

Прогнать на `main` @ `8496255` и на вершине ветки, привести обе колонки.
Ожидание: движения нет или оно в шуме — геттер считает два сравнения, а
перезапуск случается там, где прежде отвечали неверно. **Если вставки
заметно просели** — не объяснять это шумом, а показать, на каком входе,
и вынести в отчёт.

- [ ] **Шаг 3: записать числа**

Все числа шагов 1-2 — в отчёт волны. Число без корпуса непроверяемо:
рядом с каждым сказать, на чём снято.

---

### Задание 5: закрыть две находки в handoff'е

**Файлы:**
- Правится: `docs/handoff.md` — разделы «Прогретый обход отвечает иначе
  свежего парсера и теряет байты» и «Прогретый обход обходит
  документированный отказ» внутри «Найдено волнами»

- [ ] **Шаг 1: проверить CHANGELOG чтением**

```bash
grep -n 'Unfinished\|unfinished' CHANGELOG.md | head
```

Убедиться, что отказ описан в неизданной записи 4.0.0 и что правки не
требуется. **Если окажется, что запись описывает поведение неверно** —
сказать об этом в отчёте и остановиться: правка CHANGELOG за пределами
плана.

- [ ] **Шаг 2: снять два закрытых раздела**

Обе находки убрать из «Найдено волнами» целиком: они закрыты, а раздел
описывает открытое. Взамен — строка в разделе «Чего не переоткрывать»,
таблица закрытых пунктов:

```markdown
| прогретый обход отвечал иначе свежего: вставка теряла байты и обходила отказ | `2026-08-13[1]` |
```

- [ ] **Шаг 3: дополнить строку про волны**

В таблицу «Чем пакет занимался последние дни» добавить строку; хеш мержа
проставляется после мержа, отдельным коммитом на `main`:

```markdown
| Прогретый обход отвечает как свежий | `2026-08-13[1]`, `[2]` | — |
```

- [ ] **Шаг 4: записать находку про стража**

В «Найдено волнами» — новый короткий раздел: `performance_guards_test.dart`
держит линейность разбора и нарезки, но **серию вставок не держит
никто** (`grep insert` по файлу — ноль совпадений). Волна на это
наткнулась мутацией и обошла стороной, заменив поле производным
вопросом; для владельца это уборка на будущее, а не долг этой волны.

- [ ] **Шаг 5: коммит**

```bash
git add docs/handoff.md
git commit -m "docs: two findings the wave closed leave the open list"
```

---

## Самопроверка плана против спеки

| требование спеки (с поправкой в шапке) | где закрыто |
|---|---|
| производный `codesStopAtPiece` вместо поля со сбросом | задание 2, шаг 3 |
| `_seamAt` поднимает обход только при истинном геттере | задание 2, шаг 4 |
| `_Walk.takePiece` сводит два места в одно (уборка рядом) | задание 1, шаги 2-4 |
| дартдок `lastCode` называет обе повинности | задание 2, шаг 5 |
| новый `test/warm_walk_invariant_test.dart`, корпус в тесте | задание 3, шаг 1 |
| два именованных теста на оба репро | задание 2, шаг 1 |
| тесты первыми, красные до правки | задание 2, шаги 1-2; для инварианта — мутации, задание 3, шаг 3 |
| ворота, `memory_guard`, бенчмарк вставок | задание 4 |
| CHANGELOG проверить чтением, не править | задание 5, шаг 1 |
| `finalState`/`finalLink`, дартдок `insertAfter`, шесть мест — не трогать | ни одно задание их не касается |

## Порядок после заданий

1. Финальное ревью всей ветки — отдельным заходом, по дифу
   `8496255..HEAD`, а не по заданиям: прошлая волна поймала дефект
   дартдока только так.
2. `git push -u origin fix/warm-walk-seam` и **ожидание зелёного CI на
   обеих ногах SDK**. Нижняя нога `3.6.0` локально не гоняется вовсе, и
   это единственное место, где проверяется объявленный floor.
3. `git checkout main && git merge --no-ff fix/warm-walk-seam`,
   `git push origin main`.
4. Проставить хеш мержа в таблицу `docs/handoff.md` и переписать handoff
   под новое состояние; отработавший — в `docs/records/`.
5. Публикация и тег `v4.0.0` — **не в этой волне**: ждут слова
   владельца, как ждали с 2026-08-05.
