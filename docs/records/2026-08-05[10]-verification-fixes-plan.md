# План: фиксы по итогам верификации ревью

> **Состояние документа**
>
> - **Тип:** план, 2026-08-05; закрывает находки отчёта `2026-08-05[9]`
> - **Статус:** выполнен, влит в `main` мержем `56c8244`
> - **Осторожно:** волна оставила долг: `_SinkPrinterBase.prepare` возвращает
>   на место обе ссылочные переменные, но `lastState` оставляет сдвинутым.
>   Пункт до сих пор открыт — `docs/backlog.md`
> - **Пути:** ссылки в тексте старые — записи с тех пор лежат в
>   `docs/records/`, `TODO.md` стал `docs/backlog.md`, текущий handoff —
>   `docs/handoff.md`

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Закрыть находки отчёта верификации `docs/2026-08-05[9]-review-verification-report.md`: регрессию памяти M5, дыру L7-класса в `extensions.dart`, лишний `namedGroup` (M7-минимум), незащищённое выключение режимов в `currentCursorPos`, незакрываемую ссылку в `Printer`; запиннить риски M6; хвосты — в бэклог.

**Architecture:** Семь независимых задач-коммитов на ветке `fix/verification-follow-up`; каждая — red-тест (где применимо) + фикс + CHANGELOG одним коммитом. Финальное whole-branch-ревью, затем локальный `merge --no-ff` в main, без PR. Публикации 4.0.0 и тега НЕТ (решение пользователя 2026-08-05).

**Tech Stack:** Dart 3.6+ (пакет ansi_escape_codes), `dart test`, строжайший линт-сет (`--fatal-infos`).

## Global Constraints

- Версию в pubspec НЕ бампать (остаётся 4.0.0, не опубликована).
- Один фикс — один коммит; conventional-префикс; повествовательный стиль сообщений, как в `git log` (`fix: the terminal modes come back in the order Windows allows`).
- Каждый коммит заканчивать трейлером `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.
- После каждой задачи: `dart format --output=none --set-exit-if-changed .`, `dart analyze --fatal-infos`, `dart test` — всё зелёное.
- CHANGELOG: правки только внутри секции 4.0.0 (релиз не выпущен).
- Комментарии и dartdoc — на английском, в стиле окружающего кода (полные предложения, «почему», не «что»).

---

### Task 1: Откат регрессии памяти M5 — SGR-списки снова копии

**Files:**
- Modify: `lib/src/parsing/parser/entities/sgr.dart:19-28`
- Modify: `CHANGELOG.md` (~строки 56-58, абзац «wrapped once rather than copied twice»)

**Контекст:** Верификация (отчёт [9], разбор M5): `UnmodifiableListView` поверх growable-списка удерживает builder-список вместе с запасом ёмкости backing-массива — +303 МБ на плотных 10 МБ, удержание выросло ~66×→~96× входа. Прямое доказательство: откат ровно этих двух строк возвращает 966 → 634 МБ. По времени откат бесплатен на больших входах. Красный тест непрактичен (удержание кучи не пинится юнит-тестом); основание — измерения верификации.

- [ ] **Step 1: Заменить инициализаторы и комментарий**

В `lib/src/parsing/parser/entities/sgr.dart` заменить строки 19-28:

```dart
  // Compact copies, not views: a view would keep the growable builder
  // lists alive — with the slack capacity of their backing arrays — for
  // as long as the Sgr lives, and parsed entities live long.
  Sgr._(
    super.string,
    List<CsiParam> params,
    List<SgrFunction> functions,
  )   : params = List.unmodifiable(params),
        functions = List.unmodifiable(functions),
        super._();
```

Проверить объявления полей `params`/`functions` этого класса: если их тип — `UnmodifiableListView<...>`, сменить на `List<...>`. Проверить, останется ли `import 'dart:collection'` (или экспортирующий его импорт) нужным в файле (`grep UnmodifiableListView` по файлу); неиспользуемый импорт убрать — иначе `--fatal-infos` красный.

- [ ] **Step 2: Поправить CHANGELOG**

В абзаце перф-секции 4.0.0 (~56-58) фраза «and the SGR lists handed back to callers are wrapped once rather than copied twice» подаёт замену как экономию — по измерениям это ~2× рост удерживаемой памяти на список. Заменить фразу на: «and the SGR lists handed back to callers are single compact copies that let the growable builders behind them go». Остальное предложение не трогать.

- [ ] **Step 3: Ворота**

Run: `dart format --output=none --set-exit-if-changed . && dart analyze --fatal-infos && dart test`
Expected: всё зелёное (366 тестов; поведение неотличимо — оба варианта дают неизменяемый список).

- [ ] **Step 4: Commit**

```bash
git add lib/src/parsing/parser/entities/sgr.dart CHANGELOG.md
git commit -m "fix: the SGR lists are copies again — a view held the builder alive"
```

---

### Task 2: `extensions.dart` может назвать собственный параметр

**Files:**
- Modify: `lib/extensions.dart` (5 строк экспортов)
- Test: `test/entry_point_extensions_test.dart`
- Modify: `CHANGELOG.md` (~строки 175-180, буллет про entry points)

**Контекст:** Отчёт [9], разбор L7: публичная сигнатура `ansiRemoveControlCodes({Set<ControlFunctionsC0> exclude})` (`lib/src/extensions/remove.dart:51`) видна из точки `extensions.dart`, но enum `ControlFunctionsC0` из неё не экспортирован — пользователь получает undefined_identifier. Файл enum: `lib/src/parsing/control_functions/control_functions_c0.dart`.

- [ ] **Step 1: Красный тест**

В `test/entry_point_extensions_test.dart` (импортирует только `package:ansi_escape_codes/extensions.dart`) добавить в существующий тест (или рядом, в стиле файла):

```dart
    expect(
      'a\nb'.ansiRemoveControlCodes(exclude: {ControlFunctionsC0.LF}),
      'a\nb',
    );
```

- [ ] **Step 2: Убедиться, что красный**

Run: `dart analyze test/entry_point_extensions_test.dart`
Expected: FAIL — undefined_identifier `ControlFunctionsC0`.

- [ ] **Step 3: Экспорт**

В `lib/extensions.dart` добавить строку (после блока `src/extensions/`, сохранив сортировку путей):

```dart
export 'src/parsing/control_functions/control_functions_c0.dart';
```

- [ ] **Step 4: Зелёный + ворота**

Run: `dart analyze --fatal-infos && dart test test/entry_point_extensions_test.dart && dart test`
Expected: PASS везде.

- [ ] **Step 5: CHANGELOG**

В буллете про entry points (заканчивается «...and every entry point carries a closure test.»):
1. Заменить «carries a closure test» на «carries an exports test» (тесты — рукописные перечисления, не вычисление замыкания; формулировка была завышена — отчёт [9], находка 2).
2. Дописать в тот же буллет предложение: «The `extensions` point had the same gap: `ansiRemoveControlCodes` takes a `Set<ControlFunctionsC0>` its own importer could not name, so the enum is now part of the point.»

- [ ] **Step 6: Commit**

```bash
git add lib/extensions.dart test/entry_point_extensions_test.dart CHANGELOG.md
git commit -m "fix: the extensions entry point can name its own parameter"
```

---

### Task 3: Текст матча читается один раз

**Files:**
- Modify: `lib/src/parsing/parser/entities/matching_state.dart:9`
- Modify: `CHANGELOG.md` (перф-абзац, та же фраза, что в Task 1 — согласовать после)

**Контекст:** Отчёт [9], разбор M7: `string` — геттер, зовущий `match.namedGroup('all')` при каждом чтении; байт-диспетчеризация добавила лишний вызов на CSI/SGR-путь (5 против 4 у baseline, ~47 нс каждый). Поле снимает все повторные чтения.

- [ ] **Step 1: Поле вместо геттера**

В `lib/src/parsing/parser/entities/matching_state.dart` строка 9:

```dart
  // было
  String get string => match.namedGroup('all')!;
  // стало
  late final String string = match.namedGroup('all')!;
```

Если конструктор класса `const` — убрать `const` не понадобится (`late final` с инициализатором несовместим с const-конструктором; в этом случае — инициализация в конструкторе). Проверить фактическую структуру класса и выбрать минимальную форму.

- [ ] **Step 2: Ворота**

Run: `dart format --output=none --set-exit-if-changed . && dart analyze --fatal-infos && dart test`
Expected: зелёное; поведение идентично (тот же текст, единожды).

- [ ] **Step 3: CHANGELOG**

В перф-абзаце (тот же, что Task 1) после «a simple SGR function comes from a cached table instead of being rebuilt» добавить «, the matched text is read out of the match once».

- [ ] **Step 4: Commit**

```bash
git add lib/src/parsing/parser/entities/matching_state.dart CHANGELOG.md
git commit -m "perf: the matched text is read once"
```

---

### Task 4: `currentCursorPos` — отказ одного переключения не бросает второе

**Files:**
- Modify: `lib/src/utils/current_cursor_pos.dart:30-52`
- Test: `test/current_cursor_pos_windows_test.dart`
- Modify: `CHANGELOG.md` (буллет Fixed про порядок восстановления режимов, ~134-137)

**Контекст:** Отчёт [9], находка 4: выключение (`..echoMode = false ..lineMode = false`, строки 33-35) стоит ДО внутреннего `try` — если `echoMode = false` прошёл, а `lineMode = false` бросил (не-консольный stdin, отказ ioctl), `finally` не выполняется и эхо остаётся выключенным. Тот же класс утечки, что чинил H1.

- [ ] **Step 1: Красный тест**

В `test/current_cursor_pos_windows_test.dart` добавить тест и фейк (фейки в файле `final` — новый класс, не наследование):

```dart
    test('puts echo back when line mode refuses to turn off', () async {
      final stdin = _NoRawModeStdin();

      await expectLater(
        currentCursorPos(_FakeStdout(), stdin),
        throwsA(isA<UnsupportedError>()),
      );

      expect(stdin.echoMode, isTrue);
    });
```

```dart
/// A stdin whose line mode cannot be turned off — the shape of an input
/// that is not a console. Echo goes off first, so if the refusal is not
/// guarded, echo stays off for good.
final class _NoRawModeStdin implements Stdin {
  bool _echoMode = true;

  @override
  bool get echoMode => _echoMode;

  @override
  set echoMode(bool value) => _echoMode = value;

  @override
  bool get lineMode => true;

  @override
  set lineMode(bool value) {
    if (!value) {
      throw const StdinException('line mode cannot be disabled');
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
```

- [ ] **Step 2: Убедиться, что красный**

Run: `dart test test/current_cursor_pos_windows_test.dart`
Expected: новый тест FAIL — `echoMode` остаётся `false` (восстановление не выполнилось).

- [ ] **Step 3: Фикс**

В `current_cursor_pos.dart` перенести выключение внутрь защищённого блока и восстанавливать только фактически изменённое:

```dart
  try {
    final keepEchoMode = stdin.echoMode;
    final keepLineMode = stdin.lineMode;
    var echoModeOff = false;
    var lineModeOff = false;

    try {
      stdin.echoMode = false;
      echoModeOff = true;
      stdin.lineMode = false;
      lineModeOff = true;

      report = await _readReport(
        input ?? stdin,
        () => stdout.write('${CSI}6$DSR'),
        timeout,
      );
    } finally {
      // Line mode first, mirroring the way they were turned off: Windows
      // lets echo come back only once line mode is on. Nested, so a throw
      // restoring one does not keep the other from being restored, and
      // only what actually changed is put back — a stdin that refused a
      // change is not asked to undo it.
      try {
        if (lineModeOff) {
          stdin.lineMode = keepLineMode;
        }
      } finally {
        if (echoModeOff) {
          stdin.echoMode = keepEchoMode;
        }
      }
    }
  } on Object catch (_, stacktrace) {
    ...без изменений...
  }
```

- [ ] **Step 4: Зелёный + ворота**

Run: `dart test test/current_cursor_pos_windows_test.dart && dart test && dart analyze --fatal-infos && dart format --output=none --set-exit-if-changed .`
Expected: все три теста файла PASS; полный набор зелёный.

- [ ] **Step 5: CHANGELOG**

В существующий буллет Fixed про восстановление режимов (H1) дописать предложение: «Turning them off is guarded the same way now: when a stdin refuses one change, the one already made is undone instead of being left behind.»

- [ ] **Step 6: Commit**

```bash
git add lib/src/utils/current_cursor_pos.dart test/current_cursor_pos_windows_test.dart CHANGELOG.md
git commit -m "fix: a refused mode change no longer strands the one before it"
```

---

### Task 5: Напечатанная строка закрывает открытую ею ссылку

**Files:**
- Modify: `lib/src/parsing/parser/printer.dart:137-163` (`_PrinterBase.prepare` — общая база всех четырёх принтеров)
- Create: `test/printer_links_test.dart`
- Modify: `CHANGELOG.md` (Fixed, рядом с буллетом про slice/link, ~138-141)

**Контекст:** Отчёт [9], находка 3: цикл `prepare` пишет `m.entity.string` как есть и в конце закрывает только стиль — `linkClose` не дописывается никогда; строка с незакрытой ссылкой делает кликабельным всё напечатанное после (формулировка M1 на поверхности принтера). Решение зеркалит принятое в M1 для `substring`: закрывать за собой. Ссылка, в отличие от стиля, на следующей строке НЕ переоткрывается (`Link` не входит в `State`) — это документируется; переоткрытие — отдельный дизайн-заход (бэклог, Task 7).

**Interfaces:**
- Consumes: `Link` (`lib/src/parsing/parser/entities/osc.dart:37`, поле `url`; `Link` с пустым `url` — это закрытие), `linkClose` (`lib/src/ready_to_use/osc.dart:23`). Паттерн учёта — как в `parser.dart:319,387-389,404-409`. Проверить видимость `Link`/`linkClose` из `printer.dart` (part-структура библиотеки); при необходимости добавить импорт.

- [ ] **Step 1: Красные тесты**

Создать `test/printer_links_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('a printed line closes the hyperlink it opened:', () {
    test('an unclosed link gets its close', () {
      expect(
        Printer(debugForTest: false).prepare('\x1B]8;;http://u/\x1B\\click'),
        '\x1B[0m\x1B]8;;http://u/\x1B\\click\x1B]8;;\x1B\\',
      );
    });

    test('a closed link is not closed twice', () {
      expect(
        Printer(debugForTest: false)
            .prepare('\x1B]8;;http://u/\x1B\\click\x1B]8;;\x1B\\ tail'),
        '\x1B[0m\x1B]8;;http://u/\x1B\\click\x1B]8;;\x1B\\ tail',
      );
    });

    test('the close comes before the style is unwound', () {
      expect(
        Printer(debugForTest: false)
            .prepare('\x1B[31m\x1B]8;;http://u/\x1B\\click'),
        '\x1B[0m\x1B[31m\x1B]8;;http://u/\x1B\\click\x1B]8;;\x1B\\\x1B[0m',
      );
    });

    test('a stacked printer closes the link the same way', () {
      expect(
        StackedPrinter(debugForTest: false)
            .prepare('\x1B]8;;http://u/\x1B\\click'),
        '\x1B[0m\x1B]8;;http://u/\x1B\\click\x1B]8;;\x1B\\',
      );
    });

    test('a NoStyle printer still passes the line through untouched', () {
      expect(
        Printer(defaultStyle: NoStyle(), debugForTest: false)
            .prepare('\x1B]8;;http://u/\x1B\\click'),
        '\x1B]8;;http://u/\x1B\\click',
      );
    });

    test('ansiCodesEnabled: false strips the link with the rest', () {
      expect(
        Printer(ansiCodesEnabled: false, debugForTest: false)
            .prepare('\x1B]8;;http://u/\x1B\\click'),
        'click',
      );
    });
  });
}
```

Сигнатуры конструкторов (`debugForTest`, `ansiCodesEnabled`, `defaultStyle`) сверить с фактическим публичным API `Printer`/`StackedPrinter` (см. `test/printer_no_style_test.dart` как образец) и скорректировать вызовы; ожидания «до фикса» проверить прогоном — префикс `\x1B[0m` и отсутствие хвостового reset для бесстилевых строк подтверждены пробами верификации.

- [ ] **Step 2: Убедиться, что красные**

Run: `dart test test/printer_links_test.dart`
Expected: тесты 1, 3, 4 FAIL (нет `\x1B]8;;\x1B\\` в конце); тесты 2, 5, 6 PASS (поведение уже верное).

- [ ] **Step 3: Фикс в `prepare`**

В `_PrinterBase.prepare` (printer.dart:142-163) добавить учёт ссылки и закрытие перед разматыванием стиля:

```dart
    var linkIsOpen = false;

    for (final m in parser.matches) {
      if (m.entity case Sgr()) {
        continue;
      }

      // A hyperlink passes through as it came, but not unnoticed: a line
      // that opens one and does not close it would make everything printed
      // after it part of the link, so the close is written at the end of
      // the line — the way a slice closes the link it opened. Unlike the
      // style, a link is not reopened on the next line.
      if (m.entity case Link(:final url)) {
        linkIsOpen = url.isNotEmpty;
      }

      final newState = m.state.changeDefaultsTo(defaultStyle);
      buf
        ..write(lastState.transitTo(newState))
        ..write(m.entity.string);
      lastState = newState;
    }

    if (linkIsOpen) {
      buf.write(linkClose);
    }
    buf.write(lastState.transitTo(stateDefaults));
```

(Существующий комментарий перед циклом про SGR сохранить; новый комментарий — при `Link`-ветке, старый про «opens a hyperlink» в списке пропускаемого скорректировать, чтобы не врал.)

- [ ] **Step 4: Dartdoc**

В dartdoc `prepare` (printer.dart:120) добавить: «A line that opens a hyperlink and does not close it gets the close written at its end, the way a slice does. A link, unlike the style, is not carried over to the next line.»

- [ ] **Step 5: Зелёный + ворота**

Run: `dart test test/printer_links_test.dart && dart test && dart analyze --fatal-infos && dart format --output=none --set-exit-if-changed .`
Expected: все PASS, включая существующие принтер-тесты (`printer_no_style_test`, `ansi_constants_test` с runZoned-принтерами — если какой-то из них пинит старое поведение со ссылкой, разобраться, а не подгонять).

- [ ] **Step 6: CHANGELOG**

Fixed-буллет после буллета про slice/link: «The printers had the gap the slice had: a prepared line that opened a hyperlink left it open, and everything printed after was part of it. A line now closes the link it opened; unlike the style, a link is not reopened on the next line.»

- [ ] **Step 7: Commit**

```bash
git add lib/src/parsing/parser/printer.dart test/printer_links_test.dart CHANGELOG.md
git commit -m "fix: a printed line closes the hyperlink it opened"
```

---

### Task 6: Контракт равенства пинит собственные следствия

**Files:**
- Test: `test/state_equality_contract_test.dart`
- Modify: `lib/src/parsing/state/state.dart` (dartdoc `operator ==`, ~423-431)

**Контекст:** Отчёт [9], находка 9: названный ревью риск M6 (дедупликация склеивает поведенчески разные стеки в `Set`/`Map`) тестом не запиннен; смежно — `Stack == Style` с равным `hashCode` выводимо из контракта, но прямо не сказано.

- [ ] **Step 1: Тесты следствий**

В `test/state_equality_contract_test.dart` (реиспользуя уже построенные там `grown`/`direct` или в их стиле) добавить:

```dart
  test('equal surfaces collapse as keys, history and all', () {
    final grown = Stack.terminalColors.underline.doublyUnderline;
    final direct = Stack.terminalColors.doublyUnderline;

    expect({grown, direct}, hasLength(1));
    expect(({grown: 'a'}..[direct] = 'b').length, 1);
  });

  test('a Stack equals a plain Style with the same surface', () {
    expect(Stack.terminalColors == Style.terminalColors, isTrue);
    expect(Stack.terminalColors.hashCode, Style.terminalColors.hashCode);
  });
```

(Оба теста должны пройти сразу — они пинят существующее задокументированное поведение, это пины контракта, не красные тесты бага. Типы сравнения проверить: если анализатор ругается на unrelated-types — сравнить через `Object`-переменные.)

- [ ] **Step 2: Фраза в контракт**

В dartdoc `State.==` (state.dart:423-431) добавить предложение: «The surface is all of it: a [Stack] and a plain [Style] that look the same are equal, and as keys of a `Set` or `Map` equal states collapse into one, however they were built.»

- [ ] **Step 3: Ворота**

Run: `dart test test/state_equality_contract_test.dart && dart test && dart analyze --fatal-infos && dart format --output=none --set-exit-if-changed .`
Expected: зелёное.

- [ ] **Step 4: Commit**

```bash
git add test/state_equality_contract_test.dart lib/src/parsing/state/state.dart
git commit -m "test: the equality contract pins its own consequences"
```

---

### Task 7: Гигиена и бэклог верификационного хвоста

**Files:**
- Modify: `test/parser_substring_links_test.dart:45-46` (русский комментарий → английский)
- Modify: `TODO.md`

**Контекст:** Отчёт [9], находки 7, 8, 10, 11, 12 (дешёвые улучшения — в бэклог, не в этот заход) и гигиена из находки 13.

- [ ] **Step 1: Перевести комментарий**

В `test/parser_substring_links_test.dart:45-46` перевести комментарий на английский, сохранив смысл (про `maxLength: 1`, чтобы конец среза не дотянулся до закрытия ссылки). Точный текст — по фактическому содержимому строк.

- [ ] **Step 2: Бэклог в TODO.md**

Дописать в `TODO.md` (в стиле существующего пункта про dependabot, со ссылкой на отчёт):

```markdown
From the verification report (`docs/2026-08-05[9]-review-verification-report.md`):

- Link continuity: neither a slice nor a printed line can reopen a
  hyperlink the way the style is reopened (`Link` is not part of `State`)
  — needs a design pass (finding 5).
- Fuzzer alphabets: an unterminated OSC and a second truncated CSI for
  `has_agrees_with_parser_test.dart`; cover `ansiHasSgr`/`ansiRemoveSgr`
  and pin per-function preservation (finding 8).
- One loop pinning the names to the cube:
  `Color256.rgb(r, g, b).color == Colors.values[16 + 36 * r + 6 * g + b]`
  (finding 7).
- A known-limitations line for the removal side of the int-overflow SGR,
  and `optimize` not closing a link where `substring` does (findings 10,
  11).
- CI: run the examples as a loop over `example/*.dart`, put a floor under
  coverage; `lengthWithoutEscapeCodes` without building the cleaned
  string (finding 12).
```

- [ ] **Step 3: Ворота**

Run: `dart format --output=none --set-exit-if-changed . && dart analyze --fatal-infos && dart test`
Expected: зелёное (правки не трогают код).

- [ ] **Step 4: Commit**

```bash
git add test/parser_substring_links_test.dart TODO.md
git commit -m "chore: the backlog takes the verification tail"
```

---

## Завершение ветки

1. Whole-branch-ревью свежим ревьюером (Opus): весь дифф ветки против main, с отчётом [9] как контекстом. Блокеры чинить отдельными коммитами до чистого вердикта.
2. `git checkout main && git merge --no-ff fix/verification-follow-up` с повествовательным сообщением merge-коммита.
3. Ворота на main: format, analyze, `dart test` (366 + новые), `dart pub publish --dry-run` (0 предупреждений), `dart run tool/generate.dart && git diff --exit-code -- lib/`.
4. `git push origin main`. Ветку удалить. **Без тега v4.0.0, без `dart pub publish`** — публикация отложена решением пользователя.
