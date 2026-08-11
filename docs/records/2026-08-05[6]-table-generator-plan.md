# Генератор таблиц цветов — план имплементации

> **Состояние документа**
>
> - **Тип:** план, 2026-08-05, по дизайну `2026-08-05[5]`
> - **Статус:** выполнен, влит в `main` мержем `fecaaf9`
> - **Актуальность:** верификация `2026-08-05[9]` подтвердила: восемь
>   поверхностей покрыты, генератор идемпотентен, CI краснеет при ручной
>   правке генерируемой зоны
> - **Пути:** ссылки в тексте старые — записи с тех пор лежат в
>   `docs/records/`, `TODO.md` стал `docs/backlog.md`, текущий handoff —
>   `docs/handoff.md`

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** `tool/generate.dart`, порождающий все семь рукописных
поверхностей 256-цветной таблицы, с доказательством «первый прогон
воспроизводит репозиторий байт-в-байт» — по спеке
`docs/2026-08-05[5]-table-generator-design.md`.

**Architecture:** три коммита в ветке `feat/table-generator`: маркеры
зон (no-op-дифф) → генератор с байт-в-байт-прогоном → CI-шаг
generate+diff и `tool/` в `.pubignore`. Затем финальное ревью и
локальный `merge --no-ff` в main — без PR.

**Tech Stack:** Dart ≥3, только `dart:io` в генераторе.

## Global Constraints

- Ветка `feat/table-generator` от текущего `main`.
- Существующие тест-файлы не редактируются; `test/color_tables_test.dart`
  (M8-свип) остаётся независимой сеткой и обязан быть зелёным на каждом
  шаге.
- Перед каждым коммитом: `dart format .` идемпотентен, полный
  `dart test`, `dart analyze --fatal-infos`.
- Версия 4.0.0 и CHANGELOG **не трогаются** (генератор не меняет
  поведения пакета; tool/ не публикуется).
- **Запрет подгонки**: если после написания генератора
  `git diff -- lib/` не пуст — чинится генератор, не таблицы.
  Единственное исключение: вскрывшаяся реальная опечатка таблицы —
  тогда STOP, BLOCKED, отдельное решение пользователя.
- Сообщения коммитов: conventional-префикс, строчные, английские, в
  стиле репозитория, + trailer
  `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.
- Точные тексты маркеров (везде одинаковые, отступ — по месту вставки):

```dart
// BEGIN GENERATED — by tool/generate.dart; edit the generator, not this.
```

```dart
// END GENERATED
```

Генератор ищет строки, чей `trim()` равен этим текстам, и заменяет всё
между ними; отсутствующий или непарный маркер — `stderr` с именем файла
и `exit(1)`.

---

### Task 1: Маркеры зон

**Files:**
- Modify (только вставка комментариев): `lib/src/ansi/colors.dart`,
  `lib/src/ready_to_use/sgr/colors256/fg256.dart`, `…/bg256.dart`,
  `…/underline256.dart`, `lib/src/parsing/colors/color_indexes.dart`,
  `lib/src/parsing/colors/color_256.dart`,
  `lib/src/parsing/state/styles.dart`,
  `lib/src/parsing/state/style_colors.dart`

**Interfaces:**
- Produces: пары маркеров, которые Task 2 находит по `trim()`-равенству.

Границы зон (сверить по факту — правило: зона накрывает **все**
табличные строки поверхности, включая секционные комментарии внутри
таблицы, и **ничего** рукописного):

| Файл | BEGIN сразу после | END сразу перед |
|---|---|---|
| `ansi/colors.dart` | шапки `library;` (зона включает `// Standard color indexes.` и все секции) | конца файла |
| `fg256.dart` | закрывающей `}` функции `fg256()` | конца файла |
| `bg256.dart` | закрывающей `}` функции `bg256()` | конца файла |
| `underline256.dart` | закрывающей `}` функции `underline256()` | конца файла |
| `color_indexes.dart` | строки `enum Colors implements Comparable<Colors> {` | строки `const Colors();` (её и всё после — вне зоны; терминатор списка приклеен к последнему значению — `  gray23;` — и **входит** в зону, эмиттер завершает последнюю строку `;` вместо `,`) |
| `color_256.dart` | doc-блока и строки объявления первого статика — точнее: после последнего рукописного члена перед `static const Color256 black` (сверить: конструкторы/factory выше) | строки `int get index => color.index;` (первый рукописный член после таблицы; его doc-блок — вне зоны) |
| `styles.dart` | строки `static const Style subscript = Style(subscript: true);` (последнее из 15 свойств) | закрывающей `}` класса |
| `style_colors.dart` | строки `extension StyleColors on Style {` | закрывающей `}` extension |

Если в `color_256.dart`/`styles.dart` между указанными якорями есть
рукописные doc-блоки или секционные комментарии на границах — сдвинуть
маркер так, чтобы рукописное осталось снаружи, и зафиксировать выбор в
отчёте (Task 2 всё равно докажет корректность байт-в-байт).

- [ ] **Step 1: Создать ветку**

```bash
git checkout main && git checkout -b feat/table-generator
```

- [ ] **Step 2: Вставить 8 пар маркеров** по таблице выше. Отступ маркера
  = отступ окружающих строк зоны (0 для top-level, 2 пробела внутри
  класса/enum/extension).

- [ ] **Step 3: Проверить no-op**

```bash
git diff --stat
git diff | grep -v "^[+-].*GENERATED" | grep "^[+-]" | grep -v "^[+-][+-]"
dart format .
dart test
dart analyze --fatal-infos
```

Expected: во втором grep — пусто (дифф состоит из одних
маркер-строк); всё зелёное.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: the colour tables get their generation markers

Eight files, seven surfaces: a BEGIN/END pair around every table zone,
comments only, nothing generated yet. The generator lands next and must
reproduce what is between them byte for byte."
```

---

### Task 2: `tool/generate.dart`

**Files:**
- Create: `tool/generate.dart`

**Interfaces:**
- Consumes: маркеры Task 1 (`trim()`-равенство текстам из Global
  Constraints).
- Produces: `dart run tool/generate.dart` перегенерирует все 8 зон;
  Task 3 вешает на это CI-шаг.

Каркас (дописывается по фактическим файлам; **судья — байт-в-байт**):

```dart
/// Regenerates the seven hand-written surfaces of the 256-colour table.
///
/// The list of names below is the one source of truth; every surface —
/// the index constants, the ready-to-use strings, the enum, the statics,
/// the styles and the getters — is emitted from it into the zone between
/// its BEGIN/END markers. Run it after changing the naming policy:
///
///     dart run tool/generate.dart
///
/// The CI keeps the zones and the generator in step.
library;

import 'dart:io';

const _begin =
    '// BEGIN GENERATED — by tool/generate.dart; edit the generator, not this.';
const _end = '// END GENERATED';

void main() {
  final names = _names();

  _replace('lib/src/ansi/colors.dart', _ansiIndexes(names));
  _replace(
    'lib/src/ready_to_use/sgr/colors256/fg256.dart',
    _readyToUse(names, prefix: 'fg256', word: 'Foreground'),
  );
  _replace(
    'lib/src/ready_to_use/sgr/colors256/bg256.dart',
    _readyToUse(names, prefix: 'bg256', word: 'Background'),
  );
  _replace(
    'lib/src/ready_to_use/sgr/colors256/underline256.dart',
    _readyToUse(names, prefix: 'underline256', word: 'Underline'),
  );
  _replace('lib/src/parsing/colors/color_indexes.dart', _enumValues(names));
  _replace('lib/src/parsing/colors/color_256.dart', _statics(names));
  _replace('lib/src/parsing/state/styles.dart', _styles(names));
  _replace('lib/src/parsing/state/style_colors.dart', _getters(names));
}

/// One colour of the table: its place and the pieces its names are
/// built from.
class _Name {
  final int index;

  /// `black`, `highRed`, `rgb113`, `gray5` — the enum spelling.
  final String id;

  /// `BLACK`, `HIGH_RED`, `RGB_113`, `GRAY5` — the constant spelling.
  final String constant;

  /// `Black`, `HighRed`, `Rgb113`, `Gray5` — the spelling after a prefix.
  String get cap => id[0].toUpperCase() + id.substring(1);

  _Name(this.index, this.id, this.constant);
}

List<_Name> _names() {
  const named = [
    'black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white', //
    'highBlack', 'highRed', 'highGreen', 'highYellow', 'highBlue',
    'highMagenta', 'highCyan', 'highWhite',
  ];

  String screaming(String id) => id
      .replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}')
      .toUpperCase();

  return [
    for (final (i, id) in named.indexed) _Name(i, id, screaming(id)),
    for (var r = 0; r < 6; r++)
      for (var g = 0; g < 6; g++)
        for (var b = 0; b < 6; b++)
          _Name(16 + r * 36 + g * 6 + b, 'rgb$r$g$b', 'RGB_$r$g$b'),
    for (var level = 0; level < 24; level++)
      _Name(232 + level, 'gray$level', 'GRAY$level'),
  ];
}

void _replace(String path, List<String> zone) {
  final file = File(path);
  final lines = file.readAsLinesSync();
  final begin = lines.indexWhere((l) => l.trim() == _begin);
  final end = lines.indexWhere((l) => l.trim() == _end);

  if (begin < 0 || end < 0 || end < begin) {
    stderr.writeln('$path: BEGIN/END markers missing or unpaired');
    exit(1);
  }

  file.writeAsStringSync(
    [...lines.take(begin + 1), ...zone, ...lines.skip(end), '']
        .join('\n'),
  );
}
```

Эмиттеры (`_ansiIndexes`, `_readyToUse`, `_enumValues`, `_statics`,
`_styles`, `_getters`) возвращают `List<String>` — строки зоны с их
отступами. Снятые с файлов образцы построчной грамматики (каждый
эмиттер **сверяется с фактическим файлом**, нерегулярности переносятся
в код как есть — байт-в-байт не оставляет свободы):

- `ansi/colors.dart`: секционные комментарии
  (`// Standard color indexes.` и т.д. — в зоне) и записи вида
  `/// Black index from 256-color table.` → `const int BLACK = 0;`;
  rgb: `/// RGB 113 index from 256-color table.` →
  `const int RGB_113 = 61;`; gray: `/// Gray 5 index from 256-color
  table.` → `const int GRAY5 = 237;`.
- `fg256.dart`: `/// Foreground black from 256-color table.` →
  `const String fg256Black = '$fg256Open$BLACK$fg256Close';`;
  rgb: `/// Foreground RGB 113 from 256-color table.`;
  gray: **`/// Foreground gray color 5 from 256-color table.`**
  (нерегулярность: «gray color N», не «Gray N»). Секционные комментарии
  внутри — сверить. `word`-параметр даёт «Foreground/Background/
  Underline»; underline-вариант сверить целиком (свои Open/Close).
- `color_indexes.dart`: голые `  black,` … `  gray23,` (без доков;
  trailing comma у последнего — сверить, в файле список закрывается
  `gray23;` — точную форму снять с файла).
- `color_256.dart`: `  static const Color256 black = Color256(Colors.black);`.
- `styles.dart`: двухстрочные записи
  `  static const Style red =` /
  `      Style(foreground: Color256.on(Colors.red, ColorTarget.foreground));`
  — три блока (foreground/bg<Cap>/underline<Cap>) по 256; секционные
  комментарии между блоками — сверить; однострочные записи, где имя
  короткое и влезает — сверить фактическую разбивку (судья — формат).
- `style_colors.dart`: `  Style get black => foreground(Color256.black);`
  и `  Style get bgBlack => background(Color256.black);` — два блока по
  256; граница между ними — сверить.

- [ ] **Step 1: Написать генератор** (каркас выше + эмиттеры по
  фактическим файлам).

- [ ] **Step 2: Байт-в-байт**

```bash
dart run tool/generate.dart
git diff --stat -- lib/
git status --porcelain
```

Expected: дифф пуст, статус чист (кроме нового `tool/generate.dart`).
Не пуст → чинить **генератор** до пустого диффа. Вскрылась реальная
опечатка таблицы → STOP, BLOCKED.

- [ ] **Step 3: Идемпотентность скрипта — второй прогон подряд**

```bash
dart run tool/generate.dart && git diff --exit-code -- lib/
```

Expected: exit 0.

- [ ] **Step 4: Гейты и коммит**

```bash
dart format .
dart test
dart analyze --fatal-infos
git add tool/generate.dart
git commit -m "feat: the colour tables come from one place

tool/generate.dart holds the one list of 256 names and emits all seven
surfaces into their marker zones — the index constants, the three
ready-to-use tables, the enum, the statics, the styles and the getters.
Its first run reproduces the repository byte for byte, which is the
proof that nothing changed but the origin."
```

(`dart format .` не должен трогать `tool/generate.dart` — писать сразу
в формате; если тронул — вписать правки и повторить Step 2-3.)

---

### Task 3: CI-шаг и `.pubignore`

**Files:**
- Modify: `.github/workflows/dart.yml` (после шага
  `Analyze project source`)
- Modify: `.pubignore`

**Interfaces:**
- Consumes: `tool/generate.dart` из Task 2.

- [ ] **Step 1: CI-шаг**

После шага «Analyze project source» вставить:

```yaml
      - name: Check the generated tables are in step with the generator
        run: |
          dart run tool/generate.dart
          git diff --exit-code -- lib/
```

- [ ] **Step 2: `.pubignore`**

Добавить `tool/` (посмотреть файл: стиль комментариев — с пояснениями;
дать строку в том же духе, по прецеденту `benchmark/compare.dart`).

- [ ] **Step 3: Sabotage-проверка** (порча генератора, не зоны):

во `_names()` временно поменять один индекс (например, `232 + level` →
`231 + level`), затем:

```bash
dart run tool/generate.dart; git diff --stat -- lib/   # Expected: дифф НЕ пуст
git checkout -- lib/ tool/generate.dart                # откат порчи и зон
dart run tool/generate.dart && git diff --exit-code -- lib/  # Expected: exit 0
git status --porcelain                                  # Expected: чисто
```

- [ ] **Step 4: Публикация и гейты**

```bash
rm -rf coverage
dart pub publish --dry-run 2>&1 | tail -5   # 0 warnings; tool/ в листинге нет
dart format .
dart test
dart analyze --fatal-infos
```

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/dart.yml .pubignore
git commit -m "ci: the tables cannot drift from their generator

The workflow regenerates the zones and fails on any diff, so a table
edited by hand or a generator changed without regeneration is caught
before merge. tool/ stays out of the published archive: the script
needs the repository, the package does not need the script."
```

---

### Task 4: Финальная проверка, whole-branch ревью, локальный merge

- [ ] **Step 1: Полный прогон**

```bash
dart format --set-exit-if-changed .
dart analyze --fatal-infos
dart test
rm -rf coverage && dart pub publish --dry-run
dart run tool/generate.dart && git diff --exit-code -- lib/
```

- [ ] **Step 2: Whole-branch ревью** по процессу
  subagent-driven-development, сверка со спекой
  `docs/2026-08-05[5]-table-generator-design.md`; находки —
  fixup-коммитами до слияния.

- [ ] **Step 3: Локальный merge — без PR**

```bash
git checkout main
git merge --no-ff feat/table-generator \
  -m "merge: the colour tables get their generator — the review closes"
git push
git branch -d feat/table-generator
```

После слияния отчёт `docs/2026-08-04[1]-project-review.md` закрыт
полностью. Публикация 4.0.0 — отдельное решение пользователя.
