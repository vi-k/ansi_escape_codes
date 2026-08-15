# План: шов перед чередой незавершённых кодов

> **Состояние на 2026-08-16:** исполнен и влит в `main` мержем `41068fd`.
> Верна реализация, а не текст плана: код задания 2 здесь недостаточен
> (правило свелось к одному `_Walk.takeCode`, который зовут оба обхода), а
> запрет трогать условие отказа снят владельцем по итогам задания 2 —
> волна добавила задание 5 о симметричном отказе. Ожидания в заданиях
> читать как намерение.
> **Что это:** план реализации шва перед чередой незавершённых кодов.
> **Связанные записи:** `2026-08-12[3]-unfinished-run-seam-design.md`.

**Цель:** `insertAfter` перестаёт приземляться внутрь незавершённого
кода, когда на шве стоит череда из двух и более таких кодов.

**Устройство:** `_Walk` начинает помнить начало текущей череды
незавершённых кодов; оба места в `_seamAt`, отступающие к
`code.start`, отступают к началу череды.

**Инструменты:** Dart SDK `^3.6.0`, `package:test`.

## Общие ограничения

- **Ожидаемые значения в тестах снимаются пробником с живого кода.**
  Подгонять ожидание под вывод запрещено. Поправил — объясни в отчёте.
- **Меняется ровно одна клетка поведения** — `insertAfter` на шве с
  чередой. Всё остальное обязано остаться байт в байт, и это
  доказывается отпечатком, а не утверждается.
- Условие отказа `UnfinishedSequenceException` не трогается; `offset` в
  нём остаётся началом кода, на котором обход остановился.
- Версия не бампается; CHANGELOG правится на месте в записи `4.0.0`.
- Код, dartdoc, README, CHANGELOG, коммиты — по-английски; `docs/` —
  по-русски. `README.ru.md` правится тем же коммитом, что `README.md`.
- Один фикс — один коммит, conventional-префикс, тело повествовательное.
- Ворота перед каждым коммитом: `dart format --set-exit-if-changed`,
  `dart analyze --fatal-infos`, `dart run tool/check_entry_points.dart`,
  `dart test`. Полный набор — в задании 4.

## Что где лежит

| файл | что с ним |
|---|---|
| `test/insert_unfinished_invariant_test.dart` | правится: входы с чередой в `_inputs` |
| `test/parser_insert_test.dart` | правится: точечные тесты на шов |
| `lib/src/parsing/parser/parser.dart` | правится: `_Walk` и два места в `_seamAt` |
| `docs/`, `README*`, `CHANGELOG.md` | правятся в задании 4 |

---

## Задание 1: тесты, которые ловят дефект

**Файлы:**
- Правка: `test/insert_unfinished_invariant_test.dart`
- Правка: `test/parser_insert_test.dart`

**Интерфейсы:** ничего не производит.

- [ ] **Шаг 1: добавить входы в инвариант**

В `test/insert_unfinished_invariant_test.dart` дописать в `_inputs`:

```dart
  // Две незавершённые последовательности подряд: шов принадлежит месту
  // перед обеими, а не промежутку между ними.
  'aa\x1B]0;t\x1B[31',
  'aa\x1BPpay\x1B[31',
  'aa\x1BPpay\x1B',
  'aa\x1B\x1B[31',
  'aa\x1B(\x1B[31',
  // Череда длиннее двух.
  'aa\x1BPpay\x1B(\x1B[31',
  // Законченный код череду рвёт — вставка за ним верна и должна остаться.
  'aa\x1BPpay\x1B(B\x1B[31',
```

- [ ] **Шаг 2: прогнать инвариант**

```bash
dart test test/insert_unfinished_invariant_test.dart
```

Ожидается: **первый тест краснеет** («an insertion either lands where it
was asked or is refused») на входах с чередой. Сообщение должно
показывать, что плоский текст результата потерял `X`.

Записать в отчёт, какие именно входы и позиции покраснели. Если
краснеет и второй тест («no byte of the input is invented or dropped») —
это неожиданность, разобраться и сказать.

- [ ] **Шаг 3: точечные тесты**

В `test/parser_insert_test.dart` дописать группу. **Ожидания снять
пробником с живого кода:** для каждого входа посмотреть, что даёт
`insertBefore` — он верен и сегодня, — и написать, что `insertAfter`
обязан дать то же самое.

```dart
  group('a seam in front of a run of unfinished codes:', () {
    test('an insertion does not land between two unfinished codes', () {
      // insertBefore is right today; insertAfter must agree with it, since
      // both mean "in front of what could not be finished".
      const input = 'aa\x1BPpay\x1B[31';

      expect(Parser(input).insertAfter(2, 'X'), 'aaX\x1BPpay\x1B[31');
      expect(Parser(input).insertBefore(2, 'X'), 'aaX\x1BPpay\x1B[31');
    });

    test('the run needs no control string in it', () {
      expect(Parser('aa\x1B\x1B[31').insertAfter(2, 'X'), 'aaX\x1B\x1B[31');
      expect(Parser('aa\x1B(\x1B[31').insertAfter(2, 'X'), 'aaX\x1B(\x1B[31');
    });

    test('a run longer than two is stepped over whole', () {
      expect(
        Parser('aa\x1BPpay\x1B(\x1B[31').insertAfter(2, 'X'),
        'aaX\x1BPpay\x1B(\x1B[31',
      );
    });

    test('a finished code ends the run and is passed over', () {
      // The DCS body ends at the ESC of the ESC ( B, so text behind that
      // code is outside the string and belongs there.
      expect(
        Parser('aa\x1BPpay\x1B(B\x1B[31').insertAfter(2, 'X'),
        'aa\x1BPpay\x1B(BX\x1B[31',
      );
    });

    test('a run at the end of the input is stepped over too', () {
      expect(Parser('aa\x1BPpay\x1B').insertAfter(2, 'X'), 'aaX\x1BPpay\x1B');
    });

    test('every opener and every unfinished tail agree with insertBefore', () {
      // The matrix the design asks for: five openers, three kinds of tail
      // that cannot finish, and both insertions at the seam. insertBefore is
      // right today, so it is the answer insertAfter must give.
      for (final opener in [OSC, DCS, SOS, PM, APC]) {
        for (final tail in [ESC, '$ESC[31', '$ESC(']) {
          final input = 'aa${opener}pay$tail';
          final parser = Parser(input);
          final reason = 'input ${input.ansiShowEscapeSequences()}';

          expect(
            parser.insertAfter(2, 'X'),
            parser.insertBefore(2, 'X'),
            reason: reason,
          );
          expect(
            Parser(parser.insertAfter(2, 'X')).removeAll(),
            '${parser.removeAll().substring(0, 2)}X'
            '${parser.removeAll().substring(2)}',
            reason: reason,
          );
        }
      }
    });

    test('the refusal among a truncated CSI stays where it was', () {
      final parser = Parser('aa\x1BPpay\x1B[31');

      expect(
        () => parser.insertAfter(3, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
      );
      expect(
        () => parser.insertBefore(4, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
      );
    });
  });
```

- [ ] **Шаг 4: прогнать и записать**

```bash
dart test test/parser_insert_test.dart -N 'run of unfinished codes'
```

Ожидается: краснеют все, кроме «a finished code ends the run» и «the
refusal among a truncated CSI» — эти два зелены и до правки, они
контрольные. Если картина иная — записать, какая, и **не подгонять**.

- [ ] **Шаг 5: коммит**

Коммит `test:`, тело объясняет, что тесты ловят: шов принадлежит месту
перед всей чередой, а не промежутку внутри неё.

---

## Задание 2: починка

**Файлы:**
- Правка: `lib/src/parsing/parser/parser.dart` — класс `_Walk` (около
  строки 1097) и два места в `_seamAt` (около строк 905 и 930)

**Интерфейсы:**
- Даёт заданию 3: поле `int? _Walk.unfinishedRunStart`.

- [ ] **Шаг 1: снять отпечаток до правки**

Положить в корень пакета пробник (иначе `package:`-импорты не
разрешаются) и убрать за собой. Каркас, входы дополнить своими:

```dart
import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

String v(String s) => s.runes
    .map((r) => r < 0x20 || (r >= 0x7F && r <= 0x9F)
        ? '<${r.toRadixString(16).padLeft(2, '0')}>'
        : String.fromCharCode(r))
    .join();

final inputs = <String>[
  for (final o in [OSC, DCS, SOS, PM, APC])
    for (final t in ['', ST, ESC, '$ESC[31', '$ESC(', '$ESC(B'])
      'aa${o}pay${t}bb',
  'aa$ESC$ESC[31',
  'aa$ESC($ESC[31',
  'aa$ESC[31',
  'aa${fgRed}bb$reset',
  '${OSC}8;;http://u${ST}link${OSC}8;;$ST',
  'aa$ESC]8;;http://u$ESC[31',
  'plain',
  '',
];

void main() {
  for (final input in inputs) {
    final p = Parser(input);
    print('### ${v(input)}');
    for (final m in p.matches) {
      print('  ent ${m.entity.runtimeType} ${v(m.entity.string)} '
          'link=${m.link?.url ?? '-'}');
    }
    print('  plain=${v(p.removeAll())} len=${p.length}');
    print('  opt=${v(p.optimize())} optOpen=${v(p.optimize(close: false))}');
    for (var s = 0; s <= p.length; s++) {
      for (var n = 0; n <= p.length - s; n++) {
        print('  sub($s,$n)=${v(p.substring(s, maxLength: n))}');
        print('  subOpen($s,$n)='
            '${v(p.substring(s, maxLength: n, close: false))}');
      }
      for (final after in [true, false]) {
        final label = after ? 'insA' : 'insB';
        try {
          print('  $label($s)='
              '${v(after ? p.insertAfter(s, '@') : p.insertBefore(s, '@'))}');
        } on UnfinishedSequenceException catch (e) {
          print('  $label($s)=THROW ${e.pos} ${e.offset}');
        }
      }
      print('  stateAt($s)=${p.stateAt(s)} '
          'linkAt($s)=${p.linkAt(s)?.url ?? '-'}');
    }
    final lines = <String>[];
    Printer(output: lines.add).writeln(input);
    print('  printer=${v(lines.join('|'))}');
    final buf = StringBuffer();
    SinkPrinter(buf).writeln(input);
    print('  sink=${v(buf.toString())}');
    print('  show=${v(input.ansiShowEscapeSequences())}');
    print('  rmEsc=${v(input.ansiRemoveEscapeCodes())}');
  }
}
```

Маркер `@`, а не `X`: `X` — байт открывателя `SOS`, и поиск по нему в
собственном пробнике уже один раз соврал.

Сохранить вывод в файл **вне репозитория**. Это не формальность: волна
обязана изменить **ровно одну клетку**, и доказывается это сравнением, а
не утверждением.

- [ ] **Шаг 2: научить `_Walk` помнить череду**

В классе `_Walk` дописать поле рядом с `lastCode`:

```dart
  /// Where the run of unfinished codes standing in front of [current]
  /// begins, or null where the code in front of it is finished and where
  /// there is none.
  ///
  /// [lastCode] is not enough to step back from: it is the code nearest the
  /// piece, and an insertion that stops in front of it can still land inside
  /// the one before. Two in a row is the case that shows it — a control
  /// string that never closed and a truncated `CSI` behind it — and the seam
  /// belongs in front of both, since the string's body swallows whatever
  /// stands between them.
  int? unfinishedRunStart;
```

и переписать `nextPiece()`:

```dart
  bool nextPiece() {
    // The piece handed out last time stands between whatever run came
    // before it and the one being looked for now.
    unfinishedRunStart = null;

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

      // Matches tile the input, so codes that follow one another are
      // adjacent and a run needs no more than this: keep the earliest start
      // while they stay unfinished, and let a finished one end the run.
      unfinishedRunStart =
          _unfinished(entity) ? unfinishedRunStart ?? m.start : null;
      lastCode = m;
    }

    isSpent = true;

    return false;
  }
```

- [ ] **Шаг 3: отступать к началу череды**

Первое место в `_seamAt` — ветка, где позиция попала в кусок текста:

```dart
          return (code.start, m.state, m.link);
```

становится:

```dart
          return (walk.unfinishedRunStart ?? code.start, m.state, m.link);
```

Второе — ветка исчерпанного обхода:

```dart
      return (
        code.start,
        walk.current?.state ?? initialState,
        walk.current?.link ?? initialLink,
      );
```

становится:

```dart
      return (
        walk.unfinishedRunStart ?? code.start,
        walk.current?.state ?? initialState,
        walk.current?.link ?? initialLink,
      );
```

**Броски `UnfinishedSequenceException` в обоих местах не трогать** — ни
условие, ни `offset`.

- [ ] **Шаг 4: прогнать тесты задания 1**

```bash
dart test test/insert_unfinished_invariant_test.dart
dart test test/parser_insert_test.dart
dart test
```

Ожидается: зелено. Если что-то падает вне тестов задания 1 — **не
править тест, пока не объяснишь, что изменилось**.

- [ ] **Шаг 5: сравнить отпечаток**

Снять отпечаток тем же пробником и сравнить с шагом 1. Ожидается: расходятся
**только** строки `insA` на швах с чередой. Всё остальное — байт в байт.

Расхождение сверх названного — остановиться и сказать мне.

- [ ] **Шаг 6: ворота и коммит**

Коммит `fix:`, тело объясняет: правило было верное, не хватало охвата —
`lastCode` это ближайший код, а не вся череда.

---

## Задание 3: состояние и ссылка на шве

**Файлы:**
- Правка: `lib/src/parsing/parser/parser.dart` — только если пробник
  покажет, что нужна
- Правка: `test/parser_insert_links_test.dart`

**Интерфейсы:** берёт `_Walk.unfinishedRunStart` из задания 2.

Задание проверочное, и вопрос в нём один. `_seamAt` возвращает тройку —
срез, состояние и ссылку. Отступив за череду, вставка отступает и за
коды, которые могли что-то открыть.

Незавершённые коды стилем обычно не являются. Но **незакрытый `OSC 8`
парсер читает как `Link`**: параметров три, терминатор необязателен.

- [ ] **Шаг 1: выяснить пробником**

Собрать вход, где череду открывает незакрытый `OSC 8`, а за ним стоит
оборванный `CSI`:

```dart
final input = 'aa\x1B]8;;http://u\x1B[31';
```

Посмотреть: какие сущности; что даёт `linkAt` на каждой позиции; что
даёт `insertAfter(2)` и `insertBefore(2)`; оказывается ли вставленный
текст внутри ссылки или снаружи; совпадают ли обе вставки.

Сравнить с тем же входом **без** оборванного `CSI`
(`'aa\x1B]8;;http://u'`), где череда из одного кода и поведение волной
не менялось.

- [ ] **Шаг 2: решить и записать**

Два исхода, оба нормальные:

- **Состояние и ссылка на шве верны** — записать в отчёт, чем это
  проверено, и дописать в дартдок `_seamAt` одну фразу о том, почему
  отступление за череду их не портит. Кода не трогать.
- **Не верны** — значит `_Walk` должен помнить и то, что действовало до
  череды, рядом с `unfinishedRunStart`. Реализовать, и в дартдоке поля
  сказать, зачем оно.

**Не угадывать.** Если пробник даёт картину, которую не удаётся
объяснить, — остановиться и сказать мне.

- [ ] **Шаг 3: тест**

В `test/parser_insert_links_test.dart` дописать тест на этот вход,
закрепляющий выясненное. Ожидания — из пробника.

- [ ] **Шаг 4: ворота и коммит**

Если кода не трогал — коммит `test:`, и в теле сказать, что вопрос
проверен и закрыт наблюдением.

---

## Задание 4: документы и полные ворота

**Файлы:**
- Правка: `lib/src/parsing/parser/parser.dart` — дартдок `insertBefore`
- Правка: `README.md`, `README.ru.md`
- Правка: `CHANGELOG.md`
- Правка: `docs/architecture.md`, `docs/handoff.md`

- [ ] **Шаг 1: снять оговорку**

Волна C1-строковых записала в трёх местах абзац о шве, который
оставался непокрытым: дартдок `insertBefore` в `parser.dart`, и по
абзацу в `README.md` и `README.ru.md`. Найти их (искать «One seam is left
over» и русский перевод) и **снять**: шва больше нет.

Убедиться, что остальное в этих абзацах — про отказ среди параметров
оборванного `CSI` — осталось верным и на месте.

README обе версии — **одним коммитом**.

- [ ] **Шаг 2: дартдок исключения**

`lib/src/parsing/parser/unfinished_sequence_exception.dart` говорит, что
управляющая строка это исключение не вызывает и что перед ней встают.
Это **осталось верным**. Проверить, что формулировка не обещает лишнего
и не отсылает к снятой оговорке.

- [ ] **Шаг 3: карта**

`docs/architecture.md`, механизм 1 («Шов вставки») описывает
`_unfinished`. Дописать, что шов принадлежит месту перед всей чередой
незавершённых кодов, а не перед ближайшим.

- [ ] **Шаг 4: handoff**

В `docs/handoff.md`, раздел «Найдено волнами», пункт про вставку в тело
незакрытой строки **закрыт** — убрать его оттуда. Не трогать
`docs/backlog.md`: это список владельца, агенты в него не пишут.

- [ ] **Шаг 5: CHANGELOG**

Правка на месте в записи `4.0.0`, по-английски.

- [ ] **Шаг 6: полные ворота**

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

Вывод каждых — дословно в отчёт. Прогнать примеры из `example/`.

- [ ] **Шаг 7: коммит**

---

## Что после плана

Финальное ревью всей ветки → **пуш ветки и ожидание зелёного CI** →
`git merge --no-ff` в `main` → пуш. После мержа: строки «влит мержем» в
шапки записей `[3]` и `[4]`, и `docs/handoff.md` переписывается.
