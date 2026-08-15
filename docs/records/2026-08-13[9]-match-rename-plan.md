# План — `Match` уходит, приходит `Piece`

> **Состояние на 2026-08-16:** исполнен целиком и влит — переименование
> сделано одним коммитом `a7978a4`, ветка `fix/match-rename` слита в
> `main` мержем `f1a927d`; H9 закрыт, страж на возврат имени стоит.
> **Что это:** пошаговый план замены `Match`/`Matches`/`Parser.matches`
> на `Piece`/`Pieces`/`Parser.pieces` со стражем против возврата имени.
> **Связанные записи:** `2026-08-13[8]-match-rename-design.md`.

> **Исполнителю:** шаги отмечены чекбоксами `- [ ]`. Читать спеку
> `docs/records/2026-08-13[8]-match-rename-design.md` до первого шага.

**Цель:** убрать молчаливое перекрытие `dart:core.Match` — переименовать
`Match<S>` в `Piece<S>`, `Matches<S>` в `Pieces<S>`, `Parser.matches` в
`Parser.pieces` — и завести страж, который поймает возврат имени.

**Подход:** переименование механическое, поведение не меняется. Работа
идёт снизу вверх: сначала страж (он красный и остаётся красным до конца
второй задачи), затем `lib/`, затем тесты и примеры, затем документация.
Коммит **один, в последней задаче** — так решил владелец, и так велит
правило про README-пару.

**Инструменты:** Dart SDK (floor `^3.6.0`), `dart test`, `dart analyze`,
`git mv`.

## Общие ограничения

Действуют в каждой задаче, повторяться не будут:

- **Версию не бампать.** В `pubspec.yaml` уже `4.0.0`, она не издана,
  CHANGELOG правится на месте.
- **Языки:** код, dartdoc, README, CHANGELOG — по-английски; этот план и
  спека — по-русски.
- **`README.ru.md` — перевод `README.md`**, правятся **одним коммитом**,
  расхождение считается дефектом.
- **Зона между маркерами `BEGIN`/`END`** в `lib/` — вывод
  `tool/generate.dart`, руками не правится. Переименование её не
  касается, но `git diff --exit-code -- lib/` после генератора всё равно
  прогоняется.
- **Ожидаемые значения снимаются пробником**, а не выводятся
  рассуждением. Если шаг даёт не то, что здесь написано, — **объяснить
  почему, а не подгонять ожидание под код**.
- **Коммит один** — в задаче 4. Задачи 1–3 заканчиваются проверкой, а не
  коммитом: страж красный до конца задачи 2, а тесты не компилируются
  между задачами 2 и 3, поэтому промежуточный коммит был бы красным.

## Карта файлов

**Переезжают (`git mv`, история сохраняется):**

| было | стало |
|---|---|
| `lib/src/parsing/parser/matches/match.dart` | `lib/src/parsing/parser/pieces/piece.dart` |
| `lib/src/parsing/parser/matches/matches.dart` | `lib/src/parsing/parser/pieces/pieces.dart` |
| `lib/src/parsing/parser/matches/matches_result.dart` | `lib/src/parsing/parser/pieces/pieces_result.dart` |
| `lib/src/parsing/parser/matches/parser_iterator.dart` | `lib/src/parsing/parser/pieces/parser_iterator.dart` |

**Правятся:** `lib/src/parsing/parser/parser.dart` (17 мест),
`lib/src/parsing/parser/unfinished_sequence_exception.dart` (1),
`lib/src/parsing/parser/entities/sgr.dart` (1),
`lib/src/extensions/remove.dart` (проза комментария),
`test/` (92 обращения `.matches` + 1 golden), `example/` (1 файл),
`benchmark/` (2 файла), `README.md`, `README.ru.md`, `CHANGELOG.md`,
`docs/architecture.md`.

**Создаётся:** `test/name_collision_test.dart`.

**Не трогается — проверить глазами, не `sed`-ом:**

- `lib/src/parsing/parser/entities/matching_state.dart` целиком:
  `_MatchingState` держит `RegExpMatch` движка регулярок, его «match» —
  верное слово.
- `RegExpMatch`, `allMatches`, `namedGroup` везде, где встречаются.
- `docs/architecture.md:38` — «сразу в `allMatches`»: это про regex.

---

### Задача 1: страж имени

**Файлы:**
- Создать: `test/name_collision_test.dart`

**Что даёт дальше:** тест, который красен, пока `Match` перекрывает
`dart:core.Match`, и зеленеет ровно тогда, когда перекрытие снято.

- [ ] **Шаг 1: написать падающий тест**

Файл `test/name_collision_test.dart`. Импорт — **один**, как у
пользователя пакета; в этом весь смысл стража: имя проверяется снаружи, а
не изнутри, где `Match` всегда значил свой.

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// What a user of this package can still write beside it.
///
/// The parser used to export a `Match` of its own, which shadowed
/// `dart:core.Match` silently: an explicit import outranks the implicit
/// `dart:core`, so the compiler never asked which was meant and ordinary
/// code with a regular expression failed with two errors that named no
/// package. This file is that ordinary code. It does not test the parser —
/// it tests that the parser leaves the name alone, and it fails to compile
/// where it does not. See `docs/records/2026-08-13[8]`.
void main() {
  group('a name this package does not take:', () {
    test('dart:core Match is what Match means beside a single import', () {
      final words = <String>[
        for (final Match m in RegExp(r'\w+').allMatches('one two')) m.group(0)!,
      ];

      expect(words, ['one', 'two']);
    });

    test('and the parser hands out pieces under a name of its own', () {
      final pieces = Parser('\x1B[1mbold').pieces.toList();

      expect(pieces, hasLength(2));
      expect(pieces.first.entity, isA<Sgr>());
      expect(pieces.last.entity.string, 'bold');
    });
  });
}
```

- [ ] **Шаг 2: убедиться, что он красный, и что красный именно тот**

```bash
dart analyze test/name_collision_test.dart
```

Ожидание — **ровно две ошибки**, снятые пробником с живого кода
2026-08-13; текст важен, потому что он и есть описание дефекта:

```
error - The type 'Iterable<RegExpMatch>' used in the 'for' loop must implement
        'Iterable' with a type argument that can be assigned to
        'Match<State<dynamic>>'. - for_in_of_invalid_element_type
error - The method 'group' isn't defined for the type 'Match'. - undefined_method
```

Второй тест группы добавит к ним ошибку про `pieces` — геттера ещё нет.
Это ожидаемо: он зеленеет в задаче 2.

Если ошибок нет — остановиться и разобраться: значит, перекрытия уже нет
и находка описывает не то. **Не править план под результат.**

---

### Задача 2: переименование в `lib/`

**Файлы:**
- Переместить: четыре файла папки `matches/` в `pieces/` (карта выше)
- Изменить: `lib/src/parsing/parser/parser.dart`,
  `lib/src/parsing/parser/unfinished_sequence_exception.dart:58`,
  `lib/src/parsing/parser/entities/sgr.dart:339`,
  `lib/src/extensions/remove.dart:127`

**Что даёт дальше:** публичные `Piece<S>`, `Pieces<S>`, `Parser.pieces`;
приватный `_PiecesResult<S>` с полем `pieces`.

- [ ] **Шаг 1: перенести файлы**

```bash
mkdir -p lib/src/parsing/parser/pieces
git mv lib/src/parsing/parser/matches/match.dart          lib/src/parsing/parser/pieces/piece.dart
git mv lib/src/parsing/parser/matches/matches.dart        lib/src/parsing/parser/pieces/pieces.dart
git mv lib/src/parsing/parser/matches/matches_result.dart lib/src/parsing/parser/pieces/pieces_result.dart
git mv lib/src/parsing/parser/matches/parser_iterator.dart lib/src/parsing/parser/pieces/parser_iterator.dart
rmdir lib/src/parsing/parser/matches
```

- [ ] **Шаг 2: поправить `part`-директивы**

`lib/src/parsing/parser/parser.dart:37-40`. Было:

```dart
part 'matches/parser_iterator.dart';
part 'matches/match.dart';
part 'matches/matches.dart';
part 'matches/matches_result.dart';
```

Стало:

```dart
part 'pieces/parser_iterator.dart';
part 'pieces/piece.dart';
part 'pieces/pieces.dart';
part 'pieces/pieces_result.dart';
```

Строка `part 'entities/matching_state.dart';` (34) **не меняется**.

- [ ] **Шаг 3: переименовать типы и члены**

`Match<` → `Piece<`, `Matches<` → `Pieces<`, `Matches._` → `Pieces._`,
`_MatchesResult` → `_PiecesResult`, поле `matches:` этого результата →
`pieces:`, геттер `Parser.matches` → `Parser.pieces` и его приватное поле
`_matches` → `_pieces`.

Точные места вне папки `pieces/`:

| файл:строка | было |
|---|---|
| `parser.dart:127` | `Matches<S>? _matches;` |
| `parser.dart:157-159` | дартдок `/// The [Matches] of the string.`, геттер `Matches<S> get matches`, тело `_matches ??= Matches._(...)` |
| `parser.dart:283` | `Match<S>? _pieceAt(int pos)` |
| `parser.dart:446` | `Match<S>? lastMatch;` |
| `parser.dart:478` | `Match<S>? piece;` |
| `parser.dart:491` | `final Match<S> m;` |
| `parser.dart:850` | `Matches<S>._(text, ambient, initialLink: ambientLink)` |
| `parser.dart:1167` | проза `/// A resumable walk over the matches:` |
| `parser.dart:1176, 1185, 1195, 1259` | `Iterator<Match<S>>`, `Match<S>? current`, `Match<S>? lastCode`, `Match<S>? beforeRun` |
| `parser.dart:1311, 1330` | проза `// Matches tile the input, …` (дважды) |
| `parser.dart:1321, 1347` | `void takeCode(Match<S> m)`, `void takePiece(Match<S> m, int plainStart)` |
| `unfinished_sequence_exception.dart:58` | проза `the way `Match.start` does` |
| `entities/sgr.dart:339` | пример в дартдоке `Parser('$bold').matches.first.entity as Sgr` |
| `extensions/remove.dart:127` | проза `walk over the matches` |

Проза правится по смыслу: «Matches tile the input» → «Pieces tile the
input», «walk over the matches» → «walk over the pieces». Локальная
переменная `lastMatch` (`parser.dart:446`) становится `lastPiece`; `m`
остаётся `m`.

- [ ] **Шаг 4: проверить, что `lib/` собирается и имя ушло**

```bash
dart analyze lib/
grep -rnE "\bMatch(es)?\b" lib/ --include="*.dart" | grep -v RegExpMatch | grep -v _MatchingState | grep -v allMatches
```

Ожидание: анализ чист; `grep` не печатает ничего. Всё, что он печатает, —
пропущенное место, кроме трёх исключённых имён.

Тесты на этом шаге **не запускаются**: они ещё зовут `.matches` и не
компилируются. Это ожидаемо и чинится задачей 3.

---

### Задача 3: тесты, примеры, бенчмарки

**Файлы:**
- Изменить: `test/` (92 обращения `.matches`, 1 golden в
  `test/entities_test.dart:68`), `example/ansi_escape_codes_example.dart`,
  `benchmark/parser_benchmark.dart`, `benchmark/memory_guard.dart`

- [ ] **Шаг 1: заменить обращения**

`.matches` → `.pieces`, `Match<` → `Piece<`, `Matches` → `Pieces` во всех
файлах `test/`, `example/`, `benchmark/`. Имена тестов, где «match» стоит
словом прозы, правятся по смыслу.

- [ ] **Шаг 2: поправить единственное golden-ожидание**

`test/entities_test.dart:68`. `Piece.toString` печатает собственное имя
типа (`'${Piece<S>}('`), поэтому строка меняется:

```dart
        "Piece<Style>(start: 0, end: 1, entity: Text('a'), state: Style(), "
```

**Это единственная правка ожидания, которую переименование оправдывает.**
Любая другая — признак ошибки переноса: поведение не менялось, значит
числа и строки, кроме этой, обязаны совпасть.

- [ ] **Шаг 3: прогнать тесты**

```bash
dart test
```

Ожидание: **811 тестов** зелены — прежние 809 плюс **два** теста стража,
который здесь зеленеет впервые. Если число разойдётся — назвать причину,
а не подогнать ожидание под вывод.

Ожидания внутри стража сняты пробником на живом коде: `Parser('\x1B[1mbold')`
даёт ровно два куска — `Sgr` со строкой `\x1B[1m` и `Text` со строкой
`bold`.

- [ ] **Шаг 4: убедиться, что страж действительно страж**

Мутация: временно вернуть имя и увидеть красное.

```bash
printf "\ntypedef Match<S extends State<S>> = Piece<S>;\n" >> lib/src/parsing/parser/parser.dart
dart analyze test/name_collision_test.dart
```

Ожидание: те же две ошибки, что в задаче 1, шаг 2. Затем убрать строку:

```bash
git checkout lib/src/parsing/parser/parser.dart
dart analyze test/name_collision_test.dart
```

Ожидание: `No issues found.` **Тест, который не видели красным, — не
тест**; этот видели.

---

### Задача 4: документация, ворота, коммит

**Файлы:**
- Изменить: `README.md`, `README.ru.md`, `CHANGELOG.md`,
  `docs/architecture.md`

- [ ] **Шаг 1: README — оба языка одной правкой**

`README.md:216-235` и `README.ru.md:221-238`. Из списка перекрывающихся
имён уходит `Match`; остаются пять флаттерных (`Text`, `State`, `Stack`,
`Colors`, `Color`), и фраза про вопрос компилятора становится верной,
потому что относится теперь только к ним: Flutter импортируют явно, две
явных стороны дают неоднозначность. Строка `hide` в примере теряет
`Match`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart'
    hide Color, Colors, Stack, State, Text;
```

Фраза «The parser is still `Parser`, and `Matches` — its own name — is
untouched by this» больше не верна: `Matches` стал `Pieces`. Переписать.

Дальше по обоим файлам: примеры с `.matches` → `.pieces` и выводы
`toString` в комментариях (`README.ru.md:770-774` и та же таблица в
английском) — `Match<Style>(…)` → `Piece<Style>(…)`.

- [ ] **Шаг 2: CHANGELOG**

Запись в раздел **Renamed** секции 4.0.0. Черновик, править по вкусу, но
три вещи в нём должны остаться: новое имя, почему старое ушло молча, и
почему моста нет.

```markdown
- `Match` is `Piece`, `Matches` is `Pieces`, and `parser.matches` is
  `parser.pieces`. The old name shadowed `dart:core.Match` silently: an
  explicit import outranks the implicit one, so the compiler never asked
  which was meant, and ordinary code beside this package —
  `for (final Match m in RegExp(r'\w+').allMatches(s))` — failed with two
  errors that named no package. `Piece` is the word this package already
  used for the thing: the class dartdoc opens with "one piece of a parsed
  string", and `_pieceAt`, `nextPiece` and `takePiece` were there before
  the rename. There is deliberately no `typedef Match<S> = Piece<S>` to
  ease the move: it would reintroduce the shadowing this removes. A test
  now holds the name open — it uses `dart:core.Match` beside a single
  import of this package, and fails to compile if the name is ever taken
  back.
```

- [ ] **Шаг 3: architecture.md**

Строки 23, 49, 50, 161: `Match<S>` → `Piece<S>`, путь
`parser/matches/match.dart` → `parser/pieces/piece.dart`, `Matches` →
`Pieces`, `_MatchesResult` → `_PiecesResult`, `Match.link` → `Piece.link`.
**Строку 38 не трогать** — «сразу в `allMatches`» про regex.

- [ ] **Шаг 4: ворота целиком**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
dart run tool/generate.dart && git diff --exit-code -- lib/
dart test
dart run benchmark/memory_guard.dart
dart doc --dry-run
dart pub publish --dry-run
```

Ожидания: формат и анализ чисты; входы «closed»; генератор не даёт
диффа; 811 тестов зелены; удержание памяти в полосе 159…332 (прошлый
замер — 258.2, переименование его не двигает); `dart doc` 0 ошибок и 0
предупреждений; `publish --dry-run` 0 предупреждений.

- [ ] **Шаг 5: последняя проверка имени по всему репозиторию**

```bash
grep -rnE "\bMatch(es)?\b" lib/ test/ example/ benchmark/ README.md README.ru.md docs/architecture.md \
  | grep -v RegExpMatch | grep -v _MatchingState | grep -v allMatches
```

Ожидание: пусто. Печатает — значит место пропущено; разобрать каждое.

- [ ] **Шаг 6: коммит**

Один на всю волну. Тело — повествовательное, по-английски, про «почему»:

```bash
git add -A
git commit
```

Заголовок в духе репозитория, например
`refactor: dart:core keeps its Match, and the parser hands out pieces`.
Префикс `refactor:` — переименование не чинит поведение и не добавляет
функции.
