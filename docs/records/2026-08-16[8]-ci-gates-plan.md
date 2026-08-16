> **Состояние на 2026-08-16:** план написан, работа не начата.
> **Что это:** план работ по спеке волны 6 — восемь правок в проверяющем
> контуре, разложенные на шесть заданий с TDD-циклом в каждом.
> **Связанные записи:** `2026-08-16[7]-ci-gates-design.md` (спека),
> `2026-08-16[5]-project-review.md` (откуда находки).

# План волны 6: закрыть дыры в проверяющем контуре

> **Исполнителю:** задания идут по порядку, каждое кончается коммитом.
> Шаги отмечены чекбоксами. Ожидаемые значения в этом плане **сняты
> пробником с живого кода** — если шаг «убедиться, что тест падает» даёт
> не то, что здесь написано, это находка, а не повод подогнать ожидание.

**Цель:** починить восемь мест, где проверка может не состояться молча.

**Устройство:** два новых инструмента в `tool/` по образцу
`check_entry_points.dart` (тонкий CLI + чистая логика в `tool/src/`,
которую зовёт тест напрямую) и шесть правок в конфигах CI.

**Стек:** Dart 3.6.0+, `package:test`, GitHub Actions. Новых зависимостей
волна не добавляет.

**Спека:** `docs/records/2026-08-16[7]-ci-gates-design.md`

## Общие ограничения

Действуют в каждом задании, повторять в шагах не буду:

- **Ветка `fix/ci-gates`.** Префикс `fix/**` входит в нынешний allow-list,
  так что CI проверяет заход с первого пуша.
- **`lib/` волна не трогает вообще.** `generate.dart`, `memory_guard` и
  `complexity_guard` обязаны остаться на прежних числах. Их движение —
  сигнал, что работа вышла за границы.
- **Версию не бампать**, `pubspec.yaml` правится только в части
  зависимостей и только там, где сказано.
- **Языки:** дартдок, комментарии в `lib/`, `tool/`, `.github/` и тексты
  ошибок — **по-английски**; `docs/` и `AGENTS.md` — по-русски.
- **Коммиты:** один пункт — один коммит, conventional-префикс, тело
  повествовательное по-английски, про «почему», а не «что». Писать через
  `git commit -F -` с закавыченным heredoc (`<<'EOF'`) — при `-m "..."`
  шелл съедает обратные кавычки, на этом уже потерялось слово в `751dab2`.
- **В индекс — только своё, поимённо.** `git add -A` не использовать.
- Ворота перед каждым коммитом: `dart format --output=none
  --set-exit-if-changed .` и `dart analyze --fatal-infos`.

---

## Задание 1: M11 — триггер, который закрывается, а не открывается

**Файлы:**
- Правка: `.github/workflows/dart.yml:8-18`

**Что даёт дальше:** ничего в коде; следующим заданиям не нужен.

- [ ] **Шаг 1: заменить allow-list на deny-list**

В `.github/workflows/dart.yml` блок `on:` целиком (строки 8-18) заменить
на:

```yaml
on:
  # Every branch but dependabot's, so that the gate stands before `main`
  # and not after it. A wave is verified locally on one SDK; the 3.6.0 leg
  # of the matrix is the floor the package claims to support and nothing
  # local runs it, so a branch that reaches `main` unchecked takes a red
  # there with it.
  #
  # A deny-list rather than the allow-list this was: an allow-list opens
  # outwards. It held `main`, `feat/**`, `fix/**` and `perf/**`, and a
  # branch named anything else — `docs/`, `chore/`, `test/` — ran no CI at
  # all and read as if it had. The one exclusion has its own reason:
  # dependabot's branches arrive with a pull request and would otherwise
  # be built twice.
  push:
    branches-ignore: [ "dependabot/**" ]
  pull_request:
    branches: [ "main" ]
```

- [ ] **Шаг 2: проверить, что YAML разобрался**

```bash
python3 -c "import yaml,sys; d=yaml.safe_load(open('.github/workflows/dart.yml')); print(d['on'])"
```

Ожидается: `{'push': {'branches-ignore': ['dependabot/**']}, 'pull_request': {'branches': ['main']}}`

Ключ `on` YAML разбирает как булево `True` в некоторых загрузчиках; если
печать даёт `KeyError`, взять `d[True]` — это особенность загрузчика, а не
дефект файла.

- [ ] **Шаг 3: коммит**

```bash
git add .github/workflows/dart.yml
git commit -F - <<'EOF'
ci: check every branch that is not dependabot's

The trigger was an allow-list of four prefixes, and an allow-list opens
outwards: a branch named docs/ or chore/ ran no CI over its whole life,
and the first thing to see it was a push to main with the red already in
it. The floor leg of the matrix, SDK 3.6.0, is the part that makes this
expensive — nothing local runs it, so green gates on a machine say
nothing about it.

Inverted to a deny-list, so the unfamiliar is checked rather than waved
through. The single exclusion keeps the reason the old comment gave for
naming prefixes at all: dependabot's branches arrive with a pull request,
and building them on push as well would build them twice.
EOF
```

---

## Задание 2: пол coverage переезжает из awk в инструмент

Поведение не меняется. Это подготовка: пол должен считаться кодом, который
можно позвать из теста, прежде чем к нему добавится третий оракул.

**Отступление от спеки, намеренное.** Спека отводила M12 один коммит;
план делит его на два — этот и следующий. Причина в правиле «один фикс —
один коммит»: переезд пола из awk в инструмент ничего не чинит и ничего
не меняет в поведении, а находка M12 — это только третий оракул. Слитые в
один коммит, они читались бы как одна правка, и рефакторинг прятал бы
новые ворота.

**Файлы:**
- Создать: `tool/src/coverage_report.dart`
- Создать: `tool/check_coverage.dart`
- Создать: `test/tool/check_coverage_test.dart`
- Правка: `.github/workflows/dart.yml` — шаг «Check hand-written lib
  coverage holds its floor» (строки 114-150)

**Что даёт дальше:** задание 3 дополняет `tool/src/coverage_report.dart`
функцией `checkReportedFiles` и константой
`librariesWithoutExecutableLines`; сигнатуры — там же.

- [ ] **Шаг 1: написать падающий тест на разбор и пол**

Создать `test/tool/check_coverage_test.dart`:

```dart
import 'package:test/test.dart';

import '../../tool/src/coverage_report.dart';

const _root = '/pkg';

String _record(String path, List<(int, int)> lines) {
  final hit = lines.where((line) => line.$2 != 0).length;
  return [
    'SF:$_root/$path',
    for (final (number, count) in lines) 'DA:$number,$count',
    'LF:${lines.length}',
    'LH:$hit',
    'end_of_record',
  ].join('\n');
}

void main() {
  group('lcov parsing', () {
    test('keys records by a path relative to the package root', () {
      final files = parseLcov(
        _record('lib/a.dart', [(1, 1), (2, 0)]),
        root: _root,
      );

      expect(files, hasLength(1));
      expect(files.single.path, 'lib/a.dart');
      expect(files.single.found, 2);
      expect(files.single.hit, 1);
      expect(files.single.daFound, 2);
      expect(files.single.daHit, 1);
    });

    test('reads every record of a report, not only the first', () {
      final files = parseLcov(
        [
          _record('lib/a.dart', [(1, 1)]),
          _record('lib/b.dart', [(1, 0), (2, 3)]),
        ].join('\n'),
        root: _root,
      );

      expect(files.map((file) => file.path), ['lib/a.dart', 'lib/b.dart']);
      expect(files.last.hit, 1);
    });
  });

  group('lcov consistency', () {
    test('passes a report whose summaries match its records', () {
      final files = parseLcov(
        _record('lib/a.dart', [(1, 1), (2, 0)]),
        root: _root,
      );

      expect(checkLcovConsistency(files), isNull);
    });

    test('catches a summary that disagrees with the records under it', () {
      final files = parseLcov(
        'SF:$_root/lib/a.dart\n'
        'DA:1,1\n'
        'DA:2,0\n'
        'LF:9\n'
        'LH:9\n'
        'end_of_record',
        root: _root,
      );

      final diagnostic = checkLcovConsistency(files);

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('lib/a.dart'));
      expect(diagnostic, contains('9'));
    });
  });

  group('coverage floor', () {
    test('passes coverage standing on the floor exactly', () {
      final files = parseLcov(
        _record('lib/a.dart', [(1, 1), (2, 1), (3, 1), (4, 0)]),
        root: _root,
      );

      expect(checkCoverageFloor(files, 75), isNull);
    });

    test('catches coverage a hair under the floor', () {
      final files = parseLcov(
        _record('lib/a.dart', [(1, 1), (2, 1), (3, 1), (4, 0)]),
        root: _root,
      );

      final diagnostic = checkCoverageFloor(files, 75.001);

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('75.000%'));
    });

    test('catches a report that counted nothing at all', () {
      expect(
        checkCoverageFloor(const [], 95),
        'the report counted no lines at all',
      );
    });
  });
}
```

- [ ] **Шаг 2: убедиться, что тест падает**

```bash
dart test test/tool/check_coverage_test.dart
```

Ожидается: провал компиляции — `Error when reading
'tool/src/coverage_report.dart': No such file or directory`.

- [ ] **Шаг 3: написать `tool/src/coverage_report.dart`**

```dart
import 'dart:convert';

/// One `SF:` record of an lcov report: its file and its line counts.
///
/// [found] and [hit] are the report's own `LF:` and `LH:` summaries;
/// [daFound] and [daHit] are the same two numbers counted from the `DA:`
/// records beneath them. A report whose summaries disagree with its own
/// records is not one to measure a floor against, so the two are carried
/// apart and held against each other.
typedef LcovFile = ({
  String path,
  int found,
  int hit,
  int daFound,
  int daHit,
});

/// Parses [lcov], returning one record per file with paths as they read
/// from [root].
///
/// `format_coverage` writes absolute paths, so every path is made relative
/// to [root] and separators are normalised to `/`; a report collected on
/// Windows otherwise compares against nothing.
List<LcovFile> parseLcov(String lcov, {required String root}) {
  final prefix = '${_normalize(root)}/';
  final files = <LcovFile>[];
  String? path;
  var found = 0;
  var hit = 0;
  var daFound = 0;
  var daHit = 0;

  void flush() {
    if (path == null) {
      return;
    }
    files.add((
      path: path!,
      found: found,
      hit: hit,
      daFound: daFound,
      daHit: daHit,
    ));
    path = null;
    found = 0;
    hit = 0;
    daFound = 0;
    daHit = 0;
  }

  for (final line in const LineSplitter().convert(lcov)) {
    if (line.startsWith('SF:')) {
      flush();
      final source = _normalize(line.substring(3));
      path = source.startsWith(prefix) ? source.substring(prefix.length) : source;
    } else if (line.startsWith('LF:')) {
      found += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      hit += int.parse(line.substring(3));
    } else if (line.startsWith('DA:')) {
      final counts = line.substring(3).split(',');
      daFound++;
      if (counts.length > 1 && int.parse(counts[1]) != 0) {
        daHit++;
      }
    } else if (line == 'end_of_record') {
      flush();
    }
  }
  flush();

  return files;
}

/// Holds each file's `LF:`/`LH:` summaries to its own `DA:` records,
/// returning a diagnostic when they disagree.
String? checkLcovConsistency(List<LcovFile> files) {
  final diagnostics = <String>[];
  for (final file in files) {
    if (file.found != file.daFound || file.hit != file.daHit) {
      diagnostics.add(
        '${file.path}: the summary says ${file.hit} of ${file.found} lines, '
        'the records say ${file.daHit} of ${file.daFound}',
      );
    }
  }

  return diagnostics.isEmpty ? null : diagnostics.join('\n');
}

/// What [files] cover, as a percentage and the counts behind it.
({double percent, int hit, int found}) coverageOf(List<LcovFile> files) {
  var found = 0;
  var hit = 0;
  for (final file in files) {
    found += file.found;
    hit += file.hit;
  }

  return (percent: found == 0 ? 0 : 100 * hit / found, hit: hit, found: found);
}

/// Holds the coverage of [files] to [floor] percent, returning a
/// diagnostic when it falls through.
String? checkCoverageFloor(List<LcovFile> files, double floor) {
  final coverage = coverageOf(files);
  if (coverage.found == 0) {
    return 'the report counted no lines at all';
  }
  if (coverage.percent >= floor) {
    return null;
  }

  // Three decimals, not one: the boundary is where this does its work, and
  // one decimal prints the same "95.0%" for the run that passes and the run
  // just under it that does not.
  return 'the coverage has fallen through the floor: '
      '${coverage.percent.toStringAsFixed(3)}% '
      '(${coverage.hit} of ${coverage.found} lines), '
      'floor ${floor.toStringAsFixed(1)}%';
}

String _normalize(String path) {
  final slashed = path.replaceAll(r'\', '/');

  return slashed.endsWith('/')
      ? slashed.substring(0, slashed.length - 1)
      : slashed;
}
```

- [ ] **Шаг 4: убедиться, что тест проходит**

```bash
dart test test/tool/check_coverage_test.dart
```

Ожидается: все 7 тестов зелёные.

- [ ] **Шаг 5: написать CLI `tool/check_coverage.dart`**

```dart
/// Holds a collected coverage report to two answers: its summaries agree
/// with its own records, and the hand-written part of `lib/` covers at
/// least the floor.
///
/// The report comes from `dart test --coverage` put through
/// `coverage:format_coverage`; the workflow writes both the full report and
/// the gated one, which leaves out the generated `style_colors.dart`.
///
///     dart run tool/check_coverage.dart
///
import 'dart:io';

import 'src/coverage_report.dart';

// The same shape as tool/check_entry_points.dart: the native separator,
// resolved once.
final _sep = Platform.pathSeparator;

void main(List<String> args) {
  exitCode = runCoverageCheck(args, root: _packageRoot());
}

/// Runs the coverage checks under [root].
int runCoverageCheck(List<String> args, {required String root}) {
  var gated = 'coverage/lcov.gated.info';
  var floor = 95.0;

  for (final arg in args) {
    if (arg.startsWith('--gated=')) {
      gated = arg.substring('--gated='.length);
    } else if (arg.startsWith('--floor=')) {
      final value = double.tryParse(arg.substring('--floor='.length));
      if (value == null) {
        stderr.writeln('not a number: $arg');
        return 2;
      }
      floor = value;
    } else {
      stderr.writeln(
        'Usage: dart run tool/check_coverage.dart '
        '[--gated=<lcov>] [--floor=<percent>]',
      );
      return 2;
    }
  }

  final gatedFile = File('$root$_sep$gated');
  if (!gatedFile.existsSync()) {
    stderr.writeln('no report at $gated');
    return 2;
  }

  final files = parseLcov(gatedFile.readAsStringSync(), root: root);
  // Written out rather than as null-aware elements in a list literal:
  // those arrived in Dart 3.8 and this package's floor is 3.6.0, so the
  // floor leg of the matrix would not compile them.
  final diagnostics = <String>[];
  final consistency = checkLcovConsistency(files);
  if (consistency != null) {
    diagnostics.add(consistency);
  }
  final floorDiagnostic = checkCoverageFloor(files, floor);
  if (floorDiagnostic != null) {
    diagnostics.add(floorDiagnostic);
  }
  if (diagnostics.isNotEmpty) {
    diagnostics.forEach(stderr.writeln);
    return 1;
  }

  final coverage = coverageOf(files);
  stdout.writeln(
    'coverage of hand-written lib/: '
    '${coverage.percent.toStringAsFixed(3)}% '
    '(${coverage.hit} of ${coverage.found} lines), '
    'floor ${floor.toStringAsFixed(1)}%',
  );

  return 0;
}

/// The package root: the directory holding the `tool/` this script runs
/// from, so that the check reads the same tree whatever the cwd.
String _packageRoot() {
  final script = File.fromUri(Platform.script).absolute.path;
  final tool = script.lastIndexOf('${_sep}tool$_sep');

  return tool == -1
      ? Directory.current.absolute.path
      : script.substring(0, tool);
}
```

- [ ] **Шаг 6: проверить CLI на живом отчёте**

```bash
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.gated.info \
  --report-on=lib --ignore-files='**/style_colors.dart'
dart run tool/check_coverage.dart
```

Ожидается на `deca8ca`, ровно эта строка и код возврата 0:

```
coverage of hand-written lib/: 97.529% (2447 of 2509 lines), floor 95.0%
```

Число снято пробником 2026-08-16. Если оно другое — это не повод править
план: значит покрытие сдвинулось между заходами, и надо сверить, что
сдвиг объясним.

- [ ] **Шаг 7: заменить awk-блок в workflow**

Шаг «Check hand-written lib coverage holds its floor» (строки 114-150)
заменить целиком на:

```yaml
      - name: Check hand-written lib coverage holds its floor
        if: matrix.sdk == 'stable'
        # style_colors.dart is generated code. Keep it in the full artifact
        # for diagnosis, but permanently exclude it from this gate.
        run: dart run tool/check_coverage.dart
```

- [ ] **Шаг 8: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test test/tool/check_coverage_test.dart
git add tool/src/coverage_report.dart tool/check_coverage.dart \
  test/tool/check_coverage_test.dart .github/workflows/dart.yml
git commit -F - <<'EOF'
ci: give the coverage floor a body a test can call

The floor lived as an awk program inside the workflow, which is the one
place in this repository where checking code is itself unchecked: nothing
runs it but a push, and nothing holds it to anything. It also has a
successor coming — the report needs to be held to the files it should
contain, and that is not an awk-sized answer.

Moved to tool/check_coverage.dart with the arithmetic in tool/src, where
the tests reach it directly. Behaviour is deliberately unchanged, down to
the three decimals the old program printed: one decimal shows the same
"95.0%" for the run that passes and the run just under it that does not.
EOF
```

---

## Задание 3: M12 — отчёт держат к файлам, которые в нём должны быть

**Файлы:**
- Правка: `tool/src/coverage_report.dart` — добавить константу и функцию
- Правка: `tool/check_coverage.dart` — третий оракул и аргумент `--full`
- Правка: `test/tool/check_coverage_test.dart` — новая группа
- Правка: `.github/workflows/dart.yml` — передать полный отчёт
- Правка: `AGENTS.md` — строка в списке ворот

**Что берёт из задания 2:** `parseLcov`, `LcovFile`.

- [ ] **Шаг 1: написать падающий тест на три оракула**

Дописать в `test/tool/check_coverage_test.dart` перед закрывающей скобкой
`main`:

```dart
  group('report completeness', () {
    test('passes a report holding every file that has code', () {
      expect(
        checkReportedFiles(
          reported: const ['lib/a.dart', 'lib/b.dart'],
          onDisk: const ['lib/a.dart', 'lib/b.dart', 'lib/barrel.dart'],
          exempt: const ['lib/barrel.dart'],
        ),
        isNull,
      );
    });

    test('catches a library that no test loaded', () {
      final diagnostic = checkReportedFiles(
        reported: const ['lib/a.dart'],
        onDisk: const ['lib/a.dart', 'lib/lonely.dart'],
        exempt: const [],
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('lib/lonely.dart'));
      expect(diagnostic, contains('absent from the report'));
    });

    test('catches a record for a file the tree no longer has', () {
      final diagnostic = checkReportedFiles(
        reported: const ['lib/a.dart', 'lib/gone.dart'],
        onDisk: const ['lib/a.dart'],
        exempt: const [],
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('lib/gone.dart'));
      expect(diagnostic, contains('not on disk'));
    });

    test('catches an exemption for a file the tree no longer has', () {
      final diagnostic = checkReportedFiles(
        reported: const ['lib/a.dart'],
        onDisk: const ['lib/a.dart'],
        exempt: const ['lib/gone.dart'],
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('lib/gone.dart'));
      expect(diagnostic, contains('exempted'));
    });

    test('catches an exemption for a file that has grown code', () {
      // The half that makes the exemption self-expiring: without it the
      // list would be the same blind spot this gate exists to close.
      final diagnostic = checkReportedFiles(
        reported: const ['lib/a.dart', 'lib/barrel.dart'],
        onDisk: const ['lib/a.dart', 'lib/barrel.dart'],
        exempt: const ['lib/barrel.dart'],
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('lib/barrel.dart'));
      expect(diagnostic, contains('present in the report'));
    });

    test('reports every disagreement at once, sorted', () {
      final diagnostic = checkReportedFiles(
        reported: const ['lib/z.dart'],
        onDisk: const ['lib/a.dart'],
        exempt: const [],
      );

      expect(
        diagnostic!.split('\n'),
        [
          'on disk but absent from the report: lib/a.dart',
          'reported but not on disk: lib/z.dart',
        ],
      );
    });

    test('the exemption list names the files that have no code', () {
      // Pinned, so that a file quietly joining or leaving the list is a
      // decision and not a drift. The fifteen were probed on deca8ca.
      expect(librariesWithoutExecutableLines, hasLength(15));
      expect(librariesWithoutExecutableLines, contains('lib/ansi.dart'));
      expect(
        librariesWithoutExecutableLines,
        contains('lib/src/parsing/state/styles.dart'),
      );
      expect(
        librariesWithoutExecutableLines,
        List<String>.from(librariesWithoutExecutableLines)..sort(),
        reason: 'the list is kept sorted so a diff to it reads',
      );
    });
  });
```

- [ ] **Шаг 2: убедиться, что тест падает**

```bash
dart test test/tool/check_coverage_test.dart
```

Ожидается: провал компиляции — `Undefined name 'checkReportedFiles'` и
`Undefined name 'librariesWithoutExecutableLines'`.

- [ ] **Шаг 3: дописать `tool/src/coverage_report.dart`**

Добавить в конец файла, перед `String _normalize`:

```dart
/// The files under `lib/` that hold no executable line, and so leave no
/// record in a coverage report however thoroughly they are used.
///
/// A file appears in the report if and only if it has a line to execute:
/// neither `part of` nor living under `lib/src/` changes that — 20 of the
/// 21 part files in this package are reported, and the one that is not is
/// the one holding only constants.
///
/// Kept sorted, and held by [checkReportedFiles] to still being absent:
/// the moment one of these grows a line of code it starts being reported,
/// and an exemption nobody revisits would be the same blind spot this
/// gate exists to close.
const librariesWithoutExecutableLines = <String>[
  // The five entry points: `export` directives and nothing else.
  'lib/ansi.dart',
  'lib/ansi_escape_codes.dart',
  'lib/extensions.dart',
  'lib/style.dart',
  'lib/utils.dart',
  // The C0/C1/CSI/SGR names and the colour tables: `const String` only.
  'lib/src/ansi/c0.dart',
  'lib/src/ansi/c1.dart',
  'lib/src/ansi/colors.dart',
  'lib/src/ansi/csi.dart',
  'lib/src/ansi/esc_fs.dart',
  'lib/src/ansi/sgr.dart',
  // The ready-made sequences and styles: `const` again, one a part file.
  'lib/src/parsing/state/styles.dart',
  'lib/src/ready_to_use/esc.dart',
  'lib/src/ready_to_use/sgr/sgr.dart',
  'lib/src/ready_to_use/sgr/standard_colors/standard_colors.dart',
];

/// Holds the report's file set against the tree, returning a diagnostic
/// when they disagree.
///
/// `format_coverage --report-on=lib` builds its report from the hitmap of
/// the run, so a library no test ever loaded leaves no record at all. It
/// does not read as nought per cent — it reads as absent, and a floor
/// measured over what is present cannot see it. Three answers close that:
/// everything reported is on disk, everything on disk is reported or
/// exempted, and everything exempted is on disk and still unreported.
String? checkReportedFiles({
  required Iterable<String> reported,
  required Iterable<String> onDisk,
  required Iterable<String> exempt,
}) {
  final reportedSet = reported.toSet();
  final onDiskSet = onDisk.toSet();
  final exemptSet = exempt.toSet();
  final diagnostics = <String>[];

  for (final path in (reportedSet.difference(onDiskSet).toList()..sort())) {
    diagnostics.add('reported but not on disk: $path');
  }
  for (final path in (onDiskSet
      .difference(reportedSet)
      .difference(exemptSet)
      .toList()
    ..sort())) {
    diagnostics.add('on disk but absent from the report: $path');
  }
  for (final path in (exemptSet.difference(onDiskSet).toList()..sort())) {
    diagnostics.add('exempted but not on disk: $path');
  }
  for (final path
      in (exemptSet.intersection(reportedSet).toList()..sort())) {
    diagnostics.add('exempted but present in the report: $path');
  }

  return diagnostics.isEmpty ? null : (diagnostics..sort()).join('\n');
}
```

- [ ] **Шаг 4: убедиться, что тест проходит**

```bash
dart test test/tool/check_coverage_test.dart
```

Ожидается: 14 тестов зелёные.

- [ ] **Шаг 5: подключить третий оракул в CLI**

Три правки в `tool/check_coverage.dart`.

**Первая** — объявить путь полного отчёта рядом с `gated`:

```dart
  var full = 'coverage/lcov.info';
  var gated = 'coverage/lcov.gated.info';
```

**Вторая** — разобрать его аргумент; ветку добавить **перед** веткой
`--gated=`, иначе она никогда не сработает:

```dart
    if (arg.startsWith('--full=')) {
      full = arg.substring('--full='.length);
    } else if (arg.startsWith('--gated=')) {
```

и дополнить строку usage:

```dart
        'Usage: dart run tool/check_coverage.dart '
        '[--full=<lcov>] [--gated=<lcov>] [--floor=<percent>]',
```

**Третья** — прочитать полный отчёт и обойти `lib/`. Вставить после
чтения gated-отчёта, до сборки `diagnostics`:

```dart
  final fullFile = File('$root$_sep$full');
  if (!fullFile.existsSync()) {
    stderr.writeln('no report at $full');
    return 2;
  }
  final reported = parseLcov(fullFile.readAsStringSync(), root: root)
      .map((file) => file.path);
  // The substring comes before the separators are normalised: `root` holds
  // native ones, and cutting a normalised path by its length would slice a
  // Windows path in the wrong place.
  final onDisk = Directory('$root${_sep}lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((entity) => entity.path.endsWith('.dart'))
      .map((entity) =>
          entity.path.substring(root.length + 1).replaceAll(r'\', '/'))
      .toList();
```

и добавить в список диагностик третий вызов:

```dart
checkReportedFiles(
  reported: reported,
  onDisk: onDisk,
  exempt: librariesWithoutExecutableLines,
)
```

- [ ] **Шаг 6: проверить на живом дереве, что оракул 2 действительно ловит**

Это главный шаг задания: доказать, что ворота краснеют на том, ради чего
поставлены. Прогон на копии дерева, чтобы рабочее не пострадало:

```bash
tmp=$(mktemp -d) && git archive HEAD | tar -x -C "$tmp" && cd "$tmp"
dart pub get
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.gated.info \
  --report-on=lib --ignore-files='**/style_colors.dart'
dart run tool/check_coverage.dart ; echo "clean tree exit=$?"
printf 'int unloaded() => 1;\n' > lib/src/unloaded.dart
dart run tool/check_coverage.dart ; echo "with an unloaded library exit=$?"
```

Ожидается: первый прогон — `exit=0` и строка про 97.529 %; второй —
`exit=1` и `on disk but absent from the report: lib/src/unloaded.dart`.

Второй прогон намеренно **не пересобирает** отчёт: файл добавлен в дерево
после сбора, чего оракул и должен хватиться. Если второй прогон даёт 0 —
остановиться и разобраться, а не править ожидание.

Убрать копию: `cd - && rm -rf "$tmp"`.

- [ ] **Шаг 7: передать полный отчёт из workflow**

Шаг «Check hand-written lib coverage holds its floor» в
`.github/workflows/dart.yml` заменить на:

```yaml
      - name: Check the coverage report holds its floor and its files
        if: matrix.sdk == 'stable'
        # Two answers over the two reports the step above wrote. The floor
        # is measured over the gated report, which leaves out the generated
        # style_colors.dart; the file set is measured over the full one,
        # because a file excluded from the floor still has to be there.
        run: dart run tool/check_coverage.dart
```

- [ ] **Шаг 8: строка в списке ворот `AGENTS.md`**

В разделе «Ворота», в блоке команд, после строки про `dart test` добавить:

```bash
dart run tool/check_coverage.dart   # когда coverage собран; в CI всегда
```

и абзацем ниже, к списку пояснений про инструменты:

```markdown
- **`check_coverage.dart`** держит собранный отчёт к двум ответам: пол
  95.0 % по gated-отчёту и множество файлов по полному. Второй ответ —
  про то, что `format_coverage` строит отчёт из hitmap: библиотека,
  которую не загрузил ни один тест, не даёт записи вовсе, и пол её не
  видит. Файлы без исполняемых строк перечислены в инструменте константой,
  и она самоистекающая: как только в таком файле заводится код, ворота
  требуют убрать его из списка. Инструменту нужен собранный отчёт,
  поэтому локально он гоняется после `dart test --coverage`, а в CI —
  всегда.
```

- [ ] **Шаг 9: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test test/tool/check_coverage_test.dart
git add tool/src/coverage_report.dart tool/check_coverage.dart \
  test/tool/check_coverage_test.dart .github/workflows/dart.yml AGENTS.md
git commit -F - <<'EOF'
ci: hold the coverage report to the files it should contain

format_coverage builds its report from the hitmap of the run, so a library
no test ever loaded leaves no record in it. That does not read as nought
per cent; it reads as absent, and a floor averaged over what is present
cannot see it. The hole was described as open but empty. It is not empty:
the report carries 49 records against 64 files in lib/.

The fifteen turned out to be absent for a good reason — none of them has
an executable line, and it is code and not location that decides, since 20
of the 21 part files here are reported. So the answer could not be that
every file must appear. It is three: everything reported is on disk,
everything on disk is reported or named as codeless, and everything named
as codeless is still on disk and still unreported. The last is what keeps
the exemption list from becoming the blind spot it was written to close.
EOF
```

---

## Задание 4: L19 — два README держат к одной форме

**Файлы:**
- Создать: `tool/src/readme_structure.dart`
- Создать: `tool/check_readme_sync.dart`
- Создать: `test/tool/check_readme_sync_test.dart`
- Правка: `.github/workflows/dart.yml` — новый шаг
- Правка: `AGENTS.md` — список ворот

- [ ] **Шаг 1: написать падающий тест**

Создать `test/tool/check_readme_sync_test.dart`:

````dart
import 'package:test/test.dart';

import '../../tool/src/readme_structure.dart';

void main() {
  group('stripping a dart line comment', () {
    test('cuts a trailing comment and the space before it', () {
      expect(stripDartComment("print('a'); // says a"), "print('a');");
    });

    test('leaves a line that has no comment alone', () {
      expect(stripDartComment('final a = 1;'), 'final a = 1;');
    });

    test('empties a line that is only a comment', () {
      expect(stripDartComment('  // a note'), '');
    });

    test('keeps slashes inside a single-quoted literal', () {
      // No example in either readme has one today, which is exactly why
      // this is pinned: the first one that does must not move the gate.
      expect(
        stripDartComment("print('https://a'); // fetch"),
        "print('https://a');",
      );
    });

    test('keeps slashes inside a double-quoted literal', () {
      expect(stripDartComment('print("a//b");'), 'print("a//b");');
    });

    test('keeps slashes inside a raw literal', () {
      expect(stripDartComment(r"print(r'a\//b');"), r"print(r'a\//b');");
    });

    test('reads an escaped quote as part of the literal', () {
      expect(stripDartComment(r"print('it\'s //'); // c"), r"print('it\'s //');");
    });
  });

  group('reading the shape of a readme', () {
    const markdown = '''
# Title

Prose.

## Section

```dart
final a = 1; // one
print(a);
```

Prose again.

```
plain
```
''';

    test('takes heading levels in document order', () {
      expect(readReadmeShape(markdown).headings.map((h) => h.level), [1, 2]);
    });

    test('takes code blocks with their info strings', () {
      final blocks = readReadmeShape(markdown).blocks;

      expect(blocks.map((b) => b.info), ['dart', '']);
      expect(blocks.first.lines, ['final a = 1; // one', 'print(a);']);
    });
  });

  group('comparing two readmes', () {
    ReadmeShape shapeOf(String markdown) => readReadmeShape(markdown);

    String block(String code) => '# T\n\n```dart\n$code\n```\n';

    test('passes when only prose and comment text differ', () {
      expect(
        compareReadmeShapes(
          shapeOf('# Title\n\nHello.\n\n```dart\nfinal a = 1; // one\n```\n'),
          shapeOf('# Заголовок\n\nПривет.\n\n```dart\nfinal a = 1; // один\n```\n'),
          englishPath: 'README.md',
          translationPath: 'README.ru.md',
        ),
        isNull,
      );
    });

    test('catches code that differs under the comments', () {
      final diagnostic = compareReadmeShapes(
        shapeOf(block('final a = 1; // one')),
        shapeOf(block('final a = 2; // один')),
        englishPath: 'README.md',
        translationPath: 'README.ru.md',
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('README.md'));
      expect(diagnostic, contains('README.ru.md'));
      expect(diagnostic, contains('final a = 1;'));
      expect(diagnostic, contains('final a = 2;'));
    });

    test('catches a comment line dropped from one side', () {
      // The half that keeps shown output honest: the text of a comment is
      // translated and cannot be compared, but its presence can.
      final diagnostic = compareReadmeShapes(
        shapeOf(block('print(a);\n// a')),
        shapeOf(block('print(a);\n')),
        englishPath: 'README.md',
        translationPath: 'README.ru.md',
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('comment'));
    });

    test('catches a heading missing from the translation', () {
      final diagnostic = compareReadmeShapes(
        shapeOf('# A\n\n## B\n'),
        shapeOf('# A\n'),
        englishPath: 'README.md',
        translationPath: 'README.ru.md',
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('heading'));
    });

    test('catches a block whose language differs', () {
      final diagnostic = compareReadmeShapes(
        shapeOf('# T\n\n```dart\na\n```\n'),
        shapeOf('# T\n\n```bash\na\n```\n'),
        englishPath: 'README.md',
        translationPath: 'README.ru.md',
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('dart'));
      expect(diagnostic, contains('bash'));
    });
  });
}
````

- [ ] **Шаг 2: убедиться, что тест падает**

```bash
dart test test/tool/check_readme_sync_test.dart
```

Ожидается: провал компиляции — нет `tool/src/readme_structure.dart`.

- [ ] **Шаг 3: написать `tool/src/readme_structure.dart`**

```dart
import 'dart:convert';

/// One fenced code block: where it opens, its info string and its lines.
typedef CodeBlock = ({int line, String info, List<String> lines});

/// One heading: where it stands and how deep it is.
typedef Heading = ({int line, int level});

/// What of a readme is held to its translation: headings and code, in
/// document order. The prose between them is translated and is not here.
typedef ReadmeShape = ({List<Heading> headings, List<CodeBlock> blocks});

/// Reads the shape of [markdown].
ReadmeShape readReadmeShape(String markdown) {
  final headings = <Heading>[];
  final blocks = <CodeBlock>[];
  final lines = const LineSplitter().convert(markdown);
  String? fence;
  var openedAt = 0;
  var info = '';
  var body = <String>[];

  for (var index = 0; index < lines.length; index++) {
    final line = lines[index];
    final number = index + 1;

    if (fence != null) {
      if (line.trimRight() == fence) {
        blocks.add((line: openedAt, info: info, lines: body));
        fence = null;
        body = <String>[];
      } else {
        body.add(line);
      }
      continue;
    }

    final opening = RegExp(r'^\s*(`{3,}|~{3,})(.*)$').firstMatch(line);
    if (opening != null) {
      fence = opening.group(1)!;
      info = opening.group(2)!.trim();
      openedAt = number;
      continue;
    }

    final heading = RegExp(r'^(#{1,6})\s').firstMatch(line);
    if (heading != null) {
      headings.add((line: number, level: heading.group(1)!.length));
    }
  }

  return (headings: headings, blocks: blocks);
}

/// [line] with its Dart line comment removed, respecting string literals.
///
/// A `//` inside a literal is not a comment. No example in either readme
/// has one today; the scanner is here so that the first one that does
/// cannot move this gate quietly.
String stripDartComment(String line) {
  var quote = '';
  var raw = false;

  for (var index = 0; index < line.length; index++) {
    final char = line[index];

    if (quote.isEmpty) {
      if (char == "'" || char == '"') {
        quote = line.startsWith(char * 3, index) ? char * 3 : char;
        raw = index > 0 && line[index - 1] == 'r';
        index += quote.length - 1;
      } else if (char == '/' && line.startsWith('//', index)) {
        return line.substring(0, index).trimRight();
      }
      continue;
    }

    if (!raw && char == r'\') {
      index++;
    } else if (line.startsWith(quote, index)) {
      index += quote.length - 1;
      quote = '';
    }
  }

  return line.trimRight();
}

/// Holds [translation] to [english], returning a diagnostic when the two
/// disagree on anything that is not translated.
///
/// Four answers: the same heading levels in the same order, the same code
/// blocks in the same languages, the same code under the comments, and
/// comments in the same places. The text of a comment is not compared —
/// prose inside an example is translated — but its presence is, so an
/// example whose shown output was corrected on one side only is caught.
String? compareReadmeShapes(
  ReadmeShape english,
  ReadmeShape translation, {
  required String englishPath,
  required String translationPath,
}) {
  final diagnostics = <String>[];

  if (english.headings.length != translation.headings.length) {
    diagnostics.add(
      'heading count: $englishPath has ${english.headings.length}, '
      '$translationPath has ${translation.headings.length}',
    );
  }
  for (var i = 0;
      i < english.headings.length && i < translation.headings.length;
      i++) {
    final left = english.headings[i];
    final right = translation.headings[i];
    if (left.level != right.level) {
      diagnostics.add(
        'heading ${i + 1} is level ${left.level} at $englishPath:${left.line} '
        'and level ${right.level} at $translationPath:${right.line}',
      );
    }
  }

  if (english.blocks.length != translation.blocks.length) {
    diagnostics.add(
      'code block count: $englishPath has ${english.blocks.length}, '
      '$translationPath has ${translation.blocks.length}',
    );
  }
  for (var i = 0;
      i < english.blocks.length && i < translation.blocks.length;
      i++) {
    final left = english.blocks[i];
    final right = translation.blocks[i];

    if (left.info != right.info) {
      diagnostics.add(
        'code block ${i + 1} is "${left.info}" at $englishPath:${left.line} '
        'and "${right.info}" at $translationPath:${right.line}',
      );
      continue;
    }

    final leftCode = left.lines.map(stripDartComment).toList();
    final rightCode = right.lines.map(stripDartComment).toList();
    if (leftCode.length != rightCode.length) {
      diagnostics.add(
        'code block ${i + 1} has ${leftCode.length} lines at '
        '$englishPath:${left.line} and ${rightCode.length} at '
        '$translationPath:${right.line}',
      );
      continue;
    }

    for (var line = 0; line < leftCode.length; line++) {
      if (leftCode[line] != rightCode[line]) {
        diagnostics.add(
          'code differs at $englishPath:${left.line + 1 + line} and '
          '$translationPath:${right.line + 1 + line}\n'
          '  $englishPath: ${leftCode[line]}\n'
          '  $translationPath: ${rightCode[line]}',
        );
      }
      final leftHasComment = leftCode[line] != left.lines[line].trimRight();
      final rightHasComment = rightCode[line] != right.lines[line].trimRight();
      if (leftHasComment != rightHasComment) {
        diagnostics.add(
          'a comment stands at ${leftHasComment ? englishPath : translationPath}'
          ':${(leftHasComment ? left.line : right.line) + 1 + line} '
          'and not at the same place in '
          '${leftHasComment ? translationPath : englishPath}',
        );
      }
    }
  }

  return diagnostics.isEmpty ? null : diagnostics.join('\n');
}
```

- [ ] **Шаг 4: убедиться, что тест проходит**

```bash
dart test test/tool/check_readme_sync_test.dart
```

Ожидается: 14 тестов зелёные.

- [ ] **Шаг 5: написать CLI `tool/check_readme_sync.dart`**

```dart
/// Holds `README.ru.md` to `README.md`: the same headings, the same code
/// blocks, the same code under the comments.
///
/// The English readme is the source and the Russian one its translation,
/// and AGENTS.md calls a divergence between them a defect. Until now that
/// rule was kept by attention alone.
///
///     dart run tool/check_readme_sync.dart
///
import 'dart:io';

import 'src/readme_structure.dart';

// The same shape as tool/check_entry_points.dart.
final _sep = Platform.pathSeparator;
const _english = 'README.md';
const _translation = 'README.ru.md';

void main(List<String> args) {
  exitCode = runReadmeSyncCheck(args, root: _packageRoot());
}

/// Runs the readme comparison under [root].
int runReadmeSyncCheck(List<String> args, {required String root}) {
  if (args.isNotEmpty) {
    stderr.writeln('Usage: dart run tool/check_readme_sync.dart');
    return 2;
  }

  final shapes = <String, ReadmeShape>{};
  for (final name in const [_english, _translation]) {
    final file = File('$root$_sep$name');
    if (!file.existsSync()) {
      stderr.writeln('no $name under $root');
      return 2;
    }
    shapes[name] = readReadmeShape(file.readAsStringSync());
  }

  final diagnostic = compareReadmeShapes(
    shapes[_english]!,
    shapes[_translation]!,
    englishPath: _english,
    translationPath: _translation,
  );
  if (diagnostic != null) {
    stderr.writeln(diagnostic);
    return 1;
  }

  stdout.writeln(
    'the two readmes agree: '
    '${shapes[_english]!.headings.length} headings, '
    '${shapes[_english]!.blocks.length} code blocks',
  );

  return 0;
}

/// The package root: the directory holding the `tool/` this script runs
/// from, so that the check reads the same tree whatever the cwd.
String _packageRoot() {
  final script = File.fromUri(Platform.script).absolute.path;
  final tool = script.lastIndexOf('${_sep}tool$_sep');

  return tool == -1
      ? Directory.current.absolute.path
      : script.substring(0, tool);
}
```

- [ ] **Шаг 6: прогнать на живых README**

```bash
dart run tool/check_readme_sync.dart
```

Ожидается на `deca8ca`, ровно эта строка и код возврата 0:

```
the two readmes agree: 24 headings, 72 code blocks
```

Оба числа сняты пробником 2026-08-16. **Если инструмент краснеет — это
находка, а не повод ослабить сравнение:** значит README действительно
разошлись, и надо разобраться, где, прежде чем идти дальше.

- [ ] **Шаг 7: доказать, что ворота ловят подсунутое расхождение**

```bash
tmp=$(mktemp -d) && git archive HEAD | tar -x -C "$tmp" && cd "$tmp"
# заменить первое `final` в первом dart-блоке перевода
perl -0pi -e 's/final/FINAL/' README.ru.md
dart run tool/check_readme_sync.dart ; echo "exit=$?"
cd - && rm -rf "$tmp"
```

Ожидается: `exit=1` и строка `code differs at README.md:<n> and
README.ru.md:<m>` с обеими версиями строки.

- [ ] **Шаг 8: шаг в workflow**

Добавить в `.github/workflows/dart.yml` после шага «Analyze project
source»:

```yaml
      - name: Check the two readmes still say the same thing
        # AGENTS.md calls a divergence between README.md and README.ru.md a
        # defect and asks for both in one commit. Headings, code blocks and
        # the code under their comments are compared; the prose and the text
        # of the comments are translated and are not.
        run: dart run tool/check_readme_sync.dart
```

- [ ] **Шаг 9: строка в списке ворот `AGENTS.md`**

В блок команд раздела «Ворота», после `dart run
tool/check_entry_points.dart`:

```bash
dart run tool/check_readme_sync.dart
```

и в список пояснений:

```markdown
- **`check_readme_sync.dart`** сверяет `README.ru.md` с `README.md`:
  последовательность уровней заголовков, языки блоков кода, код внутри
  блоков с вырезанными комментариями и позиции комментарных строк. Текст
  комментария не сравнивается — проза внутри примеров переводится, — но
  его наличие сравнивается, поэтому пример, у которого показанный вывод
  поправили с одной стороны, ловится. Что не ловится ничем: расхождение
  в тексте самого прозаического комментария.
```

- [ ] **Шаг 10: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test test/tool/check_readme_sync_test.dart
git add tool/src/readme_structure.dart tool/check_readme_sync.dart \
  test/tool/check_readme_sync_test.dart .github/workflows/dart.yml AGENTS.md
git commit -F - <<'EOF'
ci: hold the two readmes to the same shape

AGENTS.md calls a divergence between README.md and README.ru.md a defect
and asks for both in the same commit, and until now the only thing keeping
that rule was attention. The two agree today — 24 headings and 72 code
blocks each — which is the moment to pin it, not after they have drifted.

What can be compared is narrower than it first looks. The rule says the
prose and the comments inside examples are translated, so the blocks are
not comparable byte for byte. But some of those comments are not prose at
all: they are the output an example prints, and there is nothing in them
to translate. So the code is compared with its comments cut away, and the
comments are compared by where they stand rather than what they say. An
example whose shown output was corrected on one side only is caught by the
second half.
EOF
```

---

## Задание 5: флейк — дать медленному тесту время медленного раннера

**Файлы:**
- Правка: `test/tool/check_entry_points_test.dart:1` — добавить аннотацию

- [ ] **Шаг 1: снять, сколько тест идёт сейчас**

```bash
dart test test/tool/check_entry_points_test.dart --reporter=expanded 2>&1 | tail -5
time dart test test/tool/check_entry_points_test.dart
```

Записать полученное время: план исходит из 7.4 с на самом долгом кейсе,
снятых в прошлой волне. Если сейчас существенно больше — это отдельная
находка, сказать владельцу.

- [ ] **Шаг 2: добавить аннотацию**

В начало `test/tool/check_entry_points_test.dart`, **перед** всеми
`import`:

```dart
@Timeout(Duration(seconds: 90))
library;

import 'dart:io';
```

- [ ] **Шаг 3: дописать комментарий над аннотацией**

Над `@Timeout` поставить:

```dart
// This file is the slow one: it stands up an analyser session and walks
// the export namespace of every entry point, which is 77% of the suite's
// running time and 7.4 seconds in its longest case. The default 30 leaves
// four times that, and the runner the CI uses has two cores where the
// machines this was measured on have more — four times is not enough
// margin for a slowdown that comes from the host rather than the code.
//
// Raised here rather than in a dart_test.yaml on purpose: a package-wide
// timeout would loosen the net for all 1069 tests, and the next test to
// start hanging would hang longer before anyone noticed.
@Timeout(Duration(seconds: 90))
library;
```

- [ ] **Шаг 4: убедиться, что тест по-прежнему проходит**

```bash
dart analyze --fatal-infos
dart test test/tool/check_entry_points_test.dart
```

Ожидается: зелено, число тестов не изменилось.

Если `dart analyze` ругается на `library;` без имени — это не так, пустая
директива `library;` законна с Dart 2.19, а пол пакета 3.6.0.

- [ ] **Шаг 5: коммит**

```bash
dart format --output=none --set-exit-if-changed .
git add test/tool/check_entry_points_test.dart
git commit -F - <<'EOF'
test: give the entry point sweep the time a slow runner needs

The file is 77% of the suite's running time and its longest case takes
7.4 seconds, against a default timeout of 30. Four times over is thin
margin when the slowdown would not come from the code: the test stands up
an analyser session, and the CI runner has two cores where the machines
this was measured on have more. It is the only place in the suite that can
go red intermittently without anything changing.

Raised on this file rather than in a dart_test.yaml, so the fact sits next
to its cause. A package-wide timeout would loosen the net for the other
thousand tests, and the next one to start hanging would hang longer before
anybody noticed.
EOF
```

---

## Задание 6: гигиена конфигов

Четыре мелкие правки, четыре коммита. Ни одна не требует теста сверх
самих ворот.

**Файлы:**
- Правка: `.github/dependabot.yml`
- Правка: `.github/workflows/dart.yml`
- Правка: `.pubignore`

- [ ] **Шаг 1: L15 — pub-экосистема в dependabot**

Дописать в `.github/dependabot.yml`:

```yaml

  # Two of the five are held back on purpose and must not be bumped here:
  # analyzer 8 asks for an SDK above the ^3.6.0 floor in pubspec.yaml, and
  # test moves with it because test_core past 0.6.12 wants analyzer 8. A
  # pull request bumping either would take the floor leg of the CI down.
  # Raising the floor is its own wave, and it lifts these two lines.
  - package-ecosystem: "pub"
    directory: "/"
    schedule:
      interval: "weekly"
    ignore:
      - dependency-name: "analyzer"
      - dependency-name: "test"
```

Проверить разбор:

```bash
python3 -c "import yaml; d=yaml.safe_load(open('.github/dependabot.yml')); print([u['package-ecosystem'] for u in d['updates']])"
```

Ожидается: `['github-actions', 'pub']`

```bash
git add .github/dependabot.yml
git commit -F - <<'EOF'
ci: watch the pub dependencies that are free to move

Dependabot watched the pinned actions and nothing else, so meta, coverage
and lints could sit at whatever version they were added at. The other two
cannot be watched the same way: analyzer is held at 7 because 8 asks for
an SDK above the floor this package promises, and test moves with it. A
bump to either would take the floor leg of the matrix down, so both are
named as ignored with the reason beside them — and raising the floor,
whenever that wave comes, is what lifts them.
EOF
```

- [ ] **Шаг 2: L16 — границы у job**

В `.github/workflows/dart.yml` после блока `permissions:` добавить:

```yaml
concurrency:
  # A branch that gets two pushes in a minute does not need the first run
  # finished. `main` is excluded: a run there is checking what is already
  # merged, and cancelling it leaves the question of whether the merge was
  # green unanswered.
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.ref != 'refs/heads/main' }}
```

и в `jobs.build`, сразу после `runs-on: ubuntu-latest`:

```yaml
    # The longest job observed over the runs of 2026-08-16 was 5m34s on
    # stable, against 3m17s on the floor leg. Twenty minutes is over three
    # times the worst of those — wide enough not to fire on a slow runner,
    # and far short of the six hours a hung job would otherwise burn.
    timeout-minutes: 20
```

```bash
python3 -c "import yaml; d=yaml.safe_load(open('.github/workflows/dart.yml')); print(d['jobs']['build']['timeout-minutes'], d['concurrency'])"
git add .github/workflows/dart.yml
git commit -F - <<'EOF'
ci: bound the job and drop runs a newer push supersedes

Neither bound existed. A hung job would have run to the six-hour default
before anyone was told, and every push to a branch left its predecessor
running to the end for an answer nobody wanted. Twenty minutes is over
three times the worst job observed, so it can only fire on something
genuinely stuck.

Cancellation deliberately stops short of main. A run there is checking
what is already merged, and killing it would leave exactly the question
the run exists to answer.
EOF
```

- [ ] **Шаг 3: L17 — сказать, почему сьют гоняется дважды**

Над шагом «Collect coverage» в `.github/workflows/dart.yml` дописать:

```yaml
      - name: Collect coverage
        if: matrix.sdk == 'stable'
        # The suite has already run once on this leg, plainly. This run is
        # the instrumented one, and the two are kept apart on purpose: a
        # pass under instrumentation is not the same evidence as a pass
        # without it, and the gate should stand on the plain run. What this
        # one produces is a measurement, not a verdict.
        run: dart test --coverage=coverage
```

```bash
git add .github/workflows/dart.yml
git commit -F - <<'EOF'
ci: say why the suite runs twice on the stable leg

A review counted the second run as waste. It is not: the plain run is the
gate and the instrumented one is the measurement, and a pass under
instrumentation is not the same evidence as a pass without it. Nothing
about the workflow said so, which is why it read as an oversight.
EOF
```

- [ ] **Шаг 4: L20 — назвать редакторский конфиг в `.pubignore`**

В `.pubignore`, в комментарий перед списком, дописать абзац:

```
# .vscode/ is the launch configuration, kept in git for whoever works on
# the package here. It stays out of the archive today only because pub
# skips hidden directories — a property of the tool rather than a decision
# of this package, and one that would take the file with it if it changed.
```

и в список путей, после `coverage/`:

```
.vscode/
```

Проверить, что архив от этого не изменился (файла там не было и не будет):

```bash
dart pub publish --dry-run 2>&1 | tail -5
```

Ожидается: 0 предупреждений, как и до правки.

```bash
git add .pubignore
git commit -F - <<'EOF'
chore: name the editor config the archive should not carry

.vscode/launch.json is tracked and named in neither ignore file. It stays
out of the published archive only because pub skips hidden directories,
which is a property of the tool and not a decision of this package. Named
here, so the exclusion survives the tool changing its mind. It stays in
git either way: it is useful to whoever works on the package.
EOF
```

---

## Сдача волны

- [ ] **Шаг 1: полные ворота локально**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
dart run tool/check_readme_sync.dart
dart run tool/generate.dart && git diff --exit-code -- lib/
dart test
dart run benchmark/memory_guard.dart
dart run benchmark/complexity_guard.dart
dart doc --dry-run
dart pub publish --dry-run
```

Ожидается: всё зелёное. `check_entry_points` — 5 входов, 1646 имён;
`generate.dart` — 8 зон без диффа; `dart test` — **1069 + новые** (7 в
`check_coverage_test`, ещё 7 добавляются в задании 3, 14 в
`check_readme_sync_test` — итого 1097, но число сверить прогоном, а не
сложением); `memory_guard` и `complexity_guard` — в прежних полосах,
`lib/` волна не трогала.

- [ ] **Шаг 2: пуш ветки и ожидание зелёного CI**

```bash
git push -u origin fix/ci-gates
gh run watch
```

**Обе ноги матрицы должны быть зелёными.** Нога `3.6.0` — единственное,
что проверяет пол SDK, и локально она не гоняется.

- [ ] **Шаг 3: финальное ревью всей ветки**

```bash
git diff main...fix/ci-gates
```

- [ ] **Шаг 4: мерж и пуш**

**`git merge` не читает сообщение со stdin** — в отличие от `git commit`,
`-F -` даёт `error: could not read file '-'` и код 129 (проверено).
Сообщение писать во временный файл:

```bash
git checkout main
msg=$(mktemp)
cat > "$msg" <<'EOF'
merge: repair the checking before it is trusted again

Eight findings that turned out to share one shape: a check that quietly
does not happen looks exactly like a check that passed. A branch outside
the allow-list ran no CI and read as green. A library nothing loaded left
no record in the coverage report and read as covered. A translation could
drift from its original and nothing would say so.

The trigger is now a deny-list, so the unfamiliar branch is checked rather
than waved through. The coverage floor moved out of awk and into a tool
that also holds the report to the files it should contain — with the list
of codeless files held to still being codeless, or the exemption would be
the same blind spot again. The two readmes are compared on everything that
is not translated. The rest are bounds and comments the configuration was
missing.
EOF
git merge --no-ff fix/ci-gates -F "$msg"
rm -f "$msg"
git push origin main
```

- [ ] **Шаг 5: документы**

- `docs/handoff.md` переписать под новое состояние: волна 6 закрыта,
  остались 7 и 8, числа ворот снять прогоном заново;
- шапку `docs/records/2026-08-16[7]-ci-gates-design.md` и этого плана
  обновить на «сделано и смержено (коммит)»;
- отчёт волны — записью жанра `report` в `docs/records/`.

---

## Чего этот план не делает

- **Не ускоряет `check_entry_points_test`** — флейк закрывается запасом
  по времени. Ускорение трогает тест, стерегущий публичную поверхность.
- **Не поднимает пол 95.0** — волна чинит то, по чему он считается.
- **Не трогает `lib/`** — код-долг это волна 8.
- **Не заводит `dart_test.yaml`** — обосновано в задании 5.
- **Не чинит `751dab2`**, потерявший слово в сообщении мержа: правка
  требует force-push в `main`, запрещённого без слова владельца.
