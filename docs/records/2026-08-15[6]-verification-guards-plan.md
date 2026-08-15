# План: замыкание verification-ворот перед публикацией

> **Состояние на 2026-08-16:** исполнен целиком — через рестарт после блокера
> и починки по ревью — и влит в `main` мержем `6b2d1cb` при зелёных feature
> CI `31902380497` и main CI `31902669556` на SDK `3.6.0` и `stable`; писался
> против `main` @ `c6eda18`. Baseline и calibration в тексте — снятые до
> работы пробники, а не результаты ворот и CI; фактические прогоны записаны в
> `2026-08-16[1]`.
> **Что это:** план волны verification guards по спеке `2026-08-15[4]` — M6,
> M7, M8 и кластер M13/L12.
> **Связанные записи:** `2026-08-15[4]-verification-guards-design.md`,
> `2026-08-15[5]-pre-verification-guards-handoff.md`,
> `2026-08-16[1]-post-verification-guards-handoff.md`.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** независимо зафиксировать публичные namespace entry point’ов и registry генератора, считать coverage рукописного кода и вынести откалиброванные complexity-ratio из общего test process.

**Architecture:** M6 дополняет closure-walk точным JSON-oracle; M7 валидирует полный перечень marker-файлов до первой записи. M8 хранит полный LCOV artifact, но floor применяет к filtered-варианту. Semantic anchors четырёх corpus остаются в dart test, а standalone benchmark измеряет выполненную работу только на stable.

**Tech Stack:** Dart ^3.6.0, package:analyzer, dart:convert, dart:io, package:test, coverage:format_coverage, GitHub Actions.

## Снятые baseline и параметры guard

Временный probe на живом c6eda18 снял следующие значения; это oracle, а не рассуждение.

| scenario | corpus / batch | 5-pair median | healthy ratio | band |
|---|---|---:|---:|---|
| parse | 2 000 / 4 000 ANSI-строк, 20 parses/sample | 53.391 / 106.370 ms | 1.992 | < 2.5 |
| slice | 400 / 800 строк, 100 full walks/sample | 21.665 / 44.663 ms | 2.062 | < 2.5 |
| Stack | 4 000 / 8 000 смен цвета, 4 parses/sample | 24.257 / 62.226 ms | 2.565 | < 3.5 |
| insert | 200 строк; 10 shared или 1 fresh run/sample | 16.360 / 51.083 ms | 31.219 fresh/shared | > 24.0 |

Пять пар чередуют порядок small/shared и large/fresh. Insert shared sample делится на 10 до ratio. Каждая сторона прогревается один раз, а semantic anchor и operation count проверяются до timer.

    parse:   cleaned length 91999, FNV-1a-32 a20a9a76
    slice:   400 slices, plain width 41, first/last length 52, digest 39ef6bc5
    Stack:   length 24000; green, red, green, red, green, red, green
    insert:  400 results from each route; both digest 7879f6e5

## Global Constraints

- Создать из main изолированный worktree fix/verification-guards через superpowers:using-git-worktrees до первой правки кода.
- До первой правки в lib/ прочитать docs/architecture.md. Код, тесты и git старше рабочих бумаг.
- Значения выше сняты probe. Red с ними объяснять pipeline, а не подгонять ожидания.
- Работать RED → GREEN; один смысловой фикс — один conventional commit с английским повествовательным телом.
- Не менять lib/, public API, пять entry point’ов, SDK-floor ^3.6.0, версию 4.0.0, marker text либо generated zones. Не трогать docs/backlog.md, тег и публикацию.
- README не меняется: пользовательский контракт и examples прежние. Код, dartdoc, CHANGELOG и commits — по-английски, docs — по-русски.
- Перед merge запушить ветку и дождаться зелёной matrix 3.6.0/stable; PR не создавать.

---

### Task 1: Изолировать ветку и подтвердить базу

**Files:**

- Modify: нет — worktree и read-only baseline.

**Interfaces:**

- Consumes: main @ c6eda18, спека [4], этот plan [6].
- Produces: чистый worktree fix/verification-guards.

- [ ] **Step 1: создать отдельный worktree**

Использовать skill superpowers:using-git-worktrees и выполнить:

    git worktree add ../ansi_escape_codes-verification-guards -b fix/verification-guards main
    cd ../ansi_escape_codes-verification-guards
    git status --short --branch
    git log -1 --oneline

Ожидание: HEAD c6eda18, branch fix/verification-guards и ни одного чужого файла.

- [ ] **Step 2: снять baseline gates**

    dart run tool/check_entry_points.dart
    dart run tool/generate.dart
    git diff --exit-code -- lib/
    dart test test/performance_guards_test.dart
    dart run benchmark/memory_guard.dart

Ожидание: пять closed entry point’ов, generator без lib diff, пять старых performance/memory tests зелёные и memory внутри 159…332.

### Task 2: M6 — точный snapshot namespace entry point’ов

**Files:**

- Create: tool/entry_point_names.json
- Create: tool/src/entry_point_snapshot.dart
- Create: test/tool/check_entry_points_test.dart
- Modify: tool/check_entry_points.dart

**Interfaces:**

- Consumes: LibraryElement2.exportNamespace.definedNames2 и прежний _Closure.check().
- Produces: NamesByEntryPoint = Map<String, Set<String>>, compareEntryPointSnapshot, encodeEntryPointSnapshot и Future<int> runEntryPointCheck(List<String> args, {required String root}).
- Preserves: прежний signature closure criterion и normal CI command.

- [ ] **Step 1: написать RED pure tests snapshot seam**

В test/tool/check_entry_points_test.dart импортировать ../../tool/src/entry_point_snapshot.dart. Fixtures обязаны содержать expected extensions A и StringHasEscapeCodesExtension, actual A и Extra, missing lib/utils.dart и unexpected lib/style.dart. Assert render diagnostic содержит путь, StringHasEscapeCodesExtension, unexpected Extra, missing и unexpected entry points. Второй test проверяет лексикографически sorted paths/names, two-space JSON и один trailing newline.

    dart test test/tool/check_entry_points_test.dart

Ожидание: RED, seam ещё отсутствует.

- [ ] **Step 2: реализовать pure comparison без process exit**

Создать tool/src/entry_point_snapshot.dart. encodeEntryPointSnapshot сортирует paths и names, сериализует JsonEncoder.withIndent('  ') и добавляет newline. compareEntryPointSnapshot отдельно собирает sorted missing/unexpected entry point’ы и names; diagnostic печатает entry point и expected/actual counts. Этот файл не вызывает exit.

    dart format tool/src/entry_point_snapshot.dart test/tool/check_entry_points_test.dart
    dart test test/tool/check_entry_points_test.dart

- [ ] **Step 3: подключить snapshot к analyzer checker**

Заменить main тонким process edge:

    Future<void> main(List<String> args) async {
      exitCode = await runEntryPointCheck(args, root: _packageRoot());
    }

runEntryPointCheck принимает только [] и [--update-snapshot]; иной argv печатает Usage: dart run tool/check_entry_points.dart [--update-snapshot] и возвращает 64. Для всех lib/*.dart собрать names одновременно с прежними closure failures. Обычный mode сравнивает snapshot и closure; update mode пишет JSON только после успешных analysis и closure. Success печатает entry point и public-name total. Получить JSON исключительно успешным mode, сохранив known counts 510 ansi, 1037 umbrella, 8 extensions, 91 style, 2 utils.

    dart run tool/check_entry_points.dart --update-snapshot
    dart run tool/check_entry_points.dart
    git diff --check -- tool/check_entry_points.dart tool/src/entry_point_snapshot.dart tool/entry_point_names.json

- [ ] **Step 4: добавить process fixture и exact mutation**

Helper копирует lib/, tool/ и .dart_tool/package_config.json в Directory.systemTemp и запускает copied tool/check_entry_points.dart через Platform.resolvedExecutable. В mutation-fixture удалить только export src/extensions/has.dart из copied lib/extensions.dart. Required assertions:

    exitCode == 1
    stderr contains lib/extensions.dart
    stderr contains StringHasEscapeCodesExtension
    stderr contains expected 8, actual 7

В отдельной fixture скрыть ControlFunctionsC0 и подтвердить, что старый closure-site всё ещё diagnostic. Проверить, что update mode не пишет snapshot при closure failure, а unknown arg возвращает 64.

- [ ] **Step 5: targeted verification и commit**

    dart test test/tool/check_entry_points_test.dart
    dart run tool/check_entry_points.dart
    git add tool/check_entry_points.dart tool/src/entry_point_snapshot.dart tool/entry_point_names.json test/tool/check_entry_points_test.dart
    git commit -m "test: snapshot entry point namespaces" -m "The closure walk cannot observe a name that no remaining signature reaches."

### Task 3: M7 — preflight полного registry генератора

**Files:**

- Create: test/tool/generate_preflight_test.dart
- Modify: tool/generate.dart

**Interfaces:**

- Consumes: восемь старых emitters и exact _begin/_end.
- Produces: ordered List<({String path, List<String> Function(List<_Name>) emit})> и read-only preflight.
- Preserves: те же восемь zones; success пишет каждую ровно раз.

- [ ] **Step 1: RED fixture для девятой зоны и atomicity**

Создать temporary lib/ со всеми восьмью exact registry paths, sentinel до/между/после markers в каждом и ninth lib/src/extra.dart с парой markers. Скопировать настоящий script в temporary tool/ и запустить direct script so _packageRoot sees fixture. Перед запуском сохранить bytes nine files; после failure assert nonzero, stderr contains lib/src/extra.dart, все bytes identical. Добавить cases missing registry file, BEGIN-only, END-only, duplicate BEGIN, duplicate END, END before BEGIN.

    dart test test/tool/generate_preflight_test.dart

Ожидание: RED на ninth marker file.

- [ ] **Step 2: реализовать ordered registry и read-only validation**

В main сначала создать list registry, затем _preflight(registry); map не использовать, иначе duplicate key потеряется. _preflight рекурсивно читает только *.dart под lib/, считает trim-equivalent BEGIN/END, collects marker files, проверяет exact one pair and order, registry existence и equality discovered/registered paths. Missing/unexpected/duplicate/unpaired diagnostics sorted. При errors установить exitCode 1 и return до emitter/file.writeAsStringSync. После successful writes stdout exactly generated 8 zones.

- [ ] **Step 3: positive, duplicate и idempotence cases**

Fixture без ninth file завершается 0, печатает generated 8 zones и второй run leaves bytes identical. Duplicate case использует controlled copy script с повторным registry path; ожидает duplicate diagnostic и no writes.

    dart test test/tool/generate_preflight_test.dart
    dart run tool/generate.dart
    dart run tool/generate.dart
    git diff --exit-code -- lib/

- [ ] **Step 4: commit M7**

    git add tool/generate.dart test/tool/generate_preflight_test.dart
    git commit -m "fix: preflight generated marker registry" -m "An unregistered generated surface must fail before any table is rewritten."

### Task 4: M8 — full artifact и gated handwritten coverage

**Files:**

- Modify: .github/workflows/dart.yml

**Interfaces:**

- Consumes: один dart test --coverage=coverage run и coverage:format_coverage.
- Produces: coverage/lcov.info full artifact, coverage/lcov.gated.info without style_colors.dart, floor 95.0 only on gated report.
- Preserves: stable-only coverage, always artifact, red zero denominator.

- [ ] **Step 1: выполнить живой RED/GREEN report protocol**

Не создавать искусственный YAML unit-test. После full test сформировать reports:

    dart test --coverage=coverage
    dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
    dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.gated.info --report-on=lib --ignore-files='**/style_colors.dart'

Подтвердить, что full содержит style_colors.dart, gated — нет, а gated LF/LH не меньше 95.0. На копии gated report изменить три DA рукописного файла from hit to zero: existing inline AWK обязан return 1. Изменение records style_colors не меняет gated percentage; empty report тоже red.

- [ ] **Step 2: изменить stable workflow**

После full formatter добавить exact second command above. Floor step читает only coverage/lcov.gated.info, keeps zero-LF failure, declares floor=95.0 и output calls this hand-written lib. Comment объясняет permanent style_colors exclusion, но не хранит mutable percentages. Artifact uploads coverage/ with both reports.

- [ ] **Step 3: проверить source и commit**

    rg -n "lcov.info|lcov.gated.info|ignore-files|floor=95.0|style_colors" .github/workflows/dart.yml
    git diff --check -- .github/workflows/dart.yml
    git add .github/workflows/dart.yml
    git commit -m "ci: gate handwritten coverage" -m "Generated color getters must remain diagnosable without diluting handwritten coverage."

### Task 5: M13 — deterministic complexity anchors в dart test

**Files:**

- Modify: test/performance_guards_test.dart

**Interfaces:**

- Consumes: Parser.removeAll, Parser.substring, StackedParser.finalState, Parser.insertAfter.
- Produces: private FNV-1a-32 helper and four semantic tests with zero wall-clock assertions.
- Preserves: Text.string memory pin.

- [ ] **Step 1: заменить timers на exact semantic contracts**

Удалить bestOf, Stopwatch и timing ratios. Add FNV-1a-32 that mixes 0xff after each string. Parse corpus has ANSI sentinel in every one of 2,000 lines and asserts cleaned plain page, length 91999, digest a20a9a76: return-input must be red. Slice asserts width 41, 400 results, first/last length 52, exact first ESC[31;1m tag ESC[0m string and digest 39ef6bc5. Stack keeps length 24000 and colours green/red alternating through six pops. Insert builds both 400-result routes, asserts each digest 7879f6e5, equality, and first/last @ placement.

    dart test test/performance_guards_test.dart

Ожидание: GREEN на живом implementation; red требует объяснения probe mismatch before any changed expected value.

- [ ] **Step 2: prove anchors matter and restore exact sources**

Apply then reverse exact patches:

    Parser.removeAll returns input                   -> parse anchor RED
    slice loop returns empty list                    -> slice anchor RED
    Stack._copyWith clones foreground frame tail     -> semantic GREEN, Task 6 ratio RED
    shared insert loop is skipped                    -> insert count/digest RED

For stack mutation add temporary _cloneFrames(_Frame<T>? top) and substitute only foreground carried tail. It preserves answers while intentionally restoring quadratic work. Do not use git checkout for restoration.

- [ ] **Step 3: commit**

    dart format test/performance_guards_test.dart
    dart test test/performance_guards_test.dart
    git add test/performance_guards_test.dart
    git commit -m "test: anchor complexity workloads" -m "A complexity measurement is meaningful only when the work it times is observable."

### Task 6: L12 — standalone stable-only complexity guard

**Files:**

- Create: benchmark/complexity_guard.dart
- Create: test/tool/complexity_guard_cli_test.dart
- Modify: .github/workflows/dart.yml
- Modify: .pubignore

**Interfaces:**

- Consumes: four corpus/anchors from Task 5.
- Produces: dart run benchmark/complexity_guard.dart, zero args success, any argument exit 64.
- Preserves: memory_guard is independent cold process; dart test has no wall-clock assertion.

- [ ] **Step 1: write RED CLI contract**

test/tool/complexity_guard_cli_test.dart starts a child process with Platform.resolvedExecutable and unexpected argument. Assert exit 64 and stderr contains Usage: dart run benchmark/complexity_guard.dart. A no-arg integration invocation expects exit 0 and the four labels parse, slice, stack, insert, but never asserts microseconds.

    dart test test/tool/complexity_guard_cli_test.dart

Ожидание: RED because script is absent.

- [ ] **Step 2: implement paired harness with measured constants**

main rejects nonempty args with 64. _measurePair measures supplied body repeatedly and returns microseconds per logical run. _measureScenario warms both sides, takes exactly five alternating pairs, separately sorts values and chooses index 2. Before time it executes Task-5 anchor and checks operation counts: 20×2000/4000 parse, 100×400/800 slices, 4×4000/8000 stack, 10×200 shared and 1×200 fresh insert. Constants are exact:

    const _pairs = 5;
    const _parseLimit = 2.5;
    const _sliceLimit = 2.5;
    const _stackLimit = 3.5;
    const _insertFloor = 24.0;

Output prints two raw median samples, normalized ratio, exact band and scenario name. Anchor, operation count and band failure all set exitCode 1; collect every scenario failure for a complete diagnostic. Script imports package library only, never package:test.

- [ ] **Step 3: calibration evidence and five reverse mutations**

Run twenty independent cold invocations clean, then twenty under identical bounded CPU load (one busy worker per physical core minus one, started before and waited after each invocation). All forty healthy runs must exit 0.

Then patch and restore one mutation at a time:

    1. Parser.removeAll returns input                    -> parse anchor RED
    2. slice loop returns empty list                     -> slice anchor RED
    3. Stack._copyWith clones foreground frame tail      -> stack ratio >= 3.5 RED
    4. _ParserBase._pieceAt always starts a new _Walk    -> insert ratio <= 24.0 RED
    5. remove Pieces._parsed replay plus carried _walk   -> insert ratio <= 24.0 RED

For (4), replace only the forward walk-resumption branch. For (5), also create a new _ParserIterator instead of replaying _parsed. These preserve result, so red must name the intended performance band. A healthy red is never fixed by widening a threshold: enlarge corpus/batch or pair count, repeat forty healthy runs and all five mutations.

- [ ] **Step 4: wire stable CI and archive boundary**

After memory step add a separate stable-only complexity step running the script. Add benchmark/complexity_guard.dart beside memory_guard.dart in .pubignore and revise its comment to say both are environment-calibrated.

    dart test test/tool/complexity_guard_cli_test.dart
    dart run benchmark/complexity_guard.dart
    git add benchmark/complexity_guard.dart test/tool/complexity_guard_cli_test.dart .github/workflows/dart.yml .pubignore
    git commit -m "test: isolate complexity calibration" -m "Wall-clock ratios need a warmed stable-only process rather than the test scheduler."

### Task 7: Документация, full review, CI и handoff

**Files:**

- Modify: AGENTS.md
- Modify: docs/architecture.md
- Modify: CHANGELOG.md
- Modify: docs/handoff.md
- Create: docs/records/2026-08-15[7]-post-verification-guards-handoff.md

**Interfaces:**

- Consumes: closed M6/M7/M8/M13/L12 and actual verification evidence.
- Produces: accurate restart point without package API or README changes.

- [ ] **Step 1: update documentation**

AGENTS adds complexity guard after memory gate and describes namespace snapshot, marker preflight and 95.0 handwritten coverage. Architecture documents the same four independent mechanisms. CHANGELOG adds a concise English 4.0.0 verification-hardening note.

- [ ] **Step 2: full local verification**

    dart format --output=none --set-exit-if-changed .
    dart analyze --fatal-infos
    dart run tool/check_entry_points.dart
    dart run tool/generate.dart && git diff --exit-code -- lib/
    dart test
    dart run benchmark/memory_guard.dart
    dart run benchmark/complexity_guard.dart
    dart doc --dry-run
    dart pub publish --dry-run

Record actual test count, memory/complexity output and zero publish warnings for handoff; do not claim green without each output.

- [ ] **Step 3: whole-branch review and docs commit**

Use code-critic on full diff, verify accepted M6/M7/M13/L12 mutation matrix, fix real findings, rerun relevant tests and full suite.

    git add AGENTS.md docs/architecture.md CHANGELOG.md
    git commit -m "docs: describe verification guards" -m "The release checklist must describe the independent evidence each gate provides."

- [ ] **Step 4: feature CI, merge, main CI and final handoff**

    git push -u origin fix/verification-guards
    gh run list --branch fix/verification-guards --limit 5
    git checkout main
    git merge --no-ff fix/verification-guards
    git push origin main
    gh run list --branch main --limit 5

Merge only after the feature 3.6.0/stable matrix is green. Then archive current handoff as record [7], rewrite docs/handoff.md with actual commits, gates, test count, memory/complexity ranges and feature/main CI run IDs; commit and push it.

## Self-review плана

- Tasks 2, 3, 4, 5–6 cover M6, M7, M8 and M13/L12; Task 7 covers docs, whole review, feature CI, main CI and handoff.
- Нет незаполненных мест: digest, corpus, batches, pairs, bands and mutation outcomes named exactly. Noise is addressed only by corpus/batch/pairs followed by the full evidence matrix.
- Interfaces used downstream are defined in their producing task. Public API and generated lib remain out of scope.
