# План: безопасная обратная сборка вставляемого текста

> **Состояние на 2026-08-16:** исполнен и влит — `2ea6c77`, `32ecb0b`,
> `1e48ee6`, ветка `fix/inserted-unfinished-reemission` слита в `main`
> мержем `d86e75e`; оракул Task 1 при исполнении заменён (`dde8573`):
> `plain` не считается проверяемым `Parser`, тест несёт пары «вход →
> ожидаемый plain» литералами.
> **Что это:** TDD-план H4 — `_insert` придерживает незавершённый код
> вставки и выпускает его перед следующим куском.
> **Связанные записи:** `2026-08-14[1]-inserted-unfinished-code-design.md`,
> `2026-08-14[3]-pre-h4-handoff.md`.

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** `insertBefore` и `insertAfter` сохраняют весь plain-текст
вставки и исходного хвоста, даже когда аргумент `text` кончается внутри
незавершённой escape-последовательности.

**Architecture:** `_seamAt` остаётся без изменений. `_insert` один раз
разбирает аргумент, вычисляет следующие за ним байты и отдаёт готовые
`Piece` новому приватному помощнику: тот копирует законченные сущности
дословно, придерживает `_unfinished` и выпускает его через существующий
`_terminatedOpening` перед следующим куском или перед концом результата.

**Tech Stack:** Dart `^3.6.0`, `package:test`, существующие
`_unfinished`, `_terminatedOpening`, `_firstNotEmpty`, локальные ворота и
GitHub Actions на SDK `3.6.0` и `stable`.

## Global Constraints

- Ожидаемые значения сначала снять пробником с живого кода. Если тест
  падает иначе, объяснить расхождение, а не подгонять ожидание.
- Каждый новый тест увидеть красным до правки реализации; после правки
  вернуть сырой `$text` мутацией и увидеть страж красным ещё раз.
- `_seamAt`, публичный API, `UnfinishedSequenceException`, `RangeError` и
  правила surrogate-пар не менять.
- Законченные байты вставки не оптимизировать и не канонизировать.
- Второго парсинга аргумента не добавлять; использовать готовый
  `_PiecesResult<S>`.
- `README.md` — источник, `README.ru.md` — синхронный перевод в том же
  коммите с той же структурой и кодом примера.
- `docs/backlog.md` не менять; H4 закрывается только в новом handoff.
- Версию `4.0.0` не бампать, пакет не публиковать и тег не создавать.
- Код, dartdoc, README, CHANGELOG и сообщения коммитов — по-английски;
  записи в `docs/` — по-русски.
- Один смысловой фикс — один коммит; последующие документационные
  коммиты не смешивают с ним другие находки.

---

### Task 1: Красный страж и безопасное переиздание вставки

**Files:**
- Modify: `test/parser_insert_test.dart`
- Create: `test/insert_text_unfinished_invariant_test.dart`
- Modify: `lib/src/parsing/parser/parser.dart:720-875`

**Interfaces:**
- Consumes: `_unfinished(Entity)`, `_terminatedOpening(String, String,
  {required bool closing})`, `_firstNotEmpty`.
- Produces: приватный
  `String _terminatedInsertion(String text, _PiecesResult<S> read,
  String following)` внутри `_ParserBase<S>`.
- Preserves: `String insertBefore(int pos, String text)` и
  `String insertAfter(int pos, String text)` без изменения сигнатур.

- [ ] **Step 1: снять текущие и эталонные байты пробником**

Пробник должен напечатать `jsonEncode` результата и его `removeAll` для
двух путей:

```dart
const unfinished = '\x1B]0;t';
final inserted = Parser('abcdef').insertBefore(3, unfinished);
final safe = Parser(unfinished).optimize();
```

Зафиксированное на `main @ c27dc8c` ожидание:

```text
inserted bytes: "abc\u001b]0;tdef"
inserted plain: "abc"
safe bytes: "\u001b]0;t\u001b\\"
safe plain: ""
```

Для остальных форм живой `optimize()` уже дал:

```text
"\u001b"    -> "\u001b\u001b\\"
"\u001b[31" -> "\u001b[\u001b\\31"
"\u001b("   -> "\u001b(\u001b\\"
```

- [ ] **Step 2: добавить точные красные тесты в `parser_insert_test.dart`**

Внутри `main()` добавить группу:

```dart
  group('an unfinished sequence in the inserted text:', () {
    const cases = <String, String>{
      '\x1B]0;t': '\x1B]0;t$ST',
      '\x1B': '\x1B$ST',
      '\x1B[31': '\x1B[$ST' '31',
      '\x1B(': '\x1B($ST',
    };

    for (final entry in cases.entries) {
      test('${entry.key.ansiShowEscapeSequences()} keeps both plain sides',
          () {
        for (final after in [false, true]) {
          final parser = Parser('abcdef');
          final result = after
              ? parser.insertAfter(3, entry.key)
              : parser.insertBefore(3, entry.key);

          expect(result, 'abc${entry.value}def', reason: 'after: $after');
          expect(
            Parser(result).removeAll(),
            'abc${Parser(entry.key).removeAll()}def',
            reason: 'after: $after',
          );
        }
      });
    }

    test('the end of the result is a closing boundary', () {
      expect(
        Parser('abc').insertBefore(3, '\x1B]0;t'),
        'abc\x1B]0;t$ST',
      );
    });

    test('an ESC already following supplies the boundary', () {
      expect(
        Parser('abc${fgRed}def$reset').insertBefore(3, '\x1B]0;t'),
        'abc\x1B]0;t${fgRed}def$reset',
        reason: 'the SGR starts with the ESC the OSC is waiting for',
      );
    });

    test('the hyperlink repair supplies the boundary too', () {
      const opening = '\x1B]8;;http://a/';

      expect(
        Parser('abcdef').insertBefore(3, opening),
        'abc$opening${linkClose}def',
        reason: 'linkClose starts with ESC and must not be preceded by ST',
      );
    });

    test('a close:false slice composes with insertion', () {
      final slice =
          Parser('hi\x1B]0;window title').substring(0, close: false);
      final result = Parser('abcdef').insertBefore(3, slice);

      expect(result, 'abchi\x1B]0;window title${ST}def');
      expect(Parser(result).removeAll(), 'abchidef');
    });

    test('the stacked parser and string extension take the same path', () {
      expect(
        StackedParser('abcdef').insertAfter(3, '\x1B]0;t'),
        'abc\x1B]0;t${ST}def',
      );
      expect(
        'abcdef'.ansiInsertBefore(3, '\x1B]0;t'),
        'abc\x1B]0;t${ST}def',
      );
    });
  });
```

- [ ] **Step 3: добавить корпус plain-инварианта**

Создать `test/insert_text_unfinished_invariant_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

const _inputs = <String>[
  'abcdef',
  '${fgRed}abc${reset}def',
  'ab${linkOpen}https://a/$linkTextOpen'
      'cd${linkClose}ef',
];

const _insertions = <String>[
  '',
  'plain',
  '\x1B]0;t',
  '\x1B',
  '\x1B[31',
  '\x1B(',
  '\x1B]0;t\x1B[31',
  '\x1B[31\x1B[0m',
  '\x1B]0;t\x1B[0mword',
];

void main() {
  test('insertion preserves the parser model of all three texts', () {
    for (final input in _inputs) {
      final plain = Parser(input).removeAll();
      for (var pos = 0; pos <= plain.length; pos++) {
        for (final insertion in _insertions) {
          final insertedPlain = Parser(insertion).removeAll();
          final expected = '${plain.substring(0, pos)}'
              '$insertedPlain${plain.substring(pos)}';

          for (final after in [false, true]) {
            final parser = Parser(input);
            final result = after
                ? parser.insertAfter(pos, insertion)
                : parser.insertBefore(pos, insertion);

            expect(
              Parser(result).removeAll(),
              expected,
              reason: 'input ${input.ansiShowEscapeSequences()}, '
                  'insertion ${insertion.ansiShowEscapeSequences()}, '
                  'pos $pos, after: $after',
            );
          }
        }
      }
    }
  });
}
```

Корпус намеренно не содержит surrogate-пар: у них старый контракт
сдвигает `pos`, и его уже держит `parser_insert_surrogates_test.dart`.

- [ ] **Step 4: увидеть тесты красными и объяснить падения**

Run:

```bash
rtk dart test test/parser_insert_test.dart \
  test/insert_text_unfinished_invariant_test.dart
```

Expected: новые точные тесты и plain-инвариант падают. Для `OSC 0`
результат содержит сырой `abc\x1B]0;tdef` и plain `abc`; для оборванного
`CSI` — plain `abcef` вместо `abc31def`. Старые тесты проходят.

- [ ] **Step 5: заменить сырую сборку на приватный помощник**

В `_insert` вычислить следующие части один раз и передать их помощнику:

```dart
    final linkBack = _linkBack(seam: ambientLink, left: read.finalLink);
    final transit = read.finalState.toStyle().transitTo(ambient);
    final tail = input.substring(cut);
    final following = _firstNotEmpty(linkBack, transit, tail);
    final insertion = _terminatedInsertion(text, read, following);

    return '${input.substring(0, cut)}'
        '$insertion$linkBack$transit$tail';
```

Сразу за `_insert` добавить:

```dart
  /// [text] copied byte for byte, save for the `ST` an unfinished sequence
  /// needs before text or at the closed edge of the insertion result.
  ///
  /// The argument has already been parsed for its final state and link. Its
  /// pieces are reused here: a second parse would answer the same question
  /// and make every insertion pay for it twice. The fast path returns [text]
  /// itself where no sequence needs holding, so ordinary insertions allocate
  /// no extra copy.
  String _terminatedInsertion(
    String text,
    _PiecesResult<S> read,
    String following,
  ) {
    if (!read.pieces.any((piece) => _unfinished(piece.entity))) {
      return text;
    }

    final buf = StringBuffer();
    var heldOpening = '';

    for (final piece in read.pieces) {
      final entity = piece.entity;
      final string = entity.string;

      if (heldOpening.isNotEmpty) {
        buf.write(
          _terminatedOpening(heldOpening, string, closing: false),
        );
        heldOpening = '';
      }

      if (_unfinished(entity)) {
        heldOpening = string;
      } else {
        buf.write(string);
      }
    }

    buf.write(
      _terminatedOpening(heldOpening, following, closing: true),
    );

    return buf.toString();
  }
```

- [ ] **Step 6: прогнать форматирование, анализ и оба тестовых файла**

Run:

```bash
rtk dart format --output=none --set-exit-if-changed \
  lib/src/parsing/parser/parser.dart \
  test/parser_insert_test.dart \
  test/insert_text_unfinished_invariant_test.dart
rtk dart analyze --fatal-infos
rtk dart test test/parser_insert_test.dart \
  test/insert_text_unfinished_invariant_test.dart
```

Expected: всё PASS, анализ без diagnostics.

- [ ] **Step 7: доказать красноту мутацией и вернуть исправление**

Временно заменить `$insertion` в возврате `_insert` на `$text`, не меняя
остальной код. Повторить два тестовых файла: точные тесты и инвариант
обязаны упасть теми же plain-расхождениями. Вернуть `$insertion`, повторить
прогон и получить PASS.

- [ ] **Step 8: обновить dartdoc и сделать коммит фикса**

В dartdoc `insertBefore`, сразу после абзаца о возврате стиля, добавить:

```dart
  /// If the inserted text itself ends inside an escape sequence the parser
  /// could not finish, the sequence is terminated before text follows it and
  /// at the end of the result. This is the other side of the unfinished-input
  /// rule below: that rule keeps the insertion out of the input's sequence;
  /// this one keeps the input's tail out of the insertion's sequence.
```

`insertAfter` уже говорит, что во всём прочем совпадает с
`insertBefore`; отдельный дубль не добавлять.

Run:

```bash
rtk dart format --output=none --set-exit-if-changed .
rtk dart analyze --fatal-infos
rtk dart test test/parser_insert_test.dart \
  test/insert_text_unfinished_invariant_test.dart
```

Commit:

```bash
rtk git add lib/src/parsing/parser/parser.dart \
  test/parser_insert_test.dart \
  test/insert_text_unfinished_invariant_test.dart
rtk git commit -m "fix: unfinished inserted code cannot consume the tail" \
  -m "Insertion arguments were parsed for their state and link but copied raw, so an unfinished sequence could continue into both its own parser-text and the original suffix. Reemit only that boundary through the shared terminator rule while keeping every completed byte unchanged."
```

---

### Task 2: Публичная документация и карта механизма

**Files:**
- Modify: `README.md`
- Modify: `README.ru.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/architecture.md`

**Interfaces:**
- Consumes: принятый контракт `_terminatedInsertion` из Task 1.
- Produces: синхронное описание двух сторон незавершённой вставки для
  пользователя и следующего агента.

- [ ] **Step 1: дополнить английский README**

После первого примера `insertBefore` в разделе вставок добавить:

```markdown
If the inserted text itself ends inside an escape sequence the parser could
not finish, the sequence is terminated before the original tail follows it.
This is the other side of the unfinished-input rule below: that rule keeps the
insertion out of the input's sequence; this one keeps the input's tail out of
the insertion's sequence.
```

- [ ] **Step 2: синхронно дополнить русский README**

В том же месте и с той же структурой добавить:

```markdown
Если сам вставляемый текст кончается внутри escape-последовательности, которую
парсер не смог закончить, перед исходным хвостом последовательность получает
терминатор. Это вторая сторона описанного ниже правила незавершённого входа:
то правило не пускает вставку внутрь последовательности исходника, а это —
исходный хвост внутрь последовательности вставки.
```

- [ ] **Step 3: записать исправление в CHANGELOG**

В секции `4.0.0`, под `Fixed:`, рядом с прежним исправлением ссылочной
вставки добавить:

```markdown
- An unfinished escape sequence in the inserted text swallowed the original
  tail: a truncated `OSC` consumed it whole, while a truncated `CSI` took its
  first byte as the missing final byte. Insertions now preserve the same text
  model as `optimize`, `substring` and the printers, without rewriting
  completed escape codes.
```

- [ ] **Step 4: связать пятую поверхность в architecture**

В механизме 2 `docs/architecture.md`, после перечисления четырёх выходов,
добавить отдельный абзац:

```markdown
Вставки — пятая поверхность того же правила, но с другой границей:
`_seamAt` защищает аргумент от незавершённого кода исходника, а
`_terminatedInsertion` защищает исходный хвост от незавершённого кода в
аргументе. Вставка копирует законченные сущности дословно и пользуется тем же
`_terminatedOpening` только для придержанного кода; прогонять аргумент через
`optimize` нельзя, потому что тот пересобирает `SGR`.
```

- [ ] **Step 5: проверить синхронность и закоммитить документы**

Run:

```bash
rtk dart format --output=none --set-exit-if-changed .
rtk dart analyze --fatal-infos
rtk git diff --check
```

Вручную сверить, что абзац стоит в одном месте обоих README, порядок
разделов и код примеров не разошлись.

Commit:

```bash
rtk git add README.md README.ru.md CHANGELOG.md docs/architecture.md
rtk git commit -m "docs: distinguish both unfinished insertion boundaries" \
  -m "The seam rule already explains unfinished sequences in the source, but the symmetric risk in the insertion argument was invisible. Name both boundaries so the raw-copy regression is not reintroduced."
```

---

### Task 3: Полные ворота и финальное ревью ветки

**Files:**
- Review: весь diff `main...fix/inserted-unfinished-reemission`
- Fix confirmed findings only in: `lib/src/parsing/parser/parser.dart`,
  `test/parser_insert_test.dart`,
  `test/insert_text_unfinished_invariant_test.dart`, `README.md`,
  `README.ru.md`, `CHANGELOG.md`, `docs/architecture.md`

**Interfaces:**
- Consumes: код, тесты и документацию Tasks 1–2.
- Produces: ветку без подтверждённых дефектов и с полностью зелёными
  локальными воротами.

- [ ] **Step 1: прогнать все локальные ворота**

Сначала подтвердить чистое дерево. После двух коммитов Tasks 1–2 простой
`git diff --exit-code -- lib/` уже отличает работу генератора от работы
ветки и потому служит точной проверкой:

```bash
rtk git status --short
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

Expected: исходное дерево чистое, формат чист, analyze без diagnostics,
entry points closed, генератор не меняет `lib/`, все тесты PASS, memory
guard внутри актуальной полосы из `docs/handoff.md`, dartdoc 0/0, publish
dry-run без предупреждений.

- [ ] **Step 2: провести строгое ревью всего diff**

Проверить как минимум:

- все требования `2026-08-14[1]` имеют код или тест;
- `read.pieces` не парсится второй раз;
- fast path возвращает исходный `text` без копии;
- оборванный `CSI` получает `ST` перед своим `Text`, не после него;
- следующий `ESC`, `linkClose`, ambient-transition и конец строки
  различаются правильно;
- `_seamAt`, исключения, surrogate-пары и законченные коды не изменились;
- README EN/RU синхронны;
- тест действительно был красным при мутации.

Любое подтверждённое замечание исправить через красный тест, повторить
затронутые и полные ворота и закоммитить отдельным conventional-коммитом с
английским объяснением причины.

- [ ] **Step 3: проверить чистоту ветки**

Run:

```bash
rtk git status --short --branch
rtk git diff --check main...HEAD
rtk git log --oneline --decorate main..HEAD
```

Expected: рабочее дерево чистое, diff-check пуст, в ветке только спека,
план, фикс, синхронная документация и возможные подтверждённые review-fix.

---

### Task 4: CI, merge и новый handoff

**Files:**
- Archive: `docs/handoff.md` в следующий свободный
  `docs/records/2026-08-14[3]-pre-h4-handoff.md`
- Rewrite: `docs/handoff.md`

**Interfaces:**
- Consumes: зелёную и отревьюированную ветку Task 3.
- Produces: зелёный `main`, запушенный в `origin`, и handoff без H4 в
  открытых High.

- [ ] **Step 1: запушить ветку и дождаться обеих ног CI**

```bash
rtk git push -u origin fix/inserted-unfinished-reemission
rtk gh run list --branch fix/inserted-unfinished-reemission --limit 5
```

Дождаться завершения нужного прогона и проверить обе матричные ноги SDK
`3.6.0` и `stable`. Красный CI расследовать по логам; не сливать ветку,
пока он не зелёный.

- [ ] **Step 2: слить ветку обычным merge-коммитом и запушить main**

```bash
rtk git switch main
rtk git merge --no-ff fix/inserted-unfinished-reemission \
  -m "merge: inserted unfinished code gives the original tail back"
rtk git push origin main
```

Дождаться зелёного CI на merge-коммите `main`.

- [ ] **Step 3: архивировать прежний handoff и переписать текущий**

Архивная запись сохраняет прежний текст с шапкой состояния документа:
это handoff до H4, закрытый соответствующим merge-коммитом; его prose не
переписывается. Новый `docs/handoff.md` должен содержать фактические:

- хэши fix- и merge-коммитов;
- номер зелёного CI ветки и `main`, обе ноги SDK;
- результаты восьми локальных ворот и новое число тестов;
- H4 в таблице закрытых и без него в открытых High;
- H6 как следующий кандидат на разбор, H7/H8 как требующие решения;
- отсутствие рабочих веток после их безопасного удаления;
- прежние запреты на публикацию, version bump и 8-bit C1.

Коммит:

```bash
rtk git add docs/handoff.md \
  'docs/records/2026-08-14[3]-pre-h4-handoff.md'
rtk git commit -m "docs: hand off the package after the inserted-code fix" \
  -m "H4 is merged and verified on both supported SDK legs, so the live handoff now points at the remaining findings and preserves the completed wave as a record."
rtk git push origin main
```

Дождаться зелёного CI документационного коммита на `main`.

- [ ] **Step 4: удалить отработавшую ветку и проверить финальное состояние**

После зелёного CI `main`:

```bash
rtk git branch -d fix/inserted-unfinished-reemission
rtk git push origin --delete fix/inserted-unfinished-reemission
rtk git status --short --branch
rtk git log -5 --oneline --decorate
```

Expected: `main...origin/main`, дерево чистое, ветки H4 нет локально и на
remote, H4 закрыта в handoff. Тег и публикацию не выполнять.
