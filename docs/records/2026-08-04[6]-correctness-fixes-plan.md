# Корректность-фиксы 4.0.0 — план имплементации

> **Состояние на 2026-08-16:** выполнен и влит в `main` мержем `7373f69`
> (PR #11). Вердикты по H1, H2, M1, M8 — в отчёте `2026-08-05[9]`: все
> четыре закрыты, хвосты N3 и N4 добрала волна `56c8244`.
> **Что это:** план имплементации фиксов корректности по дизайну
> `2026-08-04[5]`.
> **Связанные записи:** `2026-08-04[1]-pre-4.0.0-project-review.md`,
> `2026-08-04[4]-correctness-fixes-report.md`,
> `2026-08-04[5]-correctness-fixes-design.md`,
> `2026-08-05[9]-review-verification-report.md`,
> `2026-08-05[10]-verification-fixes-plan.md`.

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** четыре корректность-фикса ревью 4.0.0 — свип таблиц цветов (M8),
порядок восстановления режимов терминала на Windows (H1), закрытие
гиперссылки в `substring` (M1), сдвиг вставки с середины суррогатной пары
(H2) — по спеке `docs/2026-08-04[5]-correctness-fixes-design.md`.

**Architecture:** каждый фикс — один коммит в ветке `fix/review-correctness`
(red-тест + фикс + CHANGELOG в том же коммите), порядок M8 → H1 → M1 → H2.
M8 — только тесты (mirrors-свип + source-проверка), кода пакета не трогает.
H1 — вложенный try/finally в `current_cursor_pos.dart`. M1 — отслеживание
эмитированной ссылки в `Parser.substring`. H2 — самоперевызов `_seamAt`
глубиной 1.

**Tech Stack:** Dart ≥3, `package:test`, `dart:mirrors` (только в тестах,
тесты и так VM-only).

## Global Constraints

- Ветка: `fix/review-correctness` от текущего локального `main`.
- Существующие тест-файлы **не редактируются** (фейки и хелперы дублируются
  в новые файлы — паттерн проекта).
- Перед каждым коммитом зелёные: `dart test`, `dart analyze --fatal-infos`,
  `dart format --set-exit-if-changed .` (запускать `dart format .` до
  проверки).
- Версия пакета не меняется: 4.0.0, не опубликована. CHANGELOG-строки
  добавляются в конец существующей секции `Fixed:` записи `## 4.0.0`
  (сейчас CHANGELOG.md:83).
- Сообщения коммитов: conventional-префикс, строчные, английские, в стиле
  репозитория («fix: the terminal comes back …»).
- Стиль кода и dartdoc — как в файле, который правишь: прозаические
  комментарии, никаких «obvious what» комментариев.
- Позиции API — UTF-16 code units; это фиксированное решение спеки, не
  перерешивать.

---

### Task 1: M8 — свип таблиц цветов (тесты и есть фикс)

**Files:**
- Create: `test/color_tables_test.dart`
- Никакие файлы `lib/` не меняются.

**Interfaces:**
- Consumes: `Colors` (enum, 256 значений, `lib/src/parsing/colors/color_indexes.dart`),
  `Color256` (256 статиков + `Color256(Colors.x)`, `==` сравнивает только
  `color`), `Styles` (783 static const `Style`), `Style` (конструктор с
  `bold:`/`foreground:`/`background:`/`underlineColor:` и `==` по видимой
  поверхности), функции `fg256(int)`, `bg256(int)`, `underline256(int)`.
  Всё экспортируется из `package:ansi_escape_codes/ansi_escape_codes.dart`.
- Produces: страховочная сетка для Task 2–4 и будущего генератора (#12).

Факты, на которые опирается тест (проверены в спеке по исходникам):

- `Colors.values`: 16 именованных + 216 `rgbRGB` (R,G,B ∈ 0..5) + 24
  `grayN` (0..23); `Colors.values[i].index == i`.
- `Styles`: 15 свойств (`bold`…`subscript`) + на каждый цвет `<name>`,
  `bg<Name>`, `underline<Name>`; формула
  `Style(foreground: Color256.on(Colors.<name>, ColorTarget.foreground))`
  (для bg/underline — свой слот). `Color256.on` — `@internal`, в тесте не
  используется: `Color256.==` игнорирует target, поэтому сверка через
  `Style(foreground: Color256(color))` эквивалентна.
- `StyleColors` (`lib/src/parsing/state/style_colors.dart`): 512 геттеров
  `Style get <name> => foreground(Color256.<name>);` и
  `Style get bg<Name> => background(Color256.<name>);`. Underline-геттеров
  нет. Mirrors расширений не видят — только source-проверка.
- `fg256.dart`/`bg256.dart`/`underline256.dart`: по 256 констант
  `const String fg256<Name> = '$fg256Open$<INDEX>$fg256Close';` плюс
  `<prefix>Open`, `<prefix>Close` и функция `<prefix>(int)`.

- [ ] **Step 1: Создать ветку**

```bash
git checkout main && git checkout -b fix/review-correctness
```

- [ ] **Step 2: Написать тест-файл целиком**

Создать `test/color_tables_test.dart`:

```dart
@TestOn('vm')
library;

import 'dart:io';
import 'dart:mirrors';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// `bgHighRed` and `fg256Rgb013` spell a colour with its first letter up.
String _cap(String name) => name[0].toUpperCase() + name.substring(1);

/// The library a table of top-level constants lives in.
LibraryMirror _library(String pathEnd) => currentMirrorSystem()
    .libraries
    .entries
    .firstWhere((e) => e.key.path.endsWith(pathEnd))
    .value;

void main() {
  group('Styles:', () {
    final styles = reflectClass(Styles);

    test('holds the 15 properties and the 256 colours thrice, nothing else',
        () {
      final consts = styles.declarations.values
          .whereType<VariableMirror>()
          .where((d) => d.isStatic && d.isConst);
      expect(consts, hasLength(783));
    });

    test('each property style carries its own property', () {
      const expected = {
        'bold': Style(bold: true),
        'dim': Style(dim: true),
        'italic': Style(italic: true),
        'underline': Style(underline: true),
        'doublyUnderline': Style(doublyUnderline: true),
        'blink': Style(blink: true),
        'blinkRapid': Style(blinkRapid: true),
        'inverse': Style(inverse: true),
        'invisible': Style(invisible: true),
        'strikethrough': Style(strikethrough: true),
        'frame': Style(frame: true),
        'encircle': Style(encircle: true),
        'overline': Style(overline: true),
        'superscript': Style(superscript: true),
        'subscript': Style(subscript: true),
      };

      for (final MapEntry(key: name, value: style) in expected.entries) {
        expect(
          styles.getField(Symbol(name)).reflectee,
          style,
          reason: 'Styles.$name',
        );
      }
    });

    test('each colour name carries its colour in its slot', () {
      for (final color in Colors.values) {
        final name = color.name;

        expect(
          styles.getField(Symbol(name)).reflectee,
          Style(foreground: Color256(color)),
          reason: 'Styles.$name',
        );
        expect(
          styles.getField(Symbol('bg${_cap(name)}')).reflectee,
          Style(background: Color256(color)),
          reason: 'Styles.bg${_cap(name)}',
        );
        expect(
          styles.getField(Symbol('underline${_cap(name)}')).reflectee,
          Style(underlineColor: Color256(color)),
          reason: 'Styles.underline${_cap(name)}',
        );
      }
    });
  });

  group('Color256:', () {
    final color256 = reflectClass(Color256);

    test('names every colour of the table after its index', () {
      for (final color in Colors.values) {
        expect(
          color256.getField(Symbol(color.name)).reflectee,
          Color256(color),
          reason: 'Color256.${color.name}',
        );
      }
    });

    test('and holds no colour besides', () {
      final consts = color256.declarations.values
          .whereType<VariableMirror>()
          .where((d) => d.isStatic && d.isConst);
      expect(consts, hasLength(256));
    });
  });

  group('the ready-to-use 256-colour strings:', () {
    final tables = <String, (LibraryMirror, String Function(int))>{
      'fg256': (_library('colors256/fg256.dart'), fg256),
      'bg256': (_library('colors256/bg256.dart'), bg256),
      'underline256': (
        _library('colors256/underline256.dart'),
        underline256,
      ),
    };

    for (final MapEntry(key: prefix, value: (lib, func)) in tables.entries) {
      test('$prefix* agree with $prefix()', () {
        for (final color in Colors.values) {
          expect(
            lib.getField(Symbol('$prefix${_cap(color.name)}')).reflectee,
            func(color.index),
            reason: '$prefix${_cap(color.name)}',
          );
        }
      });

      test('$prefix* name all 256 colours and nothing else', () {
        final names = lib.declarations.values
            .whereType<VariableMirror>()
            .where((d) => d.isConst)
            .map((d) => MirrorSystem.getName(d.simpleName))
            .where((n) => n != '${prefix}Open' && n != '${prefix}Close');
        expect(names, hasLength(256));
      });
    }
  });

  group('StyleColors, checked at the source — mirrors cannot see it:', () {
    final source = File('lib/src/parsing/state/style_colors.dart')
        .readAsStringSync();

    test('each getter hands its own colour to its own slot, once', () {
      final getters = RegExp(
        r'Style get (\w+) =>\s*(foreground|background)\(Color256\.(\w+)\);',
      ).allMatches(source);

      final seen = <String>{};
      for (final m in getters) {
        final (getter, slot, color) = (m[1]!, m[2]!, m[3]!);

        expect(seen.add(getter), isTrue, reason: 'a second $getter');
        expect(
          getter,
          slot == 'foreground' ? color : 'bg${_cap(color)}',
          reason: '$getter took Color256.$color',
        );
      }

      for (final color in Colors.values) {
        expect(seen, contains(color.name));
        expect(seen, contains('bg${_cap(color.name)}'));
      }
      expect(seen, hasLength(512));
    });

    test('no getter fell outside the pattern', () {
      expect(RegExp('Style get ').allMatches(source), hasLength(512));
    });
  });
}
```

- [ ] **Step 3: Прогнать — таблицы сегодня корректны, всё зелёное**

Run: `dart test test/color_tables_test.dart`
Expected: PASS (все тесты).

- [ ] **Step 4: Sabotage-проверка — свип обязан кусаться**

По одной временной порче на механизм; после каждой — прогон, падение,
откат:

```bash
# 1. Styles: не тот цвет
sed -i '' 's/Style(foreground: Color256.on(Colors.red, ColorTarget.foreground))/Style(foreground: Color256.on(Colors.green, ColorTarget.foreground))/' lib/src/parsing/state/styles.dart
dart test test/color_tables_test.dart  # Expected: FAIL (Styles.red)
git checkout -- lib/src/parsing/state/styles.dart

# 2. StyleColors: не тот цвет в геттере
sed -i '' 's/Style get red => foreground(Color256.red);/Style get red => foreground(Color256.green);/' lib/src/parsing/state/style_colors.dart
dart test test/color_tables_test.dart  # Expected: FAIL (red took Color256.green)
git checkout -- lib/src/parsing/state/style_colors.dart

# 3. fg256: не тот индекс
sed -i '' "s/const String fg256Red = '\$fg256Open\$RED\$fg256Close';/const String fg256Red = '\$fg256Open\$GREEN\$fg256Close';/" lib/src/ready_to_use/sgr/colors256/fg256.dart
dart test test/color_tables_test.dart  # Expected: FAIL (fg256Red)
git checkout -- lib/src/ready_to_use/sgr/colors256/fg256.dart
```

После откатов: `git status` — рабочая копия чистая, кроме нового
тест-файла.

- [ ] **Step 5: Полная проверка**

```bash
dart format .
dart test
dart analyze --fatal-infos
```

Expected: формат без правок (кроме, возможно, нового файла), 302+ тестов
зелёные, analyze чистый.

- [ ] **Step 6: Commit**

```bash
git add test/color_tables_test.dart
git commit -m "test: the colour tables are swept against their formula

The 783 Styles constants, the 256 of Color256, the three tables of
ready-to-use strings and the 512 StyleColors getters were hand-written
and unchecked: a slot or index typo shipped silently. A mirrors sweep
checks the values, a source check covers the extension mirrors cannot
see. Sabotage-verified: each mechanism fails on a planted typo."
```

---

### Task 2: H1 — порядок восстановления режимов терминала

**Files:**
- Modify: `lib/src/utils/current_cursor_pos.dart:43-47`
- Create: `test/current_cursor_pos_windows_test.dart`
- Modify: `CHANGELOG.md` (секция Fixed записи 4.0.0)
- Не трогать: `test/current_cursor_pos_test.dart`

**Interfaces:**
- Consumes: `currentCursorPos(Stdout, Stdin, {timeout, input})` из
  `package:ansi_escape_codes/utils.dart`; `CSI` из
  `package:ansi_escape_codes/ansi.dart`.
- Produces: ничего нового; сигнатура не меняется.

- [ ] **Step 1: Написать падающий тест**

Создать `test/current_cursor_pos_windows_test.dart`:

```dart
import 'dart:async';
import 'dart:io';

import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/utils.dart';
import 'package:test/test.dart';

void main() {
  group('currentCursorPos against a Windows console:', () {
    test('comes back with the modes restored', () async {
      final stdin = _FakeWindowsStdin(Stream.value('${CSI}12;34R'.codeUnits));

      expect(await currentCursorPos(_FakeStdout(), stdin), (12, 34));
      expect(stdin.echoMode, isTrue);
      expect(stdin.lineMode, isTrue);
    });

    test('restores the modes when there is no answer', () async {
      final controller = StreamController<List<int>>();
      addTearDown(controller.close);
      final stdin = _FakeWindowsStdin(controller.stream);

      await expectLater(
        currentCursorPos(
          _FakeStdout(),
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

/// A [Stdin] with the rules the SDK documents for a Windows console: echo
/// only comes on while line mode is on, and line mode only goes off while
/// echo is off.
final class _FakeWindowsStdin implements Stdin {
  _FakeWindowsStdin(this._stream);

  final Stream<List<int>> _stream;

  bool _echoMode = true;
  bool _lineMode = true;

  @override
  bool get echoMode => _echoMode;

  @override
  set echoMode(bool value) {
    if (value && !_lineMode) {
      throw const StdinException(
        'echo mode cannot be enabled while line mode is disabled',
      );
    }
    _echoMode = value;
  }

  @override
  bool get lineMode => _lineMode;

  @override
  set lineMode(bool value) {
    if (!value && _echoMode) {
      throw const StdinException(
        'line mode cannot be disabled while echo mode is enabled',
      );
    }
    _lineMode = value;
  }

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
  @override
  void write(Object? object) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
```

- [ ] **Step 2: Убедиться, что тесты падают (RED)**

Run: `dart test test/current_cursor_pos_windows_test.dart`
Expected: FAIL оба теста. Восстановление начинается с
`echoMode = true` при ещё выключенном `lineMode`, фейк бросает
`StdinException`, наружу выходит `UnsupportedError` вместо `(12, 34)`,
и режимы остаются выключенными.

- [ ] **Step 3: Фикс — вложенный try/finally, lineMode первым**

В `lib/src/utils/current_cursor_pos.dart` заменить блок (строки 43-47):

```dart
    } finally {
      stdin
        ..echoMode = keepEchoMode
        ..lineMode = keepLineMode;
    }
```

на:

```dart
    } finally {
      // Line mode first, mirroring the way they were turned off: Windows
      // lets echo come back only once line mode is on. Nested, so a throw
      // restoring one does not keep the other from being restored.
      try {
        stdin.lineMode = keepLineMode;
      } finally {
        stdin.echoMode = keepEchoMode;
      }
    }
```

- [ ] **Step 4: Прогнать тесты (GREEN)**

```bash
dart test test/current_cursor_pos_windows_test.dart
dart test test/current_cursor_pos_test.dart
```

Expected: PASS оба файла. POSIX-эквивалентность: те же два присваивания
в другом порядке — 12 существующих тестов зелёные без правок.

- [ ] **Step 5: CHANGELOG**

В `CHANGELOG.md`, в конец секции `Fixed:` записи `## 4.0.0`, добавить:

```markdown
- On Windows the terminal modes were put back in an order the console
  refuses — echo first, line mode still off — so `currentCursorPos` threw
  and left the terminal raw. Line mode now comes back first, and each mode
  is restored even when the other throws.
```

- [ ] **Step 6: Полная проверка и коммит**

```bash
dart format .
dart test
dart analyze --fatal-infos
git add lib/src/utils/current_cursor_pos.dart \
  test/current_cursor_pos_windows_test.dart CHANGELOG.md
git commit -m "fix: the terminal modes come back in the order Windows allows

Restoring echo before line mode is refused by a Windows console, so
currentCursorPos threw and left the terminal raw. Line mode is restored
first, mirroring the way the modes were turned off, and each mode is
restored even when the other throws."
```

---

### Task 3: M1 — `substring` закрывает гиперссылку

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart` (метод `substring`,
  строки ~288-395)
- Create: `test/parser_substring_links_test.dart`
- Modify: `CHANGELOG.md`
- Не трогать: `test/parser_substring_differential_test.dart`,
  `test/parser_substring_trailing_codes_test.dart`

**Interfaces:**
- Consumes: `Link` (entity с `url`, пустой url — закрытие), `linkClose`,
  `linkOpen`, `linkTextOpen`, `link(url, {text})` из
  `package:ansi_escape_codes/ansi_escape_codes.dart`. `linkClose` уже
  импортирован в parser.dart (его использует `_closeLink`).
- Produces: `substring(start, {maxLength, close})` — сигнатура прежняя;
  при `close: true` срез, эмитировавший открытие ссылки без закрытия,
  завершается `linkClose` перед финальным `transitTo`.

- [ ] **Step 1: Написать тесты**

Создать `test/parser_substring_links_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  const url = 'https://example.com/';
  final linked = '${link(url, text: 'click')} tail';

  group('substring over a hyperlink:', () {
    test('closes the link the slice opened', () {
      expect(
        Parser(linked).substring(0, maxLength: 3),
        '$linkOpen$url$linkTextOpen' 'cli' '$linkClose',
      );
    });

    test('adds nothing when the slice closed it itself', () {
      expect(
        Parser(linked).substring(0, maxLength: 5),
        '$linkOpen$url$linkTextOpen' 'click' '$linkClose',
      );
    });

    test('gives the whole string back as it was', () {
      expect(Parser(linked).substring(0), linked);
    });

    test('does not close what it did not open', () {
      expect(Parser(linked).substring(2, maxLength: 2), 'ic');
    });

    test('close: false leaves the link open, as it leaves the style', () {
      expect(
        Parser(linked).substring(0, maxLength: 3, close: false),
        '$linkOpen$url$linkTextOpen' 'cli',
      );
    });

    test('a resumed walk stays outside a link it did not open', () {
      final parser = Parser(linked);

      expect(
        parser.substring(0, maxLength: 3),
        '$linkOpen$url$linkTextOpen' 'cli' '$linkClose',
      );
      // maxLength: 1, чтобы конец среза не дотянулся до входного linkClose,
      // стоящего на границе: коды на границе среза включаются по дизайну.
      expect(parser.substring(3, maxLength: 1), 'c');
    });
  });
}
```

- [ ] **Step 2: Убедиться в падении (RED)**

Run: `dart test test/parser_substring_links_test.dart`
Expected: FAIL «closes the link the slice opened» и первый expect в
«a resumed walk …» — сейчас срез обрывается с открытой ссылкой. Остальные
тесты зелёные (пиннинг текущего поведения).

- [ ] **Step 3: Фикс — отслеживать эмитированную ссылку**

В `substring` (parser.dart) три правки.

К локальным переменным (после `Match<S>? lastMatch;`):

```dart
    var linkIsOpen = false;
```

В ветке `case EscapeCode():` — после записи кода в буфер (внутри
существующего `if`):

```dart
        case EscapeCode():
          if (entity is! Sgr && pos >= start && (end == null || pos <= end)) {
            buf
              ..write(currentState.transitTo(m.state))
              ..write(entity.string);
            currentState = m.state.toStyle();
            if (entity is Link) {
              linkIsOpen = entity.url.isNotEmpty;
            }
          }
          lastMatch = m;
```

В финальном блоке — `linkClose` перед `transitTo`, зеркально `_insert`:

```dart
    if (lastMatch != null) {
      if (close && linkIsOpen) {
        // A slice that opened a link closes it, the way an insertion does:
        // what is printed after the slice must not stay clickable on the
        // slice's URL. A slice that began inside a link never wrote the
        // opening, and has nothing to close.
        buf.write(linkClose);
      }
      buf.write(
        currentState.transitTo(
          close ? initialState : lastMatch.state,
          skipSet: true,
        ),
      );
    }
```

- [ ] **Step 4: Прогнать (GREEN) и дифференциальные**

```bash
dart test test/parser_substring_links_test.dart
dart test test/parser_substring_differential_test.dart \
  test/parser_substring_trailing_codes_test.dart
```

Expected: PASS все.

- [ ] **Step 5: Dartdoc `close` в `substring`**

В dartdoc метода `substring` строку
`/// [close] is whether to close the substring with the default style.`
заменить на:

```dart
  /// [close] is whether to close the substring with the default style. A
  /// hyperlink the slice opened and did not close is closed along with it,
  /// the way an insertion closes one: what is printed after the slice must
  /// not stay clickable. With `close: false` the link stays open, as the
  /// style does. A slice that began inside a link does not repeat the
  /// opening, and is not the one to close it.
```

- [ ] **Step 6: CHANGELOG**

В конец секции `Fixed:` записи `## 4.0.0`:

```markdown
- `substring` left a hyperlink open: a slice that ended inside one kept
  everything printed after it clickable on the slice's URL. With
  `close: true` the slice now closes the link it opened, the way an
  insertion does.
```

- [ ] **Step 7: Полная проверка и коммит**

```bash
dart format .
dart test
dart analyze --fatal-infos
git add lib/src/parsing/parser/parser.dart \
  test/parser_substring_links_test.dart CHANGELOG.md
git commit -m "fix: a slice closes the hyperlink it opened

substring with close: true ended inside an open OSC 8 link and kept
everything printed after it clickable. The slice now tracks the link it
wrote into the buffer and closes it before the final transition, the way
an insertion does. A slice that began inside a link never wrote the
opening and appends nothing."
```

---

### Task 4: H2 — вставка не разрывает суррогатную пару

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart` (`_seamAt`, ~строка 500;
  dartdoc `insertBefore`/`insertAfter`/`length`/`padRight`/`padLeft`;
  два приватных хелпера рядом с `_Walk`)
- Create: `test/parser_insert_surrogates_test.dart`
- Modify: `README.md` (формулировки «counts what is seen»), `CHANGELOG.md`
- Не трогать: `test/parser_insert_test.dart`

**Interfaces:**
- Consumes: `Parser`, `StackedParser`, `insertBefore(pos, text)`,
  `insertAfter(pos, text)`, `removeAll()`, `length`; константы `fgRed`,
  `reset`, `bg256Red`, `link(url, {text})` из барреля.
- Produces: `_isHighSurrogate(int)`, `_isLowSurrogate(int)` — приватные
  хелперы parser.dart; поведение `insertBefore`/`insertAfter` на mid-pair
  позициях: сдвиг к границе пары по направлению вставки. Сигнатуры прежние.

- [ ] **Step 1: Написать тесты**

Создать `test/parser_insert_surrogates_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

bool _isHigh(int u) => (u & 0xFC00) == 0xD800;
bool _isLow(int u) => (u & 0xFC00) == 0xDC00;

/// Whether every surrogate in [s] is half of a whole pair.
bool _isValidUtf16(String s) {
  for (var i = 0; i < s.length; i++) {
    final u = s.codeUnitAt(i);
    if (_isHigh(u)) {
      if (i + 1 == s.length || !_isLow(s.codeUnitAt(i + 1))) {
        return false;
      }
      i++;
    } else if (_isLow(u)) {
      return false;
    }
  }

  return true;
}

/// Where the insertion is expected to land in the plain text: at [pos], or
/// shifted off the middle of a pair towards its edge.
int _landing(String plain, int pos, {required bool after}) {
  if (pos > 0 &&
      pos < plain.length &&
      _isHigh(plain.codeUnitAt(pos - 1)) &&
      _isLow(plain.codeUnitAt(pos))) {
    return after ? pos + 1 : pos - 1;
  }

  return pos;
}

void main() {
  group('an insertion aimed inside a surrogate pair:', () {
    test('insertBefore shifts to the front of the pair', () {
      expect(Parser('𝄞abc').insertBefore(1, 'X'), 'X𝄞abc');
    });

    test('insertAfter shifts past the pair', () {
      expect(Parser('𝄞abc').insertAfter(1, 'X'), '𝄞Xabc');
    });

    test('a styled string shifts the same way', () {
      expect(
        Parser('$fgRed𝄞$reset').insertBefore(1, 'X'),
        'X$fgRed𝄞$reset',
      );
    });

    test('StackedParser shifts the same way', () {
      expect(StackedParser('𝄞abc').insertBefore(1, 'X'), 'X𝄞abc');
    });

    test('a lone half next to a pair does not pull the shift further', () {
      // D834, then the pair D834 DD1E: position 2 is mid-pair, position 1
      // is between two highs — one step is always enough.
      expect(Parser('\uD834𝄞').insertBefore(2, 'X'), '\uD834X𝄞');
      expect(Parser('\uD834𝄞').insertAfter(2, 'X'), '\uD834𝄞X');
    });

    test('a pair the input broke with a code is left as it lies', () {
      // The halves are lone surrogates of the input itself: the library
      // does not mend invalid input, and the seam between them stays open.
      expect(
        Parser('\uD834$fgRed\uDD1E').insertBefore(1, 'X'),
        '\uD834X$fgRed\uDD1E',
      );
      expect(
        Parser('\uD834$fgRed\uDD1E').insertAfter(1, 'X'),
        '\uD834${fgRed}X\uDD1E',
      );
    });

    test('never breaks a pair anywhere in a mixed corpus', () {
      final corpus = [
        '𝄞abc',
        'a𝄞b😀c',
        '$fgRed😀$reset😀',
        'né😀${bg256Red}日本語𝄞$reset',
        '${link('https://e.com/', text: '😀𝄞')} tail',
      ];

      for (final text in corpus) {
        final parser = Parser(text);
        final plain = parser.removeAll();

        for (var pos = 0; pos <= parser.length; pos++) {
          for (final after in [false, true]) {
            final result = after
                ? parser.insertAfter(pos, 'X')
                : parser.insertBefore(pos, 'X');
            final reason = '"$text" @ $pos, after: $after';

            expect(_isValidUtf16(result), isTrue, reason: reason);

            final landing = _landing(plain, pos, after: after);
            expect(
              Parser(result).removeAll(),
              '${plain.substring(0, landing)}X${plain.substring(landing)}',
              reason: reason,
            );
          }
        }
      }
    });
  });
}
```

Замечание для имплементера: в корпусе все входы — валидный UTF-16 и ни
одна пара не разорвана escape-кодом, поэтому mid-pair в plain-координатах
означает mid-pair и во входе; для входов с разорванными парами хелпер
`_landing` неприменим — они пиннятся отдельным тестом выше.

- [ ] **Step 2: Убедиться в падении (RED)**

Run: `dart test test/parser_insert_surrogates_test.dart`
Expected: FAIL как минимум «insertBefore shifts …», «insertAfter shifts …»,
«a styled string …», «StackedParser …», «a lone half …» и корпус (валидность
UTF-16 на mid-pair позициях). Тест «a pair the input broke …» зелёный —
это пиннинг текущего поведения.

- [ ] **Step 3: Фикс — сдвиг в `_seamAt`**

В `parser.dart` после класса `_Walk` (конец файла) добавить:

```dart
/// Whether [codeUnit] is the leading half of a surrogate pair.
bool _isHighSurrogate(int codeUnit) => (codeUnit & 0xFC00) == 0xD800;

/// Whether [codeUnit] is the trailing half of a surrogate pair.
bool _isLowSurrogate(int codeUnit) => (codeUnit & 0xFC00) == 0xDC00;
```

В `_seamAt` заменить возврат внутри цикла:

```dart
      // Both ends of the seam sit inside a piece of text when the position
      // falls within one, and there the two insertions are the same.
      if (after ? pos < end : pos > plainPos && pos <= end) {
        return (m.start + (pos - plainPos), m.state);
      }
```

на:

```dart
      // Both ends of the seam sit inside a piece of text when the position
      // falls within one, and there the two insertions are the same.
      if (after ? pos < end : pos > plainPos && pos <= end) {
        final cut = m.start + (pos - plainPos);

        // A cut between the halves of a surrogate pair would land the
        // insertion inside a character. It shifts along the direction of
        // the insertion — insertBefore to the front of the pair,
        // insertAfter past it — and one step is always enough: the unit
        // next to a pair is never the missing half of another one. Halves
        // an escape code keeps apart are lone surrogates of the input
        // itself, sit in different pieces, and are left as they lie.
        if (cut > m.start &&
            cut < m.end &&
            _isHighSurrogate(input.codeUnitAt(cut - 1)) &&
            _isLowSurrogate(input.codeUnitAt(cut))) {
          return _seamAt(after ? pos + 1 : pos - 1, after: after);
        }

        return (cut, m.state);
      }
```

- [ ] **Step 4: Прогнать (GREEN)**

```bash
dart test test/parser_insert_surrogates_test.dart
dart test test/parser_insert_test.dart
```

Expected: PASS оба файла; существующие insert-тесты не задеты (они не
ходят по mid-pair позициям).

- [ ] **Step 5: Dartdoc — code-unit-семантика**

В `parser.dart`:

1. `insertBefore` — после абзаца «[pos] is the position in the string
   without ANSI escape codes.» добавить:

```dart
  /// [pos] counts UTF-16 code units, the units [String.length] counts. A
  /// position between the halves of a surrogate pair — inside a `𝄞` —
  /// shifts to the front of the pair, so the pair is never split;
  /// [insertAfter] shifts past it instead.
```

2. `insertAfter` — туда же:

```dart
  /// A position between the halves of a surrogate pair shifts past the
  /// pair; see [insertBefore] for the other direction.
```

3. `length` — заменить `/// String length without ANSI escape codes.` на:

```dart
  /// String length without ANSI escape codes, in UTF-16 code units.
  ///
  /// The count is [String.length] minus the codes — `𝄞` is two, and a
  /// grapheme a terminal draws as one glyph may be several. Graphemes are
  /// not counted.
```

4. `padRight` — в конец dartdoc добавить:

```dart
  /// The width is counted in UTF-16 code units, as [length] counts them —
  /// not in glyphs a terminal draws.
```

5. `padLeft` — тот же абзац, что в 4.

6. `substring` — в конец dartdoc:

```dart
  /// [start] and [maxLength] count UTF-16 code units, as [length] does.
```

- [ ] **Step 6: README**

`grep -n "what is seen" README.md` — найти оба места (≈43-44 и ≈712).

1. Буллет в шапке: заменить

```markdown
- [reading](#reading) strings that carry escape codes: what they say, how wide
  they are, what style is in force at any point
```

на:

```markdown
- [reading](#reading) strings that carry escape codes: what they say, how long
  they are without the codes, what style is in force at any point
```

2. В разделе про ширину: заменить предложение
```
`Parser` counts what is seen:
```
на:

```markdown
`Parser` counts the same UTF-16 code units without the codes — `𝄞` is
still two, as everywhere in Dart, and positions never land inside a
surrogate pair:
```

3. Остальные вхождения «what is seen» (если grep покажет ещё) — привести
   к той же формулировке «code units without the codes».

- [ ] **Step 7: CHANGELOG**

В конец секции `Fixed:` записи `## 4.0.0`:

```markdown
- `insertBefore` and `insertAfter` could put text between the halves of a
  surrogate pair and hand back a string that is no longer valid UTF-16. A
  position inside a pair now shifts to its edge — `insertBefore` to the
  front, `insertAfter` past it. Positions, `length` and the paddings are
  UTF-16 code units, as `String` counts them, and the docs now say so
  instead of promising what is seen.
```

- [ ] **Step 8: Полная проверка и коммит**

```bash
dart format .
dart test
dart analyze --fatal-infos
git add lib/src/parsing/parser/parser.dart \
  test/parser_insert_surrogates_test.dart README.md CHANGELOG.md
git commit -m "fix: an insertion never splits a surrogate pair

A position between the halves of a pair shifts to the pair's edge along
the direction of the insertion: insertBefore to the front, insertAfter
past it. Halves an escape code keeps apart are lone surrogates of the
input and are left as they lie. Positions stay UTF-16 code units, and
the docs now say so instead of promising what is seen."
```

---

### Task 5: Финальная проверка ветки и PR

**Files:**
- Ничего не создаётся и не меняется, кроме случая находок ревью.

**Interfaces:**
- Consumes: ветка `fix/review-correctness` с четырьмя коммитами Task 1-4.
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

`git diff main...fix/review-correctness` — финальное ревью всей ветки по
процессу subagent-driven-development (ревьюер сверяет диффы со спекой
`docs/2026-08-04[5]-correctness-fixes-design.md`). Находки чинятся
отдельными fixup-коммитами до пуша.

- [ ] **Step 3: Пуш и PR**

```bash
git push -u origin fix/review-correctness
gh pr create --title "fix: correctness fixes from the 4.0.0 review (M8, H1, M1, H2)" \
  --body "$(cat <<'EOF'
## Summary
- test: the colour tables (783 Styles, 256 Color256, 3×256 ready-to-use
  strings, 512 StyleColors getters) are swept against their formula (M8)
- fix: the terminal modes come back in the order Windows allows (H1)
- fix: a substring slice closes the hyperlink it opened (M1)
- fix: an insertion never splits a surrogate pair (H2)

Per docs/2026-08-04[5]-correctness-fixes-design.md; review findings from
docs/2026-08-04[1]-project-review.md. One fix per commit, red-green
throughout (sabotage-verified for M8).

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Публикация 4.0.0 и тег v4.0.0 — **не в этом PR**; отдельное решение
пользователя после слияния.
