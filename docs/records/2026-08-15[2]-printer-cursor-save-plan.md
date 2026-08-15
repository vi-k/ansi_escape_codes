# План: межстрочный cursor save-slot в принтерах

> **Состояние на 2026-08-16:** исполнен целиком, работа влита в `main` мержем
> `2db4abd` (`6185964`, `69333e8`). Результаты тестов, ворот и CI в тексте —
> ожидаемые на момент написания, а не факт прогонов; фактические записаны в
> `2026-08-15[3]` и в `docs/handoff.md`.
> **Что это:** план H8 по спеке `2026-08-15[1]` — перенос save-slot `ESC 7` /
> `ESC 8` через строки и writes во всех принтерах.
> **Связанные записи:** `2026-08-15[1]-printer-cursor-save-design.md`,
> `2026-08-15[3]-pre-h8-handoff.md`,
> `2026-08-15[5]-pre-verification-guards-handoff.md`.

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** `Printer`, `StackedPrinter`, `SinkPrinter` и `StackedSinkPrinter`
переносят единичный save-slot `ESC 7` / `ESC 8` через строки и writes, не меняя
цельнострочный контракт `Parser`/`StackedParser` и публичный API.

**Architecture:** приватный generic record `_CursorSave<S>` проходит через
`_ParserBase` → `Pieces` → `_ParserIterator` → `_PiecesResult`. Принтер хранит
итоговый nullable-slot рядом с state/link/residual, а отсутствие save отделено
от restore-fallback: у обычного парсера fallback равен его seed, у принтера —
terminal defaults без link и residual.

**Tech Stack:** Dart `^3.6.0`, records и generics, `package:test`, существующие
`Parser`/`StackedParser`, четыре printer surface, локальные ворота и GitHub
Actions на SDK `3.6.0` и `stable`.

## Global Constraints

- Выполнять в изолированной ветке `fix/printer-cursor-save`, созданной через
  `superpowers:using-git-worktrees` от `main` после коммита этого плана.
- До первой правки `lib/` прочитать `docs/architecture.md`; код, тесты и git
  старше документов при расхождении.
- Ожидания новых тестов брать из принятой спеки и уже снятых пробников. Если
  красный прогон отличается, объяснить расхождение по живому pipeline, а не
  подгонять тест под реализацию.
- Использовать TDD: сначала увидеть новые cross-boundary ожидания красными,
  затем внести минимальный private carry. После зелени выполнить все пять
  точных обратных мутаций из Task 1 и восстановить рабочий код.
- Публичные имена, сигнатуры, constructors, entry points и exports не менять.
  Новый record, параметры и getters остаются private внутри library.
- Цельнострочные `Parser`/`StackedParser`, lazy pause, cache replay, cursor
  coordinates, raw-положение `ESC 7`/`ESC 8`, substring/insert seam, H7 reset-
  границу и residual-модель H6 не менять.
- Slot единичный и nullable: `null` значит «save не было»; сохранённые
  `link: null` и `residual: null` — настоящий снимок, не fallback.
- `ESC 8` не потребляет slot; `ESC 7` полностью перезаписывает его. `SGR 0`,
  selective reset, hyperlink close, output-boundary resets и пустые куски slot
  не очищают.
- `NoStyle` оставляет байты как есть без private carry;
  `ansiCodesEnabled: false` удаляет cursor-коды и также не меняет carry.
- `SinkPrinter.prepare()` и `StackedSinkPrinter.prepare()` откатывают slot
  вместе с пятью уже откатываемыми carry-полями.
- `README.md` — источник, `README.ru.md` — синхронный перевод в том же коммите
  с той же структурой, порядком разделов и кодом примеров.
- Не править generated-зоны `BEGIN`/`END`, `docs/backlog.md`, версию `4.0.0`;
  не создавать тег и не публиковать пакет.
- Код, dartdoc, README, CHANGELOG и сообщения коммитов — по-английски;
  записи в `docs/` — по-русски.
- Один смысловой фикс — один коммит; публичная документация — отдельный
  коммит. До merge ветку запушить и дождаться зелёного CI обеих ног.

---

### Task 1: Приватный save-slot, красные контракты и реализация carry

**Files:**
- Create: `test/printer_cursor_save_test.dart`
- Modify: `test/link_continuity_fuzz_test.dart:475-522`
- Modify: `lib/src/parsing/parser/parser.dart:118-195,900-907`
- Modify: `lib/src/parsing/parser/pieces/pieces.dart:8-62`
- Modify: `lib/src/parsing/parser/pieces/parser_iterator.dart:3-236`
- Modify: `lib/src/parsing/parser/pieces/pieces_result.dart:3-32`
- Modify: `lib/src/parsing/parser/printer.dart:113-455,524-589`

**Interfaces:**
- Consumes: existing private `State<S>`, `Link`, `_SgrResidual`, lazy `Pieces`
  cache and `_PrinterBase` carry; public `saveCursor`/`restoreCursor` bytes.
- Produces: private
  `typedef _CursorSave<S extends State<S>> = ({S state, Link? link, _SgrResidual? residual});`,
  `_ParserBase._finalCursorSave` and session field
  `_PrinterBase._savedCursor`; no public interface.
- Preserves: ordinary parser fallback to its own initial state/link/residual,
  raw entity bytes, cache replay, four printer surfaces and sink rollback.

- [ ] **Step 1: записать общие test helpers и cross-boundary contracts**

Создать `test/printer_cursor_save_test.dart`. В начале файла определить
четыре независимых surface renderer; sink-варианты обязаны пересекать именно
границы отдельных `writeln`, а не только newline внутри одного `write`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

typedef _Render = String Function(List<String> chunks);

Map<String, _Render> surfaces() => {
      'Printer': (chunks) {
        final printer = Printer();
        return chunks.map(printer.prepare).join('\n');
      },
      'StackedPrinter': (chunks) {
        final printer = StackedPrinter();
        return chunks.map(printer.prepare).join('\n');
      },
      'SinkPrinter': (chunks) {
        final sink = StringBuffer();
        final printer = SinkPrinter(sink);
        for (final chunk in chunks) {
          printer.writeln(chunk);
        }
        return sink.toString();
      },
      'StackedSinkPrinter': (chunks) {
        final sink = StringBuffer();
        final printer = StackedSinkPrinter(sink);
        for (final chunk in chunks) {
          printer.writeln(chunk);
        }
        return sink.toString();
      },
    };

Style styleAt(String output, String marker) {
  final parser = Parser(output);
  return parser.stateAt(parser.indexOf(marker));
}

Link? linkAt(String output, String marker) {
  final parser = Parser(output);
  return parser.linkAt(parser.indexOf(marker));
}
```

В `main()` добавить общий контракт. Маркеры уникальны, а проверка включает и
restore-кусок, и следующий кусок, чтобы raw `ESC 8` не скрывал рассинхронизацию
внутреннего state:

```dart
group('the cursor save slot crosses printer boundaries:', () {
  for (final MapEntry(key: name, value: render) in surfaces().entries) {
    test('$name restores a save and carries it onward', () {
      final output = render([
        '$fgRed$saveCursor$fgBlue A',
        '${restoreCursor}B',
        'C',
      ]);

      expect(styleAt(output, 'B').foregroundColor, Color16.red);
      expect(styleAt(output, 'C').foregroundColor, Color16.red);
      expect(output, contains(saveCursor));
      expect(output, contains(restoreCursor));
    });

    test('$name uses terminal defaults before the first save', () {
      final output = render([
        '${fgRed}A',
        '${restoreCursor}B',
        'C',
      ]);

      expect(styleAt(output, 'B'), Style.terminalColors);
      expect(styleAt(output, 'C'), Style.terminalColors);
    });
  }
});
```

- [ ] **Step 2: записать overwrite, repeated restore и полный Stack**

В тот же файл добавить три самостоятельных теста:

```dart
group('the save slot is one reusable record:', () {
  test('restore does not consume it', () {
    final printer = Printer();
    final output = [
      printer.prepare('$fgRed$saveCursor$fgBlue A'),
      printer.prepare(''),
      printer.prepare('${restoreCursor}B'),
      printer.prepare('$fgGreen${restoreCursor}C'),
      printer.prepare('D'),
    ].join('\n');

    for (final marker in ['B', 'C', 'D']) {
      expect(styleAt(output, marker).foregroundColor, Color16.red);
    }
  });

  test('a later save replaces the earlier one', () {
    final printer = Printer();
    final output = [
      printer.prepare(
        '$fgRed$saveCursor$fgGreen$saveCursor$fgBlue A',
      ),
      printer.prepare('${restoreCursor}B'),
      printer.prepare('C'),
    ].join('\n');

    expect(styleAt(output, 'B').foregroundColor, Color16.green);
    expect(styleAt(output, 'C').foregroundColor, Color16.green);
  });

  test('a stacked save keeps the full foreground history', () {
    final printer = StackedPrinter();
    final output = [
      printer.prepare('$fgRed$fgGreen$saveCursor$fgBlue A'),
      printer.prepare('$restoreCursor$resetFg' 'B'),
      printer.prepare('C'),
    ].join('\n');

    expect(styleAt(output, 'B').foregroundColor, Color16.red);
    expect(styleAt(output, 'C').foregroundColor, Color16.red);
  });
});
```

Последний тест обязан упасть, если snapshot сузить до `Style`: после restore
stacked selective reset должен открыть сохранённый lower frame red.

- [ ] **Step 3: записать link, residual, sink rollback и bypass**

В тот же файл добавить channel- и lifecycle-проверки. Для opaque residual
положение байтов exact — это значения уже снятого пробника:

```dart
group('the cursor slot carries every private channel:', () {
  test('a saved link returns across a boundary and stays carried', () {
    final printer = Printer();
    final output = [
      printer.prepare(
        '${linkOpen}http://u/$linkTextOpen'
        '${saveCursor}A$linkClose',
      ),
      printer.prepare('${restoreCursor}B'),
      printer.prepare('C'),
    ].join('\n');

    expect(linkAt(output, 'B')?.url, 'http://u/');
    expect(linkAt(output, 'C')?.url, 'http://u/');
  });

  test('a saved null link wins over a seeded ambient link', () {
    final printer = Printer();
    final output = [
      printer.prepare(
        '$saveCursor${linkOpen}http://u/$linkTextOpen' 'A',
      ),
      printer.prepare('B'),
      printer.prepare('${restoreCursor}C'),
      printer.prepare('D'),
    ].join('\n');

    expect(linkAt(output, 'B')?.url, 'http://u/');
    expect(linkAt(output, 'C'), isNull);
    expect(linkAt(output, 'D'), isNull);
  });

  test('opaque SGR is restored and replayed after the next boundary', () {
    const unknown = '\x1B[99m';
    final printer = Printer();

    expect(
      printer.prepare('$unknown$saveCursor$reset'),
      '$reset$unknown$saveCursor$reset',
    );
    expect(
      printer.prepare('${restoreCursor}B'),
      '$reset$unknown${restoreCursor}B$reset',
    );
    expect(printer.prepare('C'), '$reset$unknown' 'C$reset');
  });
});

group('sink probing and bypasses do not create cursor carry:', () {
  test('SinkPrinter rolls prepare back', () {
    final sink = StringBuffer();
    final printer = SinkPrinter(sink)
      ..write('$fgRed$saveCursor')
      ..prepare('$fgGreen$saveCursor')
      ..write('$fgBlue${restoreCursor}B')
      ..writeln();

    expect(styleAt(sink.toString(), 'B').foregroundColor, Color16.red);
    expect(printer.lastState?.foregroundColor, Color16.red);
  });

  test('StackedSinkPrinter rolls prepare back', () {
    final sink = StringBuffer();
    final printer = StackedSinkPrinter(sink)
      ..write('$fgRed$saveCursor')
      ..prepare('$fgGreen$saveCursor')
      ..write('$fgBlue${restoreCursor}B')
      ..writeln();

    expect(styleAt(sink.toString(), 'B').foregroundColor, Color16.red);
    expect(printer.lastState?.foregroundColor, Color16.red);
  });

  test('writeAll, write and writeCharCode share the sink slot', () {
    final sink = StringBuffer();
    SinkPrinter(sink)
      ..writeAll(['$fgRed$saveCursor', '$fgBlue' 'A'])
      ..write(restoreCursor)
      ..writeCharCode(0x42)
      ..writeln();

    expect(styleAt(sink.toString(), 'B').foregroundColor, Color16.red);
  });

  test('NoStyle leaves both cursor bytes untouched', () {
    final printer = Printer(defaultStyle: const NoStyle());

    expect(printer.prepare('$saveCursor A'), '$saveCursor A');
    expect(printer.prepare('${restoreCursor}B'), '${restoreCursor}B');
  });

  test('disabled ANSI removes both cursor bytes', () {
    final printer = Printer(ansiCodesEnabled: false);

    expect(printer.prepare('$saveCursor A'), ' A');
    expect(printer.prepare('${restoreCursor}B'), 'B');
  });
});
```

- [ ] **Step 4: развернуть два accepted-limit теста в регрессии**

В `test/link_continuity_fuzz_test.dart` переименовать group в:

```dart
group('a restore reaching across a line break keeps the printer in sync:',
    () {
```

В первом тесте оставить цельнострочную проверку и заменить ожидание printed
document на terminal defaults:

```dart
expect(
  Parser(lines.join('\n')).stateAt(4),
  Parser('C').stateAt(0),
  reason: 'with no save the restore fallback is the terminal default, not '
      'the state seeded from the line before it',
);
```

Во втором заменить printed-link ожидание на:

```dart
expect(
  Parser(lines.join('\n')).linkAt(2),
  isNull,
  reason: 'with no save the restore fallback has no link, even when the '
      'line was seeded inside the link carried from the line before it',
);
```

- [ ] **Step 5: увидеть новый контракт красным**

Run:

```bash
rtk dart format test/printer_cursor_save_test.dart \
  test/link_continuity_fuzz_test.dart
rtk dart test test/printer_cursor_save_test.dart \
  test/link_continuity_fuzz_test.dart --reporter expanded
```

Expected на `main @ 3787952`: cross-save state возвращает blue вместо red;
no-save state остаётся red вместо terminal defaults; repeated restore и
overwrite теряют прошлый slot; link после cross-boundary restore отсутствует,
а no-save поднимает ambient link; opaque `[99]` не переигрывается; пробный sink
`prepare` может подменить будущий slot после добавления carry без rollback.
Bypass-тесты уже PASS. Красные ожидания объяснить этими симптомами до правки
реализации; точные probes из handoff не менять.

- [ ] **Step 6: ввести единый private record и развести три входа parser**

После `_Seam` в `parser.dart` добавить:

```dart
typedef _CursorSave<S extends State<S>> = ({
  S state,
  Link? link,
  _SgrResidual? residual,
});
```

В `_ParserBase` добавить `_initialCursorSave` и `_restoreFallback`. Constructor
при отсутствии явного fallback сохраняет прежний parser-контракт:

```dart
final _CursorSave<S>? _initialCursorSave;
final _CursorSave<S> _restoreFallback;

_ParserBase(
  this.input,
  this.initialState, {
  this.initialLink,
  _SgrResidual? initialResidual,
  _CursorSave<S>? initialCursorSave,
  _CursorSave<S>? restoreFallback,
})  : _initialResidual = initialResidual,
      _initialCursorSave = initialCursorSave,
      _restoreFallback = restoreFallback ??
          (
            state: initialState,
            link: initialLink,
            residual: initialResidual,
          );
```

В getter `pieces` передать оба значения. Добавить private getter:

```dart
_CursorSave<S>? get _finalCursorSave =>
    pieces._requireParsingResult.finalCursorSave;
```

Прямой `Pieces<S>._` внутри `_insert` получает explicit fallback из seam:

```dart
restoreFallback: (
  state: seam.state,
  link: seam.link,
  residual: seam.residual,
),
```

Initial cursor save для вставки не задавать: это отдельный цельнострочный
разбор, а его прежний restore-fallback равен seam seed.

- [ ] **Step 7: провести slot через Pieces, iterator и final result**

В `Pieces` хранить `_initialCursorSave` и `_restoreFallback`, принимать их в
private constructor и передавать в `_ParserIterator._` после initial residual.

В `_ParserIterator` заменить inline-record `_saved` на
`_CursorSave<S>? _saved`, добавить final `_restoreFallback` и инициализировать
slot принесённым значением:

```dart
_ParserIterator._(
  this._parent,
  this._initialState,
  this._initialLink,
  this._initialResidual,
  _CursorSave<S>? initialCursorSave,
  this._restoreFallback,
) : _saved = initialCursorSave;
```

Replay `SaveCursor` и настоящий `SaveCursor` продолжают присваивать весь
record. `RestoreCursor` не очищает `_saved`; он выбирает один record и
применяет все три поля:

```dart
final saved = _saved ?? _restoreFallback;
matchingState
  ..state = saved.state
  ..residual = saved.residual;
link = saved.link;
```

При завершении iterator передать `finalCursorSave: _saved` в `_PiecesResult`.
В `_PiecesResult` добавить required nullable field и вывести его в `toString`:

```dart
final _CursorSave<S>? finalCursorSave;
```

Не превращать fallback в final slot: если save не было, `_saved` остаётся
`null`. Cache replay уже повторно видит `SaveCursor` и поэтому восстанавливает
тот же итоговый slot без второго обхода входа.

- [ ] **Step 8: сохранить slot в общем printer base и откатить sink probe**

В `_PrinterBase` рядом с `_lastResidual` добавить:

```dart
/// The state, link and opaque rendition saved by the latest `ESC 7` in this
/// printer session, or `null` before the first save.
_CursorSave<S>? _savedCursor;
```

При создании `_ParserBase` в `_prepare` передать:

```dart
initialCursorSave: _savedCursor,
restoreFallback: (
  state: stateDefaults,
  link: null,
  residual: null,
),
```

После полного обхода, рядом с assignments `lastState`, `_lastResidual` и
`_ambientLink`, сохранить:

```dart
_savedCursor = parser._finalCursorSave;
```

В `_SinkPrinterBase.prepare` снять `keepSavedCursor` до `super.prepare` и
восстановить `_savedCursor` вместе с остальными полями. Early returns для
disabled ANSI, `NoStyle` и пустого куска оставить перед parser construction:
так они не создают и не меняют slot.

- [ ] **Step 9: прогнать целевой набор и parser cache guards**

Run:

```bash
rtk dart format --output=none --set-exit-if-changed \
  lib/src/parsing/parser test/printer_cursor_save_test.dart \
  test/link_continuity_fuzz_test.dart
rtk dart analyze --fatal-infos
rtk dart test test/printer_cursor_save_test.dart \
  test/link_continuity_fuzz_test.dart test/parser_esc_test.dart \
  test/link_channel_test.dart test/sgr_residual_test.dart --reporter expanded
```

Expected: format и analyze чисты; все перечисленные тесты PASS. Existing
`parser_esc_test.dart` держит цельнострочный no-save fallback и lazy pause,
`link_channel_test.dart` — saved-null и cache replay, `sgr_residual_test.dart`
— прежнюю residual-модель.

- [ ] **Step 10: доказать контракт пятью обратными мутациями**

Каждую мутацию вносить отдельно через `apply_patch`, запускать названный
минимальный тест, фиксировать ожидаемую красноту, затем полностью
восстанавливать рабочую реализацию и получать PASS перед следующей:

1. Не передать `initialCursorSave` из printer в `_ParserBase` — cross-save
   state/link/residual тесты FAIL.
2. Убрать printer `restoreFallback` и снова использовать initial seed — оба
   no-save теста и перевёрнутые fuzz-регрессии FAIL.
3. Не восстанавливать `_savedCursor` в sink `prepare()` — оба rollback-теста
   FAIL (probe подменяет red-save на green-save).
4. После `RestoreCursor` присвоить `_saved = null` — repeated restore FAIL.
5. В `SaveCursor` временно сохранять `link: null`, затем отдельно
   `residual: null` — соответствующие channel tests FAIL.

После пятой мутации повторить команду Step 9 и `rtk git diff --check`.

- [ ] **Step 11: закоммитить смысловой фикс**

Run:

```bash
rtk git add lib/src/parsing/parser/parser.dart \
  lib/src/parsing/parser/pieces/pieces.dart \
  lib/src/parsing/parser/pieces/parser_iterator.dart \
  lib/src/parsing/parser/pieces/pieces_result.dart \
  lib/src/parsing/parser/printer.dart \
  test/printer_cursor_save_test.dart test/link_continuity_fuzz_test.dart
rtk git commit -m "fix: carry cursor saves across printer boundaries" \
  -m "Each printed line or sink write created a fresh parser, losing the state, hyperlink, and opaque SGR saved by ESC 7. Thread one private save record through the parser result and printer session while keeping a missing save distinct from the next chunk's seeded state."
```

---

### Task 2: Публичный контракт session-wide slot

**Files:**
- Modify: `lib/src/parsing/parser/printer.dart:3-111,207-270,524-575`
- Modify: `README.md:432-557`
- Modify: `README.ru.md:432-553`
- Modify: `CHANGELOG.md:124-145`
- Modify: `docs/architecture.md:1-136`

**Interfaces:**
- Consumes: private session slot из Task 1 и прежние public signatures всех
  четырёх принтеров.
- Produces: согласованный English dartdoc/README/CHANGELOG, синхронный русский
  README и обновлённая карта architecture; code examples не меняются.
- Preserves: accepted `prepare` hyperlink placement limitation и различие
  terminal/stacked reset semantics.

- [ ] **Step 1: документировать четыре поверхности и prepare lifecycle**

В class dartdoc `Printer` после абзаца о hyperlink добавить:

```dart
/// `ESC 7` and `ESC 8` use one save slot for the lifetime of the printer. The
/// saved rendition, hyperlink and opaque SGR state cross line boundaries;
/// another `ESC 7` replaces them, while `ESC 8` restores without consuming.
```

В `StackedPrinter` добавить тот же абзац, заменив `rendition` на
`stacked rendition`. В `SinkPrinter` и `StackedSinkPrinter` написать `cross
write and line boundaries` вместо `cross line boundaries`.

В dartdoc `_PrinterBase.prepare` перед абзацем о sink prepare добавить:

```dart
/// Cursor saves belong to the printer session rather than one parse. A save
/// made on an earlier line is available to a restore here; before the first
/// save, a restore returns to the terminal defaults rather than to the state
/// inherited from the previous line.
```

В override dartdoc `_SinkPrinterBase.prepare` явно добавить, что пробный вызов
откатывает cursor slot вместе с rendition/link/terminator carry.

- [ ] **Step 2: дополнить English README и синхронный перевод**

После первого объясняющего абзаца под `### Printer` добавить в `README.md`:

```markdown
A printer also treats `ESC 7` / `ESC 8` as one session-wide cursor save slot.
The saved rendition, hyperlink and opaque SGR state survive line boundaries
(and write boundaries for a sink printer); another save replaces the slot, and
a restore does not consume it. Before the first save, restore returns to the
terminal defaults rather than to the state carried from the previous line.
```

В том же месте `README.ru.md` добавить перевод:

```markdown
Кроме того, принтер считает `ESC 7` / `ESC 8` одним save-slot курсора на всю
сессию. Сохранённые rendition, hyperlink и opaque SGR переживают границы строк
(а у sink-принтера — и границы write); следующий save заменяет slot, restore
его не потребляет. До первого save restore возвращает терминальные значения по
умолчанию, а не состояние, перенесённое с предыдущей строки.
```

Не добавлять новый пример и не менять существующий код: структура и порядок
README остаются одинаковыми.

- [ ] **Step 3: записать H8 в CHANGELOG и architecture**

В начале `Fixed:` CHANGELOG, перед H7, добавить:

```markdown
- `ESC 7` / `ESC 8` lost their saved rendition, hyperlink and opaque SGR at
  every printer line or sink-write boundary, and a restore with no preceding
  save incorrectly used the previous chunk's seeded state. All four printers
  now keep one non-consuming, replaceable cursor save slot for their session;
  sink `prepare` rolls a probed slot back with its other carry.
```

В `docs/architecture.md` оставить дату `2026-08-15`, заменить исторический
абзац после residual carry на структурное описание:

```markdown
Cursor save-slot идёт четвёртым carry-каналом. Приватный `_CursorSave<S>`
проходит через `_ParserBase` → `Pieces` → `_ParserIterator` → `_PiecesResult`;
`_PrinterBase` передаёт итоговый nullable-slot следующему разбору. Initial
state/link/residual текущего куска отделены от restore-fallback: обычный parser
возвращается к своему seed, printer без предшествующего save — к terminal
defaults без link и residual. Sink `prepare` откатывает slot вместе с прочими
carry-полями.
```

- [ ] **Step 4: проверить документацию и синхронность README**

Run:

```bash
rtk dart format --output=none --set-exit-if-changed lib/
rtk dart analyze --fatal-infos
rtk dart doc --dry-run
rtk dart run tool/check_entry_points.dart
rtk git diff --check
```

Expected: format clean, analyze без diagnostics, dartdoc 0 warnings/errors,
все 5 entry points замкнуты, diff check clean. Отдельно сравнить headings и
все fenced code blocks обоих README; они должны иметь одинаковый порядок и
байт-в-байт одинаковый Dart-код.

- [ ] **Step 5: закоммитить публичную документацию**

Run:

```bash
rtk git add lib/src/parsing/parser/printer.dart README.md README.ru.md \
  CHANGELOG.md docs/architecture.md
rtk git commit -m "docs: describe printer cursor save continuity" \
  -m "The four printer surfaces now preserve one cursor save across their parsing boundaries. Document its replaceable, non-consuming lifetime, terminal fallback, and sink prepare rollback in both public languages and the internal architecture map."
```

---

## Final verification and integration

После task-review обоих коммитов выполнить whole-branch review от merge-base
с `main`. Все Critical/Important findings исправляет один отдельный сабагент,
после чего один scoped re-review проверяет только fix wave.

На чистом feature HEAD последовательно выполнить все ворота:

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

Expected: format clean; analyze без diagnostics; 5 entry points; generator не
меняет `lib/`; весь test corpus PASS; memory guard внутри актуальной полосы из
handoff; dartdoc 0 warnings/errors; publish dry-run 0 warnings.

Затем:

1. `rtk git push -u origin fix/printer-cursor-save`.
2. Дождаться зелёного GitHub Actions для feature HEAD на SDK `3.6.0` и
   `stable`; записать run/job ids.
3. Только после зелёного CI выполнить `rtk git merge --no-ff
   fix/printer-cursor-save` в `main` и `rtk git push origin main`.
4. Дождаться зелёного CI merge-коммита.
5. Архивировать старый handoff отдельной записью следующего свободного номера,
   переписать `docs/handoff.md` фактическими commit/run/gate results и добавить
   только новые находки в «Найдено волнами»; `docs/backlog.md` не менять.
6. Закоммитить и запушить финальный handoff. Версию, тег и публикацию не
   трогать.
