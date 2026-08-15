# План: незавершённый `OSC` перестаёт съедать текст

> **Состояние на 2026-08-16:** выполнен и влит в `main` мержем `57b8443`.
> Часть задач написана по ложному инварианту, поправки внесены в текст
> задач после реализации — верная формулировка в дизайне `2026-08-08[1]` и
> в `AGENTS.md`. Волна закрыла три поверхности из четырёх; оставшийся
> `insertAfter` закрыт волной `2026-08-11[2]`/`[3]` мержем `00fe2ca`.
> Ссылки в прозе старые — записи лежат в `docs/records/`, `TODO.md` стал
> `docs/backlog.md`.
> **Что это:** план реализации той же починки — срез, `optimize` и
> напечатанная строка перестают терять текст за незавершённым `OSC`.
> **Связанные записи:** `2026-08-08[1]-osc-termination-design.md`,
> `2026-08-11[3]-insert-unfinished-sequence-plan.md`.

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** `OSC`, который во входе не получил терминатора, перестаёт съедать
текст за собой в срезе, в `optimize` и в напечатанной строке — так же, как
это уже сделано для `OSC 8`.

**Architecture:** Приём, который уже есть, теряет ссылочную оговорку.
Незавершённое открытие придерживается, пока не станет известно, перед чем
оно встанет; следом текст — подставляется `ST`, следом escape-код — байты
как пришли. На краю вывода, где поверхность и так закрывает ссылку,
терминатор тоже подставляется. Условие `entity is Link` становится
`entity is Osc` в двух поверхностях; в третьей (`substring`) заводится
второй придержанный буфер, и порядок между ними задаёт инвариант «где
придержаны оба, открытие пришло первым» — он заменил инвариант «в любой
момент придержано не больше одного», по которому Task 3 был написан и
который оказался ложным; см. поправку в самой задаче.

**Tech Stack:** Dart 3.6+, `package:test`. Пакет `ansi_escape_codes`,
ветка `fix/osc-termination`, база main @ `80b68b2`.

**Спека:** `docs/2026-08-08[1]-osc-termination-design.md` — читать её не
обязательно, всё нужное перенесено сюда.

## Global Constraints

- Версию **не бампаем**: 4.0.0 не опубликована, публикация — отдельное
  решение пользователя.
- Строки кода и комментариев — **не длиннее 80 символов**.
- Каждая задача заканчивается коммитом; префиксы conventional (`fix:`,
  `test:`, `docs:`), сообщение — повествовательное, по-английски, как в
  истории репозитория (`git log` покажет тон).
- Ворота, которые должны быть зелёными на каждом коммите:
  `dart format --output=none --set-exit-if-changed .`,
  `dart analyze --fatal-infos`, `dart test`.
- Комментарии в коде — по-английски, в тоне окружающего кода: объясняют
  **почему**, а не пересказывают строку.
- Ничего не переименовывать и не рефакторить сверх описанного.
- `ST` и `OSC` в тестах берутся из `package:ansi_escape_codes/ansi.dart`;
  `Parser`, `Printer`, `SinkPrinter`, `reset`, `fgRed` — из
  `package:ansi_escape_codes/ansi_escape_codes.dart`.

## Структура файлов

| файл | за что отвечает в этой волне |
| --- | --- |
| `lib/src/parsing/parser/entities/osc.dart` | правило терминирования: две функции над одним ядром |
| `lib/src/parsing/parser/parser.dart` | `optimize` (Task 1) и `substring` (Task 3) |
| `lib/src/parsing/parser/printer.dart` | `_prepare`: цикл и хвост (Task 2) |
| `test/osc_termination_test.dart` | новый; пины по поверхностям, группа на задачу |
| `test/link_continuity_fuzz_test.dart` | оракул «видимый текст не пропадает» (Task 4) |
| `CHANGELOG.md`, `TODO.md`, dartdoc | Task 5 |

---

### Task 1: `optimize` терминирует любой `OSC`, и правило переезжает в две функции

**Files:**
- Modify: `lib/src/parsing/parser/entities/osc.dart:59-64`
- Modify: `lib/src/parsing/parser/parser.dart:836-911`
- Test: `test/osc_termination_test.dart` (создать)

**Interfaces:**
- Produces: `String _terminatedUnlessCodeFollows(String codes, String
  following)` — байты `codes` с дописанным `ST`, если они кончаются
  незавершённым `OSC` и `following` не начинается с `ESC`. Пустой
  `following` означает «терминатор нужен». Задачи 2 и 3 зовут её на своих
  хвостах.
- Produces: `String _terminatedIfTextFollows(String codes, String
  following)` — та же, но пустой `following` означает «оставить как есть».
  Сигнатура и поведение при непустом `following` не меняются.

- [ ] **Step 1: Написать падающие тесты**

Создать `test/osc_termination_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// Setting the window title, and never terminated: no `ST`, no `BEL`. The
/// parser reads a sequence like this to the next `ESC` or to the end of the
/// text — `oscPattern` is written that way on purpose — so whatever is
/// written straight after it is read as more of the title.
const title = '${ESC}]0;title';

void main() {
  group('optimize terminates an OSC that would swallow what follows', () {
    test('a title the input never terminated, in front of text', () {
      // The `reset` ends the title in the input, and is written again as a
      // transition to the default style — which changes nothing here and so
      // writes nothing, leaving the title against the text.
      expect(Parser('$title${reset}word').optimize(), '$title${ST}word');
    });

    test('a transition that does write something ends it already', () {
      expect(
        Parser('$title${fgRed}word').optimize(),
        '$title${fgRed}word$reset',
      );
    });

    test('a code copied over as it stands ends it already', () {
      expect(
        Parser('$title\x1B[2Cword').optimize(),
        '$title\x1B[2Cword',
      );
    });

    test('a title that got its BEL is left alone', () {
      expect(
        Parser('$title\x07${reset}word').optimize(),
        '$title\x07word',
      );
    });

    test('a title at the end of a closed string is terminated', () {
      // Nothing follows it here, and that is the point: what the caller
      // prints after this string follows it.
      expect(Parser('a$title').optimize(), 'a$title$ST');
    });

    test('a title at the end of an unclosed string is left as it came', () {
      expect(Parser('a$title').optimize(close: false), 'a$title');
    });
  });
}
```

- [ ] **Step 2: Прогнать и убедиться, что падает**

Run: `dart test test/osc_termination_test.dart`

Expected: FAIL — четыре теста из шести. `'a title the input never
terminated, in front of text'` вернёт `'\x1B]0;titleword'` вместо
ожидаемого; `'a title at the end of a closed string'` вернёт `'a\x1B]0;title'`.
Два теста про уже-разделённые случаи (`fgRed`, `\x1B[2C`) и один про `BEL`
должны пройти сразу — если падают они, значит ожидание записано неверно,
и чинить надо тест, а не код.

- [ ] **Step 3: Разделить правило на две функции**

В `lib/src/parsing/parser/entities/osc.dart` заменить тело
`_terminatedIfTextFollows` (сейчас строки 59-64) на две функции. Комментарий
над первой оставить как есть, дописав к нему абзац про вторую:

```dart
String _terminatedIfTextFollows(String codes, String following) =>
    following.isEmpty ? codes : _terminatedUnlessCodeFollows(codes, following);

/// [codes] with a terminator supplied where they end in an `OSC` that never
/// got one and nothing beginning with an `ESC` follows to end it.
///
/// The rule at the edge of an output, where [_terminatedIfTextFollows] is the
/// rule inside one, and the two differ in what an empty [following] means.
/// Inside a string it means nothing follows the opening at all, so there is
/// nothing to be swallowed and the bytes go out as they came. At the edge of
/// an output that closes — a slice with `close: true`, a printed line — it
/// means the next thing written is whatever the caller prints after, and the
/// terminator is owed for the same reason the hyperlink close is.
String _terminatedUnlessCodeFollows(String codes, String following) =>
    codes.isEmpty || _oscTerminated(codes) || following.startsWith(ESC)
        ? codes
        : '$codes$ST';
```

- [ ] **Step 4: Снять со `optimize` ссылочную оговорку**

В `lib/src/parsing/parser/parser.dart`, строка 878:

```dart
        if (entity is Link && !_oscTerminated(string)) {   // было
        if (entity is Osc && !_oscTerminated(string)) {    // стало
```

И поправить комментарий над `heldOpening` (строки 840-844) — он говорит
«An opening the string never terminated», это уже верно и про заголовок,
но слово `Link` в ссылке на `_terminatedIfTextFollows` менять не нужно.
Достаточно убедиться, что он не обещает, будто речь только про ссылку.

- [ ] **Step 5: Переписать хвост `optimize`**

Заменить строки 888-908 на:

```dart
    // The string is over. What follows the opening held back is the close
    // below, or the unwinding of the style, or nothing at all — and where it
    // is nothing, `close` says whether a terminator is owed: what is printed
    // after a closed string must not be read as more of an `OSC`.
    final lastMatch = matches.lastOrNull;
    final closingLink = close && finalLink != null ? linkClose : '';
    final tail = close
        ? currentState.transitTo(initialState)
        : lastMatch == null
            ? ''
            : currentState.transitTo(lastMatch.state);
    final following = _firstNotEmpty(closingLink, tail);

    buf
      ..write(
        close
            ? _terminatedUnlessCodeFollows(heldOpening, following)
            : _terminatedIfTextFollows(heldOpening, following),
      )
      // The link is closed the way the style is, and after the opening held
      // back: whatever the string left open — an opening of its own, or the
      // link it was seeded inside — must not go on catching what is printed
      // after.
      ..write(closingLink)
      ..write(tail);
```

- [ ] **Step 6: Прогнать тесты**

Run: `dart test test/osc_termination_test.dart`
Expected: PASS, все шесть.

Run: `dart test`
Expected: PASS, ни один существующий тест не меняет поведения. Если
падает `test/parser_optimize_*` — разобраться, а не править ожидание:
поведение для входов без незавершённого `OSC` обязано остаться прежним
байт в байт.

- [ ] **Step 7: Ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
git add lib/src/parsing/parser/entities/osc.dart \
        lib/src/parsing/parser/parser.dart \
        test/osc_termination_test.dart
git commit
```

Сообщение — про то, что правило перестало быть ссылочным и что край
теперь тоже платит.

---

### Task 2: принтеры терминируют на настоящем конце строки

**Files:**
- Modify: `lib/src/parsing/parser/printer.dart:308-312` (условие в цикле)
- Modify: `lib/src/parsing/parser/printer.dart:322-339` (хвост)
- Test: `test/osc_termination_test.dart` (дописать группу)

**Interfaces:**
- Consumes: `_terminatedUnlessCodeFollows(String codes, String following)` и
  `_terminatedIfTextFollows(String codes, String following)` из Task 1, обе
  в `entities/osc.dart`, обе доступны здесь — `printer.dart` это
  `part of '../parser.dart'`.
- Consumes: `_firstNotEmpty(String first, String second, [String third])`,
  уже существует. Четвёртый необязательный аргумент у неё появится в
  Task 3 — принтеру он не нужен, здесь кандидатов два.

- [ ] **Step 1: Написать падающие тесты**

Дописать в `test/osc_termination_test.dart`, внутрь `main()`, после
существующей группы:

```dart
  group('a printed line terminates an OSC it would leave open', () {
    test('a title in front of the line text', () {
      final lines = <String>[];
      Printer(output: lines.add).print('$title${reset}word');

      // Every prepared piece opens with a reset — that is the printer's own
      // doing and not this rule's.
      expect(lines, ['$reset$title${ST}word']);
    });

    test('a title at the end of the line', () {
      // The line is over, and a newline follows it into the terminal: the
      // terminator is owed here the way a link close is.
      final lines = <String>[];
      Printer(output: lines.add).print('a$title');

      expect(lines, ['${reset}a$title$ST']);
    });

    test('a line that got its terminator is left alone', () {
      final lines = <String>[];
      Printer(output: lines.add).print('$title$ST${reset}word');

      expect(lines, ['$reset$title${ST}word']);
    });

    test('a title carried to the end of the first line of two', () {
      final lines = <String>[];
      Printer(output: lines.add).print('$title${reset}one\ntwo');

      expect(lines, ['$reset$title${ST}one', '${reset}two']);
    });
  });

  group('a sink terminates where the line really ends', () {
    test('a write that has not ended the line owes nothing', () {
      final buf = StringBuffer();
      SinkPrinter(buf).write('a$title');

      expect(buf.toString(), '${reset}a$title');
    });

    test('a writeln ends the line and owes the terminator', () {
      final buf = StringBuffer();
      SinkPrinter(buf).writeln('a$title');

      expect(buf.toString(), '${reset}a$title$ST\n');
    });

    test('a newline inside a write ends the line there', () {
      final buf = StringBuffer();
      SinkPrinter(buf).write('a$title${reset}word\nnext');

      expect(buf.toString(), '${reset}a$title${ST}word\n${reset}next');
    });
  });
```

- [ ] **Step 2: Прогнать и убедиться, что падает**

Run: `dart test test/osc_termination_test.dart`

Expected: FAIL — падают `'a title in front of the line text'`,
`'a title at the end of the line'`, `'a title carried to the end of the
first line of two'`, `'a writeln ends the line and owes the terminator'` и
`'a newline inside a write ends the line there'`. Проходят сразу
`'a line that got its terminator is left alone'` и `'a write that has not
ended the line owes nothing'` — эти два пина стерегут то, что меняться не
должно.

- [ ] **Step 3: Снять ссылочную оговорку в цикле**

`lib/src/parsing/parser/printer.dart`, строка 310:

```dart
      if (m.entity is Link && !_oscTerminated(string)) {   // было
      if (m.entity is Osc && !_oscTerminated(string)) {    // стало
```

- [ ] **Step 4: Переписать хвост `_prepare`**

Заменить строки 322-339 на:

```dart
    // The line is over. What follows the opening held back is the close
    // below, or the unwinding of the style, or nothing at all — and where it
    // is nothing, whether a terminator is owed is the same question as
    // whether a link close is: a piece that has not ended the line is not
    // the end of an output, and owes neither.
    final closingLink = closeLink && writtenLink != null ? linkClose : '';
    final tail = lastState.transitTo(stateDefaults);
    final following = _firstNotEmpty(closingLink, tail);

    buf.write(
      closeLink
          ? _terminatedUnlessCodeFollows(heldOpening, following)
          : _terminatedIfTextFollows(heldOpening, following),
    );

    if (closingLink.isNotEmpty) {
      buf.write(closingLink);
      writtenLink = null;
    }
    _writtenLink = writtenLink;

    // What the text leaves open outlives the close written above: the close
    // is for the terminal, which must not make the next line clickable by
    // accident, and this is for the next line, which opens the link again.
    _ambientLink = parser.finalLink;

    buf.write(tail);
    this.lastState = parser.finalState;

    return buf.toString();
```

- [ ] **Step 5: Прогнать тесты**

Run: `dart test test/osc_termination_test.dart`
Expected: PASS, все группы.

Run: `dart test`
Expected: PASS. Особое внимание `test/printer_links_test.dart` и
`test/link_continuity_fuzz_test.dart` — они стерегут ссылочный канал, и
он этой задачей не меняется.

- [ ] **Step 6: Ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
git add lib/src/parsing/parser/printer.dart test/osc_termination_test.dart
git commit
```

---

### Task 3: срез придерживает незавершённый `OSC` рядом со ссылочным каналом

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart:438-445` (объявления),
  `:498-546` (текстовая ветка), `:547-596` (ветка escape-кода),
  `:605-632` (хвост)
- Test: `test/osc_termination_test.dart` (дописать группу)

**Interfaces:**
- Consumes: `_terminatedUnlessCodeFollows` и `_terminatedIfTextFollows` из
  Task 1.

**Инвариант этой задачи:** где придержаны оба, **открытие пришло
первым**. `heldOpening` заполняет одна только ветка не-ссылочного кода,
и она сбрасывает оба буфера прежде, чем заполнить его; ветка `Link`
трогает только свой канал — `heldLinkCodes` и `heldLink`. Значит
открытие всегда старше, и
всякий, кто пишет их обоих, пишет открытие первым, а за открытием идут
придержанные ссылочные коды. Из этого следует четвёртый аргумент
`_firstNotEmpty`: в текстовой ветке за открытием стоят придержанные
ссылочные коды, переоткрытие, переход и текст — четыре кандидата.

> **Поправка после реализации (коммит `de1b5bf`).** Задача написана по
> инварианту «`heldOpening` и `heldLinkCodes` **никогда не непусты
> одновременно**»: ветка `Link` сбрасывает `heldOpening` перед тем, как
> дописать ссылочные байты, и четвёртый аргумент `_firstNotEmpty` тогда
> не нужен нигде. Инвариант ложный. Сброс в ветке `Link` писал байты под
> обещание, что ссылочные байты встанут прямо за ними и оборвут их своим
> `ESC`; они не вставали, а уходили в `heldLinkCodes`, которые закрытый
> хвост выбрасывает — показывать внутри них нечего. `Parser('a' + title +
> link).substring(0)` кончался голым незавершённым `OSC`. Ветка `Link`
> вернулась к тому, чем была (Шаг 5), в текстовой ветке появился
> четвёртый аргумент (Шаг 4), в незакрытом хвосте — придержанные
> ссылочные коды в голове «что следом» (Шаг 7). Шаги ниже приведены к
> тому, что стоит в коде; порядок записи не менялся ни разу. Сдача
> открытия из ветки escape-кода (Шаг 6) до той правки не была прикрыта
> ничем — её убирали, и все 507 оставались зелёными, — так что в файл
> тестов пришли ещё три пина, помимо переписанного Шага 9.

- [ ] **Step 1: Написать падающие тесты**

Дописать в `test/osc_termination_test.dart`, внутрь `main()`:

```dart
  group('a slice terminates an OSC that would swallow its text', () {
    test('a title in front of the text of the slice', () {
      expect(
        Parser('$title${reset}word').substring(0),
        '$title${ST}word',
      );
    });

    test('and with close: false, where the text follows all the same', () {
      // `close` decides what is owed at the end of the slice, not what is
      // owed in front of text inside it.
      expect(
        Parser('$title${reset}word').substring(0, close: false),
        '$title${ST}word',
      );
    });

    test('a title at the end of a closed slice is terminated', () {
      expect(Parser('a$title').substring(0), 'a$title$ST');
    });

    test('a title at the end of an unclosed slice is left as it came', () {
      expect(Parser('a$title').substring(0, close: false), 'a$title');
    });

    test('a title behind a link, with the text behind both', () {
      // The link opening is written first and its `ESC` ends nothing, so the
      // title is the one that needs the terminator.
      const link = '${OSC}8;;https://a.test$ST';

      expect(
        Parser('$link$title${reset}word').substring(0),
        '$link$title${ST}word$linkClose',
      );
    });

    test('a link behind a title changes nothing: the ESC ends it', () {
      // The link opening begins with an `ESC`, so it ends the title itself
      // and nothing is supplied. A regression pin: this is what must not
      // move.
      const link = '${OSC}8;;https://a.test$ST';

      expect(
        Parser('$title$link${reset}word').substring(0),
        '$title${link}word$linkClose',
      );
    });

    test('an insertion is not touched by any of this', () {
      // `insertBefore` and `insertAfter` copy the input around the seam byte
      // for byte, so the title keeps whatever it had there. A regression pin.
      expect(
        Parser('$title${reset}word').insertBefore(2, 'X'),
        '$title${reset}woXrd',
      );
      expect(
        Parser('$title${reset}word').insertAfter(2, 'X'),
        '$title${reset}woXrd',
      );
    });
  });
```

- [ ] **Step 2: Прогнать и убедиться, что падает**

Run: `dart test test/osc_termination_test.dart`

Expected: FAIL — первые пять из семи. Последние два (`'a link behind a
title changes nothing'` и `'an insertion is not touched by any of this'`)
проходят сразу: это регрессионные пины, они стерегут то, что меняться не
должно.

- [ ] **Step 3: Завести второй придержанный**

`lib/src/parsing/parser/parser.dart`, рядом с объявлениями ссылочного
канала (после строки 445, `var heldLinkCodes = '';`):

```dart
    // An `OSC` of the slice's own that never terminated, held back until
    // what comes after it is known — the same waiting the link codes above
    // do, and sometimes beside them.
    //
    // Where the two wait together, this one came first: only the branch that
    // drains both of them fills this one, and the branch that fills the link
    // codes fills nothing else. So every place that writes them out writes
    // this one ahead of the link codes, and what follows an opening is the
    // held link codes wherever there are any.
    var heldOpening = '';
```

- [ ] **Step 4: Сбрасывать придержанное открытие в текстовой ветке**

В текстовой ветке, сразу после взятия ссылочных кодов (после
`writtenLink = heldLink;`, строка 501):

```dart
              final opening = heldOpening;
              heldOpening = '';
```

и перед записью придержанных ссылочных кодов (перед `if (held.isNotEmpty)`,
строка 523) вставить:

```dart
              // The link codes read after the opening are written straight
              // behind it, so they are the first of what follows it — and
              // where there are none, what follows the piece does.
              if (opening.isNotEmpty) {
                buf.write(
                  _terminatedIfTextFollows(
                    opening,
                    _firstNotEmpty(held, reopening, transit, substring),
                  ),
                );
              }
```

**Не** `_firstNotEmpty(reopening, transit, substring)`: `held` может быть
непуст рядом с открытием, и тогда за открытием идут именно ссылочные
коды. С тремя аргументами открытие получило бы `ST` там, где `ESC`
ссылочных кодов и так его обрывает. См. поправку выше.

- [ ] **Step 5: Ветку `Link` не трогать**

Ветка `if (entity is Link)` (строки 549-558) остаётся как есть: она
дописывает к `heldLinkCodes` и больше ничего не касается. Придержанное
открытие ждёт рядом.

**Не** сбрасывать в ней `heldOpening` «под ссылочные байты, которые
оборвут его своим `ESC`»: ссылочные байты в этой ветке не пишутся, а
уходят в `heldLinkCodes`, и закрытый хвост их выбрасывает. Открытие,
записанное под это обещание, остаётся в срезе без терминатора. Так было
написано в первой реализации — см. поправку выше.

- [ ] **Step 6: Придерживать незавершённый `OSC` в ветке escape-кода**

В ветке `else` (не-ссылочный не-`SGR` код), после взятия ссылочных кодов
и вычисления `transit`, вставить сброс придержанного открытия перед
записью `held` (перед `if (held.isNotEmpty)`, строка 572):

```dart
              // Ahead of the held link codes, which is where they were read
              // and so what follows the opening where there are any.
              final opening = heldOpening;
              heldOpening = '';
              if (opening.isNotEmpty) {
                buf.write(
                  _terminatedIfTextFollows(
                    opening,
                    _firstNotEmpty(held, transit, entity.string),
                  ),
                );
              }
```

`held` в голове по той же причине, что и в текстовой ветке: придержанные
ссылочные коды пишутся сразу за открытием, значит они и следуют за ним.

и заменить безусловную запись байтов кода (строки 581-583) на:

```dart
              buf.write(transit);

              // An opening with no terminator waits to see what it is
              // written in front of; everything else goes out where it
              // stands.
              if (entity is Osc && !_oscTerminated(entity.string)) {
                heldOpening = entity.string;
              } else {
                buf.write(entity.string);
              }
```

- [ ] **Step 7: Переписать хвост среза**

Заменить блок `if (close) { ... } else { ... }` (строки 615-630) на:

```dart
      if (close) {
        // A slice closes the link it has open, the one it began inside as
        // readily as the one it opened itself: what is printed after the
        // slice must not stay clickable on the slice's URL. An opening held
        // back is written first and terminated, for the same reason and by
        // the same right — what is printed after must not be read as more of
        // it. Held link codes are dropped instead: nothing follows them to
        // be shown inside.
        final closingLink = writtenLink != null ? linkClose : '';

        buf
          ..write(
            _terminatedUnlessCodeFollows(
              heldOpening,
              _firstNotEmpty(closingLink, tail),
            ),
          )
          ..write(closingLink);
      } else {
        // Left open, the way the style is left: what was held back is
        // written out, opening ahead of link codes as everywhere else, and
        // the slice ends inside whatever the string is inside at that point.
        // Nothing but the unwinding of the style follows, so an opening that
        // never terminated is left as it came — see
        // [_terminatedIfTextFollows].
        buf
          ..write(
            _terminatedIfTextFollows(
              heldOpening,
              _firstNotEmpty(heldLinkCodes, tail),
            ),
          )
          ..write(_terminatedIfTextFollows(heldLinkCodes, tail));
      }
```

**Не** `_terminatedIfTextFollows(heldOpening, tail)`: рядом с открытием
могут ждать ссылочные коды, и пишутся они сразу за ним. См. поправку выше.

- [ ] **Step 8: Прогнать тесты**

Run: `dart test test/osc_termination_test.dart`
Expected: PASS, все три группы.

Run: `dart test`
Expected: PASS. Особое внимание `test/parser_substring_links_test.dart` —
он стережёт ссылочный канал, который здесь трогается.

- [ ] **Step 9: Пин на порядок двух придержанных**

Дописать в группу среза тест, который сломается, если сдачу открытия из
ветки escape-кода уберут или если два придержанных поменяются местами:

```dart
    test('the two held things come out in the order they were read', () {
      const link = '${OSC}8;;https://a.test$ST';
      const close = '${OSC}8;;$ST';

      // A title, a link, a title, and text. The two wait side by side, and
      // the opening is always the older of them: it goes out first, and the
      // link codes behind it end it with their own `ESC`. The link close is
      // the last thing in front of the text and carries its own `ST`, so
      // nothing is supplied here either.
      expect(
        Parser('$title$link$title$close${reset}word').substring(0),
        '$title$link$title${close}word',
      );
    });
```

`ST` перед `word` не пишется: последним перед текстом стоит закрывашка
ссылки, а она терминирована сама. Ожидание проверить прогоном: если оно
не сходится, **не подгонять** — разобраться, какая из двух записей встала
не туда, и записать в отчёт.

- [ ] **Step 10: Ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
git add lib/src/parsing/parser/parser.dart test/osc_termination_test.dart
git commit
```

---

### Task 4: оракул «видимый текст не пропадает» и дифференциальный прогон

**Files:**
- Modify: `test/link_continuity_fuzz_test.dart`
- Test: он же

**Interfaces:**
- Consumes: поверхности, починенные задачами 1-3. Ничего нового не
  производит.

Устройство файла, чтобы не искать: сид — `const int _seed = 20260807`
(строка 11); формы рисует `String _piece(Random random, {required bool
readWhole, bool saves = true, bool lineBreaks = true})` (строка 60) через
`switch (random.nextInt(24))` с занятыми ветками `0`-`12`, остальное
падает в `default` и отдаёт слово; документ собирает `String
_document(Random random, int pieces, {required bool readWhole, bool saves
= true})` (строка 127); показывает строку локальная `_show` (строка 28).

- [ ] **Step 1: Добавить в генератор две формы**

В `_piece`, рядом с веткой `case 3` (там же живёт незавершённое открытие
ссылки — читать её доккоммент, он объясняет `readWhole`), добавить:

```dart
    case 13:
      // A window title with no terminator of its own: the same shape as the
      // opening in case 3, and it ends the same way — at the `ESC` of
      // whatever stands behind it. `readWhole` is honoured for the same
      // reason: a line break put in front of that `ESC` changes how far the
      // sequence reaches, and then the two sides are no longer reading the
      // same document.
      return readWhole
          ? '${OSC}0;title'
          : '${OSC}0;title${random.nextBool() ? reset : cursorUp}';
    case 14:
      // The same title, terminated: the shape that must not change.
      return '${OSC}0;title$ST';
```

- [ ] **Step 2: Поправить числа, которые сид больше не даёт**

В `test/link_continuity_fuzz_test.dart:346` стоит комментарий «The seed is
fixed, so these are what the run really draws — 2301 and 2096». Две новые
ветки забирают вероятность у `default`, так что числа сдвинутся.

Run: `dart test test/link_continuity_fuzz_test.dart`

Если пороги `greaterThan(1500)` и `greaterThan(1000)` держатся —
временно напечатать `roundsWithLink` и `slicesWithRestore`, вписать
настоящие числа в комментарий и убрать печать. Пороги **не трогать**: они
ловят генератор, который перестал генерировать, а не эти два числа.

- [ ] **Step 3: Написать оракул**

Добавить в тот же файл, в конец `main()`:

```dart
  group('the visible text survives every surface:', () {
    test('nothing a surface hands back has lost a character', () {
      // The codes may be rewritten, reordered or dropped — that is what
      // these surfaces are for — but the characters a terminal draws may
      // not change. An `OSC` that swallows what follows it is the one way
      // they do, and this is the oracle that says so.
      final random = Random(_seed);

      for (var round = 0; round < 500; round++) {
        final whole = _document(random, 12, readWhole: true);
        final plain = Parser(whole).removeAll();

        expect(
          Parser(Parser(whole).optimize()).removeAll(),
          plain,
          reason: 'optimize lost text:\n  in: ${_show(whole)}',
        );
        expect(
          Parser(Parser(whole).optimize(close: false)).removeAll(),
          plain,
          reason: 'optimize(close: false) lost text:\n  in: ${_show(whole)}',
        );
        expect(
          Parser(Parser(whole).substring(0)).removeAll(),
          plain,
          reason: 'substring lost text:\n  in: ${_show(whole)}',
        );
      }

      // The printer reads a document that keeps an unterminated sequence
      // and the code ending it in one piece, the way the rest of this file
      // does: a line break in between would change how far the sequence
      // reaches, and the two sides would stop reading the same document.
      for (var round = 0; round < 500; round++) {
        final printed = _document(random, 12, readWhole: false, saves: false);
        final lines = <String>[];
        Printer(output: lines.add).print(printed);

        expect(
          lines.map((line) => Parser(line).removeAll()).join('\n'),
          Parser(printed).removeAll(),
          reason: 'the printer lost text:\n  in: ${_show(printed)}',
        );
      }
    });
  });
```

- [ ] **Step 4: Прогнать**

Run: `dart test test/link_continuity_fuzz_test.dart`

Expected: PASS. Оракул написан после починки нарочно — он стережёт её, а
не находит. Если он падает, значит какая-то форма входа осталась
непочиненной: записать вход целиком в отчёт, **не подгоняя оракул**.

- [ ] **Step 5: Дифференциальный прогон против базы**

Убедиться, что на входах **без** незавершённого не-ссылочного `OSC` вывод
не изменился байт в байт. Создать `benchmark/diffprobe.dart` (файл
временный, в конце шага удаляется):

```dart
import 'dart:math';

import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

/// The pieces of the fuzz, minus the two this wave changes: what is left is
/// input the wave must not touch at all.
String _piece(Random random) {
  final url = 'http://${random.nextInt(3)}/';

  switch (random.nextInt(16)) {
    case 0:
      return '${OSC}8;;$url$ST';
    case 1:
      return '${OSC}8;;$url$BEL';
    case 2:
      return '${OSC}8;id=${random.nextInt(3)};$url$ST';
    case 3:
      return '${OSC}8;;$url';
    case 4:
      return linkClose;
    case 5:
      return '${OSC}0;title$ST';
    case 6:
      return saveCursor;
    case 7:
      return restoreCursor;
    case 8:
      return fgRed;
    case 9:
      return reset;
    case 10:
      return '\x1B[2C';
    case 11:
      return '\n';
    default:
      return const ['word ', 'a', 'x', 'yz'][random.nextInt(4)];
  }
}

void main() {
  final random = Random(4242);
  final out = StringBuffer();

  for (var round = 0; round < 400; round++) {
    final input = [for (var i = 0; i < 12; i++) _piece(random)].join();
    final length = Parser(input).length;
    final lines = <String>[];
    Printer(output: lines.add).print(input);

    out
      ..writeln('$round|sub|${Parser(input).substring(0)}')
      ..writeln('$round|sub0|${Parser(input).substring(0, close: false)}')
      ..writeln('$round|opt|${Parser(input).optimize()}')
      ..writeln('$round|opt0|${Parser(input).optimize(close: false)}')
      ..writeln('$round|ins|${Parser(input).insertBefore(length ~/ 2, 'X')}')
      ..writeln('$round|prn|${lines.join('')}');
  }

  print(out);
}
```

Прогнать в рабочем дереве и в чистой сборке базы:

```bash
dart run benchmark/diffprobe.dart > /tmp/dp_head.txt

SP=$(mktemp -d)
git archive 80b68b2 | tar -x -C "$SP"
cp benchmark/diffprobe.dart "$SP/benchmark/"
(cd "$SP" && dart pub get && dart run benchmark/diffprobe.dart) \
  > /tmp/dp_base.txt

diff /tmp/dp_base.txt /tmp/dp_head.txt && echo IDENTICAL
rm -f benchmark/diffprobe.dart
```

Expected: `IDENTICAL`. Если `diff` не пуст — разобраться и записать в
отчёт: правка не должна трогать вход, в котором нет незавершённого
не-ссылочного `OSC`.

- [ ] **Step 6: Ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test
git status --short   # benchmark/diffprobe.dart не должен остаться
git add test/link_continuity_fuzz_test.dart
git commit
```

---

### Task 5: документация

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart` (dartdoc `substring` и
  `optimize`)
- Modify: `lib/src/parsing/parser/printer.dart` (dartdoc принтеров)
- Modify: `CHANGELOG.md:202-211`
- Modify: `TODO.md`

**Interfaces:**
- Consumes: поведение, закреплённое задачами 1-3.

- [ ] **Step 1: dartdoc**

Найти в `parser.dart` и `printer.dart` места, где сегодня сказано про
незавершённое открытие **ссылки**, и сказать про незавершённый `OSC`
вообще. Искать по слову `terminator`:

```bash
grep -n "terminator" lib/src/parsing/parser/parser.dart \
                     lib/src/parsing/parser/printer.dart
```

Ссылочные места, где речь именно про `OSC 8` (переоткрытие, `id=`,
`linkClose`), не трогать: там про ссылку сказано верно.

- [ ] **Step 2: CHANGELOG**

Запись начинается словами «Copying a hyperlink out of a string could
swallow the text behind it» (`CHANGELOG.md:202`). Расширить её на любой
`OSC`: не только `OSC 8;;`, но и заголовок окна и всё прочее, и на край
вывода — слайс с `close: true` и напечатанная строка теперь дописывают
терминатор там, где за ними ничего. Правка на месте: 4.0.0 не издана, это
не breaking-note. Версию не бампать.

- [ ] **Step 3: TODO.md**

Вычеркнуть пункт, начинающийся «Неоконченный `OSC`, который не ссылка».
Он закрыт целиком — если что-то из него осталось незакрытым, не вычёркивать,
а переписать пункт под то, что осталось, и сказать об этом в отчёте.

- [ ] **Step 4: Ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test
dart doc --dry-run
git add -A
git commit
```

---

## Ворота перед мержем

После Task 5, на ветке:

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
dart test
dart run benchmark/memory_guard.dart
dart doc --dry-run
for f in example/*.dart; do
  [ "$f" = "example/utils.dart" ] && continue
  timeout 60 dart run "$f" > /dev/null < /dev/null
done
dart pub publish --dry-run
```

Все должны быть зелёными, `publish --dry-run` — 0 warnings.
