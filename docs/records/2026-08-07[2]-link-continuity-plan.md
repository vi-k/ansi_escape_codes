# План: непрерывность гиперссылки (N5)

> **Состояние на 2026-08-16:** доведена и влита в `main` мержем `5623e12`.
> Оба долга, оставленных волной, с тех пор закрыты: незавершённый
> не-ссылочный `OSC` — мержем `57b8443`, `lastState` у `prepare` синка —
> мержем `73d725d`. Текст плана называет второй долг открытым: это неверно
> с 2026-08-11, находка M15 ревью `2026-08-13[5]`. Ссылки в прозе старые —
> записи лежат в `docs/records/`, `TODO.md` стал `docs/backlog.md`.
> **Что это:** план реализации непрерывности гиперссылки — срез, печать и
> вставка переоткрывают ссылку исходными байтами, канал ссылки едет рядом
> с `State`.
> **Связанные записи:** `2026-08-07[1]-link-continuity-design.md`,
> `2026-08-05[9]-review-verification-report.md` (оттуда находка N5).

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ссылка ведёт себя как стиль: срез, напечатанная строка и вставка переоткрывают её, а пакет умеет ответить, какая ссылка открыта в позиции.

**Architecture:** Канал «открытая ссылка» едет рядом с `State`, а не внутри него: `_ParserIterator` ведёт его как производную (по образцу `currentState`), `Match` отдаёт полем `link`, конструкторы парсера/`Matches`/`_MatchesResult` принимают засев `initialLink`. Поверхности (срез, принтеры, вставка, `optimize`) читают канал и переоткрывают ссылку **исходными байтами** её открытия. `State`, `Style`, `Stack`, `transitTo` не трогаются.

**Tech Stack:** Dart 3.6+, `dart test`, `--fatal-infos`; сторож `benchmark/memory_guard.dart`, замыкание `tool/check_entry_points.dart`.

**Спека:** `docs/2026-08-07[1]-link-continuity-design.md` — читать до первой задачи; она объясняет ПОЧЕМУ канал рядом, а не внутри `State`.

## Global Constraints

- Версию в pubspec **НЕ бампать** (4.0.0 не опубликована; user-visible правки — в секцию 4.0.0 CHANGELOG).
- Один фикс — один коммит; повествовательные сообщения в голосе `git log`; трейлер `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.
- После каждой задачи зелёные: `dart format --output=none --set-exit-if-changed .`, `dart analyze --fatal-infos`, `dart test`.
- TDD: где задача меняет поведение — сначала красный тест, RED-вывод в отчёт.
- Комментарии и dartdoc — на английском, в голосе окружающего текста (полные предложения, «почему», не «что»).
- `State`, `Style`, `Stack`, `transitTo`, генератор и таблицы цветов — **не трогать**.
- Переоткрытие пишет **исходные байты открытия** (`Link.string`), не канонизированную форму: BEL остаётся BEL, `id=` доезжает.

---

### Task 1: Канал в итераторе и поле `Match.link`

**Files:**
- Modify: `lib/src/parsing/parser/entities/match.dart` (класс `Match`)
- Modify: `lib/src/parsing/parser/matches/parser_iterator.dart`
- Modify: `lib/src/parsing/parser/matches/matches.dart`, `matches_result.dart`
- Modify: `lib/src/parsing/parser/parser.dart` (`_ParserBase` — поле и конструктор)
- Test: `test/link_channel_test.dart` (создать)

**Interfaces (на них опираются задачи 2-6):**
- Produces: `final Link? link` на `Match<S>` — ссылка, действующая на этом куске: для `Text` — та, внутри которой лежит текст; для escape-кода — та, которую он **оставляет за собой**; `null` — ссылка не открыта.
- Produces: `Link? get currentLink` на `_ParserIterator` (внутренний, зеркало `currentState`).
- Produces: `Link? initialLink` — необязательный именованный параметр `_ParserBase`, `Matches._`, `_MatchesResult`; по умолчанию `null`. Публичные `Parser(String input)` / `StackedParser(String input)` его **не принимают** (зеркало `initialState`, который у них фиксирован).

- [ ] **Step 1: Красный тест**

Создать `test/link_channel_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('a match says which link it stands in:', () {
    test('the text inside a link carries it, the text after does not', () {
      final parser = Parser('a${link('http://u/')}in${linkClose}out');
      final links = [for (final m in parser.matches) m.link?.url];

      expect(links, [null, 'http://u/', 'http://u/', null]);
    });

    test('an opening supersedes the one before it', () {
      final parser =
          Parser('${link('http://a/')}x${link('http://b/')}y');
      final urls = [
        for (final m in parser.matches)
          if (m.entity is Text) m.link?.url,
      ];

      expect(urls, ['http://a/', 'http://b/']);
    });

    test('a link left open runs to the end', () {
      final parser = Parser('${link('http://u/')}tail');

      expect(parser.matches.last.link?.url, 'http://u/');
    });

    test('a close with nothing open leaves nothing open', () {
      final parser = Parser('${linkClose}x');

      expect(parser.matches.last.link, isNull);
    });

    test('the same answers come back from the cache', () {
      final parser = Parser('a${link('http://u/')}b${linkClose}c');
      final first = [for (final m in parser.matches) m.link?.url];
      final second = [for (final m in parser.matches) m.link?.url];

      expect(second, first);
    });
  });
}
```

- [ ] **Step 2: Убедиться, что красный**

Run: `dart test test/link_channel_test.dart`
Expected: FAIL при компиляции — `Match` не имеет `link`.

- [ ] **Step 3: Поле на `Match`**

В `match.dart` рядом с `state` (сохранить стиль dartdoc соседа):

```dart
  /// The link in force at this piece, or `null` where none is open.
  ///
  /// For [Text] it is the link the text sits inside; for an escape code, the
  /// link that code leaves behind it — the same way [state] is read. A link
  /// does not nest: an opening supersedes the one before it, and a close ends
  /// whatever was open.
  final Link? link;
```

Добавить в приватный конструктор `Match._` как `required this.link` и протянуть оба места создания (`parser_iterator.dart`, функции `_text` и `_escapeCode`). Дописать `link` в `toString()` рядом с `state`.

- [ ] **Step 4: Канал в итераторе**

В `_ParserIterator`: поле `final Link? _initialLink;` (через конструктор), геттер-зеркало `currentState`. **Не** `_current?.link ?? _initialLink` — эта запись склеивает «матча ещё нет» и «ссылка закрыта», и засеянная ссылка воскресает после каждого закрытия (у `currentState` так можно только потому, что `S` не-nullable):

```dart
  /// The link open at this point, the way [currentState] is the state.
  ///
  /// Told apart by the match, not by the link: a closed link is a `null` of
  /// its own, and falling back to the seed would raise it from the dead.
  Link? get currentLink {
    final current = _current;

    return current == null ? _initialLink : current.link;
  }
```

В `_escapeCode` вычислять ссылку сущности до создания `Match`:

```dart
    final link = switch (entity) {
      Link(:final url) => url.isEmpty ? null : entity,
      _ => currentLink,
    };
```

`_text` берёт `currentLink`. Кэш-путь `moveNext` (ветка `_index < parsed.length`) `link` не пересчитывает — он лежит в самом `Match`, как и `state`; переигрывать, как `_saved`, ничего не нужно.

- [ ] **Step 5: Засев**

`_ParserBase`: поле `final Link? initialLink;` и конструктор `_ParserBase(this.input, this.initialState, {this.initialLink});`. Протянуть в `Matches._`, `_MatchesResult`, `_createIterator` и в `_ParserIterator._`. Публичные `Parser`/`StackedParser` конструкторы **не меняются**.

- [ ] **Step 6: Зелёный + ворота**

Run: `dart test test/link_channel_test.dart && dart test && dart analyze --fatal-infos && dart format --output=none --set-exit-if-changed . && dart run tool/check_entry_points.dart`
Expected: всё зелёное; замыкание точек входа — `5 entry points, closed` (новое публичное поле типа `Link`, а `Link` уже экспортируется — проверить, что скрипт это подтверждает).

- [ ] **Step 7: Commit**

```bash
git add lib test/link_channel_test.dart
git commit -m "feat: a match says which link it stands in"
```

---

### Task 2: `linkAt` и `finalLink`

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart` (рядом со `stateAt`, `finalState`)
- Test: `test/link_at_test.dart` (создать)

**Interfaces:**
- Consumes: `Match.link`, `_Walk` (возобновляемый обход из `stateAt`).
- Produces: `Link? linkAt(int pos)`, `Link? get finalLink` на `_ParserBase` (наследуются `Parser` и `StackedParser`).

**Граница (главное в задаче):** позиция принадлежит куску, пока `plain > pos` в текстовой ветке; ветка `Link` выхода не даёт вовсе. Проверка `plain >= pos` даёт сдвиг на символ и ошибается на пяти формах из шести.

- [ ] **Step 1: Красный тест — шесть форм**

Создать `test/link_at_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The link each position of the plain text sits in, as a picture: a letter
/// per link, `-` where none is open.
String _picture(Parser parser, Map<String, String> names) {
  final buf = StringBuffer();
  for (var i = 0; i < parser.length; i++) {
    final url = parser.linkAt(i)?.url;
    buf.write(url == null ? '-' : names[url]);
  }

  return buf.toString();
}

void main() {
  group('linkAt answers for the position, not the piece after it:', () {
    const a = 'http://a/';
    const b = 'http://b/';
    const names = {a: 'A', b: 'B'};

    test('a link closed in the middle', () {
      final parser = Parser('ab${link(a)}cd${linkClose}ef');

      expect(_picture(parser, names), '--AA--');
    });

    test('a link left open to the end', () {
      final parser = Parser('ab${link(a)}cdef');

      expect(_picture(parser, names), '--AAAA');
    });

    test('a link superseded by another', () {
      final parser = Parser('ab${link(a)}cd${link(b)}ef');

      expect(_picture(parser, names), '--AABB');
    });

    test('a link opened the BEL way', () {
      final parser = Parser('ab${linkBel(a)}cd${linkClose}ef');

      expect(_picture(parser, names), '--AA--');
    });

    test('a close standing on its own', () {
      final parser = Parser('ab${linkClose}cdef');

      expect(_picture(parser, names), '------');
    });

    test('a link that opens at nought', () {
      final parser = Parser('${link(a)}abcd${linkClose}ef');

      expect(_picture(parser, names), 'AAAA--');
    });
  });

  group('finalLink is what the string leaves open:', () {
    test('nothing, where the string closed it', () {
      expect(Parser('${link('http://u/')}x$linkClose').finalLink, isNull);
    });

    test('the link, where it did not', () {
      expect(Parser('${link('http://u/')}x').finalLink?.url, 'http://u/');
    });
  });

  test('linkAt keeps its place the way stateAt does', () {
    final text = List.generate(
      50,
      (i) => 'line $i ${link('http://$i/')}word$linkClose\n',
    ).join();
    final resumed = Parser(text);
    final answers = <String?>[];
    for (var i = 0; i < resumed.length; i += 7) {
      answers.add(resumed.linkAt(i)?.url);
    }

    final fresh = <String?>[];
    for (var i = 0; i < Parser(text).length; i += 7) {
      fresh.add(Parser(text).linkAt(i)?.url);
    }

    expect(answers, fresh);
  });
}
```

Сверить фактические имена `link`/`linkBel`/`linkClose` по `lib/src/ready_to_use/osc.dart` и поправить вызовы, если сигнатуры иные (например, `link(url, text: …)`); картиночный оракул и ожидания — не менять.

- [ ] **Step 2: Убедиться, что красный**

Run: `dart test test/link_at_test.dart`
Expected: FAIL — `linkAt`/`finalLink` не объявлены.

- [ ] **Step 3: Реализация**

`linkAt` — по образцу `stateAt` (тот же `_Walk`, та же логика возобновления), но возвращает `m.link`; на пустой строке и за концом — как `stateAt` (сверить его контракт и повторить, включая `RangeError`, если он там есть). `finalLink` — по образцу `finalState`, берёт `link` последнего матча (или `initialLink`, если матчей нет).

- [ ] **Step 4: Зелёный + ворота**

Run: `dart test test/link_at_test.dart && dart test && dart analyze --fatal-infos && dart format --output=none --set-exit-if-changed .`

- [ ] **Step 5: Commit**

```bash
git add lib test/link_at_test.dart
git commit -m "feat: the parser answers which link a position sits in"
```

---

### Task 3: Срез переоткрывает ссылку

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart` (`substring`, ~строки 307-425; dartdoc ~276-306)
- Modify: `test/parser_substring_links_test.dart` (два теста меняют ожидания)
- Test: дописать туда же новые случаи

**Правила:**
1. Срез, начатый внутри ссылки, пишет её открытие (исходными байтами `Link.string`) перед первым куском.
2. `close: true` закрывает открытую в конце среза ссылку (как сегодня); `close: false` — переоткрывает, но не закрывает.
3. Сущность `Link`, чья запись ничего не меняет в том, что открыто **в выводе**, не пишется: закрытие, когда в выводе ничего не открыто; открытие ссылки, уже открытой в выводе той же последовательностью. Вытеснение одной ссылки другой пишется как раньше.

- [ ] **Step 1: Красные тесты**

В `test/parser_substring_links_test.dart` заменить ожидания двух тестов (сегодня они пинят отсутствие переоткрытия — «does not close what it did not open», «a resumed walk stays outside a link it did not open») на переоткрытие и добавить:

```dart
    test('a slice inside a link opens it in the form it was opened', () {
      final parser = Parser('ab${linkBel('http://u/')}cdef$linkClose');

      expect(
        parser.substring(3, maxLength: 2),
        '${linkBel('http://u/')}de$linkClose',
      );
    });

    test('a slice with close: false reopens but does not close', () {
      final parser = Parser('ab${link('http://u/')}cdef$linkClose');

      expect(
        parser.substring(3, maxLength: 2, close: false),
        '${link('http://u/')}de',
      );
    });

    test('a close that closes nothing is not written', () {
      final parser = Parser('ab${link('http://u/')}cd${linkClose}ef');

      expect(parser.substring(4, maxLength: 2), 'ef');
    });

    test('an empty slice of a linked string is empty', () {
      final parser = Parser('${link('http://u/')}abc$linkClose');

      expect(parser.substring(0, maxLength: 0), '');
    });
```

Точные байты `linkBel(...)`/`link(...)` сверить с `lib/src/ready_to_use/osc.dart`; если `link()` принимает текст, использовать ту форму, что даёт голое открытие.

- [ ] **Step 2: Убедиться, что красные**

Run: `dart test test/parser_substring_links_test.dart`
Expected: FAIL на четырёх новых и двух переписанных.

- [ ] **Step 3: Реализация**

В `substring`: вместо `var linkIsOpen = false` вести `Link? writtenLink` — что открыто **в выводе**. Перед первым записанным куском, если `m.link != null && writtenLink == null`, писать `m.link!.string` и присваивать `writtenLink`. В ветке `EscapeCode` для `entity is Link` писать сущность только если её эффект меняет `writtenLink` (правило 3), и обновлять `writtenLink`. В конце: `if (close && writtenLink != null) buf.write(linkClose);`.

- [ ] **Step 4: Зелёный + ворота**

Run: `dart test test/parser_substring_links_test.dart && dart test && dart analyze --fatal-infos && dart format --output=none --set-exit-if-changed .`
Expected: всё зелёное. Если падают `parser_substring_trailing_codes_test.dart` или дифференциальные — разобраться, не подгонять.

- [ ] **Step 5: Dartdoc**

Переписать абзац про ссылки у `substring` (~276-306): срез самодостаточен — открывает ссылку, внутри которой начался, и закрывает при `close: true`; открытие идёт в исходной форме, включая параметры вроде `id=`; закрытие всегда `linkClose`.

- [ ] **Step 6: Commit**

```bash
git add lib test/parser_substring_links_test.dart
git commit -m "fix: a slice opens the link it starts inside"
```

---

### Task 4: Принтеры несут ссылку через строки

**Files:**
- Modify: `lib/src/parsing/parser/printer.dart`
- Modify: `test/printer_links_test.dart` (два теста меняют ожидания)
- Modify: `lib/src/parsing/state/style.dart` (dartdoc `Style.call` — ограничение снимается)

**Механика:** два поля вместо `_linkIsOpen`: `Link? _writtenLink` (открыто в выводе текущей строки) и `Link? _ambientLink` (открыто логически, переезжает через границу строк). Парсер строки строится с `initialLink: _ambientLink`. В конце строки, где закрывается стиль, закрывается и ссылка (`_writtenLink != null` → `linkClose`), а `_ambientLink` сохраняется — следующая строка его переоткроет. Публичный `prepare` у синка сохраняет и возвращает **оба** поля (как сегодня одно).

- [ ] **Step 1: Красные тесты**

В `test/printer_links_test.dart` переписать ожидания двух тестов («a newline inside a write ends the line there», «a link is not carried into the next line») и добавить:

```dart
    test('a printed line reopens the link the line before left open', () {
      final printer = Printer();

      expect(
        printer.prepare('${link('http://u/')}first'),
        '$reset${link('http://u/')}first$linkClose',
      );
      expect(
        printer.prepare('second'),
        '$reset${link('http://u/')}second$linkClose',
      );
    });

    test('a closed link is not carried on', () {
      final printer = Printer();

      printer.prepare('${link('http://u/')}first$linkClose');

      expect(printer.prepare('second'), '${reset}second');
    });

    test('a multi-line styled call keeps its link', () {
      expect(
        Styles.red('${link('http://u/')}one\ntwo$linkClose'),
        contains('two'),
      );
      expect(
        Styles.red('${link('http://u/')}one\ntwo$linkClose')
            .split('\n')[1],
        startsWith('${link('http://u/')}'),
      );
    });
```

Ожидаемые байты `prepare` сверить пробой на текущем коде (префикс `reset`, порядок стиля и ссылки) и записать фактические — семантика (переоткрытие есть, закрытие в конце строки) обязательна, точная перестановка байт — по факту.

- [ ] **Step 2: Убедиться, что красные**

Run: `dart test test/printer_links_test.dart`

- [ ] **Step 3: Реализация**

Заменить `_linkIsOpen` на пару полей; в `_prepare` строить парсер как `_ParserBase<S>(line, this.lastState ?? stateDefaults, initialLink: _ambientLink)`; переоткрывать `_ambientLink` перед первым куском; вести `_writtenLink` по правилу задачи 3 (no-op не писать); в конце строки закрывать `_writtenLink`, `_ambientLink` не трогать; в сохранении/возврате у синка — оба поля.

- [ ] **Step 4: Зелёный + ворота**

Run: `dart test test/printer_links_test.dart && dart test && dart analyze --fatal-infos && dart format --output=none --set-exit-if-changed .`

- [ ] **Step 5: Dartdoc**

`printer.dart`: абзацы про ссылку — теперь она переезжает на следующую строку, как стиль; синк — внутристрочный перенос между `write` плюс межстрочный. `style.dart` (`Style.call`): снять оговорку про ссылку, разрываемую переносом.

- [ ] **Step 6: Commit**

```bash
git add lib test/printer_links_test.dart
git commit -m "fix: a printed line takes the link the line before left open"
```

---

### Task 5: Вставка возвращает ссылку

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart` (`_seamAt`, `_insert`, `_closeLink`, dartdoc `insertBefore`/`insertAfter`)
- Test: `test/parser_insert_links_test.dart` (создать)

- [ ] **Step 1: Красный тест**

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('an insertion gives the link back:', () {
    test('text inserted inside a link stays inside it', () {
      final parser = Parser('${link('http://u/')}abcd$linkClose');
      final result = parser.insertBefore(2, 'X');

      expect(Parser(result).linkAt(2)?.url, 'http://u/');
      expect(Parser(result).linkAt(3)?.url, 'http://u/');
    });

    test('an insertion with its own link reopens the outer one', () {
      final parser = Parser('${link('http://outer/')}abcd$linkClose');
      final result = parser.insertBefore(
        2,
        '${link('http://inner/')}X$linkClose',
      );

      expect(Parser(result).linkAt(2)?.url, 'http://inner/');
      expect(Parser(result).linkAt(3)?.url, 'http://outer/');
    });

    test('an insertion outside any link opens none', () {
      final parser = Parser('abcd');

      expect(Parser(parser.insertBefore(2, 'X')).linkAt(2), isNull);
    });
  });
}
```

- [ ] **Step 2: Убедиться, что красный** (второй тест — точно; первый может проходить уже)

Run: `dart test test/parser_insert_links_test.dart`

- [ ] **Step 3: Реализация**

`_seamAt` возвращает тройку (позиция, состояние, `Link?`); `_insert` после вставленного текста переоткрывает ссылку шва, если она есть и вставка её перебила; `_closeLink` (скан матчей) заменить на `finalLink` вставляемого куска.

- [ ] **Step 4: Зелёный + ворота + dartdoc**

Run: `dart test && dart analyze --fatal-infos && dart format --output=none --set-exit-if-changed .`
Снять из dartdoc `insertBefore`/`insertAfter` абзац «Hyperlinks are the one thing that cannot be given back» и сказать, что ссылка возвращается, как стиль.

- [ ] **Step 5: Commit**

```bash
git add lib test/parser_insert_links_test.dart
git commit -m "fix: an insertion gives back the link it interrupted"
```

---

### Task 6: `optimize` закрывает ссылку

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart` (`optimize`, dartdoc ~613-619)
- Test: `test/parser_optimize_test.dart` (дописать; если файла нет — создать `test/parser_optimize_links_test.dart`)

- [ ] **Step 1: Красный тест**

```dart
    test('optimize closes the link the string left open', () {
      final parser = Parser('${link('http://u/')}abc');

      expect(parser.optimize(), endsWith(linkClose));
    });

    test('optimize with close: false leaves it open', () {
      final parser = Parser('${link('http://u/')}abc');

      expect(parser.optimize(close: false), isNot(endsWith(linkClose)));
    });
```

Сверить фактическую сигнатуру `optimize` (есть ли `close`) и адаптировать; если параметра нет — закрывать всегда и второй тест не писать.

- [ ] **Step 2-4: Красный → реализация (`finalLink` в конце) → зелёный + ворота + dartdoc**

Снять из dartdoc строку о том, что ссылка остаётся открытой; в TODO.md вычеркнуть соответствующую половину пункта N10/N11, если она там ещё есть.

- [ ] **Step 5: Commit**

```bash
git commit -m "fix: the optimizer closes the link it carried"
```

---

### Task 7: ESC 7 / ESC 8 несут ссылку

**Files:**
- Modify: `lib/src/parsing/parser/matches/parser_iterator.dart` (`_saved`)
- Test: `test/link_channel_test.dart` (дописать группу)

- [ ] **Step 1: Красный тест**

```dart
  test('save and restore carry the link with the rest', () {
    final parser = Parser(
      '${link('http://u/')}a${saveCursor}b$linkClose'
      'c${restoreCursor}d',
    );

    expect(parser.linkAt(parser.length - 1)?.url, 'http://u/');
  });
```

Имена констант `saveCursor`/`restoreCursor` сверить с `lib/src/ready_to_use/` (там же, где `ESC 7`/`ESC 8`).

- [ ] **Step 2-4: Красный → `_saved` становится парой (состояние, ссылка), `RestoreCursor` возвращает обе → зелёный + ворота**

- [ ] **Step 5: Commit**

```bash
git commit -m "fix: save and restore carry the link the way the terminal does"
```

---

### Task 8: Фазз — кликабельность по символам

**Files:**
- Test: `test/link_continuity_fuzz_test.dart` (создать)

**Оракул:** для каждой позиции plain-текста ссылка, действующая в нарезанном выводе, равна ссылке, действующей в исходной строке.

- [ ] **Step 1: Тест**

```dart
import 'dart:math';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The link in force at every position of the plain text, as a list.
List<String?> _clickability(String text) {
  final parser = Parser(text);

  return [for (var i = 0; i < parser.length; i++) parser.linkAt(i)?.url];
}

void main() {
  test('slicing a document keeps every character as clickable as it was', () {
    final random = Random(20260807);
    const fragments = [
      'word ',
      'a',
      '𝄞',
      '\x1B[31m',
      '\x1B[0m',
      '\x1B[A',
    ];

    for (var round = 0; round < 300; round++) {
      final buf = StringBuffer();
      var openLinks = 0;
      for (var i = 0; i < 12; i++) {
        final roll = random.nextInt(10);
        if (roll == 0) {
          buf.write(link('http://${random.nextInt(3)}/'));
          openLinks++;
        } else if (roll == 1 && openLinks > 0) {
          buf.write(linkClose);
          openLinks = 0;
        } else {
          buf.write(fragments[random.nextInt(fragments.length)]);
        }
      }
      final text = buf.toString();

      final whole = _clickability(text);
      if (whole.isEmpty) {
        continue;
      }

      // Cut it the way a wrapper would, then read the pieces back one after
      // another: what the slices say must be what the whole string said.
      final width = 1 + random.nextInt(5);
      final sliced = <String?>[];
      final parser = Parser(text);
      for (var start = 0; start < whole.length; start += width) {
        final piece = parser.substring(start, maxLength: width);
        sliced.addAll(_clickability(piece));
      }

      expect(
        sliced,
        whole,
        reason: 'text: ${text.replaceAll('\x1B', 'ESC')}',
      );
    }
  });
}
```

Если оракул падает на форме, которая по спеке **должна** отличаться (например, срез шириной 0), сузить генератор — но не ослаблять сравнение.

- [ ] **Step 2-3: Прогон, разбор падений (если есть — это находки, не подгонка), commit**

```bash
git commit -m "test: every character stays as clickable as it was"
```

---

### Task 9: Рекалибровка сторожа памяти

**Files:**
- Modify: `benchmark/memory_guard.dart` (шапка-таблица, `_ceiling`, `_floor`)
- Modify: `TODO.md` (вернуть пункт про ubuntu-число, снятый в прошлой волне)

- [ ] **Step 1: Пять холодных прогонов финальной реализации**

Run: `for i in 1 2 3 4 5; do dart run benchmark/memory_guard.dart; done`
Записать все пять чисел.

- [ ] **Step 2: Полоса**

`_ceiling` = худший прогон × 1.25 (округлить), `_floor` = тот же × 0.6. Таблицу в шапке переписать: пять новых строк, дата, Dart-версия, причина рекалибровки («поле `link` на каждом матче»). Абзац про ubuntu-колонку вернуть.

- [ ] **Step 3: Самопроверка сторожа**

В изолированной копии (`git archive HEAD` в scratchpad) вернуть `UnmodifiableListView` в `Sgr._` — сторож обязан покраснеть на новой полосе; вывод в отчёт; копию удалить.

- [ ] **Step 4: Ворота + commit**

```bash
git commit -m "ci: the band is redrawn for the match that carries a link"
```

- [ ] **Step 5: TODO.md**

Вернуть пункт: после первого зелёного ubuntu-прогона вписать число в шапку.

---

### Task 10: Документация и пример

**Files:**
- Modify: `CHANGELOG.md` (секция 4.0.0)
- Modify: `README.md` (новый раздел про ссылки)
- Modify: `example/links.dart`
- Modify: `lib/src/parsing/parser/entities/osc.dart` (dartdoc `Link`)

- [ ] **Step 1: CHANGELOG**

Переписать пункт, обещающий «unlike the style, a link is not reopened on the next line» — запись неизданная, правка на месте. Новый текст: срез, печатаемая строка и вставка ведут ссылку через границу так же, как стиль; переоткрытие идёт в исходной форме, включая `id=`; парсер отвечает `linkAt`/`finalLink`.

- [ ] **Step 2: README**

Короткий раздел про гиперссылки (сейчас их в README нет вовсе): открыть/закрыть, что бывает при нарезке и печати, `linkAt`. Сниппеты с выводом — проверить исполнением, вывод вставить фактический.

- [ ] **Step 3: `example/links.dart`**

Дописать многострочный случай: ссылка, пересечённая переносом, печатается принтером и остаётся кликабельной.

- [ ] **Step 4: dartdoc `Link`**

Сказать, что `url` — цель, а параметры последовательности (например `id=`) живут в `string`, и что переоткрытие пишет именно `string`.

- [ ] **Step 4b: `Match.link` в «Added» 4.0.0**

Секция `Added:` перечисляет добавленное публичное API; `Match.link` — новое публичное поле и в ней должно стоять, рядом с `linkAt`/`finalLink`.

- [ ] **Step 5: Ворота (включая `dart doc --dry-run` и прогон примеров) + commit**

```bash
git commit -m "docs: the link gets the page it never had"
```

---

## Завершение ветки

1. Whole-branch-ревью свежим ревьюером (Opus) с контекстом спеки `[1]`.
2. Блокеры — отдельными коммитами; затем `git checkout main && git merge --no-ff feat/link-continuity`.
3. Ворота на main: format, analyze, test, `dart pub publish --dry-run`, `dart run tool/generate.dart && git diff --exit-code -- lib/`, `dart run tool/check_entry_points.dart`, `dart run benchmark/memory_guard.dart`, `dart run benchmark/compare.dart perf-baseline-4.0.0` (деградаций быть не должно).
4. `git push origin main`; ветку удалить. Публикация 4.0.0 — отдельное решение пользователя, этим заходом не трогается.

---

### Task 11: придержанное открытие не съедает текст (унаследованное)

**Порядок:** выполняется ПОСЛЕ задачи 7 и ДО задачи 8, чтобы фазз накрыл и это.

**Files:**
- Modify: `lib/src/parsing/parser/parser.dart` (`substring` — запись `heldLinkCodes`)
- Modify: `lib/src/parsing/parser/printer.dart` (копирующий цикл — тот же сиблинг)
- Test: `test/parser_substring_links_test.dart`, `test/printer_links_test.dart`

**Контекст.** Дефект унаследованный, а не внесённый волной: на `a98a3d3` вход
`'${OSC}8;;http://u/${reset}abcd'` через `substring(0)` даёт побайтово то же самое, что на
голове волны, и plain-текст пуст. Причина: срез (и копирующий цикл принтера) выбрасывает
no-op SGR — тот самый `ESC`, который в исходной строке терминировал незавершённое открытие
OSC, — а само открытие копирует дословно. Открытие затем съедает идущий следом текст.

**Решение (замерено ревьюером):** терминировать придержанное открытие только если то, что
пишется сразу за ним, непусто и не начинается с `ESC`. Лобовой вариант (всегда `_reopening`)
тоже зелёный, но дописывает `ST` там, где за открытием и так шёл `ESC` или не шло ничего, и
теряет байтовую тождественность `substring(0)` на трёх формах. Узкое условие меняет **8
записей из 988** — ровно те, где текст теряется.

- [ ] **Step 1: Красные тесты**

По одному на поверхность:

```dart
    test('a held opening that never terminated does not eat the text', () {
      final parser = Parser('${OSC}8;;http://u/${reset}abcd');

      expect(Parser(parser.substring(0)).removeAll(), 'abcd');
    });
```

и тот же вход через `Printer().prepare(...)` — plain-текст обязан остаться `abcd`.
Имена/импорт `OSC`/`reset` сверить (OSC живёт в `package:ansi_escape_codes/ansi.dart`).

- [ ] **Step 2: Убедиться, что красные** — оба дают пустой plain-текст.

- [ ] **Step 3: Реализация**

Хелпер вида `_terminatedIfTextFollows(codes, following)`: если `codes` оканчивается
незавершённым OSC-открытием, а `following` непусто и не начинается с `ESC` — дописать `ST`.
`following` для среза — то, что реально пойдёт следом (переоткрытие + `transitTo` + текст
куска); для принтера — его аналог в копирующем цикле.

- [ ] **Step 4: Зелёный + ворота**

Run: `dart test && dart analyze --fatal-infos && dart format --output=none --set-exit-if-changed .`
Expected: 443+ зелёных; формы `untermin-sgr`, `untermin-csi`, `untermin-end` обязаны остаться
байт-в-байт (проверить пробой, что `substring(0)` на них не изменился).

- [ ] **Step 5: Commit**

```bash
git commit -m "fix: a held opening no longer swallows the text behind it"
```
