# План: вставка рядом с незавершённой последовательностью

> **Состояние на 2026-08-16:** выполнен и влит в `main` мержем `00fe2ca`.
> Позже пересмотрен: место шва, которое этот план ставил, оказалось
> неверным — волна `2026-08-12[3]`/`[4]` (мерж `41068fd`) сдвинула шов к
> началу всей череды незавершённых кодов и сделала отказ симметричным для
> `insertBefore` и `insertAfter`. Номера строк даны по базе `6586562` и
> поехали.
> **Что это:** план реализации: `_seamAt` перестаёт ставить шов внутрь
> незавершённой последовательности, отказывая `UnfinishedSequenceException`
> там, где перенос невозможен.
> **Связанные записи:**
> `2026-08-11[2]-insert-unfinished-sequence-design.md`,
> `2026-08-12[4]-unfinished-run-seam-plan.md`.

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Вставка никогда не попадает внутрь байтов, которые терминал
прочитает как одну незавершённую последовательность: где это можно
исправить переносом среза — переносит, где нельзя — отказывает
`UnfinishedSequenceException`.

**Architecture:** Вся правка — в `_seamAt` (`lib/src/parsing/parser/parser.dart`),
который обслуживает оба метода вставки и уже возвращает тройку «срез,
состояние, ссылка». Добавляется приватный предикат «код не закончен» и две
проверки: одна в ветке, где срез ищется внутри куска текста, другая в
возврате `input.length`. Новый публичный класс исключения живёт отдельным
файлом, чтобы его можно было экспортировать из `extensions.dart`, не
затаскивая туда весь парсер.

**Tech Stack:** Dart ^3.6.0, `package:test`, встроенные ворота репозитория.

## Global Constraints

- **Ожидаемые значения в тестах ниже сняты пробником с живого кода
  2026-08-11.** Если тест падает не так, как здесь написано, — разбираться,
  а **не** подгонять тест под поведение.
- Версию в `pubspec.yaml` не бампать; 4.0.0 не публиковать.
- Один фикс — один коммит, conventional-префикс, тело по-английски.
- Ворота перед каждым коммитом: `dart format --output=none
  --set-exit-if-changed .`, `dart analyze --fatal-infos`, `dart test`.
- Публичный API растёт ровно на один класс — `UnfinishedSequenceException`.
- Строки в `.dart` — не длиннее 80 символов (`dart format` + `analyze`).

---

## Задача 1: класс исключения и три точки входа

**Files:**
- Create: `lib/src/parsing/parser/unfinished_sequence_exception.dart`
- Modify: `lib/src/parsing/parser/parser.dart` (импорт рядом с прочими)
- Modify: `lib/extensions.dart` (новый экспорт)
- Test: `test/entry_point_extensions_test.dart`,
  `test/entry_point_style_test.dart`

**Interfaces:**
- Produces: `UnfinishedSequenceException({required int pos, required int
  offset})` с полями `pos`, `offset` и `toString()`. Задачи 2 и 3 бросают
  именно его.

`ansi_escape_codes.dart` и `style.dart` уже экспортируют
`src/parsing/parser/parser.dart`, но исключение лежит **не** в его частях —
значит экспортировать надо явно во всех трёх точках. В `extensions.dart`
экспортировать сам `parser.dart` нельзя: точка входа держит 7 имён, а
принесла бы около восьмидесяти.

- [ ] **Шаг 1: падающий тест на имя в `extensions.dart`**

В конец `test/entry_point_extensions_test.dart`, внутрь `main()`:

```dart
  test('the extensions entry point names the exception its insertions throw',
      () {
    expect(
      UnfinishedSequenceException(pos: 2, offset: 2),
      isA<Exception>(),
      reason: 'the two insertions throw it, and it has to be nameable here',
    );
  });
```

- [ ] **Шаг 2: убедиться, что падает**

Run: `dart test test/entry_point_extensions_test.dart`
Expected: FAIL — `Undefined name 'UnfinishedSequenceException'`.

- [ ] **Шаг 3: написать класс**

Создать `lib/src/parsing/parser/unfinished_sequence_exception.dart`:

```dart
/// Thrown where an insertion would land inside a control sequence the
/// parser could not finish.
///
/// The string ends — or runs on to the next `ESC` — in the middle of a
/// sequence: an `OSC` that never got its terminator, a bare `ESC`, a `CSI`
/// with no final byte, an `ESC` with intermediate bytes and nothing to
/// close them. The bytes that follow such a sequence belong to it as far
/// as a terminal is concerned, whatever this package calls them, so text
/// put among them would be read as parameters rather than shown.
///
/// Where the insertion is aimed at the seam in front of the sequence, it
/// is placed there and nothing is thrown: see [Parser.insertBefore] and
/// [Parser.insertAfter]. This is for the positions past that seam, where
/// no answer is right — putting the text in front of the sequence would
/// move it before characters the caller counted before it, and leaving it
/// where it was asked for would make it part of the sequence.
///
/// It is an [Exception] and not an [Error] on purpose: the position is
/// within the plain text, it is the input that is cut short, and the
/// caller has no way of knowing it in advance. A position outside the
/// plain text is a different matter and still throws a [RangeError].
final class UnfinishedSequenceException implements Exception {
  /// Creates an exception for the insertion at [pos] refused by the
  /// sequence beginning at [offset].
  const UnfinishedSequenceException({required this.pos, required this.offset});

  /// The position in the plain text the insertion was aimed at.
  final int pos;

  /// Where the sequence begins in the string being read, so that a
  /// complaint can point at the bytes it is about — the way [Match.start]
  /// does.
  final int offset;

  @override
  String toString() => 'UnfinishedSequenceException: the text at $pos would '
      'land inside the unfinished sequence at $offset';
}
```

- [ ] **Шаг 4: экспортировать из трёх точек входа**

В `lib/extensions.dart` добавить строкой, по алфавиту среди `src/parsing`:

```dart
export 'src/parsing/parser/unfinished_sequence_exception.dart';
```

В `lib/ansi_escape_codes.dart` и `lib/style.dart` — ту же строку рядом с
`export 'src/parsing/parser/parser.dart';`.

В `lib/src/parsing/parser/parser.dart` добавить импорт рядом с остальными
относительными импортами:

```dart
import 'unfinished_sequence_exception.dart';
```

- [ ] **Шаг 5: тест на имя в `style.dart`**

В `test/entry_point_style_test.dart`, в конец существующего теста:

```dart
    expect(
      UnfinishedSequenceException(pos: 0, offset: 0),
      isA<Exception>(),
      reason: 'the parser lives here, and so does what its insertions throw',
    );
```

- [ ] **Шаг 6: ворота и коммит**

Run: `dart format --output=none --set-exit-if-changed . && dart analyze
--fatal-infos && dart test`
Expected: всё зелёное, тестов на два больше прежнего.

```bash
git add lib/src/parsing/parser/unfinished_sequence_exception.dart \
        lib/src/parsing/parser/parser.dart lib/extensions.dart \
        lib/ansi_escape_codes.dart lib/style.dart \
        test/entry_point_extensions_test.dart test/entry_point_style_test.dart
git commit -m "feat: the insertions get an exception for what cannot be answered"
```

---

## Задача 2: предикат и конец строки

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart` (`_seamAt`, новый `_unfinished`)
- Test: `test/parser_insert_test.dart`

**Interfaces:**
- Consumes: `UnfinishedSequenceException` из задачи 1.
- Produces: `bool _unfinished(Entity entity)` — приватная функция уровня
  файла рядом с `_isHighSurrogate`; задача 3 зовёт её же.

Ветка возврата `input.length`: вход кончается байтами незавершённого кода.

- [ ] **Шаг 1: падающие тесты**

Новая группа в конец `test/parser_insert_test.dart`, внутрь `main()`:

```dart
  group('inserting where the string ends inside a sequence:', () {
    test('the text goes in front of what never finished', () {
      expect(
        Parser('aa\x1B]0;title').insertAfter(2, 'X'),
        'aaX\x1B]0;title',
        reason: 'the tail is copied as it came, the text lands before it',
      );
      expect(
        Parser('aa\x1B').insertAfter(2, 'X'),
        'aaX\x1B',
        reason: 'a bare ESC cannot be finished, so nothing is written for it',
      );
      expect(
        Parser('aa\x1B[').insertAfter(2, 'X'),
        'aaX\x1B[',
      );
      expect(
        Parser('aa\x1B(').insertAfter(2, 'X'),
        'aaX\x1B(',
        reason: 'an ESC waiting for a final byte takes the insertion no more '
            'than a CSI does',
      );
    });

    test('and the hyperlink opening keeps the text outside it', () {
      final inserted = Parser('aa\x1B]8;;http://a/').insertAfter(2, 'X');

      expect(inserted, 'aaX\x1B]8;;http://a/');
      expect(
        Parser(inserted).linkAt(2),
        isNull,
        reason: 'the opening still stands after the text, not around it',
      );
    });

    test('while a finished tail is still passed by', () {
      expect(
        Parser('aa\x1B]0;t\x1B\\').insertAfter(2, 'X'),
        'aa\x1B]0;t\x1B\\X',
        reason: 'a terminated OSC ends where it says, and insertAfter goes '
            'past it as it always did',
      );
    });
  });
```

- [ ] **Шаг 2: убедиться, что падают именно так**

Run: `dart test test/parser_insert_test.dart`
Expected: первые три теста падают, четвёртый проходит. Падения:
`'aa\x1B]0;titleX'` вместо `'aaX\x1B]0;title'`, `'aa\x1BX'` вместо
`'aaX\x1B'`, `'aa\x1B[X'` вместо `'aaX\x1B['`, `'aa\x1B(X'` вместо
`'aaX\x1B('`; в ссылочном тесте `linkAt(2)` отдаёт `http://a/`.

- [ ] **Шаг 3: написать предикат**

В конец `lib/src/parsing/parser/parser.dart`, рядом с `_isHighSurrogate`:

```dart
/// Whether the parser could not finish this escape code, so that the bytes
/// written after it are read as part of it.
///
/// An `OSC` without its terminator runs to the next `ESC` or to the end of
/// the text; a bare `ESC`, a `CSI` with no final byte and an `ESC` left on
/// an intermediate byte are all waiting for the byte that ends them, and
/// whatever is written next supplies it. Everything else stands finished:
/// `ESC 7` is a save, `CSI 31 m` is a colour, and text put behind either is
/// text.
bool _unfinished(Entity entity) => switch (entity) {
      Osc() => !_oscTerminated(entity.string),
      Esc() => entity.string == ESC ||
          entity.string == CSI ||
          _isIntermediate(entity.string.codeUnitAt(entity.string.length - 1)),
      _ => false,
    };

/// Whether [codeUnit] is an intermediate byte of an escape sequence, which
/// cannot end one: `ECMA-48` gives them the range `02/00` to `02/15`.
bool _isIntermediate(int codeUnit) => codeUnit >= 0x20 && codeUnit <= 0x2F;
```

- [ ] **Шаг 4: правка ветки конца строки**

В `_seamAt` заменить последний `return`:

```dart
    return (input.length, finalState, finalLink);
```

на:

```dart
    // The walk is spent, and the string may end inside a sequence that never
    // finished: there the cut would fall among bytes a terminal reads as
    // that sequence, and the text would be read as its parameters. The
    // insertion goes in front of the sequence instead — no byte of the input
    // is invented, and the state and the link are the ones that stood before
    // it, which for a hyperlink opening means outside the link it opens.
    if (walk.lastCode case final code? when _unfinished(code.entity)) {
      // Everything past the last code is plain text, so the sequence runs to
      // the end of the input and the seam is that much before the end.
      final seam = walk.passed - (input.length - code.end);
      if (pos > seam) {
        throw UnfinishedSequenceException(pos: pos, offset: code.start);
      }

      return (
        code.start,
        walk.current?.state ?? initialState,
        walk.current?.link ?? initialLink,
      );
    }

    return (input.length, finalState, finalLink);
```

- [ ] **Шаг 5: прогнать тесты задачи**

Run: `dart test test/parser_insert_test.dart`
Expected: PASS, все четыре.

- [ ] **Шаг 6: прогнать всю сюиту**

Run: `dart test`
Expected: PASS. Если падает что-то из `parser_insert_links_test.dart` или
`osc_termination_test.dart` — читать падение, а не править ожидание: это
поведение, которое волна не собиралась менять.

- [ ] **Шаг 7: ворота и коммит**

```bash
git add lib/src/parsing/parser/parser.dart test/parser_insert_test.dart
git commit -m "fix: an insertion at the end of a cut-short string goes in front of the tail"
```

---

## Задача 3: фиктивный текст за оборванным `CSI`

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart` (`_seamAt`, ветка внутри куска)
- Test: `test/parser_insert_test.dart`

**Interfaces:**
- Consumes: `_unfinished` из задачи 2, `UnfinishedSequenceException` из
  задачи 1.

Параметры оборванного `CSI` парсер отдаёт текстом. Вставка в шов перед ними
обслуживается, вставка внутрь них — отказ, и для обоих методов.

- [ ] **Шаг 1: падающие тесты**

Новая группа в конец `test/parser_insert_test.dart`:

```dart
  group('inserting among the parameters of a CSI with no final byte:', () {
    test('the seam in front of it takes the text', () {
      expect(
        Parser('aa\x1B[31').insertAfter(2, 'X'),
        'aaX\x1B[31',
        reason: 'the position is the seam, and in front of the sequence is '
            'where the text was asked to go',
      );
      expect(
        Parser('aa\x1B[31').insertBefore(2, 'X'),
        'aaX\x1B[31',
        reason: 'insertBefore already stood there and stays where it was',
      );
    });

    test('and every position past it is refused', () {
      expect(
        () => Parser('aa\x1B[31').insertAfter(3, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
      );
      expect(
        () => Parser('aa\x1B[31').insertAfter(4, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
      );
      expect(
        () => Parser('aa\x1B[31').insertBefore(3, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
      );
      expect(
        () => Parser('aa\x1B[31').insertBefore(4, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
      );
    });

    test('the exception says where the sequence begins', () {
      try {
        Parser('aa\x1B[31').insertAfter(3, 'X');
        fail('the insertion was expected to be refused');
      } on UnfinishedSequenceException catch (e) {
        expect(e.pos, 3);
        expect(e.offset, 2, reason: 'the ESC of the sequence stands at 2');
      }
    });

    test('while a code after the parameters puts the end back in reach', () {
      expect(
        Parser('aa\x1B[31\x1B[0m').insertAfter(4, 'X'),
        'aa\x1B[31\x1B[0mX',
        reason: 'the cut goes past the SGR, outside the sequence, and that '
            'was right before this wave and stays right',
      );
      expect(
        () => Parser('aa\x1B[31\x1B[0m').insertBefore(4, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
        reason: 'insertBefore puts the cut against the parameters instead',
      );
    });

    test('and a CSI that did get its final byte is untouched', () {
      expect(
        Parser('aa\x1B[31bb').insertAfter(2, 'X'),
        'aa\x1B[31bXb',
        reason: 'b is a final byte, so the sequence is finished, the text '
            'after it is text, and the insertion goes past the code',
      );
    });
  });
```

- [ ] **Шаг 2: убедиться, что падают**

Run: `dart test test/parser_insert_test.dart`
Expected: падают четыре теста из пяти, проходит последний. Сегодняшние
ответы: `insertAfter(2)` → `'aa\x1B[X31'` (первый тест падает на первом же
`expect`, второй его `expect` — `insertBefore(2)` — уже верен);
`insertAfter(3)` → `'aa\x1B[3X1'`; исключений не бросается ни одного, так
что второй и третий тесты падают целиком; в четвёртом `insertAfter(4)` уже
верен, а `insertBefore(4)` отдаёт `'aa\x1B[31X\x1B[0m'` вместо броска.

- [ ] **Шаг 3: правка ветки внутри куска**

В `_seamAt`, сразу после проверки суррогатной пары и перед
`return (cut, m.state, m.link);`:

```dart
        // The piece may be the parameters of a `CSI` that never got its
        // final byte: the parser hands them back as text, a terminal reads
        // them as part of the sequence, and a cut among them makes the
        // inserted text its final byte. In front of the sequence is served —
        // that is where the seam is — and anything past the seam is not:
        // moving the text there would put it before characters the caller
        // counted in front of it.
        if (walk.lastCode case final code?
            when code.end == m.start && _unfinished(code.entity)) {
          if (pos > plainPos) {
            throw UnfinishedSequenceException(pos: pos, offset: code.start);
          }

          return (code.start, m.state, m.link);
        }
```

- [ ] **Шаг 4: прогнать тесты задачи**

Run: `dart test test/parser_insert_test.dart`
Expected: PASS, все пять.

- [ ] **Шаг 5: вся сюита и ворота**

Run: `dart test && dart format --output=none --set-exit-if-changed . && dart
analyze --fatal-infos`
Expected: зелено.

- [ ] **Шаг 6: коммит**

```bash
git add lib/src/parsing/parser/parser.dart test/parser_insert_test.dart
git commit -m "fix: an insertion among the parameters of an unfinished CSI is refused"
```

---

## Задача 4: исчерпывающая проба и регрессионные пины

**Files:**
- Create: `test/insert_unfinished_invariant_test.dart`

**Interfaces:**
- Consumes: поведение задач 2 и 3.

Инвариант: для любой формы и любой позиции вставка либо даёт плоский текст
со вставкой ровно на месте `pos`, либо бросает
`UnfinishedSequenceException`. Третьего не дано — сегодня третье как раз и
случается.

- [ ] **Шаг 1: написать тест**

Создать `test/insert_unfinished_invariant_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// Inputs whose tails a terminal reads differently from the way the parser
/// hands them back, and ordinary ones beside them for company.
const _inputs = <String>[
  'aa\x1B]0;title',
  'aa\x1B]8;;http://a/',
  'aa\x1B',
  'aa\x1B[',
  'aa\x1B[31',
  'aa\x1B(',
  'aa\x1B#',
  'aa\x1B[31\x1B[0m',
  'aa\x1B[31\x1B[0mcc',
  'aa\x1B]0;t\x1B\\',
  'aa\x1B]0;t\x1B7bb',
  'aa\x1B[31bb',
  'aa\x1B[31m bb \x1B[0m',
  'aa',
  '',
];

void main() {
  test('an insertion either lands where it was asked or is refused', () {
    for (final input in _inputs) {
      final plain = Parser(input).removeAll();
      for (var pos = 0; pos <= plain.length; pos++) {
        for (final after in [true, false]) {
          final parser = Parser(input);
          final String result;
          try {
            result = after
                ? parser.insertAfter(pos, 'X')
                : parser.insertBefore(pos, 'X');
          } on UnfinishedSequenceException {
            continue;
          }

          expect(
            Parser(result).removeAll(),
            '${plain.substring(0, pos)}X${plain.substring(pos)}',
            reason: 'input ${input.ansiShowEscapeSequences()}, pos $pos, '
                'after: $after',
          );
        }
      }
    }
  });

  test('and what it hands back is the input with the text put in', () {
    for (final input in _inputs) {
      final plain = Parser(input).removeAll();
      for (var pos = 0; pos <= plain.length; pos++) {
        final String result;
        try {
          result = Parser(input).insertAfter(pos, 'X');
        } on UnfinishedSequenceException {
          continue;
        }

        expect(
          result.replaceFirst('X', ''),
          input,
          reason: 'no byte of the input is invented or dropped: '
              '${input.ansiShowEscapeSequences()}, pos $pos',
        );
      }
    }
  });
}
```

- [ ] **Шаг 2: прогнать**

Run: `dart test test/insert_unfinished_invariant_test.dart`
Expected: PASS. Если второй тест падает на строке со ссылкой — читать
падение: `_linkBack` дописывает ссылочные байты законно, и тогда список
`_inputs` для второго теста надо сузить до входов без `OSC 8`, а не
ослаблять проверку.

- [ ] **Шаг 3: коммит**

```bash
git add test/insert_unfinished_invariant_test.dart
git commit -m "test: the insertion invariant holds over every shape and position"
```

---

## Задача 5: документация и бэклог

**Files:**
- Modify: `README.md`, `README.ru.md` (раздел про вставку и таблица имён)
- Modify: `CHANGELOG.md` (раздел `Fixed` 4.0.0)
- Modify: `lib/src/parsing/parser/parser.dart` (дартдок `insertBefore`,
  `insertAfter`)
- Modify: `docs/backlog.md`
- Modify: `docs/records/2026-08-11[2]-insert-unfinished-sequence-design.md`
  (шапка), `docs/records/2026-08-11[3]-insert-unfinished-sequence-plan.md`
  (шапка), `docs/handoff.md`

- [ ] **Шаг 1: дартдок обоих методов**

К `insertBefore` и `insertAfter` дописать абзац: вставка не попадает внутрь
последовательности, которую парсер не смог закончить; нацеленная в шов
перед такой последовательностью — встаёт перед ней; нацеленная внутрь её
байтов — бросает `UnfinishedSequenceException`; `RangeError` остаётся за
позицией вне диапазона.

- [ ] **Шаг 2: CHANGELOG**

В разделе `Fixed` найти запись про незавершённый `OSC` — ту, что кончается
словами «That is the same mechanism on a surface this release does not
reach, and it is left as it stands». Заменить это предложение: поверхность
теперь достаётся, и сказать как — вставка встаёт перед незавершённым
хвостом, а позиции среди его байтов отказываются исключением.

- [ ] **Шаг 3: README (оба)**

В разделе про `insertBefore`/`insertAfter` — абзац с примером отказа. В
таблице имён поправить счёт для `style.dart` и `extensions.dart` (было 81 и
7) и дописать в описание `extensions.dart` исключение. Точные числа снять
пробником, а не прибавлять единицу на глаз:

```bash
dart run tool/check_entry_points.dart
```

Английский — источник, русский правится тем же коммитом.

- [ ] **Шаг 4: бэклог**

Пункт про `insertAfter` вычеркнуть. Завести пункт про C1-строковые:

```markdown
- `ESC P` (DCS), `ESC X` (SOS), `ESC ^` (PM) и `ESC _` (APC) парсер читает
  как завершённые двухбайтовые escape, а стандарт — как открытие строки,
  идущей до `ST`. Терминал съест написанное за ними так же, как съедал
  текст за незавершённым `OSC`: `Parser('aa\x1BP').insertAfter(2, 'X')`
  отдаёт `aa\x1BPX`, где `X` — уже часть device control string. Правка —
  в модели разбора, а не во вставке: меняется чтение любой строки с этими
  кодами (плоский текст, длина, срезы, печать), поэтому отдельным заходом.
  Найдено волной `docs/records/2026-08-11[2]`.
```

- [ ] **Шаг 5: шапки записей и handoff**

В шапках `2026-08-11[2]` и `2026-08-11[3]` статус на «выполнен, влит в
`main` мержем `<hash>`» — хеш появится после мержа, поэтому шаг делается
последним коммитом уже на `main`. В `docs/handoff.md`: бэклог, число
тестов, `main` @ и строка про CI.

- [ ] **Шаг 6: ворота целиком и коммит**

Run: `dart format --output=none --set-exit-if-changed . && dart analyze
--fatal-infos && dart run tool/check_entry_points.dart && dart run
tool/generate.dart && git diff --exit-code -- lib/ && dart test && dart run
benchmark/memory_guard.dart && dart doc --dry-run && dart pub publish
--dry-run`
Expected: всё зелёное, `publish --dry-run` без предупреждений на чистом
дереве.

```bash
git add -A
git commit -m "docs: the fourth surface is closed, and the string openers take its place"
```

---

## Проверка плана на себе

- **Покрытие спеки.** Решение 1 (вставка перед прогоном) — задачи 2 и 3;
  решение 2 (отказ) — задача 3 и класс из задачи 1; решение 3 (без
  предпроверки) — ничего не добавляется, проверять нечего; решение 4
  (`Exception`, не `Error`) — задача 1 и пин на `RangeError` в задаче 3
  (`insertAfter(99)` не задет, потому что ветка range-проверки стоит
  раньше); решение 5 (C1-строковые в бэклог) — задача 5, шаг 4. Таблица
  «что не меняется» — задача 4, список `_inputs`.
- **Типы.** `_unfinished(Entity)` объявлен в задаче 2 и зовётся в задаче 3
  под тем же именем; `UnfinishedSequenceException({pos, offset})` объявлен
  в задаче 1 и бросается в задачах 2 и 3 с теми же именованными
  аргументами.
- **Заглушек нет.** Каждый шаг несёт код или команду.
