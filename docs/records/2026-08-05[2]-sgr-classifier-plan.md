# Унификация SGR-классификатора — план имплементации

> **Состояние документа**
>
> - **Тип:** план, 2026-08-05, по дизайну `2026-08-05[1]`
> - **Статус:** выполнен, влит в `main` мержем `812836b` (PR #12)
> - **Актуальность:** вердикт по пункту #3 — в отчёте `2026-08-05[9]`
> - **Пути:** ссылки в тексте старые — записи с тех пор лежат в
>   `docs/records/`, `TODO.md` стал `docs/backlog.md`, текущий handoff —
>   `docs/handoff.md`

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** одна семантика SGR для парсера и regex-пути — фиксы M2, M3, L4 и
unknown-kind-расхождения по спеке `docs/2026-08-05[1]-sgr-classifier-design.md`.

**Architecture:** три коммита в ветке `fix/sgr-classifier`: (1) сужение
`sgrRe` — приватные CSI на `m` перестают считаться SGR; (2) лист-модуль
`internal/sgr_rules.dart` — правило потребления расширенного цвета — и
переписанный на него `splitSgrFunctions`; (3) фаззинговый agreement-тест
has*/remove* против парсера + парсер берёт счётчик аргументов из ядра.

**Tech Stack:** Dart ≥3, `package:test`.

## Global Constraints

- Ветка `fix/sgr-classifier` от текущего `main`.
- Существующие тест-файлы **не редактируются** (в частности
  `remove_agrees_with_parser_test.dart` — новый agreement живёт в новом
  файле).
- Перед каждым коммитом зелёные: `dart format .` (идемпотентен),
  `dart test`, `dart analyze --fatal-infos`.
- Версия 4.0.0 не трогается. CHANGELOG-строки — в конец секции `Fixed:`
  записи `## 4.0.0` (сейчас последняя — про суррогатные пары, перед
  `Renamed:`).
- Поведение парсера не меняется — он эталон; это держат существующие
  тесты и новый agreement-фаззинг.
- Сообщения коммитов: conventional-префикс, строчные, английские, в
  стиле репозитория.

Справка по константам (`lib/src/ansi/sgr.dart`): `FOREGROUND = 38`,
`BACKGROUND = 48`, `UNDERLINE_COLOR = 58`, `COLOR_256 = 5`,
`COLOR_RGB = 2`.

---

### Task 1: L4 — сужение `sgrRe`

**Files:**
- Modify: `lib/src/parsing/patterns/patterns.dart:18`
- Create: `test/sgr_private_csi_test.dart`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `ansiHasSgr`/`ansiHasCsi` (`lib/src/extensions/has.dart`),
  `ansiRemoveSgr`/`ansiRemoveCsi`/`ansiRemoveForeground`
  (`lib/src/extensions/remove.dart`) — все из
  `package:ansi_escape_codes/ansi_escape_codes.dart`.
- Produces: `sgrPattern` c params `[0-9;:]*` — грамматика, по которой
  Task 2 пишет корпус разбиения.

- [ ] **Step 1: Создать ветку**

```bash
git checkout main && git checkout -b fix/sgr-classifier
```

- [ ] **Step 2: Написать тест**

Создать `test/sgr_private_csi_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('a private control sequence ending in m:', () {
    test('is not SGR', () {
      expect('\x1B[?5m'.ansiHasSgr, isFalse);
      expect('\x1B[>4;1m'.ansiHasSgr, isFalse);
      expect('\x1B[<35;10;2m'.ansiHasSgr, isFalse);
      expect('\x1B[=5m'.ansiHasSgr, isFalse);
    });

    test('is still CSI', () {
      expect('\x1B[?5m'.ansiHasCsi, isTrue);
      expect('\x1B[?5m'.ansiRemoveCsi(), '');
    });

    test('survives the removal of styles', () {
      expect('\x1B[>4;1m'.ansiRemoveSgr(), '\x1B[>4;1m');
      expect(
        'a\x1B[<35;10;2mb\x1B[31mc'.ansiRemoveSgr(),
        'a\x1B[<35;10;2mbc',
      );
    });

    test('is no colour to the colour surfaces', () {
      // A pin: the textual split never saw ?38 as a colour either.
      expect('\x1B[?38;5;196m'.ansiHasForeground, isFalse);
      expect('\x1B[?38;5;196m'.ansiRemoveForeground(), '\x1B[?38;5;196m');
    });

    test('what is SGR still is', () {
      expect('\x1B[1;38;5;196m'.ansiHasSgr, isTrue);
      expect('\x1B[4:3m'.ansiHasSgr, isTrue);
      expect('\x1B[;1m'.ansiHasSgr, isTrue);
      expect('\x1B[m'.ansiHasSgr, isTrue);
      expect('\x1B[038;5;196m'.ansiHasSgr, isTrue);
      expect('\x1B[1m'.ansiRemoveSgr(), '');
    });
  });
}
```

- [ ] **Step 3: Убедиться в падении (RED)**

Run: `dart test test/sgr_private_csi_test.dart`
Expected: FAIL «is not SGR» (все четыре сейчас true) и «survives the
removal of styles» (сейчас удаляются). «is no colour…» и остальные —
зелёные пины текущего поведения.

- [ ] **Step 4: Фикс**

В `lib/src/parsing/patterns/patterns.dart` заменить строку 18:

```dart
    '(?<params>[0-9:;<=>?]*)'
```

на:

```dart
    // Digits, `;` and `:` only: a params field with a private byte —
    // `?5`, `>4;1`, the SGR-mouse `<35;10;2` — is a private sequence,
    // not SGR, exactly as the parser classifies it.
    '(?<params>[0-9;:]*)'
```

- [ ] **Step 5: Прогнать (GREEN)**

```bash
dart test test/sgr_private_csi_test.dart
dart test
```

Expected: PASS всё; существующие 331+ тестов зелёные без правок.

- [ ] **Step 6: CHANGELOG**

В конец секции `Fixed:` записи `## 4.0.0` (после буллета про суррогатные
пары, перед `Renamed:`):

```markdown
- `ansiHasSgr` and `ansiRemoveSgr` counted private control sequences
  ending in `m` — xterm's modifyOtherKeys, SGR mouse reports — as SGR,
  and removing styles removed them too. The pattern now takes digits,
  `;` and `:` only, the way the parser classifies them.
```

- [ ] **Step 7: Полная проверка и коммит**

```bash
dart format .
dart test
dart analyze --fatal-infos
git add lib/src/parsing/patterns/patterns.dart \
  test/sgr_private_csi_test.dart CHANGELOG.md
git commit -m "fix: a private sequence ending in m is no SGR

The params field of sgrRe accepted the private bytes <=>?, so xterm's
modifyOtherKeys and SGR mouse reports counted as SGR to ansiHasSgr and
were eaten by ansiRemoveSgr. The pattern now takes digits, ; and :
only, the way the parser classifies these sequences."
```

---

### Task 2: Ядро правил + `splitSgrFunctions` (M3 + M2 + unknown-kind)

**Files:**
- Create: `lib/src/internal/sgr_rules.dart`
- Modify: `lib/src/internal/sgr_functions.dart:11-39` (`splitSgrFunctions`)
- Create: `test/sgr_functions_test.dart`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: константы `FOREGROUND`/`BACKGROUND`/`UNDERLINE_COLOR`/
  `COLOR_256`/`COLOR_RGB` из `lib/src/ansi/sgr.dart`; грамматику params
  `[0-9;:]*` из Task 1.
- Produces: `bool isExtendedColorIntroducer(int value)` и
  `int extendedColorArgCount(int kind)` в
  `lib/src/internal/sgr_rules.dart` — Task 3 импортирует их в парсер.

- [ ] **Step 1: Написать тест**

Создать `test/sgr_functions_test.dart` (импорт из `src` своего пакета в
тестах допустим — lint `implementation_imports` относится только к чужим
пакетам):

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/src/internal/sgr_functions.dart';
import 'package:test/test.dart';

void main() {
  group('splitSgrFunctions:', () {
    test('a whole colour stays together', () {
      expect(splitSgrFunctions('38;5;196'), ['38;5;196']);
      expect(splitSgrFunctions('48;2;1;2;3'), ['48;2;1;2;3']);
      expect(splitSgrFunctions('58;5;196'), ['58;5;196']);
      expect(splitSgrFunctions('1;38;5;196;4'), ['1', '38;5;196', '4']);
    });

    test('leading zeroes read as numbers', () {
      expect(splitSgrFunctions('038;5;196'), ['038;5;196']);
      expect(splitSgrFunctions('38;05;196'), ['38;05;196']);
    });

    test('a colour cut short gives up the introducer and the kind alone',
        () {
      expect(splitSgrFunctions('38;2;1;2'), ['38;2', '1', '2']);
      expect(splitSgrFunctions('48;2;1;2'), ['48;2', '1', '2']);
      expect(splitSgrFunctions('38;5'), ['38;5']);
      expect(splitSgrFunctions('58;5'), ['58;5']);
      expect(splitSgrFunctions('38'), ['38']);
    });

    test('an unknown kind is consumed with the introducer', () {
      expect(splitSgrFunctions('38;7;1'), ['38;7', '1']);
      expect(splitSgrFunctions('58;9;1'), ['58;9', '1']);
    });

    test('the colon form is one parameter and stays whole', () {
      expect(splitSgrFunctions('38:5:196'), ['38:5:196']);
      expect(splitSgrFunctions('38:2::1:2:3;1'), ['38:2::1:2:3', '1']);
      expect(splitSgrFunctions('38;4:3'), ['38;4:3']);
    });

    test('empty parameters split as themselves', () {
      expect(splitSgrFunctions(''), <String>[]);
      expect(splitSgrFunctions(';'), ['', '']);
      expect(splitSgrFunctions('38;'), ['38;']);
    });
  });

  group('the colour surfaces after the split:', () {
    test('a colour cut short no longer eats its neighbours', () {
      expect('\x1B[38;2;1;2mX'.ansiRemoveForeground(), '\x1B[1;2mX');
      expect('\x1B[38;2;1;2mX'.ansiHasForeground, isTrue);
    });

    test('leading zeroes no longer hide the colour', () {
      expect('\x1B[38;05;196mX'.ansiRemoveForeground(), 'X');
      expect('\x1B[038;5;196mX'.ansiRemoveForeground(), 'X');
      expect('\x1B[38;05;196mX'.ansiHasForeground, isTrue);
    });

    test('an unknown kind leaves no lone parameter behind', () {
      expect('\x1B[38;7;1mX'.ansiRemoveForeground(), '\x1B[1mX');
    });

    test('what was right stays right', () {
      expect('\x1B[1;38;5;196;4mX'.ansiRemoveForeground(), '\x1B[1;4mX');
      expect('\x1B[38;5;196mX'.ansiRemoveForeground(), 'X');
      expect('\x1B[31;42mX'.ansiRemoveForeground(), '\x1B[42mX');
    });
  });
}
```

- [ ] **Step 2: Убедиться в падении (RED)**

Run: `dart test test/sgr_functions_test.dart`
Expected: FAIL — «leading zeroes…» (оба варианта: текстовое сравнение не
видит `038`/`05`), «a colour cut short…» (клампинг съедает `1;2`),
«an unknown kind…» (сейчас потребляется только интродьюсер), `'38;'` и
`'38;4:3'` (сейчас распадаются). «a whole colour…» и «what was right…» —
зелёные пины.

- [ ] **Step 3: Ядро правил**

Создать `lib/src/internal/sgr_rules.dart`:

```dart
/// The one place the shape of an extended colour lives.
///
/// `38`, `48` and `58` open a colour whose arguments follow as parameters
/// of their own. The introducer and the kind are consumed together, and
/// the kind's arguments only when all of them are there: anything short —
/// a kind with no arguments left to take, an RGB cut off mid-colour —
/// leaves the introducer and the kind consumed alone, and the rest
/// belongs to the sequence as usual. This is the parser's rule;
/// `splitSgrFunctions` reads it from here, so the two readings cannot
/// drift apart again.
library;

import '../ansi/sgr.dart';

/// Whether [value] introduces an extended colour: the colour of the text,
/// of what is behind it, or of the underline.
bool isExtendedColorIntroducer(int value) =>
    value == FOREGROUND || value == BACKGROUND || value == UNDERLINE_COLOR;

/// How many arguments the kind of an extended colour takes: one for the
/// 256-colour table, three for RGB, none for a kind this package does
/// not know.
int extendedColorArgCount(int kind) => switch (kind) {
      COLOR_256 => 1,
      COLOR_RGB => 3,
      _ => 0,
    };
```

- [ ] **Step 4: Переписать `splitSgrFunctions`**

В `lib/src/internal/sgr_functions.dart` добавить импорт:

```dart
import 'sgr_rules.dart';
```

и заменить тело `splitSgrFunctions` (строки 11-39, dartdoc функции
оставить) на:

```dart
List<String> splitSgrFunctions(String params) {
  if (params.isEmpty) {
    return const [];
  }

  final parts = params.split(';');
  final functions = <String>[];

  for (var i = 0; i < parts.length;) {
    var length = 1;

    // A parameter that is a whole number can open an extended colour;
    // the colon form carries its arguments inside one parameter and
    // stays whole on its own. Numbers are read as numbers: ECMA-48
    // allows leading zeroes, and `038` is `38`.
    final head = int.tryParse(parts[i]);

    if (head != null &&
        isExtendedColorIntroducer(head) &&
        i + 1 < parts.length) {
      // The introducer and the kind go together, the kind's arguments
      // only when all of them are there — the rule lives in sgr_rules.
      length = 2;
      final kind = int.tryParse(parts[i + 1]);
      if (kind != null) {
        final args = extendedColorArgCount(kind);
        if (i + 2 + args <= parts.length) {
          length = 2 + args;
        }
      }
    }

    functions.add(parts.sublist(i, i + length).join(';'));
    i += length;
  }

  return functions;
}
```

Приватный `_isExtendedColor` (строки 87-90) после этого не используется —
удалить. Предикаты `isForegroundFunction`/`isBackgroundFunction`/
`isUnderlineColorFunction` и `_head` не меняются.

- [ ] **Step 5: Прогнать (GREEN)**

```bash
dart test test/sgr_functions_test.dart
dart test
```

Expected: PASS всё, включая существующий
`remove_agrees_with_parser_test.dart` (5 000 кейсов) без правок.

- [ ] **Step 6: CHANGELOG**

В конец секции `Fixed:` (после буллета Task 1):

```markdown
- `ansiRemoveForeground` and its background and underline siblings ate
  the parameters after a colour cut short: `\x1B[38;2;1;2m` lost its
  bold and dim along with the broken colour. A colour missing arguments
  now gives up only its introducer and kind, the way the parser reads
  it — and the same goes for a kind the package does not know.
- Leading zeroes hid a colour from the same functions: removing the
  colour from `\x1B[38;05;196m` removed everything but it. Parameters
  are now read as numbers, as ECMA-48 allows them to be written.
```

- [ ] **Step 7: Полная проверка и коммит**

```bash
dart format .
dart test
dart analyze --fatal-infos
git add lib/src/internal/sgr_rules.dart lib/src/internal/sgr_functions.dart \
  test/sgr_functions_test.dart CHANGELOG.md
git commit -m "fix: the split reads a colour the way the parser does

splitSgrFunctions compared parameters as text and clamped a colour cut
short to the end of the sequence, eating the functions after it. It now
reads numbers as numbers (leading zeroes included), takes the argument
count from sgr_rules — the one place the shape of an extended colour
lives — and a colour missing arguments gives up only its introducer
and kind, unknown kinds the same."
```

---

### Task 3: Agreement-фаззинг + adoption в парсере

**Files:**
- Create: `test/has_agrees_with_parser_test.dart`
- Modify: `lib/src/parsing/parser/parser.dart:1-24` (один импорт)
- Modify: `lib/src/parsing/parser/entities/sgr.dart:226-260`
  (`_parseColorFunctionFromParams`)
- Не трогать: `test/remove_agrees_with_parser_test.dart`

**Interfaces:**
- Consumes: `isExtendedColorIntroducer`/`extendedColorArgCount` из Task 2;
  `Sgr` (поле `functions`), `SgrFunctionWithCode` (поле `code`),
  `ControlFunctionsSGR.fg`/`bg`/`underlineColor`; ordinal enum'а равен
  номеру SGR-функции (`ControlFunctionsSGR.fg.index == 38`).
- Produces: ничего нового наружу; поведение парсера байт-в-байт прежнее.

- [ ] **Step 1: Написать agreement-тест**

Создать `test/has_agrees_with_parser_test.dart`:

```dart
import 'dart:math';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The pieces a terminal stream is made of, the SGR-shaped troublemakers
/// included: colours cut short, leading zeroes, kinds nobody knows,
/// private sequences ending in the SGR final.
const _fragments = <String>[
  'text',
  'a',
  '𝄞',
  '\x1B[31m',
  '\x1B[39m',
  '\x1B[41m',
  '\x1B[49m',
  '\x1B[97m',
  '\x1B[107m',
  '\x1B[0m',
  '\x1B[m',
  '\x1B[;m',
  '\x1B[1;31m',
  '\x1B[38;5;196m',
  '\x1B[48;5;21m',
  '\x1B[58;5;93m',
  '\x1B[38;2;1;2;3m',
  '\x1B[58;2;1;2;3m',
  '\x1B[38:2::1:2:3m',
  '\x1B[58:2::1:2:3m',
  '\x1B[4:3m',
  '\x1B[59m',
  '\x1B[38;2;1;2m',
  '\x1B[38;05;196m',
  '\x1B[038;5;196m',
  '\x1B[38;7;1m',
  '\x1B[58;5m',
  '\x1B[38m',
  '\x1B[?5m',
  '\x1B[>4;1m',
  '\x1B[<35;10;2m',
  '\x1B[38;5;',
  '\x1B[31',
  '\x1B',
];

/// What the parser read as touching one colour slot: a colour function on
/// it, or a simple code from its rows of the SGR table.
bool _parserHas(
  String text,
  ControlFunctionsSGR target,
  bool Function(int code) simple,
) {
  for (final m in Parser(text).matches) {
    if (m.entity case Sgr(:final functions)) {
      for (final f in functions) {
        if (f is SgrFunctionWithCode &&
            (f.code == target || simple(f.code.index))) {
          return true;
        }
      }
    }
  }

  return false;
}

bool _fgSimple(int n) => n >= 30 && n <= 37 || n == 39 || n >= 90 && n <= 97;
bool _bgSimple(int n) =>
    n >= 40 && n <= 47 || n == 49 || n >= 100 && n <= 107;
bool _underlineSimple(int n) => n == 59;

void main() {
  group('the colour surfaces and the parser agree:', () {
    test('has answers as the parser reads, whatever is thrown at it', () {
      // The seed is fixed so that a failure can be looked at again.
      final random = Random(20260805);

      for (var i = 0; i < 5000; i++) {
        final parts = [
          for (var j = 0; j < random.nextInt(6) + 1; j++)
            _fragments[random.nextInt(_fragments.length)],
        ];
        final text = parts.join();
        final reason = 'on ${text.codeUnits}';

        expect(
          text.ansiHasForeground,
          _parserHas(text, ControlFunctionsSGR.fg, _fgSimple),
          reason: reason,
        );
        expect(
          text.ansiHasBackground,
          _parserHas(text, ControlFunctionsSGR.bg, _bgSimple),
          reason: reason,
        );
        expect(
          text.ansiHasUnderlineColor,
          _parserHas(
            text,
            ControlFunctionsSGR.underlineColor,
            _underlineSimple,
          ),
          reason: reason,
        );
      }
    });

    test(
        'what remove took out, has no longer sees — '
        'and what is left reads one way', () {
      final random = Random(20260806);

      for (var i = 0; i < 2000; i++) {
        final parts = [
          for (var j = 0; j < random.nextInt(6) + 1; j++)
            _fragments[random.nextInt(_fragments.length)],
        ];
        final text = parts.join();
        final reason = 'on ${text.codeUnits}';

        expect(
          text.ansiRemoveForeground().ansiHasForeground,
          isFalse,
          reason: reason,
        );
        expect(
          text.ansiRemoveBackground().ansiHasBackground,
          isFalse,
          reason: reason,
        );
        expect(
          text.ansiRemoveUnderlineColor().ansiHasUnderlineColor,
          isFalse,
          reason: reason,
        );
        // On the stripped string, not the original: removing a complete
        // sequence can let a truncated neighbour absorb the following
        // character (`\x1B[31` + `t` is a complete CSI), so the plain
        // text of the original is not preserved on malformed input —
        // pre-existing behaviour, not a classifier question. What must
        // hold is that both readings agree on what removal left behind.
        final stripped = text.ansiRemoveForeground();
        expect(
          stripped.ansiRemoveEscapeCodes(),
          Parser(stripped).removeAll(),
          reason: reason,
        );
      }
    });
  });
}
```

- [ ] **Step 2: Прогнать — фаззинг должен быть зелёным уже сейчас**

Run: `dart test test/has_agrees_with_parser_test.dart`
Expected: PASS — Task 1 и Task 2 уже выровняли пути. Это не red-green,
а сеть на будущее; RED-функцию несёт sabotage-проверка Step 3.

- [ ] **Step 3: Sabotage-проверка сети**

Ломается сам предикат — класс регресса, который ловит именно фаззинг
(регресс клампинга ловит юнит-корпус Task 2, это уже доказано его
red-фазой). В `_isColorFunction` (`lib/src/internal/sgr_functions.dart`)
временно удалить строку:

```dart
          value == base + 9 ||
```

— `isForegroundFunction` перестаёт видеть `39` (fgDefault), а
`isBackgroundFunction` — `49`; парсер их видит.

Run: `dart test test/has_agrees_with_parser_test.dart`
Expected: FAIL (фрагменты `\x1B[39m`/`\x1B[49m` разводят has и парсер).
Откатить: `git checkout -- lib/src/internal/sgr_functions.dart`.

- [ ] **Step 4: Adoption — парсер берёт счётчик из ядра**

В `lib/src/parsing/parser/parser.dart` добавить к импортам (по алфавиту,
после `../../extensions/show_escape_codes.dart`):

```dart
import '../../internal/sgr_rules.dart';
```

В `lib/src/parsing/parser/entities/sgr.dart`,
`_parseColorFunctionFromParams`, заменить:

```dart
      if (kind is CsiParamNumber) {
        if (kind.value == COLOR_256 && parsingState.availableParamsCount >= 1) {
```

на:

```dart
      if (kind is CsiParamNumber) {
        // How many arguments the kind takes is sgr_rules' knowledge,
        // shared with splitSgrFunctions.
        final args = extendedColorArgCount(kind.value);

        if (kind.value == COLOR_256 &&
            parsingState.availableParamsCount >= args) {
```

и ниже в том же методе заменить:

```dart
        } else if (kind.value == COLOR_RGB &&
            parsingState.availableParamsCount >= 3) {
```

на:

```dart
        } else if (kind.value == COLOR_RGB &&
            parsingState.availableParamsCount >= args) {
```

Colon-ветка `_parseColorFunctionFromValues` не трогается: её счёт связан
с локальной адресацией `values` (см. спеку — «если контортит, остаётся
как есть»).

- [ ] **Step 5: Прогнать (эквивалентность)**

```bash
dart test
dart analyze --fatal-infos
```

Expected: все тесты зелёные — переформулировка эквивалентна
(`extendedColorArgCount(COLOR_256) == 1`, `(COLOR_RGB) == 3`).

- [ ] **Step 6: Полная проверка и коммит**

```bash
dart format .
git add test/has_agrees_with_parser_test.dart \
  lib/src/parsing/parser/parser.dart \
  lib/src/parsing/parser/entities/sgr.dart
git commit -m "refactor: the parser reads the colour's shape from sgr_rules

The argument count of an extended colour now comes from the same place
splitSgrFunctions takes it, and a fuzzed agreement test holds the has
surfaces, the remove surfaces and the parser to one answer — malformed
colours, leading zeroes, unknown kinds and private sequences included."
```

CHANGELOG не трогается: пользовательское поведение не меняется.

---

### Task 4: Финальная проверка ветки и PR

**Files:** ничего нового, кроме находок ревью.

**Interfaces:**
- Consumes: ветка `fix/sgr-classifier` с тремя коммитами Task 1-3.
- Produces: PR в `main`.

- [ ] **Step 1: Полный прогон**

```bash
dart format --set-exit-if-changed .
dart analyze --fatal-infos
dart test
dart pub publish --dry-run
```

Expected: всё чистое; dry-run — 0 предупреждений.

- [ ] **Step 2: Whole-branch ревью**

Финальное ревью всей ветки по процессу subagent-driven-development,
сверка со спекой `docs/2026-08-05[1]-sgr-classifier-design.md`. Находки —
отдельными fixup-коммитами до пуша.

- [ ] **Step 3: Пуш и PR**

```bash
git push -u origin fix/sgr-classifier
gh pr create --title "fix: one SGR classifier for the parser and the regex path (M2, M3, L4)" \
  --body "$(cat <<'EOF'
## Summary
- fix: private control sequences ending in m are no SGR to ansiHasSgr /
  ansiRemoveSgr (L4)
- fix: a colour cut short gives up only its introducer and kind — bold
  and dim survive `\x1B[38;2;1;2m` (M2); unknown kinds consume the same
  pair
- fix: parameters are read as numbers — leading zeroes no longer hide a
  colour (M3)
- refactor: the shape of an extended colour lives in one place
  (internal/sgr_rules.dart), read by both splitSgrFunctions and the
  parser; a fuzzed agreement test (has*/remove* vs parser, fixed seed)
  holds the paths to one answer

Per docs/2026-08-05[1]-sgr-classifier-design.md; findings from
docs/2026-08-04[1]-project-review.md (#3 in the action plan). One fix per
commit, red-green throughout; the parser's behaviour is byte-for-byte
unchanged.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Публикация 4.0.0 и тег — **не в этом PR**; отдельное решение
пользователя.
