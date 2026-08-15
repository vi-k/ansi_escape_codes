# План: граница терминальной и стековой reset-семантики

> **Состояние на 2026-08-16:** исполнен и влит — `4277fd6` и `418736b`
> слиты в `main` мержем `bbbb210`, H7 закрыт. Поправка рестарта
> отработала: архив Task 4 лежит как `2026-08-14[10]-pre-h7-report.md`,
> номер `[9]` занял handoff перед планированием.
> **Что это:** TDD-план H7 — перевод `Style.call` на обычный `Printer` и
> документирование двух reset-моделей.
> **Связанные записи:** `2026-08-14[7]-stack-reset-semantics-design.md`,
> `2026-08-14[9]-pre-h7-planning-report.md`,
> `2026-08-14[10]-pre-h7-report.md`.

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** `Style.call` следует терминальной reset-семантике обычного
`Printer`, а явно выбранные `Stack` и `Stacked*` сохраняют и документируют
свой иерархический pop-контракт.

**Architecture:** `Style.call` меняет единственную зависимость — создаёт
`Printer(defaultStyle: this)` вместо `StackedPrinter`. Обычный generic printer
pipeline уже проносит строки, hyperlink, unfinished carry и residual SGR;
`Stack`, `StackedParser`, оба stacked-принтера и zoned-обёртка не меняют код,
только получают явный публичный контракт.

**Tech Stack:** Dart `^3.6.0`, `package:test`, существующие `Style`, `Stack`,
`Parser`, `_PrinterBase`, локальные ворота и GitHub Actions на SDK `3.6.0` и
`stable`.

## Global Constraints

- Выполнять в изолированной ветке `fix/style-call-terminal-resets`, созданной
  через `superpowers:using-git-worktrees` от `main` после коммита этого плана:
  base обязан содержать и спеку `[7]` (`ad53b97`), и план `[8]`.
- В основном checkout уже есть чужое незакоммиченное изменение
  `example/ansi_escape_codes_example.dart`; не переносить его в worktree, не
  форматировать отдельно, не добавлять в индекс и не включать ни в один
  коммит H7.
- Перед планированным expectation повторить живой пробник. Если тест падает
  иначе, объяснить расхождение по `Style`/`Stack`, а не подгонять ожидание.
- Новый регрессионный тест увидеть красным до правки реализации; после фикса
  вернуть `StackedPrinter` точной мутацией, снова увидеть его красным и
  восстановить `Printer`.
- Публичные имена и сигнатуры не менять. Reset-семантику `Stack`,
  `StackedParser`, `StackedPrinter`, `StackedSinkPrinter` и
  `runZonedStackedPrinter` не менять.
- H8, residual-канал H6, hyperlink и unfinished seam не менять.
- `README.md` — источник, `README.ru.md` — синхронный перевод в том же
  коммите с той же структурой и кодом примеров.
- `docs/backlog.md` не менять; H7 закрывается только в новом handoff после
  зелёного CI и merge.
- Версию `4.0.0` не бампать, пакет не публиковать и тег не создавать.
- Код, dartdoc, README, CHANGELOG и сообщения коммитов — по-английски;
  записи в `docs/` — по-русски.
- Один смысловой фикс — один коммит; документация модели идёт отдельным
  коммитом и не подбирает посторонние находки.

---

### Task 1: Красный контракт `Style.call` и минимальная смена модели

**Files:**
- Modify: `test/stack_state_test.dart:131-160`
- Modify: `lib/src/parsing/state/style.dart:294-325`

**Interfaces:**
- Consumes: `String Printer.prepare(String line)`,
  `Printer({Style defaultStyle, ...})`, `Style Parser.stateAt(int pos)`.
- Produces: существующий `String Style.call(String text)` без изменения
  сигнатуры, но с терминальной семантикой selective reset.
- Preserves: `Stack`, `StackedParser`, `StackedPrinter`,
  `StackedSinkPrinter`, `runZonedStackedPrinter` и общий `_PrinterBase`.

- [ ] **Step 1: повторить пробник исходных и целевых байтов**

Создать через `apply_patch` временный `tool/tmp_h7_probe.dart` вне индекса и
вывести `jsonEncode`,
`ansiShowControlFunctions` и `Parser(...).stateAt(2)` для текущего
`Styles.red(input)` и эталонного обычного принтера:

```dart
import 'dart:convert';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  const input = '${fgGreen}a${fgYellow}b${resetFg}c';
  final current = Styles.red(input);
  final wanted = Printer(defaultStyle: Styles.red).prepare(input);

  for (final (name, output) in [
    ('current', current),
    ('wanted', wanted),
  ]) {
    print('$name bytes: ${jsonEncode(output)}');
    print('$name codes: ${output.ansiShowControlFunctions()}');
    print('$name c: ${Parser(output).stateAt(2)}');
  }

  final nested = 'abc${Styles.green('green')}def';
  print('nested current: '
      '${Styles.red(nested).ansiShowControlFunctions()}');
  print('nested wanted: '
      '${Printer(defaultStyle: Styles.red).prepare(nested).ansiShowControlFunctions()}');
}
```

Run:

```bash
rtk dart run tool/tmp_h7_probe.dart
```

Зафиксированное на `main @ ad53b97` ожидание:

```text
current bytes: "\u001b[0m\u001b[32ma\u001b[33mb\u001b[32mc\u001b[0m"
current codes: [reset][fgGreen]a[fgYellow]b[fgGreen]c[reset]
current c:     Style(foreground: Color16.green)
wanted bytes:  "\u001b[0m\u001b[32ma\u001b[33mb\u001b[38;5;1mc\u001b[0m"
wanted codes:  [reset][fgGreen]a[fgYellow]b[fg256Red]c[reset]
wanted c:      Style(foreground: Color256.red)
nested current: [reset][fg256Red]abc[fg256Green]green[fg256Red]def[reset]
nested wanted:  [reset][fg256Red]abc[fg256Green]green[fg256Red]def[reset]
```

Удалить временный пробник через `apply_patch` и подтвердить, что он не появился
в `git status --short`.

- [ ] **Step 2: добавить точные красные тесты терминальной модели**

В `test/stack_state_test.dart` после существующей группы
`Style.call on unbalanced input` добавить:

```dart
  group('Style.call follows terminal resets:', () {
    const foreground = '${fgGreen}a${fgYellow}b${resetFg}c';

    test('matches an ordinary Printer with the same default style', () {
      final styled = Styles.red(foreground);
      final printed = Printer(defaultStyle: Styles.red).prepare(foreground);

      expect(styled, printed);
      expect(
        styled,
        '$reset${fgGreen}a${fgYellow}b${fg256Red}c$reset',
      );
      expect(Parser(styled).stateAt(2).foregroundColor, Color256.red);
    });

    final cases = <(String, String, void Function(Style))>[
      (
        'background',
        '${bgGreen}a${bgYellow}b${resetBg}c',
        (state) => expect(state.backgroundColor, isNull),
      ),
      (
        'counter',
        '${inverse}a${inverse}b${resetInverse}c',
        (state) => expect(state.isInverse, isFalse),
      ),
      (
        'exclusive enum',
        '${underline}a${doublyUnderline}b${resetUnderline}c',
        (state) => expect(state.underlineStyle, isNull),
      ),
      (
        'extended color',
        '${underline256(1)}a'
            '${underline256(2)}b${resetUnderlineColor}c',
        (state) => expect(state.underlineColorValue, isNull),
      ),
      (
        'font',
        '${alternativeFont1}a${alternativeFont2}b${primaryFont}c',
        (state) => expect(state.fontSelection, FontSelection.primary),
      ),
    ];

    for (final (name, input, check) in cases) {
      test('$name reset does not expose the previous inner value', () {
        final state = Parser(Styles.red(input)).stateAt(2);

        expect(
          state.foregroundColor,
          Color256.red,
          reason: input.ansiShowControlFunctions(),
        );
        check(state);
      });
    }

    test('keeps nested Styles byte-for-byte', () {
      expect(
        Styles.red('abc${Styles.green('green')}def'),
        '$reset${fg256Red}abc${fg256Green}green${fg256Red}def$reset',
      );
    });

    test('explicit stacked APIs keep their pop contract', () {
      expect(
        StackedParser(foreground).stateAt(2).foregroundColor,
        Color16.green,
      );

      final output =
          StackedPrinter(defaultStyle: Styles.red).prepare(foreground);
      expect(Parser(output).stateAt(2).foregroundColor, Color16.green);
    });
  });
```

Существующие два теста unbalanced reset не переносить и не ослаблять: они
доказывают, что внешний red/bold переживает reset внутреннего текста.

- [ ] **Step 3: увидеть новый контракт красным**

Run:

```bash
rtk dart format test/stack_state_test.dart
rtk dart test test/stack_state_test.dart --reporter expanded
```

Expected: ровно шесть новых проверок красные. Тест равенства и точных
foreground-байтов падает, потому что `Style.call` выдаёт `fgGreen` перед `c`
вместо `fg256Red`; отдельные тесты background, inverse, underline, underline
color и font также видят предыдущий frame. Тест вложенных `Styles`, оба
unbalanced-теста и явные stacked-проверки PASS.

- [ ] **Step 4: переключить `Style.call` на терминальную модель**

В `lib/src/parsing/state/style.dart` заменить только конструктор принтера:

```dart
    final printer = Printer(defaultStyle: this);
```

Оставить ранний возврат, один принтер на вызов, split/join строк и весь общий
printer pipeline без изменений.

- [ ] **Step 5: уточнить dartdoc `Style.call`**

После абзаца о возврате внутреннего стиля к внешнему добавить:

```dart
  ///
  /// Escape codes in [text] keep their terminal meaning. A selective reset
  /// returns that property to the terminal's default, which this style
  /// replaces; it does not reveal an earlier value set inside [text]. Use
  /// [StackedPrinter] when resets are meant to close nested style operations
  /// one level at a time.
```

- [ ] **Step 6: прогнать целевой тест и анализ**

Run:

```bash
rtk dart format --output=none --set-exit-if-changed \
  lib/src/parsing/state/style.dart test/stack_state_test.dart
rtk dart analyze --fatal-infos
rtk dart test test/stack_state_test.dart --reporter expanded
```

Expected: формат чист, analyze без diagnostics, все тесты файла PASS.

- [ ] **Step 7: доказать красноту точной обратной мутацией**

Временно вернуть в `Style.call`:

```dart
    final printer = StackedPrinter(defaultStyle: this);
```

Повторить `test/stack_state_test.dart`. Тест терминального foreground и
представители пяти shape-семейств обязаны снова упасть; nested, unbalanced и
явные stacked-тесты остаются зелёными. Вернуть `Printer`, снова получить PASS
и проверить `git diff --check`.

- [ ] **Step 8: закоммитить смысловой фикс**

Run:

```bash
rtk git add lib/src/parsing/state/style.dart test/stack_state_test.dart
rtk git commit -m "fix: style wrappers use terminal reset semantics" \
  -m "Style.call parsed inner ANSI through Stack, so a selective reset could reveal an earlier inner value instead of the wrapper's default. Route wrappers through the ordinary Printer while leaving explicitly stacked APIs hierarchical."
```

---

### Task 2: Явный публичный контракт двух моделей

**Files:**
- Modify: `lib/src/parsing/state/stack.dart:35-49`
- Modify: `lib/src/parsing/parser/parser.dart:99-108`
- Modify: `lib/src/parsing/parser/printer.dart:32-52,82-101,672-696`
- Modify: `README.md:558-604,777-787`
- Modify: `README.ru.md:554-600,772-782`
- Modify: `CHANGELOG.md:135-155`
- Modify: `docs/architecture.md:105-112`

**Interfaces:**
- Consumes: выбранную в Task 1 терминальную реализацию `Style.call` и
  неизменённый pop-контракт `Stack`.
- Produces: согласованный dartdoc/README/CHANGELOG/architecture без изменения
  публичных сигнатур и примеров кода.

- [ ] **Step 1: отделить `Stack` от терминальной модели в dartdoc**

После существующего описания push/pop в `stack.dart` добавить:

```dart
/// This is deliberately a hierarchical interpretation, not a model of the
/// state a terminal reaches from arbitrary ANSI. A terminal's selective reset
/// clears the property to its default; a [Stack] reads the same code as one
/// pop. Use [Style] and [Parser] when the terminal's visible state is the
/// answer, and this type when resets close nested style operations.
///
/// A full reset is not a selective close: it clears every history at once and
/// returns [Stack.terminalColors].
///
```

Не менять существующие предложения о пустой истории и equality.

- [ ] **Step 2: уточнить dartdoc парсера и трёх stacked-выходов**

В dartdoc `StackedParser` после описания hierarchy добавить:

```dart
///
/// This is an opt-in interpretation for hierarchically composed input. A
/// selective reset pops one value, so the reported state may differ from what
/// a terminal shows for the same bytes. Use [Parser] for terminal semantics.
```

В dartdoc `StackedPrinter` добавить:

```dart
///
/// Choosing this printer chooses that hierarchical interpretation: a
/// selective reset closes one stacked operation instead of clearing the
/// terminal property. Use [Printer] for arbitrary ANSI whose terminal
/// meaning must be preserved.
```

В dartdoc `StackedSinkPrinter` добавить тот же контракт с точной ссылкой на
sink-пару:

```dart
///
/// Choosing this printer chooses that hierarchical interpretation: a
/// selective reset closes one stacked operation instead of clearing the
/// terminal property. Use [SinkPrinter] for arbitrary ANSI whose terminal
/// meaning must be preserved.
```

В dartdoc `runZonedStackedPrinter` между первым абзацем и `See` добавить:

```dart
///
/// The zone uses [StackedPrinter]'s hierarchical reset interpretation. Use
/// [runZonedPrinter] where printed ANSI must keep terminal reset semantics.
```

- [ ] **Step 3: дополнить английский README**

В начале раздела `StackedPrinter`, после вводного абзаца, добавить:

```markdown
This is an explicit hierarchical interpretation, not a model of the state a
terminal reaches from arbitrary ANSI. A terminal's selective reset clears a
property to its default; `StackedPrinter` reads the same code as one pop. Use
`Printer` when the terminal meaning of the input must be preserved, and use
`StackedPrinter` when resets close nested style operations such as the
template below.
```

В разделе `Parser` после существующего абзаца о разнице двух парсеров
добавить:

```markdown
That difference is semantic, not only additional bookkeeping. Use `Parser`
to ask what a terminal shows for arbitrary ANSI; choose `StackedParser` only
when its resets are meant to close the most recently applied style level.
```

- [ ] **Step 4: синхронно дополнить русский README**

В тех же местах, сохраняя структуру и код примеров, добавить:

```markdown
Это явно выбранная иерархическая интерпретация, а не модель состояния, в
которое терминал приходит на произвольном ANSI. Терминальный selective reset
очищает свойство до значения по умолчанию; `StackedPrinter` читает тот же код
как один pop. Используйте `Printer`, когда надо сохранить терминальный смысл
входа, а `StackedPrinter` — когда reset закрывает вложенную стилевую операцию,
как в шаблоне ниже.
```

И в разделе `Parser`:

```markdown
Разница семантическая, а не только в дополнительном учёте истории. Чтобы
узнать, что терминал покажет для произвольного ANSI, используйте `Parser`;
`StackedParser` выбирайте только там, где reset должен закрывать последний
наложенный уровень стиля.
```

- [ ] **Step 5: записать исправление в CHANGELOG и architecture**

В неизданной секции `4.0.0`, под `Fixed:`, рядом с другими printer-исправлениями
добавить:

```markdown
- `Style.call` read its inner ANSI through `Stack`, so a selective reset after
  two setters revealed the earlier inner value instead of returning to the
  caller's default style. Style wrappers now use the same terminal reset
  semantics as `Printer`; the explicitly selected `Stack` and `Stacked*` APIs
  keep their hierarchical pop contract.
```

В `docs/architecture.md` сразу после абзаца о паре обычных и stacked-принтеров
добавить:

```markdown
Эта пара различается семантикой, а не полнотой учёта. `Style`, `Parser`,
`Printer` и `SinkPrinter` моделируют терминал: selective reset очищает
свойство до default, который принтер затем проецирует на `defaultStyle`.
`Stack` и явно выбранные `Stacked*` читают тот же reset как pop одного уровня
иерархии. Поэтому `Style.call` строится на обычном `Printer`; stacked-модель
остаётся только у API, назвавших её явно.
```

- [ ] **Step 6: проверить документацию и сделать отдельный коммит**

Run:

```bash
rtk dart format --output=none --set-exit-if-changed .
rtk dart analyze --fatal-infos
rtk dart doc --dry-run
rtk git diff --check
```

Expected: формат чист, analyze без diagnostics, dartdoc 0 warnings/0 errors,
diff без whitespace errors. Вручную сверить, что новые абзацы стоят в
одинаковых местах README EN/RU, их структура совпадает, код примеров не
изменился.

Commit:

```bash
rtk git add lib/src/parsing/state/stack.dart \
  lib/src/parsing/parser/parser.dart \
  lib/src/parsing/parser/printer.dart \
  README.md README.ru.md CHANGELOG.md docs/architecture.md
rtk git commit -m "docs: distinguish terminal and stacked reset models" \
  -m "Stacked APIs intentionally read selective resets as hierarchy pops, but their documentation did not warn that this differs from a terminal. Make the model choice explicit wherever users select a parser or printer."
```

---

### Task 3: Полные ворота и строгое ревью ветки

**Files:**
- Review: весь diff `origin/main...fix/style-call-terminal-resets`
- Fix only confirmed H7 findings in: `lib/src/parsing/state/style.dart`,
  `lib/src/parsing/state/stack.dart`, `lib/src/parsing/parser/parser.dart`,
  `lib/src/parsing/parser/printer.dart`, `test/stack_state_test.dart`,
  `README.md`, `README.ru.md`, `CHANGELOG.md`, `docs/architecture.md`

**Interfaces:**
- Consumes: код, тесты и документацию Tasks 1–2.
- Produces: ветку без подтверждённых H7-дефектов, с чистым worktree и всеми
  зелёными локальными воротами.

- [ ] **Step 1: проверить scope и чистоту перед воротами**

Run:

```bash
rtk git status --short --branch
rtk git diff --name-status origin/main...HEAD
rtk git diff --check origin/main...HEAD
```

Expected: worktree чист; diff содержит спеки `[7]`/`[8]`, два смысловых
коммита Tasks 1–2 и только перечисленные H7-поверхности. Чужой
`example/ansi_escape_codes_example.dart` отсутствует.

- [ ] **Step 2: прогнать все локальные ворота**

Run по одному, сохраняя фактический вывод для handoff:

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

Expected: 144 файла format без изменений; analyze без diagnostics; 5 entry
points closed; generator не меняет `lib/`; **865 тестов** PASS при восьми
новых тестах Task 1; memory guard внутри актуальной полосы **159…332 байта на
match** из `docs/handoff.md`; dartdoc 0/0; publish dry-run без предупреждений.
Если к исполнению корпус изменился, в handoff писать фактическое число тестов,
а расхождение сначала объяснить.

- [ ] **Step 3: провести строгое ревью всего diff**

Применить `code-critic` к `origin/main...HEAD`, затем
`superpowers:requesting-code-review`. Проверить как минимум:

- `Style.call` использует ровно один обычный `Printer` и не потерял carry
  между строками;
- red-тест действительно отличает terminal reset от pop, а не сравнивает две
  копии одной ошибки;
- exact nested guard удерживает red/green/red и старые unbalanced-тесты не
  ослаблены;
- все explicit stacked-типы сохранили код и pop-семантику;
- dartdoc и оба README не называют `Stacked*` терминальной моделью;
- README EN/RU синхронны;
- H8, residual, hyperlink, public API, version и generated regions не
  затронуты;
- обратная мутация `StackedPrinter` была реально красной.

Если ревью находит дефект, остановить finish-поток, применить
`superpowers:receiving-code-review`, воспроизвести находку красным тестом или
точной проверкой, исправить только подтверждённую причину и сделать отдельный
conventional-коммит. После любого исправления повторить Step 2 и весь Step 3.

- [ ] **Step 4: зафиксировать финальную проверяемую вершину**

Run:

```bash
rtk git status --short --branch
rtk git log --oneline --decorate origin/main..HEAD
```

Expected: worktree чист, HEAD содержит спеки и проверенные H7-коммиты, все
числа ворот записаны для следующего handoff.

---

### Task 4: CI ветки, merge и новый handoff

**Files:**
- Archive: `docs/handoff.md` в
  `docs/records/2026-08-14[9]-pre-h7-handoff.md`
- Rewrite: `docs/handoff.md`
- Do not modify: `docs/backlog.md`, `pubspec.yaml`

**Interfaces:**
- Consumes: финальный проверенный HEAD Task 3 и принятые документы `[7]`/`[8]`.
- Produces: зелёный `main`, запушенный в `origin`, и handoff с закрытым H7 и
  оставшимся H8.

- [ ] **Step 1: запушить feature-ветку и дождаться обеих ног CI**

Run:

```bash
rtk git push -u origin fix/style-call-terminal-resets
rtk gh run list --branch fix/style-call-terminal-resets --limit 5
```

Дождаться завершения run на feature HEAD. Обязательны зелёные jobs
`build (3.6.0)` и `build (stable)`; записать run id, job ids и HEAD. Красный
CI разбирается до merge через `github:gh-fix-ci` и
`superpowers:systematic-debugging`, затем локальные ворота и CI повторяются.

- [ ] **Step 2: слить ветку обычным merge-коммитом и проверить main CI**

В основном checkout сначала подтвердить, что единственное постороннее
изменение — сохранённый файл примера и merge его не затрагивает. Не stash,
не reset и не добавлять этот файл в индекс. Если набор иной или merge требует
его затронуть, остановиться и спросить владельца.

Run:

```bash
rtk git merge --no-ff fix/style-call-terminal-resets \
  -m "merge: style wrappers keep terminal reset semantics"
rtk git push origin main
rtk gh run list --branch main --limit 5
```

Дождаться зелёного CI merge-коммита на `main` на SDK 3.6.0 и stable. Записать
merge SHA, run id и job ids. Чужое изменение примера остаётся вне merge и
вне индекса.

- [ ] **Step 3: архивировать прежний handoff и переписать текущий**

Скопировать прежний `docs/handoff.md` без изменения prose в
`docs/records/2026-08-14[9]-pre-h7-handoff.md`; в его шапке отметить, что это
состояние до H7, закрытое фактическим merge-коммитом.

Новый `docs/handoff.md` должен содержать только проверенные факты:

- fix HEAD, merge SHA и коммиты спеки/плана/кода/документации/review fixes;
- точные локальные ворота: число тестов, memory guard, dartdoc/publish;
- feature и main CI run/job ids на обеих SDK;
- H7 в таблице закрытых High с выбранной границей terminal/stacked;
- H8 как оставшийся High и все прежние Medium/Low без переоценки;
- отдельное напоминание, что `Stacked*` намеренно не моделирует терминал;
- версия 4.0.0, тег и публикация не тронуты;
- `docs/backlog.md` остался списком владельца и не менялся.

- [ ] **Step 4: проверить и закоммитить handoff**

Run:

```bash
rtk git diff --check
rtk git status --short
```

Добавить только два handoff-файла; чужой пример снова должен остаться вне
индекса.

Commit and push:

```bash
rtk git add docs/handoff.md \
  'docs/records/2026-08-14[9]-pre-h7-handoff.md'
rtk git commit -m "docs: hand off the package after terminal reset alignment" \
  -m "H7 is merged and verified on both supported SDK legs, so the live handoff now records the explicit terminal-versus-stacked boundary and leaves H8 for the next owner decision."
rtk git push origin main
```

- [ ] **Step 5: убрать отработавшую ветку после безопасной передачи**

Только после успешного push handoff и проверки, что `main` содержит feature
HEAD:

```bash
rtk git branch -d fix/style-call-terminal-resets
rtk git push origin --delete fix/style-call-terminal-resets
```

Не создавать тег и не запускать `dart pub publish`.
