# План: complexity guard, который доказывает измеренную работу

> **Состояние на 2026-08-16:** написан по принятой спеке `2026-08-16[2]`;
> реализация впереди.
> **Что это:** план переделки `benchmark/complexity_guard.dart` по задачам,
> с ожиданиями, снятыми пробником с живого кода.
> **Связанные записи:** `2026-08-16[2]-complexity-guard-design.md`,
> `2026-08-16[1]-post-verification-guards-report.md`.

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** сделать так, чтобы complexity guard не мог остаться зелёным, не
измерив настоящую работу, и чтобы всплеск планировщика не решал за код.

**Architecture:** у каждой стороны сценария остаётся одна реализация; её
результат проверяется наблюдением, снятым пробником, до серии замеров и после
неё; полосе предъявляется медиана попарных отношений, а не отношение
независимо отсортированных медиан.

**Tech Stack:** Dart ^3.6.0, `dart:io`, `package:test` (только для чистой
функции статистики), сама библиотека.

**Spec:** `docs/records/2026-08-16[2]-complexity-guard-design.md`

## Global Constraints

- **`lib/` не меняется** — ни публичный API, ни наблюдаемая семантика, ни
  пять точек входа, ни SDK-floor `^3.6.0`, ни версия `4.0.0`.
- **Полосы неизменны:** `_parseLimit = 2.5`, `_sliceLimit = 2.5`,
  `_stackLimit = 3.5`, `_insertFloor = 24.0`. Число пар `_pairs = 7`.
  Красный на здоровом коде — находка, а не повод сдвинуть число: увеличивается
  корпус, батч или число пар, после чего вся матрица доказательств
  повторяется целиком.
- **Ожидаемые значения снимаются пробником с живого кода, а не выводятся
  рассуждением.** Все константы ниже уже сняты на `e29c0e1`; если прогон даёт
  другое — объяснить расхождение, а не подогнать ожидание под код.
- Работа идёт RED → GREEN. Один смысловой фикс — один коммит,
  conventional-префикс, английское повествовательное тело (почему, а не что).
- `.github/workflows/dart.yml` и `.pubignore` не меняются: шаг стража уже
  есть, страж уже не публикуется.
- Скрипт импортирует только `dart:io` и саму библиотеку; `package:test` в нём
  не появляется.
- Документы `docs/` — по-русски; код, dartdoc, CHANGELOG и коммиты —
  по-английски.

---

### Task 1: Изолировать ветку и снять базу

**Files:**
- Modify: нет — worktree и read-only база.

**Interfaces:**
- Consumes: `main` @ `e29c0e1`, спека `2026-08-16[2]`.
- Produces: чистый worktree `fix/complexity-guard`.

- [ ] **Step 1: создать worktree**

Использовать skill `superpowers:using-git-worktrees`, затем:

```bash
git worktree add .worktrees/fix-complexity-guard -b fix/complexity-guard main
cd .worktrees/fix-complexity-guard
git status --short --branch
git log -1 --oneline
```

Ожидание: ветка `fix/complexity-guard`, HEAD `e29c0e1`, ни одного чужого файла.

- [ ] **Step 2: снять базу**

```bash
dart run benchmark/complexity_guard.dart
dart test test/tool/complexity_guard_cli_test.dart
dart test test/performance_guards_test.dart
```

Ожидание: страж печатает четыре сценария и выходит нулём; оба тестовых файла
зелёные. Записать напечатанные отношения — они понадобятся для сравнения.

### Task 2: Медиана попарных отношений как проверяемая функция

**Files:**
- Modify: `benchmark/complexity_guard.dart`
- Create: `test/tool/complexity_guard_ratio_test.dart`

**Interfaces:**
- Consumes: ничего.
- Produces: `typedef PairedRatios = ({double median, double min, double max});`
  и `PairedRatios pairedRatios(List<double> first, List<double> second)` в
  `benchmark/complexity_guard.dart` — **публичные**, чтобы тест мог их
  импортировать.

- [ ] **Step 1: написать падающий тест**

Создать `test/tool/complexity_guard_ratio_test.dart`:

```dart
import 'package:test/test.dart';

import '../../benchmark/complexity_guard.dart';

void main() {
  group('paired ratios', () {
    test('divides within a pair rather than across the sides', () {
      // Медианы сторон — 1 и 4, их отношение 4. Попарные отношения —
      // 2, 8 и 1, их медиана 2. Тест держит именно вторую величину.
      final ratios = pairedRatios([1, 1, 4], [2, 8, 4]);

      expect(ratios.median, 2.0);
    });

    test('reports the extremes of the pairs', () {
      final ratios = pairedRatios([1, 1, 4], [2, 8, 4]);

      expect(ratios.min, 1.0);
      expect(ratios.max, 8.0);
    });

    test('rejects sides of different length', () {
      expect(
        () => pairedRatios([1, 2], [1, 2, 3]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects an empty measurement', () {
      expect(() => pairedRatios([], []), throwsA(isA<ArgumentError>()));
    });

    test('rejects an even number of pairs', () {
      expect(
        () => pairedRatios([1, 2], [2, 4]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects a sample the timer could not resolve', () {
      expect(
        () => pairedRatios([1, 0, 1], [1, 1, 1]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
```

- [ ] **Step 2: убедиться, что он падает**

```bash
dart test test/tool/complexity_guard_ratio_test.dart
```

Ожидание: RED — `pairedRatios` ещё не существует, ошибка компиляции.

- [ ] **Step 3: реализовать функцию**

В `benchmark/complexity_guard.dart` добавить:

```dart
/// The median of the per-pair ratios of [second] to [first], with the
/// extremes the pairs reached.
///
/// The pairing is the whole point. Each ratio divides two samples measured
/// beside each other, so a burst of scheduler noise that lands inside one
/// pair moves that pair's ratio and leaves the rest alone. Taking a median
/// of each side on its own and dividing lets the two medians come from
/// different pairs — from different moments — and reports their ratio as
/// though it were one measurement.
///
/// The extremes are returned rather than printed away: a wide spread is
/// what a loaded machine looks like, and a reader deserves to tell that
/// apart from a moved median, which is what a regression looks like.
PairedRatios pairedRatios(List<double> first, List<double> second) {
  if (first.length != second.length) {
    throw ArgumentError(
      'the sides differ in length: ${first.length} and ${second.length}',
    );
  }
  if (first.isEmpty) {
    throw ArgumentError('there are no pairs to compare');
  }
  if (first.length.isEven) {
    throw ArgumentError(
      'an even number of pairs has no single median: ${first.length}',
    );
  }

  final ratios = <double>[];
  for (var i = 0; i < first.length; i++) {
    if (first[i] <= 0 || second[i] <= 0) {
      throw ArgumentError(
        'pair $i holds a sample the timer could not resolve: '
        '${first[i]} and ${second[i]}',
      );
    }
    ratios.add(second[i] / first[i]);
  }
  ratios.sort();

  return (
    median: ratios[ratios.length ~/ 2],
    min: ratios.first,
    max: ratios.last,
  );
}

/// What a scenario's pairs said: the median ratio and the extremes.
typedef PairedRatios = ({double median, double min, double max});
```

- [ ] **Step 4: убедиться, что тест проходит**

```bash
dart format benchmark/complexity_guard.dart test/tool/complexity_guard_ratio_test.dart
dart test test/tool/complexity_guard_ratio_test.dart
dart analyze --fatal-infos
```

Ожидание: шесть тестов зелёные, анализ без замечаний.

- [ ] **Step 5: коммит**

```bash
git add benchmark/complexity_guard.dart test/tool/complexity_guard_ratio_test.dart
git commit -m "test: divide within a pair, not across the sides" -m "The alternation exists so both sides of a scenario meet the same scheduler; sorting each side on its own throws that away and lets the two medians come from different moments."
```

### Task 3: Одна реализация на сторону и наблюдение вместо счётчика

**Files:**
- Modify: `benchmark/complexity_guard.dart`

**Interfaces:**
- Consumes: `pairedRatios` из Task 2.
- Produces: `_Side` с полями `label`, `batch`, `run`, `observe`, `expected`;
  `_runScenario`, принимающий две `_Side`, полосу и предикат.
- Исчезают: `_TimedSide`, `_timedParse`, `_timedSlices`, `_timedStack`,
  `_timedInsertions`, `_slices`, `_sharedInsertions`, `_freshInsertions`,
  `_anchorParse`, `_anchorSlice`, `_anchorStack`, `_anchorInsert`, `_sink`,
  `_unmeasured`, `_require`, `_sameStrings`, `expectedFirst`/`expectedSecond`.

- [ ] **Step 1: доказать дыру на нынешнем страже**

До правок применить мутацию к **измеряемому телу** parse (строка 251):

```dart
    _sink = Parser(page.substring(0, 100)).removeAll();
```

Запустить:

```bash
dart run benchmark/complexity_guard.dart; echo "rc=$?"
```

Ожидание: **`rc=0`** — страж зелен, померив сотую долю корпуса. Это и есть
RED задачи: сегодняшние проверки такую подмену не видят. Записать вывод, снять
мутацию, убедиться `git diff --exit-code -- benchmark/`.

- [ ] **Step 2: заменить корпуса и тела**

Заменить всё, что строит и меряет, на одну реализацию на сторону. Константы
корпусов:

```dart
const _plainLine = 'an ordinary line of an ordinary log, no codes';
const _insertLine = '\x1B[1m\x1B[31mtag\x1B[22m\x1B[39m '
    'a sentence of ordinary words to insert into';

/// A slice corpus line carrying its own number.
///
/// The number is what makes the digest positional: a walk that answers
/// every question from the wrong offset changes it. A corpus of identical
/// lines cannot tell the difference, and this one was identical until now.
/// Three digits keep the plain width equal on both sides, 400 and 800.
String _sliceLine(int i) => '\x1B[1m\x1B[31mtag\x1B[22m\x1B[39m '
    'a sentence of ordinary words to slice, no. '
    '${i.toString().padLeft(3, '0')}';

String _parsePage(int lines) =>
    List.filled(lines, '\x1B[31m$_plainLine\x1B[0m').join('\n');

String _stackPage(int runs) => '\x1B[31mfoo\x1B[32mbar' * runs;
```

Тела — ровно те, что меряются, и ничего кроме:

```dart
List<String> Function() _parseRun(int lines) {
  final page = _parsePage(lines);
  return () => [Parser(page).removeAll()];
}

List<String> Function() _sliceRun(int lines) {
  final page = [for (var i = 0; i < lines; i++) _sliceLine(i)].join('\n');
  final parser = Parser(page)..prepare();
  final width = Parser(_sliceLine(0)).length;
  return () => [
        for (var i = 0; i < lines; i++)
          parser.substring(i * (width + 1), maxLength: width),
      ];
}

StackedParser Function() _stackRun(int runs) {
  final page = _stackPage(runs);
  return () => StackedParser(page)..finalState;
}

List<String> Function() _insertRun(int lines, {required bool shared}) {
  final page = List.filled(lines, _insertLine).join('\n');
  final width = Parser(_insertLine).length;
  return () {
    final reused = shared ? Parser(page) : null;
    return [
      for (var i = 0; i < lines; i++)
        (reused ?? Parser(page)).insertAfter(i * (width + 1), '@'),
    ];
  };
}
```

Наблюдения — вне таймера:

```dart
String _observeStrings(Object produced) {
  final strings = produced as List<String>;
  final total = strings.fold<int>(0, (sum, s) => sum + s.length);
  return '${strings.length}|$total|${_fnv1a32(strings)}';
}

String _observeStack(Object produced) {
  final parsed = produced as StackedParser;
  final colors = <String>[];
  var state = parsed.finalState;
  colors.add('${state.foregroundColor}');
  for (var i = 0; i < 6; i++) {
    state = state.resetForeground;
    colors.add('${state.foregroundColor}');
  }
  return '${parsed.length}|${colors.join(',')}';
}
```

- [ ] **Step 3: описать стороны снятыми значениями**

Значения сняты пробником на `e29c0e1`. Не выводить их заново рассуждением;
расхождение объяснять, а не подгонять.

```dart
const _parseSmallWitness = '1|91999|a20a9a76';
const _parseLargeWitness = '1|183999|f0470cb6';
const _sliceSmallWitness = '400|24400|b8dc6f45';
const _sliceLargeWitness = '800|48800|b21d4625';
const _stackSmallWitness = '24000|Color16.green,Color16.red,Color16.green,'
    'Color16.red,Color16.green,Color16.red,Color16.green';
const _stackLargeWitness = '48000|Color16.green,Color16.red,Color16.green,'
    'Color16.red,Color16.green,Color16.red,Color16.green';
// Обе стороны insert обязаны дать одно и то же: разделяемый и свежий
// парсеры отвечают одинаково, разница только в проделанной работе.
const _insertWitness = '200|2680000|1dddfc15';
```

Батчи и число строк остаются прежними: `_parseBatch = 20`, `_sliceBatch = 100`,
`_stackBatch = 4`, `_sharedInsertBatch = 20`, `_freshInsertBatch = 2`,
`_insertLines = 200`. Slice-сторона `_sliceLine(0)` даёт ширину 50 на обеих
сторонах — проверено пробником для индексов 0 и 799.

- [ ] **Step 4: собрать сценарий вокруг наблюдения**

```dart
final class _Side {
  const _Side({
    required this.label,
    required this.batch,
    required this.run,
    required this.observe,
    required this.expected,
  });

  /// How this side reads in the output: '800 lines', 'fresh parser'.
  final String label;

  /// Logical runs inside one timed sample.
  final int batch;

  /// The only implementation of this side's work. This is what is timed,
  /// and this is what the observation reads — they cannot drift, because
  /// there is nothing to drift from.
  final Object Function() run;

  /// Renders a result of [run] to a comparable string. Never timed.
  final String Function(Object) observe;

  /// What [observe] must say, taken from a live probe.
  final String expected;
}

/// Runs [side] once and answers whether it produced what it must.
///
/// Called before the timing series and again after it. The second call is
/// not ceremony: a body that does its work once and then answers from a
/// cache would pass a single check and time almost nothing afterwards.
bool _observed(
  String name,
  _Side side,
  String when,
  List<String> failures,
) {
  final String witness;
  try {
    witness = side.observe(side.run());
  } on Object catch (error) {
    failures.add('$name ${side.label} $when: observation failed: $error');
    return false;
  }
  if (witness != side.expected) {
    failures.add(
      '$name ${side.label} $when: expected ${side.expected}, got $witness',
    );
    return false;
  }
  return true;
}
```

`_runScenario` принимает `name`, `first`, `second`, `band`, `inBand`,
`failures` и идёт по порядку: наблюдение обеих сторон «before» → серия замеров
→ наблюдение обеих сторон «after» → `pairedRatios` → полоса. Любой неуспех
наблюдения прекращает сценарий, но **не процесс**: отказы копятся и печатаются
в конце, `exitCode = 1` ставится один раз. Печать:

```dart
  stdout.writeln(
    '$name: ${first.label} median ${firstMedian.toStringAsFixed(1)} us/run, '
    '${second.label} median ${secondMedian.toStringAsFixed(1)} us/run; '
    'ratio ${ratios.median.toStringAsFixed(2)} '
    '(pairs ${ratios.min.toStringAsFixed(2)}..${ratios.max.toStringAsFixed(2)}); '
    'band $band',
  );
```

Медианы сторон печатаются справочно — считать их отдельной сортировкой
допустимо, полосе они не предъявляются.

`_measureScenario` сохраняет прогрев (по одному замеру на сторону до серии) и
чередование пар, но возвращает **два списка образцов**, а не две медианы:

```dart
(List<double>, List<double>) _measureScenario(_Side first, _Side second) {
  _measurePair(first);
  _measurePair(second);

  final firstSamples = <double>[];
  final secondSamples = <double>[];
  for (var pair = 0; pair < _pairs; pair++) {
    if (pair.isEven) {
      firstSamples.add(_measurePair(first));
      secondSamples.add(_measurePair(second));
    } else {
      secondSamples.add(_measurePair(second));
      firstSamples.add(_measurePair(first));
    }
  }
  return (firstSamples, secondSamples);
}

double _measurePair(_Side side) {
  final stopwatch = Stopwatch()..start();
  for (var run = 0; run < side.batch; run++) {
    side.run();
  }
  stopwatch.stop();
  return stopwatch.elapsedMicroseconds / side.batch;
}
```

Глобальные `_sink`/`_unmeasured` и их проверка в `main` удаляются: наблюдение
делает то же самое, но по сценарию, а не по процессу. Результат `run()` в
`_measurePair` не сохраняется — работу доказывает наблюдение, а не побочный
эффект.

- [ ] **Step 5: здоровый прогон**

```bash
dart format benchmark/complexity_guard.dart
dart analyze --fatal-infos
dart run benchmark/complexity_guard.dart; echo "rc=$?"
```

Ожидание: `rc=0`, четыре строки со всеми наблюдениями сошедшимися. Отношения
рядом со снятыми пробником: parse ≈ 1.99, slice ≈ 2.00, stack ≈ 2.27,
insert ≈ 35.4. Полосы `< 2.5`, `< 2.5`, `< 3.5`, `> 24.0`.

- [ ] **Step 6: та же мутация теперь краснеет**

Снова применить мутацию Step 1 — теперь к `_parseRun`:

```dart
  return () => [Parser(page.substring(0, 100)).removeAll()];
```

```bash
dart run benchmark/complexity_guard.dart; echo "rc=$?"
```

Ожидание: `rc=1`, отказ называет `parse`, сторону и расхождение наблюдения
(`expected 1|91999|a20a9a76, got ...`). Снять мутацию, `git diff --exit-code
-- benchmark/`.

- [ ] **Step 7: коммит**

```bash
git add benchmark/complexity_guard.dart
git commit -m "fix: check the work the timer actually did" -m "The work check compared a constant with itself and the code it validated was not the code it timed, so a body measuring a hundredth of its corpus passed. One implementation per side now, read by a probe-pinned observation before the series and after it."
```

### Task 4: Доказательство калибровки

**Files:**
- Modify: нет. Мутации применяются и снимаются, дерево остаётся чистым.

**Interfaces:**
- Consumes: страж после Task 3.
- Produces: матрица доказательств для записи волны.

- [ ] **Step 1: двадцать чистых прогонов**

```bash
for i in $(seq 1 20); do
  dart run benchmark/complexity_guard.dart > /tmp/cg-clean-$i.txt 2>&1 || echo "RED on run $i"
done
grep -h '^insert' /tmp/cg-clean-*.txt | sed 's/.*ratio //'
```

Ожидание: ни одного `RED`, двадцать нулевых кодов возврата. Сохранить разброс
отношений по каждому сценарию.

- [ ] **Step 2: двадцать прогонов под нагрузкой**

Нагрузка поднимается до запуска и снимается после; воркеров — по одному на
физическое ядро минус одно:

```bash
CORES=$(sysctl -n hw.physicalcpu)
for i in $(seq 1 20); do
  for w in $(seq 1 $((CORES - 1))); do (while :; do :; done) & done
  LOAD=$(jobs -p)
  dart run benchmark/complexity_guard.dart > /tmp/cg-load-$i.txt 2>&1 || echo "RED on run $i"
  kill $LOAD 2>/dev/null
  wait 2>/dev/null
done
```

Ожидание: ни одного `RED`. Если красный есть — **не расширять полосу**:
увеличить корпус, батч или `_pairs`, после чего повторить Step 1 и Step 2
целиком и заново прогнать Step 3.

- [ ] **Step 3: шесть обратных мутаций**

Каждая применяется и снимается по одной; между ними `git diff --exit-code`
обязан быть чистым. Красный обязан называть ту полосу или то наблюдение, ради
которых мутация внесена.

| # | мутация | где | что краснеет |
|---|---|---|---|
| 1 | `removeAll` возвращает вход | `lib/src/parsing/parser/parser.dart` | наблюдение parse |
| 2 | цикл срезов возвращает `<String>[]` | `benchmark/complexity_guard.dart`, `_sliceRun` | наблюдение slice |
| 3 | `Stack._copyWith` клонирует хвост кадра foreground | `lib/src/parsing/state/stack.dart` | отношение stack ≥ 3.5 |
| 4 | `_ParserBase._pieceAt` всегда начинает новый `_Walk` | `lib/src/parsing/parser/parser.dart` | отношение insert ≤ 24.0 |
| 5 | убрать переигрывание `Pieces._parsed` и перенос `_walk` | `lib/src/parsing/parser/pieces/pieces.dart` | отношение insert ≤ 24.0 |
| 6 | `_parseRun` меряет `page.substring(0, 100)` | `benchmark/complexity_guard.dart` | наблюдение parse |

Для (3) добавить временный `_cloneFrames(_Frame<T>? top)` и подменить только
переносимый хвост foreground: ответы сохраняются, квадратичная работа
возвращается — то есть семантика зелёная, а полоса красная. Для (4) заменить
только ветвь возобновления прямого обхода. Для (5) дополнительно создавать
новый `_ParserIterator` вместо переигрывания `_parsed`.

Восстановление — обратной правкой, не `git checkout`: исполнитель обязан знать,
что именно менял.

- [ ] **Step 4: записать матрицу**

Матрица (сорок здоровых прогонов, шесть мутаций, разбросы отношений) идёт в
финальную запись волны Task 5. Коммита этот шаг не делает.

### Task 5: Документация, ревью, CI, мерж

**Files:**
- Modify: `AGENTS.md`
- Modify: `docs/architecture.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/handoff.md`
- Create: `docs/records/2026-08-16[4]-complexity-guard-report.md`

**Interfaces:**
- Consumes: закрытые Task 2–4 и фактические прогоны.
- Produces: точка рестарта без невыполненных обещаний.

- [ ] **Step 1: документация**

`AGENTS.md`, пункт про `complexity_guard.dart`: сказать, что страж проверяет
наблюдение произведённой работы до серии замеров и после неё и предъявляет
полосе медиану попарных отношений. `docs/architecture.md`, guard 4: то же,
плюс почему попарность важна. `CHANGELOG.md` — английская строка в блоке
`Verification:` под существующим `## 4.0.0`, без бампа версии.

- [ ] **Step 2: полные ворота**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
dart run tool/generate.dart && git diff --exit-code -- lib/
dart test
dart run benchmark/memory_guard.dart
dart run benchmark/complexity_guard.dart
dart doc --dry-run
dart pub publish --dry-run
```

Записать фактическое число тестов, вывод обоих стражей и ноль предупреждений
publish. Не называть ворота зелёными без вывода каждой команды.

- [ ] **Step 3: ревью всей ветки**

Ревью полного диффа `main...HEAD`: проверить, что якорь и таймер физически
неразделимы, что ни одно ожидание не выведено рассуждением, что матрица Task 4
воспроизводится. Реальные находки починить, затронутые тесты и полный набор
прогнать заново.

```bash
git add AGENTS.md docs/architecture.md CHANGELOG.md
git commit -m "docs: describe what the complexity guard now proves" -m "A guard that cannot be trusted to have measured anything is worth describing precisely once it can."
```

- [ ] **Step 4: CI, мерж, запись волны**

```bash
git push -u origin fix/complexity-guard
gh run list --branch fix/complexity-guard --limit 5
```

Мержить только после зелёной матрицы `3.6.0`/`stable`:

```bash
git checkout main
git merge --no-ff fix/complexity-guard
git push origin main
gh run list --branch main --limit 5
```

Затем: `docs/handoff.md` уезжает в
`docs/records/2026-08-16[4]-complexity-guard-report.md` с шапкой новой формы,
а `docs/handoff.md` переписывается под состояние после мержа — с фактическими
воротами, ID прогонов CI и матрицей калибровки. Ветку и worktree удалить.

## Self-review плана

- **Покрытие спеки.** Дефект 1 (тавтологичный счётчик) — Task 3 Steps 1–7;
  дефект 2 (параллельные реализации) — Task 3 Step 2; дефект 3 (независимые
  медианы) — Task 2 целиком; дефект 4 (непозиционный корпус slice) — Task 3
  Step 2, `_sliceLine`; дефект 5 (глобальный `_sink`) — Task 3 Step 4.
  Доказательство калибровки — Task 4. Документация, ревью, CI, запись — Task 5.
- **Плейсхолдеров нет:** все константы наблюдений сняты пробником и выписаны;
  весь код, который нужно написать, приведён; мутации названы файлами и
  символами, существование которых проверено по `lib/`.
- **Согласованность имён:** `pairedRatios` и `PairedRatios` определены в
  Task 2 и используются в Task 3; `_Side` с полями `label`, `batch`, `run`,
  `observe`, `expected` определён в Task 3 Step 4 и используется в Steps 3, 5.
  `_measurePair` принимает `_Side`, а не пару «тело + число прогонов», как в
  прежней версии файла.
- **Чего план сознательно не делает:** не трогает полосы, `_pairs`, CI-шаг,
  `.pubignore` и `test/performance_guards_test.dart`; не заводит no-arg тест
  стража (отклонение согласовано владельцем 2026-08-15).
