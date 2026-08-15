# План: сохранение немоделируемых SGR

> **Состояние на 2026-08-16:** исполнен и влит — ветка
> `fix/preserve-unmodelled-sgr` слита в `main` мержем `a7d708c`
> (`3c8e4e3`, `b7f0064`, `eae5f17`, `87d4b5f`, `d239ffc`, `ebcaf16`,
> `b871023` и тесты), H6 закрыт. Одно ожидание при исполнении поправлено:
> для `CSI 11 m A CSI 10 m B` правильный ответ — `CSI 11 m A CSI 0 m B`,
> канонизацию известных функций спека разрешает.
> **Что это:** TDD-план H6 — типизация всех стандартных SGR плюс сквозной
> перенос неизвестных (residual) через выходы пакета и `ESC 7/8`.
> **Связанные записи:** `2026-08-14[4]-unmodelled-sgr-design.md`,
> `2026-08-14[6]-pre-h6-report.md`.

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Все известные стандартные SGR становятся публичным состоянием,
а обычные SGR, семантику которых пакет не знает, сохраняются через
`optimize`, `substring`, вставки, принтеры и `ESC 7/8` без потери порядка.

**Architecture:** Известные функции расширяют `State`/`Style`/`Stack` и
продолжают выходить через обычный дифф состояний. Первый действительно
неизвестный параметр открывает приватную persistent-цепь операций рядом со
`State` и hyperlink; каждый `Piece` несёт её снимок, а общий
`_renditionTransit` выдаёт суффикс прямого продолжения либо делает reset и
replay при переходе между ветвями. Принтер проецирует базовый стиль и
известные операции через `defaultStyle`, не меняя сырой порядок unknown.

**Tech Stack:** Dart `^3.6.0`, `package:test`, sealed classes и records,
существующие `State<S>`, `_Frame<T>`, lazy `Pieces`, GitHub Actions на SDK
`3.6.0` и `stable`.

## Global Constraints

- Ожидаемые значения текущего поведения сначала снять живым пробником.
  Расхождение теста с планом объяснить, а не подгонять под реализацию.
- Каждый новый поведенческий тест увидеть красным до production-правки и
  повторно покрасить указанной в задаче мутацией после зелёного прогона.
- `FontSelection`, `FontShape`, расширенный `UnderlineStyle`,
  `IdeogramStyle` и proportional spacing — публичный API; residual и все
  его типы остаются приватными.
- Существующие публичные имена не удалять. `ControlFunctionsSGR.reserved_26`,
  `reserved_50`, `reserved_60`–`reserved_65` остаются enum-элементами с теми
  же `.name` и позициями в `.values`.
- `SGR 0` сбрасывает публичное состояние и residual, но не hyperlink.
- Private CSI, CSI с intermediate-байтами и неизвестные не-SGR CSI проходят
  буквально и не становятся replayable-состоянием.
- Стековый pop-контракт reset не менять: H7 остаётся отдельным решением.
- Слот `ESC 7/8` не переносить между экземплярами построчного парсера: H8
  остаётся отдельным решением. Внутри одного `Pieces` residual входит в уже
  существующий save-slot.
- Закрытый контракт H5 не переоткрывать: ветка без residual продолжает
  соблюдать текущий `substring(close: false)` и его `skipSet`.
- Зоны `BEGIN GENERATED`/`END GENERATED` в `lib/` руками не править;
  изменения там идут только через `tool/generate.dart`.
- `README.md` — источник, `README.ru.md` — синхронный перевод в том же
  коммите, с теми же разделами и кодом примеров.
- `docs/backlog.md` не менять. Находки реализации записывать в
  `docs/handoff.md`, не расширяя эту волну.
- SDK-floor `^3.6.0`, версию `4.0.0` и зависимости не менять. Тег не ставить,
  пакет не публиковать.
- Код, dartdoc, README, CHANGELOG и сообщения коммитов — по-английски;
  рабочие записи `docs/` — по-русски.
- Один смысловой deliverable — один conventional-коммит с английским телом,
  объясняющим причину.

## Карта файлов и границы ответственности

- `lib/src/ansi/sgr.dart` — числовые коды, без состояния и строк вывода.
- `lib/src/ready_to_use/sgr/sgr.dart` — готовые публичные SGR-строки.
- `lib/src/parsing/control_functions/sgr.dart` — стабильная enum-индексация
  и публичные диагностические `id`.
- `lib/src/parsing/state/state.dart` — публичный контракт, переходы,
  defaults, equality/hash и общий видимый surface.
- `lib/src/parsing/state/style.dart` — плоское immutable-значение новых
  свойств.
- `lib/src/parsing/state/stack.dart` — persistent-истории новых свойств.
- `lib/src/parsing/state/styles.dart` — одно-свойственные const-стили.
- `lib/src/parsing/parser/entities/sgr.dart` — левонаправленный разбор одной
  SGR, публичные `SgrFunction` и приватные операции с точными raw-параметрами.
- Create `lib/src/parsing/parser/sgr_residual.dart` — единственное место,
  владеющее persistent-журналом, ancestry и reset/replay.
- `matching_state.dart`, `piece.dart`, `pieces.dart`, `pieces_result.dart`,
  `parser_iterator.dart` — приватная передача residual вместе со state/link.
- `csi.dart` — единственная special-case классификация overflowed SGR,
  оставляющая публичный runtime type `CsiUnknown`.
- `parser.dart` — подключение общего перехода к `optimize`, `substring` и
  вставочным швам.
- `printer.dart` — проекция residual через `defaultStyle` и перенос логического
  хвоста между строками/записями.
- `test/unmodelled_sgr_state_test.dart` — новая публичная state-модель.
- `test/sgr_residual_test.dart` — неизвестные функции, ветви и все reverse
  surfaces; узкие прежние тесты остаются в своих файлах.

---

### Task 1: Публичный словарь новых SGR

**Files:**
- Modify: `lib/src/ansi/sgr.dart:58-115,190-235`
- Modify: `lib/src/ready_to_use/sgr/sgr.dart:70-165`
- Modify: `lib/src/parsing/control_functions/sgr.dart:38-212`
- Modify: `test/ansi_constants_test.dart:20-115,235-330`

**Interfaces:**
- Consumes: существующие `CSI`, `SGR` и стабильные индексы
  `ControlFunctionsSGR.values`.
- Produces: integer constants `PROPORTIONAL_SPACING`,
  `NOT_PROPORTIONAL_SPACING`, `IDEOGRAM_*`, `NOT_IDEOGRAM`; ready strings
  `primaryFont`, `alternativeFont1`–`alternativeFont9`, `fraktur`,
  `resetFontShape`, extended underline, proportional и ideogram.
- Preserves: enum names `reserved_26`, `reserved_50`, `reserved_60`–
  `reserved_65`.

- [ ] **Step 1: повторить baseline-пробник до первой production-правки**

Запустить временный файл вне репозитория с этим телом:

```dart
import 'dart:convert';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  const samples = <String, String>{
    'fonts': '\x1B[11mA\x1B[10mB',
    'shape': '\x1B[20mA\x1B[23mB',
    'spacing': '\x1B[26mA\x1B[50mB',
    'ideogram': '\x1B[60mA\x1B[65mB',
    'mixed': '\x1B[1;11;31mA\x1B[0mB',
    'curly': '\x1B[4:3mA',
    'unknown': '\x1B[99mA',
    'unknownColor': '\x1B[38;7;1mA',
    'overflow': '\x1B[999999999999999999999999mA',
    'private': '\x1B[?99mA',
    'intermediate': '\x1B[1 mA',
  };

  for (final MapEntry(key: name, value: input) in samples.entries) {
    print(jsonEncode({
      'name': name,
      'entity': Parser(input).pieces.first.entity.runtimeType.toString(),
      'optimize': Parser(input).optimize(),
      'substring': Parser(input).substring(0),
      'printer': Printer().prepare(input),
      'stacked': StackedParser(input).optimize(),
    }));
  }
}
```

На `fd978c0` зафиксировано:

```text
fonts/shape/spacing/ideogram: optimize=AB, substring=AB,
  printer="\u001b[0mAB", stacked=AB
mixed: optimize/substring/stacked="\u001b[31;1mA\u001b[0mB"
curly: optimize/substring/stacked="\u001b[4mA\u001b[0m"
unknown: optimize/substring/stacked="A", printer="\u001b[0mA"
unknownColor: optimize="\u001b[1mA\u001b[0m"
overflow: entity=CsiUnknown and all outputs retain the whole CSI
private: entity=CsiPrivate and all outputs retain the whole CSI
intermediate: entity=CsiUnknown and all outputs retain the whole CSI
```

- [ ] **Step 2: добавить красные тесты чисел, строк и стабильных enum names**

В `ansi_constants_test.dart` добавить:

```dart
    test('the newly modelled functions have public strings', () {
      expect(primaryFont, '\x1B[10m');
      expect(alternativeFont1, '\x1B[11m');
      expect(alternativeFont9, '\x1B[19m');
      expect(fraktur, '\x1B[20m');
      expect(resetFontShape, resetItalic);
      expect(curlyUnderline, '\x1B[4:3m');
      expect(dottedUnderline, '\x1B[4:4m');
      expect(dashedUnderline, '\x1B[4:5m');
      expect(proportionalSpacing, '\x1B[26m');
      expect(resetProportionalSpacing, '\x1B[50m');
      expect(ideogramUnderline, '\x1B[60m');
      expect(ideogramDoublyUnderline, '\x1B[61m');
      expect(ideogramOverline, '\x1B[62m');
      expect(ideogramDoublyOverline, '\x1B[63m');
      expect(ideogramStress, '\x1B[64m');
      expect(resetIdeogram, '\x1B[65m');
    });

    test('historical enum names keep their positions', () {
      expect(ControlFunctionsSGR.values[26].name, 'reserved_26');
      expect(ControlFunctionsSGR.values[50].name, 'reserved_50');
      expect(ControlFunctionsSGR.values[60].name, 'reserved_60');
      expect(ControlFunctionsSGR.values[65].name, 'reserved_65');
      expect(ControlFunctionsSGR.values[26].id, 'proportionalSpacing');
      expect(ControlFunctionsSGR.values[50].id, 'resetProportionalSpacing');
      expect(ControlFunctionsSGR.values[60].id, 'ideogramUnderline');
      expect(ControlFunctionsSGR.values[65].id, 'resetIdeogram');
    });
```

В большом `showControlFunctions` expectation заменить голые `10`–`20`,
`26`, `50`, `60`–`65` на semantic ids. Остальные reserved, включая `56`,
`57`, `66`–`72`, `98`, `99`, остаются числами.

- [ ] **Step 3: увидеть тест красным**

Run:

```bash
rtk dart test test/ansi_constants_test.dart
```

Expected: compile-time failures на отсутствующих ready constants; после их
временного объявления тест enum ids всё ещё красный на старых `isUnused`.

- [ ] **Step 4: добавить числовые и ready-to-use константы**

В `lib/src/ansi/sgr.dart` добавить:

```dart
const int PROPORTIONAL_SPACING = 26;
const int NOT_PROPORTIONAL_SPACING = 50;
const int IDEOGRAM_UNDERLINE = 60;
const int IDEOGRAM_DOUBLY_UNDERLINE = 61;
const int IDEOGRAM_OVERLINE = 62;
const int IDEOGRAM_DOUBLY_OVERLINE = 63;
const int IDEOGRAM_STRESS = 64;
const int NOT_IDEOGRAM = 65;
```

В ready-to-use слое добавить завершённые строки:

```dart
const String primaryFont = '$CSI$PRIMARY_FONT$SGR';
const String alternativeFont1 = '$CSI$ALT_FONT_1$SGR';
const String alternativeFont2 = '$CSI$ALT_FONT_2$SGR';
const String alternativeFont3 = '$CSI$ALT_FONT_3$SGR';
const String alternativeFont4 = '$CSI$ALT_FONT_4$SGR';
const String alternativeFont5 = '$CSI$ALT_FONT_5$SGR';
const String alternativeFont6 = '$CSI$ALT_FONT_6$SGR';
const String alternativeFont7 = '$CSI$ALT_FONT_7$SGR';
const String alternativeFont8 = '$CSI$ALT_FONT_8$SGR';
const String alternativeFont9 = '$CSI$ALT_FONT_9$SGR';
const String fraktur = '$CSI$FRAKTUR$SGR';
const String resetFontShape = resetItalic;
const String curlyUnderline = '$CSI$UNDERLINE:3$SGR';
const String dottedUnderline = '$CSI$UNDERLINE:4$SGR';
const String dashedUnderline = '$CSI$UNDERLINE:5$SGR';
const String proportionalSpacing = '$CSI$PROPORTIONAL_SPACING$SGR';
const String resetProportionalSpacing =
    '$CSI$NOT_PROPORTIONAL_SPACING$SGR';
const String ideogramUnderline = '$CSI$IDEOGRAM_UNDERLINE$SGR';
const String ideogramDoublyUnderline =
    '$CSI$IDEOGRAM_DOUBLY_UNDERLINE$SGR';
const String ideogramOverline = '$CSI$IDEOGRAM_OVERLINE$SGR';
const String ideogramDoublyOverline =
    '$CSI$IDEOGRAM_DOUBLY_OVERLINE$SGR';
const String ideogramStress = '$CSI$IDEOGRAM_STRESS$SGR';
const String resetIdeogram = '$CSI$NOT_IDEOGRAM$SGR';
```

Каждая декларация получает английский dartdoc со ссылками на setter/reset;
девять alternative constants пишутся явно, без runtime-таблицы.

- [ ] **Step 5: сделать поддержанными стабильные enum-элементы**

Снять `isUnused: true` у `10`–`20`, `26`, `50`, `60`–`65`. Историческим
reserved-элементам задать ids:

```dart
reserved_26(id: 'proportionalSpacing'),
reserved_50(id: 'resetProportionalSpacing'),
reserved_60(id: 'ideogramUnderline'),
reserved_61(id: 'ideogramDoublyUnderline'),
reserved_62(id: 'ideogramOverline'),
reserved_63(id: 'ideogramDoublyOverline'),
reserved_64(id: 'ideogramStress'),
reserved_65(id: 'resetIdeogram'),
```

Дартдок каждого ссылается на новую ready string и integer constant.

- [ ] **Step 6: прогнать узкий цикл и закоммитить словарь**

Run:

```bash
rtk dart format --output=none --set-exit-if-changed \
  lib/src/ansi/sgr.dart \
  lib/src/ready_to_use/sgr/sgr.dart \
  lib/src/parsing/control_functions/sgr.dart \
  test/ansi_constants_test.dart
rtk dart analyze --fatal-infos
rtk dart test test/ansi_constants_test.dart
```

Expected: PASS, analyze без diagnostics.

Commit:

```bash
rtk git add lib/src/ansi/sgr.dart \
  lib/src/ready_to_use/sgr/sgr.dart \
  lib/src/parsing/control_functions/sgr.dart \
  test/ansi_constants_test.dart
rtk git commit -m "feat: name the remaining standard SGR functions" \
  -m "Alternative fonts, fraktur, proportional spacing and ideogram functions already occupied stable enum positions but were marked unused and had no public strings. Give the standard functions semantic ids without changing any historical enum name or index."
```

---

### Task 2: Публичная модель `State`, `Style` и `Stack`

**Files:**
- Create: `test/unmodelled_sgr_state_test.dart`
- Modify: `test/style_state_test.dart`
- Modify: `test/stack_state_test.dart`
- Modify: `test/state_equality_contract_test.dart`
- Modify: `lib/src/parsing/state/state.dart:25-510`
- Modify: `lib/src/parsing/state/style.dart:1-410`
- Modify: `lib/src/parsing/state/stack.dart:45-490`
- Modify: `lib/src/parsing/state/styles.dart:1-55`

**Interfaces:**
- Consumes: Task 1 ready strings and integer constants.
- Produces: public enums `FontSelection`, `FontShape`, expanded
  `UnderlineStyle`, `IdeogramStyle`; getters and immutable transitions listed
  below; const `Style` constructor parameters; persistent `Stack` histories.
- Preserves: `isItalic`, `italic`, `resetItalic`, `underline`,
  `doublyUnderline`, `resetUnderline` and all existing constructor names.

- [ ] **Step 1: написать красные API- и transition-тесты**

Создать `test/unmodelled_sgr_state_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  test('Style exposes every newly modelled property', () {
    const style = Style(
      fontSelection: FontSelection.alternative3,
      fraktur: true,
      dottedUnderline: true,
      proportionalSpacing: true,
      ideogramStyle: IdeogramStyle.doublyOverline,
    );

    expect(style.fontSelection, FontSelection.alternative3);
    expect(style.fontShape, FontShape.fraktur);
    expect(style.isItalic, isFalse);
    expect(style.isFraktur, isTrue);
    expect(style.underlineStyle, UnderlineStyle.dotted);
    expect(style.isUnderline, isTrue);
    expect(style.isDottedUnderline, isTrue);
    expect(style.isProportionalSpacing, isTrue);
    expect(style.ideogramStyle, IdeogramStyle.doublyOverline);
  });

  test('fluent setters replace members of the same family', () {
    final style = Style.terminalColors
        .alternativeFont2
        .fraktur
        .curlyUnderline
        .proportionalSpacing
        .ideogramStress;

    expect(style.italic.fontShape, FontShape.italic);
    expect(style.dashedUnderline.underlineStyle, UnderlineStyle.dashed);
    expect(style.resetFont.fontSelection, FontSelection.primary);
    expect(style.resetFontShape.fontShape, isNull);
    expect(style.resetProportionalSpacing.isProportionalSpacing, isFalse);
    expect(style.resetIdeogram.ideogramStyle, isNull);
    expect(style.resetItalic, style.resetFontShape);
  });

  test('transitTo writes selective standard functions', () {
    expect(
      Styles.alternativeFont1.transitTo(Styles.bold),
      '\x1B[10;1m',
    );
    expect(Styles.italic.transitTo(Styles.fraktur), fraktur);
    expect(Styles.fraktur.transitTo(Styles.bold), '\x1B[23;1m');
    expect(Styles.underline.transitTo(Styles.curlyUnderline), curlyUnderline);
    expect(
      Styles.proportionalSpacing.transitTo(Styles.bold),
      '\x1B[50;1m',
    );
    expect(
      Styles.ideogramStress.transitTo(Styles.bold),
      '\x1B[65;1m',
    );
  });

  test('changeDefaultsTo fills only terminal defaults', () {
    final defaults = Styles.alternativeFont4.fraktur.dashedUnderline
        .proportionalSpacing.ideogramOverline;

    expect(Style.terminalColors.changeDefaultsTo(defaults), defaults);
    expect(
      Styles.alternativeFont2.italic.curlyUnderline
          .ideogramStress
          .changeDefaultsTo(defaults),
      Styles.alternativeFont2.italic.curlyUnderline
          .proportionalSpacing.ideogramStress,
    );
  });

  test('equality distinguishes every enum value', () {
    expect(Styles.curlyUnderline, isNot(Styles.dottedUnderline));
    expect(Styles.alternativeFont1, isNot(Styles.alternativeFont2));
    expect(Styles.ideogramUnderline, isNot(Styles.ideogramOverline));
    expect(
      {Styles.curlyUnderline, Styles.dottedUnderline},
      hasLength(2),
    );
  });

  test('Stack keeps one persistent history per reset family', () {
    final stack = Stack.terminalColors
        .alternativeFont1
        .alternativeFont2
        .italic
        .fraktur
        .curlyUnderline
        .dottedUnderline
        .proportionalSpacing
        .proportionalSpacing
        .ideogramUnderline
        .ideogramStress;

    expect(stack.resetFont.fontSelection, FontSelection.alternative1);
    expect(stack.resetFontShape.fontShape, FontShape.italic);
    expect(stack.resetUnderline.underlineStyle, UnderlineStyle.curly);
    expect(stack.resetProportionalSpacing.isProportionalSpacing, isTrue);
    expect(stack.resetIdeogram.ideogramStyle, IdeogramStyle.underline);
  });
}
```

В `style_state_test.dart` расширить transition table тремя underline kinds;
в `stack_state_test.dart` добавить новые reset names в unbalanced map; в
`state_equality_contract_test.dart` добавить cross-type equality для одного
нового составного `Style` и соответствующего `Stack.toStyle()`.

- [ ] **Step 2: увидеть API-тест красным на отсутствующих типах**

Run:

```bash
rtk dart test test/unmodelled_sgr_state_test.dart \
  test/style_state_test.dart \
  test/stack_state_test.dart \
  test/state_equality_contract_test.dart
```

Expected: compile-time failures на `FontSelection`, `FontShape`, новых
constructor args и fluent getters.

- [ ] **Step 3: добавить enum и абстрактную поверхность `State`**

В `style.dart` объявить:

```dart
enum FontSelection {
  primary,
  alternative1,
  alternative2,
  alternative3,
  alternative4,
  alternative5,
  alternative6,
  alternative7,
  alternative8,
  alternative9,
}

enum FontShape { italic, fraktur }

enum UnderlineStyle { singly, doubly, curly, dotted, dashed }

enum IdeogramStyle {
  underline,
  doublyUnderline,
  overline,
  doublyOverline,
  stress,
}
```

В `State<S>` добавить точные read-интерфейсы:

```dart
FontSelection get fontSelection;
FontShape? get fontShape;
bool get isFraktur;
bool get isCurlyUnderline;
bool get isDottedUnderline;
bool get isDashedUnderline;
bool get isProportionalSpacing;
IdeogramStyle? get ideogramStyle;
```

И точные immutable transitions:

```dart
S get alternativeFont1;
S get alternativeFont2;
S get alternativeFont3;
S get alternativeFont4;
S get alternativeFont5;
S get alternativeFont6;
S get alternativeFont7;
S get alternativeFont8;
S get alternativeFont9;
S get resetFont;
S get fraktur;
S get resetFontShape;
S get curlyUnderline;
S get dottedUnderline;
S get dashedUnderline;
S get proportionalSpacing;
S get resetProportionalSpacing;
S get ideogramUnderline;
S get ideogramDoublyUnderline;
S get ideogramOverline;
S get ideogramDoublyOverline;
S get ideogramStress;
S get resetIdeogram;
```

`resetItalic` остаётся в интерфейсе и делегирует общей операции shape.

- [ ] **Step 4: расширить плоский `Style`**

Добавить поля `_fontSelection` и `_ideogramStyle`; выделить флаги для
fraktur, proportional spacing и трёх новых underline. Конструктор принимает
точно:

```dart
FontSelection fontSelection = FontSelection.primary,
bool fraktur = false,
bool curlyUnderline = false,
bool dottedUnderline = false,
bool dashedUnderline = false,
bool proportionalSpacing = false,
IdeogramStyle? ideogramStyle,
```

Assertions запрещают одновременно `italic && fraktur` и более одного из
`underline`, `doublyUnderline`, `curlyUnderline`, `dottedUnderline`,
`dashedUnderline`. `Style._`, все colour setters и `_setFlags` сохраняют оба
новых поля. Семейства реализуются заменой текущего значения:

```dart
@override
Style get fraktur => _setFontShape(FontShape.fraktur);

@override
Style get resetFontShape => _setFontShape(null);

@override
Style get resetItalic => resetFontShape;

@override
Style get curlyUnderline => _setUnderline(UnderlineStyle.curly);

@override
Style get resetUnderline => _setUnderline(null);
```

`_setFont`, `_setFontShape`, `_setUnderline`, `_setIdeogram` отвечают `this`,
если видимое значение не меняется. Proportional spacing работает флагом.
`italic` обязательно вызывает `_setFontShape(FontShape.italic)`, поэтому
заменяет fraktur, а не сосуществует с ним. `isUnderline` истинен для singly,
curly, dotted и dashed; `isDoublyUnderline` истинен только для doubly.

- [ ] **Step 5: расширить persistent `Stack` без списков**

Заменить `_italicCounter` на `_Frame<FontShape>? _fontShape` и добавить:

```dart
final _Frame<FontSelection>? _font;
final int _proportionalSpacingCounter;
final _Frame<IdeogramStyle>? _ideogram;
```

Primary остаётся отсутствием font-frame. Alternative setters push новый
`_Frame`, reset снимает один:

```dart
@override
FontSelection get fontSelection =>
    _font?.value ?? FontSelection.primary;

@override
Stack get alternativeFont1 => _copyWith(
      font: (frames: _Frame(FontSelection.alternative1, _font)),
    );

@override
Stack get resetFont {
  final top = _font;
  return top == null ? this : _copyWith(font: (frames: top.under));
}
```

Font shape, underline и ideogram используют `_Frame<T>` с push/pop.
Proportional spacing использует counter с increment и guarded decrement.
`terminalColors`, `Stack._`, `_copyWith` и `toStyle()` передают каждое новое
поле явно.

- [ ] **Step 6: расширить переход, defaults, equality и diagnostics**

В `State.transitTo`:

- reset codes: `10`, `23`, `24`, `50`, `65`;
- set codes: `11`–`19`, `3/20`, `4`, `21`, `4:3`, `4:4`, `4:5`, `26`,
  `60`–`64`;
- для underline перевести `setParams` с `List<int>` на `List<String>`, чтобы
  colon-параметр мог стоять рядом с обычными;
- full `SGR 0` shortcut оставить прежним.

`changeDefaultsTo` выбирает self, если enum не default/null, иначе other;
bool proportional объединяет через `||`. Equality сравнивает
`fontSelection`, `fontShape`, `underlineStyle`, proportional и
`ideogramStyle`, а не только старые underline bools. `hashCode` перевести на
`Object.hashAll([...])`, чтобы число полей не упиралось в arity.

`toShortString()` пишет semantic names: `alternativeFont3`, `fraktur`,
`dottedUnderline`, `proportionalSpacing`, `ideogramDoublyOverline`.

- [ ] **Step 7: добавить const-стили и получить зелёный цикл**

В `Styles` добавить девять alternative fonts, `fraktur`, три underline,
proportional spacing и пять ideogram:

```dart
static const Style alternativeFont1 =
    Style(fontSelection: FontSelection.alternative1);
static const Style alternativeFont2 =
    Style(fontSelection: FontSelection.alternative2);
static const Style alternativeFont3 =
    Style(fontSelection: FontSelection.alternative3);
static const Style alternativeFont4 =
    Style(fontSelection: FontSelection.alternative4);
static const Style alternativeFont5 =
    Style(fontSelection: FontSelection.alternative5);
static const Style alternativeFont6 =
    Style(fontSelection: FontSelection.alternative6);
static const Style alternativeFont7 =
    Style(fontSelection: FontSelection.alternative7);
static const Style alternativeFont8 =
    Style(fontSelection: FontSelection.alternative8);
static const Style alternativeFont9 =
    Style(fontSelection: FontSelection.alternative9);
static const Style fraktur = Style(fraktur: true);
static const Style curlyUnderline = Style(curlyUnderline: true);
static const Style dottedUnderline = Style(dottedUnderline: true);
static const Style dashedUnderline = Style(dashedUnderline: true);
static const Style proportionalSpacing = Style(proportionalSpacing: true);
static const Style ideogramUnderline =
    Style(ideogramStyle: IdeogramStyle.underline);
static const Style ideogramDoublyUnderline =
    Style(ideogramStyle: IdeogramStyle.doublyUnderline);
static const Style ideogramOverline =
    Style(ideogramStyle: IdeogramStyle.overline);
static const Style ideogramDoublyOverline =
    Style(ideogramStyle: IdeogramStyle.doublyOverline);
static const Style ideogramStress =
    Style(ideogramStyle: IdeogramStyle.stress);
```

Run:

```bash
rtk dart format --output=none --set-exit-if-changed \
  lib/src/parsing/state \
  test/unmodelled_sgr_state_test.dart \
  test/style_state_test.dart \
  test/stack_state_test.dart \
  test/state_equality_contract_test.dart
rtk dart analyze --fatal-infos
rtk dart test test/unmodelled_sgr_state_test.dart \
  test/style_state_test.dart \
  test/stack_state_test.dart \
  test/state_equality_contract_test.dart
```

Expected: PASS, analyze без diagnostics.

- [ ] **Step 8: доказать equality-мутацию и закоммитить модель**

Временно убрать `underlineStyle` из `State.==` и `hashCode`. Тест множества
curly/dotted обязан стать красным. Вернуть оба поля и повторить PASS.

Commit:

```bash
rtk git add lib/src/parsing/state/state.dart \
  lib/src/parsing/state/style.dart \
  lib/src/parsing/state/stack.dart \
  lib/src/parsing/state/styles.dart \
  test/unmodelled_sgr_state_test.dart \
  test/style_state_test.dart \
  test/stack_state_test.dart \
  test/state_equality_contract_test.dart
rtk git commit -m "feat: expose the remaining standard rendition state" \
  -m "Reverse operations can preserve standard SGR only when State can name it. Add typed font, shape, underline, spacing and ideogram surfaces while retaining every existing name and Stack's persistent pop semantics."
```

---

### Task 3: Известные функции проходят через parser pipeline

**Files:**
- Modify: `lib/src/parsing/parser/entities/sgr.dart:20-180,330-520`
- Modify: `test/parser_sgr_subparams_test.dart`
- Modify: `test/ansi_constants_test.dart`
- Modify: `test/unmodelled_sgr_state_test.dart`

**Interfaces:**
- Consumes: Task 2 State transitions.
- Produces: `SgrUnderlineFunction` for all `4:n`; exact left-to-right mapping
  `10–20`, `26/50`, `60–65` to public state.
- Preserves: public `Sgr.functions`, `contains`, order and unknown subclasses.

- [ ] **Step 1: добавить красные parser- и reverse-тесты**

В `unmodelled_sgr_state_test.dart` добавить:

```dart
  test('the parser maps every standard family', () {
    final state = Parser(
      '\x1B[13;20;4:4;26;63mtext',
    ).finalState;

    expect(state.fontSelection, FontSelection.alternative3);
    expect(state.fontShape, FontShape.fraktur);
    expect(state.underlineStyle, UnderlineStyle.dotted);
    expect(state.isProportionalSpacing, isTrue);
    expect(state.ideogramStyle, IdeogramStyle.doublyOverline);

    final resetState = Parser(
      '\x1B[13;20;4:4;26;63m\x1B[10;23;24;50;65m',
    ).finalState;
    expect(resetState, Style.terminalColors);
  });

  test('known functions survive every reverse output', () {
    const input = '\x1B[11mA\x1B[10mB';
    expect(Parser(input).optimize(close: false), input);
    expect(Parser(input).substring(0, close: false), input);
    expect(StackedParser(input).optimize(close: false), input);
    expect(Printer().prepare(input), '\x1B[0m$input');
  });

  test('extended underline keeps its exact semantic kind', () {
    const input = '\x1B[4:3mA';
    final function =
        (Parser(input).pieces.first.entity as Sgr).functions.single;

    expect(function, isA<SgrUnderlineFunction>());
    expect(
      (function as SgrUnderlineFunction).style,
      UnderlineStyle.curly,
    );
    expect(Parser(input).optimize(close: false), input);
  });
```

В `parser_sgr_subparams_test.dart` заменить старый тест, объединявший 1,3,4,5
в singly, на точную таблицу `0 → null`, `1 → singly`, `2 → doubly`,
`3 → curly`, `4 → dotted`, `5 → dashed`; `4:6` должен остаться
`SgrUnknownParamsFunction` и state не менять.

- [ ] **Step 2: увидеть старую потерю красной**

Run:

```bash
rtk dart test test/unmodelled_sgr_state_test.dart \
  test/parser_sgr_subparams_test.dart \
  test/ansi_constants_test.dart
```

Expected: finalState не несёт новых свойств; reverse output равен `AB`;
`4:3` всё ещё singly.

- [ ] **Step 3: добавить публичный `SgrUnderlineFunction`**

В семействе `SgrFunction` добавить:

```dart
final class SgrUnderlineFunction extends SgrFunctionWithCode {
  final UnderlineStyle? style;

  SgrUnderlineFunction(this.style)
      : super(switch (style) {
          null => ControlFunctionsSGR.resetUnderline,
          UnderlineStyle.doubly => ControlFunctionsSGR.doublyUnderline,
          _ => ControlFunctionsSGR.underline,
        });

  @override
  String toString() => switch (style) {
        null => 'resetUnderline',
        UnderlineStyle.singly => 'underline',
        UnderlineStyle.doubly => 'doublyUnderline',
        UnderlineStyle.curly => 'curlyUnderline',
        UnderlineStyle.dotted => 'dottedUnderline',
        UnderlineStyle.dashed => 'dashedUnderline',
      };
}
```

`Sgr.contains` продолжает работать через унаследованный `code`.

- [ ] **Step 4: заменить приближённый underline-разбор точной таблицей**

Для `CsiParamNumbers`, начинающегося с `UNDERLINE`, взять второй subparam
(либо 1, если он отсутствует). Значения 0–5 коммитят
`SgrUnderlineFunction` и применяют точный State transition; любое другое
значение коммитит `SgrUnknownParamsFunction(values)` без изменения state.

```dart
final style = switch (values.length > 1 ? values[1] : 1) {
  0 => null,
  1 => UnderlineStyle.singly,
  2 => UnderlineStyle.doubly,
  3 => UnderlineStyle.curly,
  4 => UnderlineStyle.dotted,
  5 => UnderlineStyle.dashed,
  _ => _unknownUnderline,
};
```

Использовать приватный sentinel вместо nullable ambiguity: `null` уже значит
валидный reset.

- [ ] **Step 5: подключить standard simple codes**

В `_parseSimpleFunction` добавить switch arms:

```dart
PRIMARY_FONT => state.resetFont,
ALT_FONT_1 => state.alternativeFont1,
ALT_FONT_2 => state.alternativeFont2,
ALT_FONT_3 => state.alternativeFont3,
ALT_FONT_4 => state.alternativeFont4,
ALT_FONT_5 => state.alternativeFont5,
ALT_FONT_6 => state.alternativeFont6,
ALT_FONT_7 => state.alternativeFont7,
ALT_FONT_8 => state.alternativeFont8,
ALT_FONT_9 => state.alternativeFont9,
FRAKTUR => state.fraktur,
NOT_ITALIC => state.resetFontShape,
PROPORTIONAL_SPACING => state.proportionalSpacing,
NOT_PROPORTIONAL_SPACING => state.resetProportionalSpacing,
IDEOGRAM_UNDERLINE => state.ideogramUnderline,
IDEOGRAM_DOUBLY_UNDERLINE => state.ideogramDoublyUnderline,
IDEOGRAM_OVERLINE => state.ideogramOverline,
IDEOGRAM_DOUBLY_OVERLINE => state.ideogramDoublyOverline,
IDEOGRAM_STRESS => state.ideogramStress,
NOT_IDEOGRAM => state.resetIdeogram,
```

- [ ] **Step 6: получить зелёные state и reverse outputs**

Run:

```bash
rtk dart format --output=none --set-exit-if-changed \
  lib/src/parsing/parser/entities/sgr.dart \
  test/parser_sgr_subparams_test.dart \
  test/ansi_constants_test.dart \
  test/unmodelled_sgr_state_test.dart
rtk dart analyze --fatal-infos
rtk dart test test/unmodelled_sgr_state_test.dart \
  test/parser_sgr_subparams_test.dart \
  test/ansi_constants_test.dart
```

Expected: PASS. Повторить Task 1 probe: четыре стандартных семейства больше
не дают `AB`; unknown и unknownColor пока остаются старой потерей.

- [ ] **Step 7: доказать parser-мутацию и закоммитить**

Временно вернуть `FRAKTUR => state` и `4:3` к singly. Тесты fraktur и curly
обязаны стать красными независимо. Вернуть mappings, повторить PASS.

Commit:

```bash
rtk git add lib/src/parsing/parser/entities/sgr.dart \
  test/parser_sgr_subparams_test.dart \
  test/ansi_constants_test.dart \
  test/unmodelled_sgr_state_test.dart
rtk git commit -m "feat: parse the full standard rendition model" \
  -m "The parser named the remaining standard parameters as unused and collapsed every decorated underline to a single line. Map each function to the typed State surface so reverse operations can reconstruct it without an opaque fallback."
```

---

### Task 4: Persistent residual и `optimize`

**Files:**
- Create: `lib/src/parsing/parser/sgr_residual.dart`
- Create: `test/sgr_residual_test.dart`
- Modify: `lib/src/parsing/parser/parser.dart:1-180,1080-1175`
- Modify: `lib/src/parsing/parser/entities/sgr.dart`
- Modify: `lib/src/parsing/parser/entities/csi.dart:8-55`
- Modify: `lib/src/parsing/parser/entities/matching_state.dart`
- Modify: `lib/src/parsing/parser/pieces/piece.dart`
- Modify: `lib/src/parsing/parser/pieces/pieces.dart`
- Modify: `lib/src/parsing/parser/pieces/pieces_result.dart`
- Modify: `lib/src/parsing/parser/pieces/parser_iterator.dart`

**Interfaces:**
- Consumes: complete known State model from Tasks 1–3.
- Produces: private `_SgrOperation`, `_SgrResidualRoot`, `_SgrResidual`,
  `_renditionTransit`; private `initialResidual`/`finalResidual` pipeline;
  `_isStatefulSgr(Entity)` for `Sgr` and overflowed SGR-shaped `CsiUnknown`.
- Preserves: public `Piece`, `Pieces`, `Sgr.functions`, `CsiUnknown` runtime
  type and all public constructors.

- [ ] **Step 1: добавить красные core residual tests**

Создать `test/sgr_residual_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

const _unknown = '\x1B[99m';
const _overflow = '\x1B[999999999999999999999999m';

void main() {
  group('optimize keeps opaque SGR state:', () {
    test('a small unknown is emitted and closed', () {
      expect(
        Parser('${_unknown}A').optimize(),
        '${_unknown}A$reset',
      );
      expect(
        Parser('${_unknown}A').optimize(close: false),
        '${_unknown}A',
      );
    });

    test('a known setter after unknown is never called redundant', () {
      const input = '${bold}${_unknown}A${bold}B';
      final output = Parser(input).optimize(close: false);

      expect(output, input);
      expect(RegExp(RegExp.escape(bold)).allMatches(output), hasLength(2));
      expect(Parser(output).optimize(close: false), output);
    });

    test('a real reset prunes everything before it', () {
      expect(
        Parser('\x1B[99;0;31mA').optimize(close: false),
        '${fgRed}A',
      );
      expect(
        Parser('\x1B[0;99mA').optimize(close: false),
        '${_unknown}A',
      );
    });

    test('an unsupported colour keeps its raw function and tail', () {
      expect(
        Parser('\x1B[38;7;1mA').optimize(close: false),
        '\x1B[38;7m${bold}A',
      );
    });

    test('overflow is stateful but keeps CsiUnknown publicly', () {
      final parser = Parser('${_overflow}A');
      expect(parser.pieces.first.entity, isA<CsiUnknown>());
      expect(parser.optimize(), '${_overflow}A$reset');
    });

    test('private and intermediate CSI stay literal, not stateful', () {
      expect(Parser('\x1B[?99mAB').substring(1), 'B');
      expect(Parser('\x1B[1 mAB').substring(1), 'B');
    });

    test('Stack reset reopens the visible lower frame', () {
      const input = '${bold}${bold}${_unknown}A${resetBoldAndDim}B';
      final output = StackedParser(input).optimize(close: false);
      final reparsed = Parser(output);
      final plain = reparsed.removeAll();

      expect(output, contains('$resetBoldAndDim$bold'));
      expect(reparsed.stateAt(plain.indexOf('B')).isBold, isTrue);
    });

    test('save and restore return to the residual branch', () {
      const input = '${_unknown}A\x1B7${bold}B\x1B8C';
      final output = Parser(input).optimize(close: false);

      expect(output, contains('$reset${_unknown}\x1B8C'));
      expect(Parser(output).optimize(close: false), output);
    });
  });
}
```

- [ ] **Step 2: увидеть все новые cases красными**

Run:

```bash
rtk dart test test/sgr_residual_test.dart
```

Expected: small unknown отсутствует; redundant bold удалён; unknown color
теряет `38;7`; overflow не получает closing reset; private/intermediate
substring tests уже зелёные и служат отрицательными стражами.

- [ ] **Step 3: ввести приватную операцию с точными raw-параметрами**

`Csi._parse` передаёт в `Sgr._parse` не только parsed params, но и
`paramsString.split(';')`. `_SgrParsingState` отмечает индекс начала каждой
функции перед switch и при `commitFunction` строит:

```dart
final rawParameters = _rawParams
    .sublist(_operationStart, _index + 1)
    .join(';');
final operation = _SgrOperation(
  string: '$CSI$rawParameters$SGR',
  function: function,
  state: state.toStyle(),
);
```

Raw-list обязателен: `CsiParamNumbers.toString()` нормализует пустой
subparameter в `0`, а residual хранит исходную запись. Публичный
`Sgr.functions` остаётся отдельным immutable list.

Операция имеет точную и закрытую форму; nullable function нужен только
overflowed SGR, который сохранил публичный тип `CsiUnknown`:

```dart
final class _SgrOperation {
  final String string;
  final SgrFunction? function;
  final Style state;

  const _SgrOperation({
    required this.string,
    required this.function,
    required this.state,
  });

  const _SgrOperation.opaque(this.string, this.state) : function = null;

  bool get isUnknown =>
      function == null || _isUnknownSgrFunction(function!);
}
```

Overflow создаёт `_SgrOperation.opaque(entity.string, state.toStyle())`;
его raw bytes попадают в тот же journal без попытки построить
`SgrFunction`.

Состояние применять в одном helper после распознавания function:

```dart
S _applyKnownSgrFunction<S extends State<S>>(
  S state,
  SgrFunction function,
) => switch (function) {
  SgrDefaultFunction() => state.reset,
  SgrUnderlineFunction(:final style) => switch (style) {
      null => state.resetUnderline,
      UnderlineStyle.singly => state.underline,
      UnderlineStyle.doubly => state.doublyUnderline,
      UnderlineStyle.curly => state.curlyUnderline,
      UnderlineStyle.dotted => state.dottedUnderline,
      UnderlineStyle.dashed => state.dashedUnderline,
    },
  SgrColorFunction(:final code, :final color) => switch (code) {
      ControlFunctionsSGR.fg => state.foreground(color),
      ControlFunctionsSGR.bg => state.background(color),
      ControlFunctionsSGR.underlineColor => state.underlineColor(color),
      _ => state,
    },
  SgrSimpleFunction(:final code) => _applySimpleCode(state, code),
  _ => state,
};
```

`_applySimpleCode` несёт полный существующий switch плюс Tasks 1–3; старые
state assignments из трёх parse-веток удаляются, чтобы mapping не жил дважды.

- [ ] **Step 4: реализовать persistent journal в отдельном part**

Добавить `part 'sgr_residual.dart';` и типы:

```dart
typedef _StyleProjection = Style Function(Style style);

Style _identityStyle(Style style) => style;

final class _SgrResidualRoot {
  final Style base;
  const _SgrResidualRoot(this.base);
}

final class _SgrResidual {
  final _SgrResidualRoot root;
  final _SgrResidual? previous;
  final _SgrOperation operation;
  final int depth;

  const _SgrResidual._(
    this.root,
    this.previous,
    this.operation,
    this.depth,
  );
}
```

Unknown при null residual создаёт root с `before.toStyle()` и первый node.
Любая функция после него добавляет node. `SgrDefaultFunction` и simple code
`reset` возвращают residual `null`, не добавляя node. Known до первого unknown
не создаёт root.

Unknown predicates перечисляют классы явно:

```dart
bool _isUnknownSgrFunction(SgrFunction function) => switch (function) {
  SgrUnknownParamFunction() ||
  SgrUnknownParamsFunction() ||
  SgrUnknownColorFunctionFromParams() ||
  SgrUnknownColorFunctionFromValues() => true,
  _ => false,
};
```

- [ ] **Step 5: реализовать ancestry и общий rendition transition**

`_renditionTransit` принимает уже effective `from`/`to`, residual tails и
projection, используемую только для root/node state:

```dart
String _renditionTransit({
  required Style from,
  required _SgrResidual? fromResidual,
  required Style to,
  required _SgrResidual? toResidual,
  _StyleProjection project = _identityStyle,
  bool skipSet = false,
  bool skipReset = false,
})
```

Алгоритм:

1. оба tail null → `from.transitTo(to, skipSet:, skipReset:)`;
2. target — descendant current → подняться от target до depth current,
   проверить identity и выпустить собранный suffix в прямом порядке через
   тот же replay операций с projection/correction;
3. from null, target active → перейти `from → project(root.base)`, затем
   replay root-to-target;
4. current active и target отсутствует/diverged → написать `reset`, затем
   `Style.terminalColors → to` либо `→ project(root.base)` и replay.

При replay unknown пишет только raw. Known пишет raw обязательно, применяет
function к effective Style, затем селективно чинит разницу до
`project(node.operation.state)`:

```dart
buf.write(operation.string);
if (!operation.isUnknown) {
  final rawAfter = _applyKnownSgrFunction(effective, operation.function!);
  final desired = project(operation.state);
  final correction = rawAfter.transitTo(desired);
  assert(correction != reset);
  buf.write(correction);
  effective = desired;
}
```

Assertion фиксирует доказанный инвариант: operation correction меняет только
семейство текущей функции и не имеет права выбрать full reset. Если он
срабатывает, добавить точный красный тест и построить selective family
correction; assertion не удалять и не заменять full reset.

- [ ] **Step 6: пронести snapshot через lazy parser**

Добавить private `_residual` в `Piece`, `finalResidual` в `_PiecesResult`,
`_initialResidual` в `Pieces`, `initialResidual`/`finalResidual` в
`_ParserBase`, `currentResidual` в iterator и residual в `_MatchingState`.

Save-slot становится:

```dart
({S state, Link? link, _SgrResidual? residual})? _saved;
```

Cached `SaveCursor` восстанавливает все три поля из `Piece`; `RestoreCursor`
возвращает saved triple либо initial triple. Каждый новый `Piece` получает
post-entity residual. `Piece.toString()` residual не печатает.

- [ ] **Step 7: классифицировать overflowed SGR без смены entity type**

В `Csi._parse` внутри `on FormatException` только для
`function == ControlSequencesFunctions.SGR` открыть/продолжить opaque residual
целой `state.string`. Возвращаемая сущность остаётся `CsiUnknown`.

Добавить helper без pattern-expression, чтобы код оставался совместим с
нижней ногой Dart 3.6:

```dart
bool _isStatefulSgr(Entity entity) {
  if (entity is Sgr) return true;
  if (entity is! CsiUnknown) return false;

  final match = sgrRe.matchAsPrefix(entity.string);
  return match != null && match.end == entity.string.length;
}
```

Private/intermediate CSI не совпадают с `sgrRe` и остаются literal.

- [ ] **Step 8: подключить общий переход к `optimize`**

`optimize` хранит `currentState` и `currentResidual` именно выведенного
контекста. `_isStatefulSgr` пропускается без немедленной записи. Перед каждым
не-SGR entity:

```dart
final transit = _renditionTransit(
  from: currentState,
  fromResidual: currentResidual,
  to: m.state.toStyle(),
  toResidual: m._residual,
);
```

После записи обновить оба current. Tail с `close:true` идёт к initial state и
initial residual; `close:false` — к state/residual последнего Piece. Так SGR
без последующего текста сохраняется только в open output, как существующий
известный стиль.

- [ ] **Step 9: получить зелёный core и доказать две мутации**

Run:

```bash
rtk dart format --output=none --set-exit-if-changed \
  lib/src/parsing/parser \
  test/sgr_residual_test.dart
rtk dart analyze --fatal-infos
rtk dart test test/sgr_residual_test.dart \
  test/parser_keeps_codes_test.dart \
  test/parser_optimize_links_test.dart \
  test/round_trip_invariant_test.dart
```

Expected: PASS, analyze без diagnostics.

Мутация A: в advancement не добавлять known operation при active residual.
Тест второго bold обязан упасть. Мутация B: вернуть `CsiUnknown` overflow к
literal-copy и не менять residual. Тест closing reset и поздний substring
обязан упасть после Task 5; на этом шаге падает exact optimize close. Вернуть
обе правки и повторить PASS.

- [ ] **Step 10: закоммитить core residual**

```bash
rtk git add lib/src/parsing/parser/parser.dart \
  lib/src/parsing/parser/sgr_residual.dart \
  lib/src/parsing/parser/entities/sgr.dart \
  lib/src/parsing/parser/entities/csi.dart \
  lib/src/parsing/parser/entities/matching_state.dart \
  lib/src/parsing/parser/pieces/piece.dart \
  lib/src/parsing/parser/pieces/pieces.dart \
  lib/src/parsing/parser/pieces/pieces_result.dart \
  lib/src/parsing/parser/pieces/parser_iterator.dart \
  test/sgr_residual_test.dart
rtk git commit -m "fix: optimize carries opaque SGR state" \
  -m "State cannot name vendor parameters, unsupported colour forms or numeric overflow, so rebuilding only its visible surface deleted them. Track an immutable operation journal beside each piece and replay only the required branch while keeping the ordinary path allocation-free."
```

---

### Task 5: `substring` восстанавливает residual на срезе

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart:430-705`
- Modify: `test/sgr_residual_test.dart`
- Test: `test/substring_open_state_test.dart`
- Test: `test/parser_substring_differential_test.dart`
- Test: `test/reemission_invariant_test.dart`

**Interfaces:**
- Consumes: `_renditionTransit`, `Piece._residual`, `_isStatefulSgr` Task 4.
- Produces: standalone reconstruction at the first emitted text and correct
  close/open tail for residual branches.
- Preserves: hyperlink/unfinished ordering and closed H5 behavior where both
  residual tails are null.

- [ ] **Step 1: добавить красные slice tests**

В `sgr_residual_test.dart` добавить:

```dart
  group('substring restores opaque state:', () {
    test('the opener may stand before the slice', () {
      const input = '${fgRed}${_unknown}A${bold}B';

      expect(
        Parser(input).substring(1, maxLength: 1),
        '${fgRed}${_unknown}${bold}B$reset',
      );
      expect(
        Parser(input).substring(1, maxLength: 1, close: false),
        '${fgRed}${_unknown}${bold}B',
      );
    });

    test('overflow is replayed when the slice starts later', () {
      expect(
        Parser('${_overflow}AB').substring(1),
        '${_overflow}B$reset',
      );
    });

    test('a restored branch is reconstructed before later text', () {
      const input = '${_unknown}A\x1B7${bold}B\x1B8C';
      final slice = Parser(input).substring(0, close: false);

      expect(slice, contains('$reset${_unknown}\x1B8C'));
      expect(Parser(slice).optimize(close: false), slice);
    });

    test('ordinary private CSI before the cut is not replayed', () {
      expect(Parser('\x1B[?99mAB').substring(1), 'B');
      expect(Parser('\x1B[1 mAB').substring(1), 'B');
    });
  });
```

- [ ] **Step 2: увидеть opener и overflow красными**

Run:

```bash
rtk dart test test/sgr_residual_test.dart
```

Expected: slices содержат только modeled red/bold либо plain text; private
negative guards проходят.

- [ ] **Step 3: вести emitted residual рядом с `currentState`**

Инициализировать `currentResidual = initialResidual`. Перед первым text и
каждым copied non-SGR entity строить общий переход к `m.state/m._residual`.
После записи обновлять оба поля. Stateful SGR, включая overflow
`CsiUnknown`, не копировать в ветке `EscapeCode`: он выйдет через transition.

Все `_firstNotEmpty` получают новый `transit` в том же месте старого, поэтому
порядок остаётся:

```text
held unfinished → held link bytes → link reopening → rendition transit → text
```

- [ ] **Step 4: перевести tail на обе координаты**

Для `close:true` target — `initialState.toStyle()` и `initialResidual`; для
`close:false` — `lastPiece.state.toStyle()` и `lastPiece._residual`.
Передать старый `skipSet: true` в `_renditionTransit`: helper применяет его
только в null/null fast path, а active residual обязан выдать нужный suffix
или reset/replay.

- [ ] **Step 5: прогнать slice-инварианты и мутацию**

Run:

```bash
rtk dart format --output=none --set-exit-if-changed \
  lib/src/parsing/parser/parser.dart \
  test/sgr_residual_test.dart
rtk dart analyze --fatal-infos
rtk dart test test/sgr_residual_test.dart \
  test/substring_open_state_test.dart \
  test/parser_substring_differential_test.dart \
  test/parser_substring_links_test.dart \
  test/reemission_invariant_test.dart
```

Expected: PASS. Временно заменить `_renditionTransit` перед text старым
`currentState.transitTo(m.state)`: opener-before-slice и overflow tests обязаны
упасть, private negative guards остаться зелёными. Вернуть helper.

- [ ] **Step 6: закоммитить substring slice**

```bash
rtk git add lib/src/parsing/parser/parser.dart test/sgr_residual_test.dart
rtk git commit -m "fix: substring reopens opaque SGR state" \
  -m "A slice can begin after the unknown function that styles its first character, so copying only codes inside the range is insufficient. Seed the slice from the piece's residual branch and preserve the established link and unfinished-sequence ordering."
```

---

### Task 6: Вставки наследуют и возвращают residual

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart:785-1075`
- Modify: `test/sgr_residual_test.dart`
- Test: `test/parser_insert_test.dart`
- Test: `test/insert_keeps_ambient_test.dart`
- Test: `test/insert_unfinished_invariant_test.dart`
- Test: `test/insert_text_unfinished_invariant_test.dart`

**Interfaces:**
- Consumes: Task 4 parser seed/final residual and rendition transition.
- Produces: private named `_Seam<S>` carrying cut/state/link/residual;
  branch restoration after raw inserted text.
- Preserves: one parse of the insertion, byte-for-byte completed insertion,
  `_terminatedInsertion` and all H2/H4 seam rules.

- [ ] **Step 1: добавить красные insertion branch tests**

В `sgr_residual_test.dart` добавить:

```dart
  group('insertions compose residual branches:', () {
    test('plain text inside an opaque ambient adds no repair', () {
      const input = '${_unknown}AB';
      expect(Parser(input).insertBefore(1, 'X'), '${_unknown}AXB');
      expect(Parser(input).insertAfter(1, 'X'), '${_unknown}AXB');
    });

    test('a reset insertion replays the outer branch', () {
      const input = '${_unknown}AB';
      expect(
        Parser(input).insertBefore(1, '${reset}X'),
        '${_unknown}A${reset}X${_unknown}B',
      );
    });

    test('an unknown insertion is reset before a clean tail', () {
      expect(
        Parser('AB').insertBefore(1, '${_unknown}X'),
        'A${_unknown}X${reset}B',
      );
    });

    test('a child branch returns to its opaque parent', () {
      const input = '${_unknown}AB';
      final result = Parser(input).insertBefore(1, '${bold}X');

      expect(result, '${_unknown}A${bold}X${reset}${_unknown}B');
    });

    test('Stack restores the visible parent frame', () {
      const input = '${bold}${bold}${_unknown}AB';
      final result =
          StackedParser(input).insertBefore(1, '${resetBoldAndDim}X');

      expect(result, contains('$reset${bold}${_unknown}B'));
    });
  });
```

В Stack journal хранит исторические два push, но после полного reset для
видимой реконструкции нижнего кадра нужен один `${bold}` перед unknown.

- [ ] **Step 2: увидеть ambient restoration красным**

Run:

```bash
rtk dart test test/sgr_residual_test.dart \
  test/insert_keeps_ambient_test.dart
```

Expected: plain insertion уже проходит; reset/child/clean-tail cases либо не
восстанавливают unknown, либо оставляют его течь в tail.

- [ ] **Step 3: заменить позиционный seam tuple named record**

Добавить:

```dart
typedef _Seam<S extends State<S>> = ({
  int cut,
  S state,
  Link? link,
  _SgrResidual? residual,
});
```

`_seamAt` возвращает `_Seam<S>` во всех ветках. Начало берёт initial triple;
text seam — `m.state/m.link/m._residual`; unfinished run — triple
`beforeRun` либо initial; конец — final triple. Рекурсивный surrogate branch
возвращает record без распаковки.

- [ ] **Step 4: seed insertion и вернуть ambient общим transition**

В `_insert`:

```dart
final seam = _seamAt(pos, after: after);
final read = Pieces<S>._(
  text,
  seam.state,
  initialLink: seam.link,
  initialResidual: seam.residual,
)._requireParsingResult;

final linkBack = _linkBack(seam: seam.link, left: read.finalLink);
final transit = _renditionTransit(
  from: read.finalState.toStyle(),
  fromResidual: read.finalResidual,
  to: seam.state.toStyle(),
  toResidual: seam.residual,
);
```

`tail`, `_firstNotEmpty`, `_terminatedInsertion` и return order остаются
прежними. Raw insertion не прогонять через optimize и не собирать из pieces.

- [ ] **Step 5: прогнать обе residual и прежние seam-матрицы**

Run:

```bash
rtk dart format --output=none --set-exit-if-changed \
  lib/src/parsing/parser/parser.dart \
  test/sgr_residual_test.dart
rtk dart analyze --fatal-infos
rtk dart test test/sgr_residual_test.dart \
  test/parser_insert_test.dart \
  test/insert_keeps_ambient_test.dart \
  test/insert_unfinished_invariant_test.dart \
  test/insert_text_unfinished_invariant_test.dart \
  test/parser_insert_surrogates_test.dart \
  test/parser_insert_links_test.dart
```

Expected: PASS; H2/H4 plain-инварианты и exact boundary bytes не меняются.

- [ ] **Step 6: доказать restoration-мутацию и закоммитить**

Временно вернуть `read.finalState.toStyle().transitTo(seam.state)` вместо
общего helper. Три branch tests обязаны упасть; plain ambient и H4 tests
остаться зелёными. Вернуть helper и повторить PASS.

Commit:

```bash
rtk git add lib/src/parsing/parser/parser.dart test/sgr_residual_test.dart
rtk git commit -m "fix: insertions restore opaque ambient rendition" \
  -m "Inserted bytes inherit the seam's unknown rendition and may reset or branch from it, while the original suffix still belongs to the parent branch. Carry the residual through seam selection and restore it without changing raw insertion or unfinished-code handling."
```

---

### Task 7: Принтеры replay residual с учётом defaults

**Files:**
- Modify: `lib/src/parsing/parser/printer.dart:110-420`
- Modify: `test/sgr_residual_test.dart`
- Test: `test/printer_keeps_codes_test.dart`
- Test: `test/printer_sink_test.dart`
- Test: `test/printer_no_style_test.dart`
- Test: `test/stack_state_test.dart`

**Interfaces:**
- Consumes: Task 4 residual projection argument and parser initial/final tail.
- Produces: private `_lastResidual` logical carry across lines/writes;
  default-aware root/node replay for four printer classes.
- Preserves: `_writtenLink`, `_ambientLink`, `_owesTerminator`, NoStyle bypass
  and H8 save-slot boundary.

- [ ] **Step 1: добавить красную printer/sink/default матрицу**

В `sgr_residual_test.dart` добавить:

```dart
  group('printers carry opaque rendition:', () {
    test('all four concrete printers preserve and close unknown', () {
      const input = '${_unknown}A';

      expect(Printer().prepare(input), '$reset${_unknown}A$reset');
      expect(StackedPrinter().prepare(input), '$reset${_unknown}A$reset');

      final sink = StringBuffer();
      SinkPrinter(sink).writeln(input);
      expect(sink.toString(), '$reset${_unknown}A$reset\n');

      final stackedSink = StringBuffer();
      StackedSinkPrinter(stackedSink).writeln(input);
      expect(stackedSink.toString(), '$reset${_unknown}A$reset\n');
    });

    test('the next line replays the logical tail after printer reset', () {
      final printer = Printer();

      expect(printer.prepare('${_unknown}A'), '$reset${_unknown}A$reset');
      expect(printer.prepare('B'), '$reset${_unknown}B$reset');
      expect(printer.prepare('${reset}C'), '${reset}C');
      expect(printer.prepare('D'), '${reset}D');
    });

    test('default style is repaired after a known reset in residual', () {
      final printer = StackedPrinter(defaultStyle: Styles.bold);
      final output = printer.prepare('${_unknown}A${resetBoldAndDim}B');

      expect(output, contains('$resetBoldAndDim$bold' 'B'));
      expect(output, endsWith(reset));
    });

    test('NoStyle keeps the original bytes and no private carry', () {
      final printer = Printer(defaultStyle: const NoStyle());
      expect(printer.prepare('${_unknown}A'), '${_unknown}A');
      expect(printer.prepare('B'), 'B');
    });
  });
```

- [ ] **Step 2: увидеть unknown красным во всех четырёх выходах**

Run:

```bash
rtk dart test test/sgr_residual_test.dart \
  test/printer_keeps_codes_test.dart \
  test/printer_sink_test.dart
```

Expected: printer outputs теряют `99`; line 2 не знает logical unknown;
NoStyle negative guard уже зелёный.

- [ ] **Step 3: переносить logical residual, но не emitted residual**

В `_PrinterBase` добавить private `_SgrResidual? _lastResidual`. Parser каждой
непустой строки seed-ится `lastState ?? stateDefaults`, `_ambientLink` и
`_lastResidual`.

Локальный emitted context после обязательного leading `reset` всегда:

```dart
var lastState = stateDefaults.toStyle();
_SgrResidual? writtenResidual;
```

Он не начинается с `_lastResidual`: reset уже очистил терминал. В конце
`_lastResidual = parser.finalResidual`, а `lastState = parser.finalState` как
раньше. Empty-line early returns logical carry не меняют.

- [ ] **Step 4: проецировать residual через `defaultStyle`**

Перед entity сохранить существующий effective target:

```dart
final newState = m.state.changeDefaultsTo(defaultStyle);
Style project(Style state) => state.changeDefaultsTo(defaultStyle);
final transit = _renditionTransit(
  from: lastState,
  fromResidual: writtenResidual,
  to: newState,
  toResidual: m._residual,
  project: project,
);
```

Root base и каждое known node получают defaults. Unknown raw остаётся между
ними. Operation correction повторно устанавливает default только когда raw
known reset снял его. Tail идёт к `stateDefaults.toStyle()` с target residual
null; projection применяется к replay nodes, но не к tail target.

Stateful SGR не копировать. После каждого реально обработанного entity
обновлять `lastState = newState` и `writtenResidual = m._residual`.

- [ ] **Step 5: прогнать printer regression matrix**

Run:

```bash
rtk dart format --output=none --set-exit-if-changed \
  lib/src/parsing/parser/printer.dart \
  test/sgr_residual_test.dart
rtk dart analyze --fatal-infos
rtk dart test test/sgr_residual_test.dart \
  test/printer_keeps_codes_test.dart \
  test/printer_sink_test.dart \
  test/printer_no_style_test.dart \
  test/printer_links_test.dart \
  test/stack_state_test.dart \
  test/osc_termination_test.dart
```

Expected: PASS. Убедиться, что ни один новый тест не ставит `ESC 7` на одной
строке, а `ESC 8` на другой: это H8, не H6.

- [ ] **Step 6: доказать carry- и projection-мутации**

Мутация A: не seed-ить следующую строку `_lastResidual` — line 2 test красный.
Мутация B: передать identity projection — default bold reset test красный.
Вернуть обе правки и повторить PASS.

- [ ] **Step 7: закоммитить printer integration**

```bash
rtk git add lib/src/parsing/parser/printer.dart test/sgr_residual_test.dart
rtk git commit -m "fix: printers replay opaque rendition on every line" \
  -m "Printers reset the terminal at each output boundary but continue parsing from the prior logical state. Carry the residual tail beside lastState and project its known operations through the configured defaults before replaying unknown bytes."
```

---

### Task 8: Публичные entry points и синхронная документация

**Files:**
- Modify: `lib/ansi_escape_codes.dart`
- Modify: `lib/style.dart`
- Modify: `test/exports_test.dart`
- Modify: `test/entry_point_style_test.dart`
- Modify: `README.md`
- Modify: `README.ru.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/architecture.md`

**Interfaces:**
- Consumes: завершённый API и reverse behavior Tasks 1–7.
- Produces: замкнутые entry points, пользовательский контракт и обновлённую
  карту третьего reverse-канала.
- Preserves: одинаковую структуру README EN/RU и неизданную версию 4.0.0.

- [ ] **Step 1: закрепить новые имена через оба public entry points**

В `exports_test.dart` и `entry_point_style_test.dart` добавить compile/use:

```dart
const style = Style(
  fontSelection: FontSelection.alternative1,
  fraktur: true,
  curlyUnderline: true,
  proportionalSpacing: true,
  ideogramStyle: IdeogramStyle.stress,
);

expect(style.fontShape, FontShape.fraktur);
expect(Styles.dashedUnderline.underlineStyle, UnderlineStyle.dashed);
```

`state.dart` уже экспортирует enums; не добавлять отдельный файл-экспорт.
Комментарии `hide IntensityStyle` в двух entry points перестают считать
«четыре пары» и говорят только, почему internal history enum скрыт.

- [ ] **Step 2: дополнить английский README**

В разделе Styles после перечисления одиночных properties добавить:

````markdown
The state model also keeps the standard font selection, italic/fraktur
shape, five underline variants, proportional spacing and five ideogram
renditions. They compose like the existing properties:

```dart
final heading = Styles.alternativeFont1.fraktur.curlyUnderline;
```

Reverse operations preserve an ordinary `CSI ... m` function even when the
package cannot name its effect. Once such a function is active, later SGR
operations are replayed in order through cuts, insertions and printer line
boundaries until `SGR 0` clears the opaque rendition. Private CSI and CSI
with intermediate bytes are copied where they occur but are not treated as
replayable SGR state.
````

Внешний markdown fence для фрагмента при внесении убрать: итог содержит
обычный абзац, один Dart fence и следующий абзац.

- [ ] **Step 3: синхронно дополнить русский README**

В том же месте и с тем же Dart-кодом добавить:

````markdown
Модель состояния также хранит стандартный выбор шрифта, начертание
italic/fraktur, пять вариантов подчёркивания, proportional spacing и пять
ideogram-оформлений. Они соединяются так же, как прежние свойства:

```dart
final heading = Styles.alternativeFont1.fraktur.curlyUnderline;
```

Обратные операции сохраняют обычную функцию `CSI ... m`, даже если пакет не
может назвать её эффект. Пока такая функция активна, последующие SGR
воспроизводятся по порядку через границы срезов, вставок и строк принтера,
пока `SGR 0` не очистит непрозрачное оформление. Private CSI и CSI с
intermediate-байтами копируются на своём месте, но replayable SGR-состоянием
не считаются.
````

- [ ] **Step 4: записать Added/Fixed в CHANGELOG 4.0.0**

В `Added`:

```markdown
- `State`, `Style`, `Stack` and `Styles` now model the standard primary and
  nine alternative fonts, fraktur, curly/dotted/dashed underline,
  proportional spacing and five ideogram renditions. Existing enum case
  names and style APIs remain source-compatible.
```

В `Fixed`:

```markdown
- `optimize`, `substring`, insertions and all printers silently discarded an
  ordinary SGR function that `State` did not model, and collapsed decorated
  underline to a single line. Known standard functions now have typed state;
  truly unknown SGR is carried by a private ordered residual channel through
  cuts, branches and printer resets until a real `SGR 0` clears it.
```

- [ ] **Step 5: добавить третий канал в architecture**

В разделе pipeline рядом со state/link добавить:

```markdown
Третий канал появляется только после обычной SGR-функции, смысл которой
пакет не знает. Persistent residual хранит базовый видимый `Style` и цепь
raw/known операций; каждый `Piece` несёт только tail. Прямой потомок пишет
суффикс, вход в ветвь переигрывает root, выход или расхождение сначала пишет
`SGR 0`. Сам reset обнуляет residual, но не hyperlink.

После unknown известная функция не считается избыточной: unknown мог
изменить то же свойство. `Stack` и printer defaults поэтому пишут raw
операцию, а затем селективно восстанавливают видимый lower frame/default.
Обычный путь держит residual равным null и новых узлов не создаёт.
```

Отдельно назвать overflowed SGR-shaped `CsiUnknown` и исключение private /
intermediate CSI. В printer section сказать, что logical residual переносится
между строками рядом с `lastState`, а emitted line каждый раз начинает после
reset. H8 save-slot не объявлять закрытым.

- [ ] **Step 6: проверить entry points и синхронность, закоммитить docs**

Run:

```bash
rtk dart format --output=none --set-exit-if-changed .
rtk dart analyze --fatal-infos
rtk dart run tool/check_entry_points.dart
rtk dart test test/exports_test.dart test/entry_point_style_test.dart
rtk git diff --check
```

Expected: format clean, analyze без diagnostics, 5 entry points closed, tests
PASS. Вручную сверить порядок sections, Dart code и смысл EN/RU.

Commit:

```bash
rtk git add lib/ansi_escape_codes.dart lib/style.dart \
  test/exports_test.dart test/entry_point_style_test.dart \
  README.md README.ru.md CHANGELOG.md docs/architecture.md
rtk git commit -m "docs: describe typed and residual SGR state" \
  -m "The public model now covers the remaining standard rendition families, while unknown SGR follows a conservative ordered channel through every reverse operation. Document both layers and their exact boundary from private and intermediate CSI in English and Russian."
```

---

### Task 9: Полные ворота и строгое ревью всей ветки

**Files:**
- Review: весь diff `main...fix/preserve-unmodelled-sgr`
- Fix confirmed findings only in files Tasks 1–8; новые находки вне H6 идут
  в `docs/handoff.md`, не в `docs/backlog.md`

**Interfaces:**
- Consumes: все implementation/docs commits Tasks 1–8.
- Produces: чистую ветку, где каждое требование спеки имеет тест и все
  локальные ворота зелёные.

- [ ] **Step 1: проверить generator round-trip до полных ворот**

Run:

```bash
rtk git status --short
rtk dart run tool/generate.dart
rtk git diff --exit-code -- lib/
```

Expected: исходное дерево чистое; generator не меняет `lib/`. Если меняет,
править generator/registry, не generated zone, затем отдельный conventional
fix commit и повторный round-trip.

- [ ] **Step 2: прогнать все локальные ворота**

```bash
rtk dart format --output=none --set-exit-if-changed .
rtk dart analyze --fatal-infos
rtk dart run tool/check_entry_points.dart
rtk dart run tool/generate.dart
rtk git diff --exit-code -- lib/
rtk dart test
rtk dart run benchmark/memory_guard.dart
rtk dart doc --dry-run
rtk dart pub publish --dry-run
```

Expected: format clean; analyze 0 diagnostics; 5 entry points closed;
generator clean; полный suite PASS; memory guard внутри актуальной полосы
`159…332` байта на match из `docs/handoff.md`; dartdoc 0 warnings/errors;
publish dry-run 0 warnings.

- [ ] **Step 3: провести строгое ревью `main...HEAD`**

Проверить каждый пункт:

- enum `.name`, `.values` и индексы не изменились;
- все новые public signature types доступны из нужных entry points;
- known standard SGR не открывает residual;
- null fast path не создаёт journal node или накопленную строку;
- unknown → redundant known сохраняет known raw operation;
- only standalone parsed `0` prunes; zero inside colour/subparams и overflow
  не ошибочно сбрасывают journal;
- ancestry использует identity/depth, не глубокое сравнение и не копирование;
- Stack correction и printer projection никогда не пишут synthetic full reset
  внутри active branch;
- overflow emitted однажды, а private/intermediate CSI не replay;
- `substring` сохранил held-opening/link order и H5;
- insertion парсится один раз и сохранила H2/H4;
- printer переносит residual, но не H8 save-slot;
- README EN/RU синхронны;
- тесты мутаций действительно были красными.

Любое подтверждённое замечание сначала закрепить красным тестом, исправить,
повторить затронутые и полные ворота и закоммитить отдельным conventional
commit с английским why-body.

- [ ] **Step 4: проверить чистоту и состав ветки**

Run:

```bash
rtk git status --short --branch
rtk git diff --check main...HEAD
rtk git log --oneline --decorate main..HEAD
```

Expected: рабочее дерево чистое; diff-check пуст; ветка содержит spec,
scope-correction, plan, восемь deliverable commits и только подтверждённые
review fixes сверх них.

---

### Task 10: CI, merge и новый handoff

**Files:**
- Archive: текущий `docs/handoff.md` в следующий свободный
  `docs/records/2026-08-14[6]-pre-h6-handoff.md`
- Rewrite: `docs/handoff.md`

**Interfaces:**
- Consumes: зелёную и отревьюированную feature branch Task 9.
- Produces: зелёный `main`, фактическую запись результатов H6 и отсутствие
  отработавшей ветки.

- [ ] **Step 1: запушить feature branch и дождаться обеих ног CI**

```bash
rtk git push -u origin fix/preserve-unmodelled-sgr
rtk gh run list --branch fix/preserve-unmodelled-sgr --limit 5
```

Выбрать run на текущем HEAD и дождаться SDK `3.6.0` и `stable`. Красный CI
разобрать по job logs, закрепить локально тестом, исправить отдельным commit,
повторить полные ворота и push. До двух зелёных ног не сливать.

- [ ] **Step 2: слить обычным merge-коммитом и проверить main CI**

```bash
rtk git switch main
rtk git merge --no-ff fix/preserve-unmodelled-sgr \
  -m "merge: preserve typed and opaque SGR state"
rtk git push origin main
rtk gh run list --branch main --limit 5
```

Дождаться зелёного run merge-коммита на обеих ногах.

- [ ] **Step 3: архивировать прежний handoff и переписать текущий**

На текущую дату следующий свободный номер — `[6]`. Если исполнение перейдёт
на другую дату, использовать первый свободный номер того дня; при исполнении
2026-08-14 создать именно `2026-08-14[6]-pre-h6-handoff.md`. Архивная запись
сохраняет старую prose и получает header: handoff до H6, закрыт
merge-коммитом. Новый `docs/handoff.md` записывает фактические:

- хэши восьми deliverable/review commits и merge;
- branch/main CI run ids и обе SDK legs;
- восемь локальных ворот, новое число тестов, memory number/band;
- H6 в закрытых High с коротким описанием typed/residual split;
- H7 и H8 по-прежнему открыты и требуют отдельных owner decisions;
- public API additions и отсутствие удалённых enum names;
- null fast path и неизбежный рост journal без reset;
- отсутствие version bump, tag и publish;
- следующую работу выбрать между H7 и H8 только после разговора с владельцем.

Commit:

```bash
rtk git add docs/handoff.md \
  'docs/records/2026-08-14[6]-pre-h6-handoff.md'
rtk git commit -m "docs: hand off the package after residual SGR support" \
  -m "H6 is merged and verified on both supported SDK legs, so the live handoff records the new typed and opaque rendition channels and leaves the two unresolved semantic findings for separate owner decisions."
rtk git push origin main
```

Дождаться зелёного CI документационного commit на `main`.

- [ ] **Step 4: удалить отработавшую ветку и проверить финал**

После зелёного CI main:

```bash
rtk git branch -d fix/preserve-unmodelled-sgr
rtk git push origin --delete fix/preserve-unmodelled-sgr
rtk git status --short --branch
rtk git log -5 --oneline --decorate
```

Expected: `main...origin/main`, дерево чистое, feature branch отсутствует
локально и на remote, H6 закрыта в handoff. Тег и публикацию не выполнять.
