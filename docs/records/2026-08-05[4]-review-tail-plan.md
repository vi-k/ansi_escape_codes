# Хвост ревью — план имплементации

> **Состояние документа**
>
> - **Тип:** план, 2026-08-05, по дизайну `2026-08-05[3]`
> - **Статус:** выполнен, влит в `main` мержем `5af798b`
> - **Актуальность:** переименования доков в тексте — та самая волна, что
>   ввела схему `YYYY-MM-DD[N]`; сегодня записи лежат в `docs/records/`.
>   Оговорка верификации по L7/L8 закрыта волной `56c8244`
> - **Пути:** ссылки в тексте старые — записи с тех пор лежат в
>   `docs/records/`, `TODO.md` стал `docs/backlog.md`, текущий handoff —
>   `docs/handoff.md`

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** закрыть весь остаток ревью, кроме генератора (#12): M6, L1–L3,
L7/L8, L9/L10, гигиена #15 — по спеке
`docs/2026-08-05[3]-review-tail-design.md`.

**Architecture:** восемь коммитов в ветке `fix/review-tail`, от семантики
к механике: док-контракт равенства (M6) → честный no-op у Style/NoStyle
(L1+L2) → passthrough Printer с NoStyle (L3) → замкнутость entry points
(L7) → скрытие IntensityStyle + тест EscCommon (L8) → CI (L9) → pubspec
(L10) → гигиена и перенумерация доков (#15). Затем финальное ревью и
локальный `merge --no-ff` в main — **без PR**.

**Tech Stack:** Dart ≥3, `package:test`, GitHub Actions.

## Global Constraints

- Ветка `fix/review-tail` от текущего `main`.
- Существующие тест-файлы не редактируются — единственное исключение:
  удаление `print('')` из `test/ansi_constants_test.dart:60` в Task 8.
- Перед каждым коммитом зелёные: `dart format .` (идемпотентен),
  `dart test`, `dart analyze --fatal-infos`.
- Версия 4.0.0 не трогается. CHANGELOG-строки — в секцию `## 4.0.0`:
  Fixed для L1/L2/L3/L7 (в конец секции, перед `Renamed:`), Removed для
  L8 (секции `Removed:` в 4.0.0 нет — создать её между `Fixed:` и
  `Renamed:`).
- Решения пользователя, зафиксированные спекой: `==` не меняется (M6 —
  только док); Printer с NoStyle — passthrough; `ansiCodesEnabled`
  остаётся; `IntensityStyle` скрывается (геттера НЕ будет); TODO.md
  наполняется, не удаляется; схема имён доков `YYYY-MM-DD[N]-<topic>.md`.
- Сообщения коммитов: conventional-префикс, строчные, английские, в
  стиле репозитория.
- Пути с `[N]` в shell всегда в кавычках (`[1]` в glob — символьный
  класс).

---

### Task 1: M6 — контракт равенства по видимой поверхности

**Files:**
- Modify: `lib/src/parsing/state/state.dart` (dartdoc над `operator ==`,
  ~строка 418; сейчас dartdoc'а нет)
- Modify: `lib/src/parsing/state/stack.dart` (одно предложение в dartdoc
  класса `Stack`)
- Create: `test/state_equality_contract_test.dart`

**Interfaces:**
- Consumes: `Stack.terminalColors`, операции `underline`,
  `doublyUnderline`, `resetUnderline` (все возвращают `Stack`),
  `State.==`/`hashCode` (state.dart:393-439 — сравнивают поверхность
  плюс NoStyle-терм, историю не видят).
- Produces: ничего нового — только документация и пины.

- [ ] **Step 1: Написать тест-пины (зелёные сразу — фиксируют документируемое)**

Создать `test/state_equality_contract_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('equality is the visible surface:', () {
    test('histories differ, surfaces equal', () {
      final grown = Stack.terminalColors.underline.doublyUnderline;
      final direct = Stack.terminalColors.doublyUnderline;

      expect(grown, direct);
      expect(grown.hashCode, direct.hashCode);
    });

    test('and equal stacks may part after one and the same reset', () {
      final grown = Stack.terminalColors.underline.doublyUnderline;
      final direct = Stack.terminalColors.doublyUnderline;

      expect(grown.resetUnderline, isNot(direct.resetUnderline));
      expect(grown.resetUnderline.isUnderline, isTrue,
          reason: 'the remembered underline comes back');
      expect(direct.resetUnderline.isUnderline, isFalse,
          reason: 'there was nothing underneath to come back to');
    });
  });
}
```

- [ ] **Step 2: Прогнать — зелёные (пины текущего поведения)**

Run: `dart test test/state_equality_contract_test.dart`
Expected: PASS. Это не red-green: поведение не меняется, тест закрепляет
контракт. Если что-то падает — STOP, BLOCKED (значит, поведение не то,
что описало ревью).

- [ ] **Step 3: Dartdoc на `State.==`**

В `lib/src/parsing/state/state.dart` перед `@override bool operator ==`
(~строка 418) добавить:

```dart
  /// Equality is the visible surface: the properties and colours this
  /// state answers with, and whether it is a [NoStyle] — nothing else.
  ///
  /// What a [Stack] remembers of how it got here is not compared: two
  /// equal stacks may answer one and the same reset differently when
  /// their histories differ. `underline.doublyUnderline` equals
  /// `doublyUnderline`, and after one `resetUnderline` each, the first
  /// keeps an underline the second never had. Equal is how it looks,
  /// not how it unwinds.
```

- [ ] **Step 4: Отсылка в dartdoc `Stack`**

В dartdoc класса `Stack` (`lib/src/parsing/state/stack.dart`, шапка
класса) добавить в конец одно предложение:

```dart
/// Equality compares the visible surface only — see [State.==]: the
/// history is what a stack does, not what it equals.
```

(Точное место — конец существующего doc-комментария класса; форму
ссылки `[State.==]` проверить анализатором, при недовольстве —
`[State.operator ==]`.)

- [ ] **Step 5: Полная проверка и коммит**

```bash
dart format .
dart test
dart analyze --fatal-infos
git add lib/src/parsing/state/state.dart lib/src/parsing/state/stack.dart \
  test/state_equality_contract_test.dart
git commit -m "docs: equal is how it looks, not how it unwinds

State equality compares the visible surface; what a Stack remembers of
how it got here is not part of it, and two equal stacks may answer the
same reset differently. The contract is now written on operator == and
pinned by tests instead of being an accident of the implementation."
```

---

### Task 2: L1 + L2 — честный no-op у Style, пустой переход между равными поверхностями

**Files:**
- Modify: `lib/src/parsing/state/style.dart` (`_setFlags`, ~строка 340;
  цветовые операции `foreground`/`background`/`underlineColor`/
  `resetForeground`/`resetBackground`/`resetUnderlineColor`,
  строки ~324-395)
- Modify: `lib/src/parsing/state/state.dart` (`transitTo`, шорткат
  terminalColors, ~строки 234-238)
- Create: `test/no_style_test.dart`
- Modify: `CHANGELOG.md` (две строки в конец `Fixed:`)

**Interfaces:**
- Consumes: `_setFlags(int flags)` — единственный путь всех флаговых
  операций (bold/dim/italic/…/reset*, style.dart:278-354); цветовые
  операции строят `Style._` напрямую; `Color.==` игнорирует target.
- Produces: инвариант «нечего менять → тот же объект (`identical`)» на
  всех операциях `Style`; `transitTo` между равными поверхностями — `''`.

- [ ] **Step 1: Написать падающий тест**

Создать `test/no_style_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('nothing to change answers itself:', () {
    test('a NoStyle stays a NoStyle through a pointless reset', () {
      const noStyle = NoStyle();

      expect(identical(noStyle.resetItalic, noStyle), isTrue);
      expect(identical(noStyle.resetBoldAndDim, noStyle), isTrue);
      expect(identical(noStyle.resetForeground, noStyle), isTrue);
      expect(noStyle.resetItalic('x'), 'x',
          reason: 'still a NoStyle, so still writes nothing');
    });

    test('a Style with nothing to change answers itself too', () {
      const style = Style(bold: true);

      expect(identical(style.bold, style), isTrue);
      expect(identical(style.resetItalic, style), isTrue);

      const red = Style(foreground: Color256.red);
      expect(identical(red.foreground(Color256.red), red), isTrue);
      expect(identical(red.resetBackground, red), isTrue);
    });

    test('a change still makes a new style', () {
      const noStyle = NoStyle();

      expect(noStyle.bold, isNot(same(noStyle)));
      expect(noStyle.bold.isBold, isTrue);
      expect(noStyle.bold, isNot(isA<NoStyle>()),
          reason: 'a NoStyle that sets something is no NoStyle');
    });
  });

  group('a transition between equal surfaces is empty:', () {
    test('NoStyle to the terminal colours writes nothing', () {
      expect(const NoStyle().transitTo(Style.terminalColors), '');
    });

    test('a loaded style still resets', () {
      expect(
        Style.terminalColors.bold.transitTo(Style.terminalColors),
        '\x1B[0m',
      );
    });
  });
}
```

- [ ] **Step 2: Убедиться в падении (RED)**

Run: `dart test test/no_style_test.dart`
Expected: FAIL — все `identical`-ожидания (операции всегда строят новый
объект), `noStyle.resetItalic('x')` (сейчас `'\x1B[0mx'`) и
«NoStyle to the terminal colours» (сейчас `'\x1B[0m'`). Зелёные пины:
«a change still makes a new style», «a loaded style still resets».

- [ ] **Step 3: Фикс L1 — `_setFlags` и цветовые операции**

В `lib/src/parsing/state/style.dart` заменить `_setFlags`:

```dart
  Style _setFlags(int flags) => Style._(
        flags,
        _foreground,
        _background,
        _underlineColor,
      );
```

на:

```dart
  // Nothing to change answers itself — the promise State makes — and a
  // NoStyle asked for nothing stays a NoStyle.
  Style _setFlags(int flags) => flags == _flags
      ? this
      : Style._(flags, _foreground, _background, _underlineColor);
```

Цветовые операции (фактические тела — в файле, строки ~324-395; тот же
guard в каждой). Образец для `foreground` и `resetForeground`:

```dart
  Style foreground(Color color) => _foreground == color
      ? this
      : Style._(_flags, color, _background, _underlineColor);

  Style get resetForeground => _foreground == null
      ? this
      : Style._(_flags, null, _background, _underlineColor);
```

— и симметрично `background`/`resetBackground`,
`underlineColor`/`resetUnderlineColor` (сохранив существующие сигнатуры
и dartdoc; менять только тело на guard + прежний конструктор).

- [ ] **Step 4: Фикс L2 — шорткат в `transitTo`**

В `lib/src/parsing/state/state.dart` (~строки 234-238) заменить:

```dart
    if (other == Style.terminalColors) {
      return skipReset || (this as State<void>) == Style.terminalColors
          ? ''
          : sgr.reset;
    }
```

на:

```dart
    if (other == Style.terminalColors) {
      // A NoStyle never wrote anything, so there is nothing to take
      // off: its surface is the terminal's own, however the == terms
      // differ.
      return skipReset ||
              this is NoStyle ||
              (this as State<void>) == Style.terminalColors
          ? ''
          : sgr.reset;
    }
```

- [ ] **Step 5: Прогнать (GREEN + полный)**

```bash
dart test test/no_style_test.dart
dart test
```

Expected: PASS всё. Существующие тесты (в т.ч.
`style_state_test.dart` с пином `NoStyle != terminalColors`) зелёные
без правок — `==` не менялся.

- [ ] **Step 6: CHANGELOG**

В конец `Fixed:` секции `## 4.0.0`:

```markdown
- A style operation with nothing to change built a new object anyway,
  and a `NoStyle` asked for a pointless reset came back a `Style` that
  writes: `NoStyle().resetItalic('x')` opened with a reset. Nothing to
  change now answers itself, as `State` promised all along.
- `NoStyle().transitTo(Style.terminalColors)` wrote a reset between two
  surfaces that are both the terminal's own. A transition between equal
  surfaces is empty.
```

- [ ] **Step 7: Полная проверка и коммит**

```bash
dart format .
dart test
dart analyze --fatal-infos
git add lib/src/parsing/state/style.dart lib/src/parsing/state/state.dart \
  test/no_style_test.dart CHANGELOG.md
git commit -m "fix: nothing to change answers itself

Every Style operation with nothing to do built a copy, which turned a
NoStyle into a Style that writes; and the terminalColors shortcut in
transitTo wrote a reset from a NoStyle whose surface is already the
terminal's own. A no-op returns this, and a transition between equal
surfaces is empty — the promise State made all along."
```

---

### Task 3: L3 — Printer с NoStyle ничего не пишет

**Files:**
- Modify: `lib/src/parsing/parser/printer.dart` (`prepare`, ~строка 117;
  dartdoc поля `defaultStyle`, ~строка 80)
- Create: `test/printer_no_style_test.dart`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `Printer`/`StackedPrinter` (`prepare(String line)`),
  `NoStyle`, константы `fgRed`/`bold`/`reset` из барреля.
- Produces: `prepare` с `defaultStyle is NoStyle` — passthrough
  байт-в-байт; `ansiCodesEnabled: false` — прежний strip (приоритетнее).

- [ ] **Step 1: Написать падающий тест**

Создать `test/printer_no_style_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('a printer given NoStyle imposes nothing:', () {
    test('a plain line goes out as it came', () {
      final printer = Printer(defaultStyle: const NoStyle());

      expect(printer.prepare('text'), 'text');
    });

    test('a styled line keeps its own codes, byte for byte', () {
      final printer = Printer(defaultStyle: const NoStyle());
      const line = 'a${fgRed}b$reset c';

      expect(printer.prepare(line), line);
    });

    test('a StackedPrinter the same way', () {
      final printer = StackedPrinter(defaultStyle: const NoStyle());
      const line = '${bold}x$reset';

      expect(printer.prepare(line), line);
    });

    test('ansiCodesEnabled: false still takes the codes out', () {
      final printer = Printer(
        defaultStyle: const NoStyle(),
        ansiCodesEnabled: false,
      );

      expect(printer.prepare('a${fgRed}b'), 'ab');
    });
  });
}
```

(Если конструкторы print-принтеров называются иначе, чем
`Printer`/`StackedPrinter` — свериться с фактическим printer.dart и
использовать реальные имена; `prepare` публичен.)

- [ ] **Step 2: Убедиться в падении (RED)**

Run: `dart test test/printer_no_style_test.dart`
Expected: FAIL первые три (сейчас каждая строка открывается `\x1B[0m` и
закрывается переходом); зелёный пин — `ansiCodesEnabled: false`.

- [ ] **Step 3: Фикс — passthrough**

В `_PrinterBase.prepare` (`printer.dart`), после существующего блока
`if (!ansiCodesEnabled) …` добавить:

```dart
    // A NoStyle imposes nothing: no reset, no default, no unwinding —
    // the line goes out exactly as it came, its own codes included.
    // Taking those out is what `ansiCodesEnabled: false` is for.
    if (defaultStyle is NoStyle) {
      return line;
    }
```

- [ ] **Step 4: Dartdoc `defaultStyle`**

Заменить dartdoc поля (`printer.dart` ~строка 80):

```dart
  /// The style the text is given where it asks for none of its own.
```

на:

```dart
  /// The style the text is given where it asks for none of its own.
  ///
  /// A [NoStyle] here keeps the printer's hands off entirely: the line
  /// goes out as it came, its own codes included. That is the other
  /// half of [ansiCodesEnabled] — a [NoStyle] leaves the text's codes
  /// alone, `ansiCodesEnabled: false` takes them out.
```

- [ ] **Step 5: Прогнать (GREEN + полный)**

```bash
dart test test/printer_no_style_test.dart
dart test
```

Expected: PASS всё. Существующие printer-тесты не задеты (они не
используют NoStyle как defaultStyle; если какой-то падает — STOP,
BLOCKED с выводом).

- [ ] **Step 6: CHANGELOG**

В конец `Fixed:`:

```markdown
- A `Printer` given `defaultStyle: NoStyle()` still opened every line
  with a reset and unwound it at the end. It now imposes nothing: the
  line goes out as it came, its own codes included —
  `ansiCodesEnabled: false` remains the way to take those out.
```

- [ ] **Step 7: Полная проверка и коммит**

```bash
dart format .
dart test
dart analyze --fatal-infos
git add lib/src/parsing/parser/printer.dart \
  test/printer_no_style_test.dart CHANGELOG.md
git commit -m "fix: a printer told to impose nothing imposes nothing

prepare opened every line with a reset even when the default style was
a NoStyle. With NoStyle the line now goes out exactly as it came, its
own codes included; ansiCodesEnabled: false remains the way to strip
them. The docs on defaultStyle spell out the pair."
```

---

### Task 4: L7 — замкнутость entry points

**Files:**
- Modify: `lib/style.dart` (пять export-строк)
- Create: `test/entry_point_style_test.dart`,
  `test/entry_point_parsing_test.dart`, `test/entry_point_ansi_test.dart`,
  `test/entry_point_extensions_test.dart`, `test/entry_point_utils_test.dart`
- Modify: `CHANGELOG.md`
- Не трогать: `test/exports_test.dart` (покрывает зонтичную точку)

**Interfaces:**
- Consumes: текущий `lib/style.dart` (экспортирует только
  `colors/color.dart`, `parser/parser.dart`, `state/state.dart`);
  `lib/parsing.dart` — та же тройка плюс пять `control_functions/*`.
- Produces: `lib/style.dart` с теми же пятью экспортами; тест замкнутости
  на каждую точку. Task 5 добавит `hide IntensityStyle` в три из этих
  файлов.

- [ ] **Step 1: Написать падающий тест точки style**

Создать `test/entry_point_style_test.dart` (импортирует ТОЛЬКО свою
точку):

```dart
import 'package:ansi_escape_codes/style.dart';
import 'package:test/test.dart';

void main() {
  test('the style entry point names the types its own API returns', () {
    final sgr = Parser('\x1B[1m').matches.first.entity as Sgr;
    expect(sgr.contains(ControlFunctionsSGR.bold), isTrue);

    final csi = Parser('\x1B[A').matches.first.entity as CsiCommon;
    expect(csi.controlSequence, ControlSequencesFunctions.CUU);

    final esc = Parser('\x1Bc').matches.first.entity as EscCommon;
    expect(esc.function, ControlFunctionsEscFs.RIS);

    expect(ControlFunctionsC0.ESC, isNotNull);
    expect(ControlFunctionsC1.CSI, isNotNull);
  });
}
```

(Имена членов enum'ов — `ControlFunctionsEscFs.RIS`,
`ControlFunctionsC1.CSI` — свериться с фактическими файлами
`control_functions/*`; при расхождении взять реальные, суть теста —
именуемость типов.)

- [ ] **Step 2: Убедиться в падении (RED)**

Run: `dart test test/entry_point_style_test.dart`
Expected: FAIL загрузки — compile error `undefined ControlFunctionsSGR`
(и соседей). Это и есть L7.

- [ ] **Step 3: Фикс — пять экспортов в `lib/style.dart`**

Привести `lib/style.dart` к:

```dart
export 'src/parsing/colors/color.dart';
export 'src/parsing/control_functions/control_functions_c0.dart';
export 'src/parsing/control_functions/control_functions_c1.dart';
export 'src/parsing/control_functions/control_functions_esc_fs.dart';
export 'src/parsing/control_functions/control_sequences.dart';
export 'src/parsing/control_functions/sgr.dart';
export 'src/parsing/parser/parser.dart';
export 'src/parsing/state/state.dart';
```

- [ ] **Step 4: Тесты остальных точек (зелёные сразу — пины замкнутости)**

`test/entry_point_parsing_test.dart` — тот же код, что в Step 1, но
`import 'package:ansi_escape_codes/parsing.dart';` и имя теста
`'the parsing entry point …'`.

`test/entry_point_ansi_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi.dart';
import 'package:test/test.dart';

void main() {
  test('the ansi entry point names its constants', () {
    expect(CSI, '\x1B[');
    expect(FG_RED, 31);
    expect(SGR, 'm');
  });
}
```

`test/entry_point_extensions_test.dart`:

```dart
import 'package:ansi_escape_codes/extensions.dart';
import 'package:test/test.dart';

void main() {
  test('the extensions entry point works on its own', () {
    expect('a\x1B[31mb'.ansiRemoveEscapeCodes(), 'ab');
    expect('a\x1B[31mb'.ansiHasSgr, isTrue);
  });
}
```

`test/entry_point_utils_test.dart`:

```dart
import 'package:ansi_escape_codes/utils.dart';
import 'package:test/test.dart';

void main() {
  test('the utils entry point names its functions', () {
    expect(currentCursorPos, isNotNull);
    expect(tabs, isNotNull);
  });
}
```

(`tabs` — свериться с фактическим экспортом `src/utils/tabs.dart`;
взять реальное имя top-level функции.)

- [ ] **Step 5: Прогнать (GREEN + полный)**

```bash
dart test test/entry_point_style_test.dart test/entry_point_parsing_test.dart \
  test/entry_point_ansi_test.dart test/entry_point_extensions_test.dart \
  test/entry_point_utils_test.dart
dart test
```

Expected: PASS всё.

- [ ] **Step 6: CHANGELOG**

В конец `Fixed:`:

```markdown
- The `style` entry point returned types it could not name:
  `ControlFunctionsSGR` and its four control-function siblings were
  reachable from the entities but undefined to the importer. The five
  exports are now part of the point, and every entry point carries a
  closure test.
```

- [ ] **Step 7: Полная проверка и коммит**

```bash
dart format .
dart test
dart analyze --fatal-infos
git add lib/style.dart test/entry_point_style_test.dart \
  test/entry_point_parsing_test.dart test/entry_point_ansi_test.dart \
  test/entry_point_extensions_test.dart test/entry_point_utils_test.dart \
  CHANGELOG.md
git commit -m "fix: the style entry point can name what it returns

Sgr.contains takes a ControlFunctionsSGR the style entry point did not
export, and the same held for the other four control-function enums
reachable from the entities. The five exports join the point, and each
entry point now carries a closure test of its own."
```

---

### Task 5: L8 — `IntensityStyle` уходит из API, `EscCommon` тестируется

**Files:**
- Modify: `lib/ansi_escape_codes.dart`, `lib/parsing.dart`,
  `lib/style.dart` (экспорт `state.dart` получает `hide IntensityStyle`)
- Create: `test/esc_common_test.dart`
- Modify: `CHANGELOG.md` (новая секция `Removed:` в `## 4.0.0` между
  `Fixed:` и `Renamed:`)

**Interfaces:**
- Consumes: `EscCommon` (поле `function: ControlFunctionsEscFs`, `id` —
  `'ESC RIS'`), константа `resetTerminal` (= `'\x1Bc'`); экспорты из
  Task 4.
- Produces: `IntensityStyle` невиден из всех трёх точек, экспортирующих
  `state.dart`; внутренний код (`stack.dart` — та же библиотека) не
  задет.

- [ ] **Step 1: Скрыть тип**

В трёх файлах — `lib/ansi_escape_codes.dart`, `lib/parsing.dart`,
`lib/style.dart` — заменить:

```dart
export 'src/parsing/state/state.dart';
```

на:

```dart
// IntensityStyle is the element a Stack's intensity history holds;
// nothing public takes or returns it, and bold and dim — unlike the
// four real pairs — coexist, so no getter can answer with one of them.
export 'src/parsing/state/state.dart' hide IntensityStyle;
```

- [ ] **Step 2: Проверить скрытие**

```bash
dart analyze --fatal-infos
grep -rn "IntensityStyle" test/ example/
```

Expected: анализ чистый (внутренние импорты идут в `src/` напрямую и не
задеты); в тестах/примерах ссылок на тип нет (если есть — STOP,
BLOCKED: тип не был мёртвым).

- [ ] **Step 3: Тест EscCommon**

Создать `test/esc_common_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('EscCommon:', () {
    test('names the function its sequence stands for', () {
      final entity = Parser(resetTerminal).matches.first.entity;

      expect(entity, isA<EscCommon>());
      expect((entity as EscCommon).function, ControlFunctionsEscFs.RIS);
      expect(entity.id, 'ESC RIS');
    });

    test('a switch over the entity reaches it', () {
      final label = switch (Parser('\x1Bc').matches.first.entity) {
        EscCommon(:final function) => function.name,
        _ => 'other',
      };

      expect(label, 'RIS');
    });
  });
}
```

(Имя члена `RIS` и значение `id` свериться с фактическими
`control_functions_esc_fs.dart` и `entities/esc.dart:39`.)

- [ ] **Step 4: CHANGELOG**

Создать секцию `Removed:` в `## 4.0.0` (между `Fixed:` и `Renamed:`):

```markdown
Removed:

- `IntensityStyle` left the public API. It is the element a `Stack`'s
  intensity history holds; nothing public takes or returns it, and bold
  and dim — unlike the other pairs — can be on at once, so no getter
  could honestly answer with one of them.
```

- [ ] **Step 5: Полная проверка и коммит**

```bash
dart format .
dart test
dart analyze --fatal-infos
git add lib/ansi_escape_codes.dart lib/parsing.dart lib/style.dart \
  test/esc_common_test.dart CHANGELOG.md
git commit -m "refactor: IntensityStyle goes back inside, EscCommon gets its test

The enum is the element a Stack's intensity history holds — nothing
public takes or returns it, and bold and dim coexist, so no getter
could answer with one of them. Hidden from the three entry points that
export state.dart. EscCommon, shipped headlined and untested, gets its
first test."
```

---

### Task 6: L9 — CI

**Files:**
- Modify: `.github/workflows/dart.yml`

**Interfaces:**
- Consumes: текущий workflow (matrix sdk 3.6.0/stable; шаги: checkout@v4
  без SHA, setup-dart запинен, pub get, format, analyze, test,
  publish dry-run на stable).
- Produces: тот же workflow + `permissions:`, SHA-пиннинг checkout,
  `dart doc --dry-run`, исполнение примеров, сбор покрытия.

- [ ] **Step 1: Правки workflow**

В `.github/workflows/dart.yml`:

1. После блока `on:` добавить:

```yaml
permissions:
  contents: read
```

2. Запинить checkout по SHA. Актуальный SHA тега v4 взять живьём:

```bash
gh api repos/actions/checkout/git/ref/tags/v4.2.2 --jq .object.sha
```

и заменить `uses: actions/checkout@v4` на
`uses: actions/checkout@<SHA>  # v4.2.2` (форма — как у соседнего
setup-dart).

3. После шага «Run tests» добавить:

```yaml
      - name: Check the docs build
        run: dart doc --dry-run

      - name: Run the examples
        # utils.dart is left out: currentCursorPos needs a terminal to
        # answer, and CI has none.
        run: |
          for f in example/ansi_escape_codes_example.dart \
                   example/check_compatibility.dart \
                   example/colors256.dart \
                   example/control.dart \
                   example/links.dart \
                   example/progress_indicator.dart \
                   example/rgb.dart \
                   example/styles.dart; do
            timeout 60 dart run "$f" > /dev/null
          done

      - name: Collect coverage
        if: matrix.sdk == 'stable'
        run: dart test --coverage=coverage

      - name: Upload coverage
        if: matrix.sdk == 'stable'
        uses: actions/upload-artifact@<SHA>  # v4.x — резолвить как checkout
        with:
          name: coverage
          path: coverage/
```

SHA для upload-artifact резолвить тем же способом
(`gh api repos/actions/upload-artifact/git/ref/tags/<последний v4-тег>`).

- [ ] **Step 2: Локальная проверка воспроизводимого**

```bash
dart doc --dry-run
for f in example/ansi_escape_codes_example.dart example/check_compatibility.dart \
         example/colors256.dart example/control.dart example/links.dart \
         example/progress_indicator.dart example/rgb.dart example/styles.dart; do
  ( dart run "$f" > /dev/null < /dev/null ) || echo "FAILED: $f"
done
dart test --coverage=coverage && rm -rf coverage
```

Expected: dry-run чистый; все примеры завершаются сами и с нулевым
кодом (если какой-то ждёт ввода или крутится вечно — STOP, BLOCKED с
именем файла: список для CI придётся сузить сознательно, не молча).

- [ ] **Step 3: Коммит**

```bash
dart format .
dart analyze --fatal-infos
git add .github/workflows/dart.yml
git commit -m "ci: the workflow checks what it was blind to

dart doc --dry-run (a docs packaging bug shipped once already), the
examples actually run instead of only being analyzed, coverage is
collected on stable, actions/checkout is pinned by SHA like its
neighbour, and GITHUB_TOKEN gets read-only permissions."
```

---

### Task 7: L10 — pubspec

**Files:**
- Modify: `pubspec.yaml` (после `homepage:`)

- [ ] **Step 1: Правка**

После строки `homepage: https://github.com/vi-k/ansi_escape_codes`
добавить:

```yaml
repository: https://github.com/vi-k/ansi_escape_codes
issue_tracker: https://github.com/vi-k/ansi_escape_codes/issues
```

- [ ] **Step 2: Проверка и коммит**

```bash
dart pub publish --dry-run
dart format --set-exit-if-changed .
dart analyze --fatal-infos
dart test
git add pubspec.yaml
git commit -m "chore: pubspec names the repository and the issue tracker

pub.dev prefers repository and issue_tracker over a lone homepage."
```

Expected: dry-run — 0 предупреждений, остальное зелёное.

---

### Task 8: #15 — гигиена и перенумерация доков

**Files:**
- Modify: `TODO.md`, `.gitignore`, `test/ansi_constants_test.dart:60`,
  `lib/src/parsing/state/stack.dart`
- Rename: все 11 файлов `docs/*.md` (git mv, схема `YYYY-MM-DD[N]-`)
- Modify: перекрёстные ссылки в `docs/*.md`

**Interfaces:**
- Consumes: схему имён и маппинг из спеки; типографику существующих
  доков.
- Produces: единая схема имён; чистые внутренние имена `stack.dart`.

- [ ] **Step 1: TODO.md**

Заменить содержимое `TODO.md` на:

```markdown
# TODO

Рабочий бэклог пакета. Пункт, взятый в работу, уходит в спеку в
`docs/` (формат имён — `YYYY-MM-DD[N]-<тема>.md`) и вычёркивается
отсюда; сделанное живёт в CHANGELOG, а не здесь.
```

- [ ] **Step 2: Мелочи**

```bash
printf '\n# Claude Code\n.claude/\n' >> .gitignore
```

В `test/ansi_constants_test.dart` удалить строку 60 (`print('');` —
паразитный вывод в тестовом прогоне; единственная разрешённая правка
существующего теста).

В `lib/src/parsing/state/stack.dart` — переименования только приватных
имён параметров:

```bash
sed -i '' 's/intencityStack/intensityStack/g; s/scripStack/scriptStack/g' \
  lib/src/parsing/state/stack.dart
grep -n "intencity\|scripStack" lib/  # Expected: пусто
```

- [ ] **Step 3: Переименование доков**

```bash
cd docs
git mv "2026-07-29-fix-spec-v3.1.2.md"            "2026-07-29[1]-fix-spec-v3.1.2.md"
git mv "2026-08-02-insert-before-after-design.md" "2026-08-02[1]-insert-before-after-design.md"
git mv "2026-08-04-project-review.md"             "2026-08-04[1]-project-review.md"
git mv "2026-08-04-perf-fixes-design.md"          "2026-08-04[2]-perf-fixes-design.md"
git mv "2026-08-04-perf-fixes-plan.md"            "2026-08-04[3]-perf-fixes-plan.md"
git mv "2026-08-04-handoff-correctness-fixes.md"  "2026-08-04[4]-handoff-correctness-fixes.md"
git mv "2026-08-04-correctness-fixes-design.md"   "2026-08-04[5]-correctness-fixes-design.md"
git mv "2026-08-04-correctness-fixes-plan.md"     "2026-08-04[6]-correctness-fixes-plan.md"
git mv "2026-08-05-sgr-classifier-design.md"      "2026-08-05[1]-sgr-classifier-design.md"
git mv "2026-08-05-sgr-classifier-plan.md"        "2026-08-05[2]-sgr-classifier-plan.md"
git mv "2026-08-05-review-tail-design.md"         "2026-08-05[3]-review-tail-design.md"
cd ..
```

(`2026-08-05[4]-review-tail-plan.md` — этот план — уже в новой схеме.)

- [ ] **Step 4: Ссылки**

Обновить все упоминания старых имён в `docs/*.md` (включая этот план)
на новые:

```bash
grep -rn "docs/2026-0[78]-" docs/ README.md CHANGELOG.md | grep -v "\["
```

пройтись по каждому найденному месту (это исторические доки — правится
только путь, не текст вокруг), затем проверить, что битых путей нет:

```bash
grep -roh "docs/2026[^ )\`'\"]*\.md" docs/ README.md CHANGELOG.md | sort -u \
  | while read -r p; do [ -f "$p" ] || echo "BROKEN: $p"; done
```

Expected: пусто (шаблон `2026-08-0X` в handoff-доке — не путь, битым не
считается; при попадании в grep — оставить как есть).

- [ ] **Step 5: Полная проверка и коммит**

```bash
dart format .
dart test
dart analyze --fatal-infos
git add -A
git commit -m "chore: the docs get their day numbers, and the hygiene debt is paid

Docs of one day now sort in the order they were written —
YYYY-MM-DD[N]-topic — with cross-references updated. TODO.md says what
it is for instead of being empty, .claude/ joins .gitignore, a stray
print('') leaves the test run, and the intencityStack/scripStack typos
are spelled out of stack.dart's parameter names."
```

---

### Task 9: Финальная проверка, whole-branch ревью, локальный merge

**Files:** ничего нового, кроме находок ревью.

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
сверка со спекой `docs/2026-08-05[3]-review-tail-design.md` (после
Task 8 — новое имя). Находки — fixup-коммитами до слияния.

- [ ] **Step 3: Локальный merge в main — без PR**

```bash
git checkout main
git merge --no-ff fix/review-tail \
  -m "merge: the review tail closes — M6, NoStyle, entry points, CI, hygiene"
git push
git branch -d fix/review-tail
```

После слияния из очереди ревью остаётся только генератор таблиц (#12).
Публикация 4.0.0 — отдельное решение пользователя.
