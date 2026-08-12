# План: 8-битные C1

> **Состояние документа**
>
> - **Тип:** план реализации, 2026-08-12, база `feat/eight-bit-c1` @
>   `0ef28d0`
> - **Статус:** написан, реализация впереди
> - **Актуальность:** реализует
>   `docs/records/2026-08-12[1]-eight-bit-c1-design.md`; спека старше
>   плана, при расхождении права спека
> - **Чему не верить:** номера строк даны по базе и поедут. И, по опыту
>   прошлой волны: **ожидания в планах этого репозитория регулярно
>   оказываются неверны** — в прошлой их было шесть, все поймали
>   исполнители, снимавшие значения пробником. Считать написанное здесь
>   намерением, а не описанием поведения

**Цель:** 8-битные C1 (`0x80`–`0x9F`) перестают быть невидимыми — их
видят показ и удаление управляющих кодов, — но по-прежнему **не
открывают escape-последовательностей**, и это закреплено тестами.

**Устройство:** две правки вне разбора — расширение `controlCodesRe` и
ветка в `ansiShowControlCodes`, — плюс пины, не дающие будущей волне
«починить» позицию.

**Инструменты:** Dart SDK `^3.6.0`, `package:test`. Новых зависимостей
нет.

> **Исполнителю:** задания идут по одному, каждое кончается зелёными
> воротами и коммитом. Шаги помечены `- [ ]`.

## Общие ограничения

- **Ожидаемые значения в тестах снимаются пробником с живого кода, а не
  выводятся рассуждением.** Если тест падает — объяснить, почему, и
  только потом решать, кто неправ. **Подгонять ожидание под вывод кода
  запрещено.** Поправил ожидание — напиши в отчёте, что разошлось.
- **Разбор escape-последовательностей эта волна не меняет.** Ни
  `patterns.dart` в части `escapeCodesRe` и его альтернатив, ни
  `entity.dart`, ни сущностей. Если покажется, что нужно, — остановись
  и скажи.
- Версия в `pubspec.yaml` **не бампается**.
- Один фикс — один коммит, conventional-префикс, тело повествовательное
  по-английски: почему, а не что.
- Код, dartdoc, README, CHANGELOG и сообщения коммитов — по-английски;
  бумаги в `docs/` — по-русски.
- `README.ru.md` — перевод `README.md`, правка одного тянет правку
  другого **тем же коммитом**.
- Зоны `BEGIN`/`END` в `lib/` генерируются, руками не править.
- Ворота перед каждым коммитом:

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
dart test
```

  Полный набор — в задании 4.

## Что где лежит

| файл | что с ним |
|---|---|
| `test/eight_bit_c1_test.dart` | **создаётся**: пины позиции, показ, удаление |
| `lib/src/parsing/patterns/patterns.dart:69` | правится: `controlCodesRe` |
| `lib/src/extensions/show_control_codes.dart:68-73` | правится: ветка для `0x80`–`0x9F` |
| `lib/src/extensions/remove.dart:49-50` | правится в задании 4: абзац дартдока |
| `docs/backlog.md`, `README.md`, `README.ru.md`, `CHANGELOG.md` | правятся в задании 4 |

`controlCodesRe` читают ровно двое — `has.dart:30` и `remove.dart:55,61`;
`ansiShowControlCodes` его не читает вовсе, он идёт по `codeUnits`.

---

## Задание 1: позиция закрепляется тестами

**Файлы:**
- Создание: `test/eight_bit_c1_test.dart`

**Интерфейсы:** ничего не производит; последующие задания дописывают
группы в тот же файл.

Задание пишет тесты, которые **зелены с самого начала**. Это не ошибка:
они закрепляют решение не распознавать 8-битные C1, а не чинят дефект.
Именно поэтому их надо проверить мутацией — иначе неизвестно, держат ли
они хоть что-нибудь.

- [ ] **Шаг 1: написать пины**

Создать `test/eight_bit_c1_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('the eight-bit C1 open nothing:', () {
    test('an eight-bit CSI stays text, and the length counts it', () {
      final parser = Parser('aa\u{9B}31mbb');

      expect(parser.matches.map((m) => m.entity.runtimeType).toList(), [Text]);
      expect(parser.removeAll(), 'aa\u{9B}31mbb');
      expect(parser.length, 8);
    });

    test('the other eight-bit openers stay text too', () {
      for (final byte in [0x9D, 0x90, 0x98, 0x9E, 0x9F]) {
        final opener = String.fromCharCode(byte);
        final input = 'aa${opener}pay\u{9C}bb';
        final parser = Parser(input);

        expect(
          parser.matches.map((m) => m.entity.runtimeType).toList(),
          [Text],
          reason: 'byte 0x${byte.toRadixString(16)}',
        );
        expect(parser.removeAll(), input);
      }
    });

    test('a seven-bit opener is not closed by an eight-bit ST, as in a '
        'UTF-8 terminal', () {
      expect(Parser('aa\x1B]0;t\u{9C}bb').removeAll(), 'aa');
    });

    test('the seven-bit forms are read as they always were', () {
      expect(Parser('aa\x1B[31mbb').removeAll(), 'aabb');
      expect(Parser('aa\x1B]0;t\x1B\\bb').removeAll(), 'aabb');
    });
  });
}
```

- [ ] **Шаг 2: прогнать — тесты обязаны быть зелёными сразу**

```bash
dart test test/eight_bit_c1_test.dart
```

Ожидается: все четыре зелёные. Если хоть один красный — **остановись и
скажи**: значит поведение не то, что описывает спека, и решение принято
на неверных основаниях.

- [ ] **Шаг 3: проверить мутацией, что пины держат**

Временно научить парсер видеть `0x9B`: в
`lib/src/parsing/patterns/patterns.dart` в `escapeCodesRe` добавить
альтернативу `'(?<c1>\u{9B})'` перед `escPattern`. Прогнать
`dart test test/eight_bit_c1_test.dart` — первый тест обязан покраснеть.
**Вернуть файл `git checkout -- lib/src/parsing/patterns/patterns.dart`
в том же вызове**, где ломал, и убедиться `git status`, что дерево
чистое.

Записать в отчёт, какие тесты покраснели. Если ни один — пины не держат
ничего, и это надо чинить прежде, чем идти дальше.

Падение с исключением вместо красного теста тоже считается: диспетчер
`EscapeCode._parse` ждёт, что матч начинается с `ESC`, и на `0x9B`
поведёт себя неопределённо. Мутация проверяет, что пины **замечают**
распознавание, а не то, каким оно вышло бы.

- [ ] **Шаг 4: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
dart test
git add test/eight_bit_c1_test.dart
git commit
```

Сообщение — `test:`, и тело должно объяснить, **зачем** тесты, которые
зелены с рождения: они держат решение, а не чинят дефект.

---

## Задание 2: управляющими кодами они остаются

**Файлы:**
- Правка: `lib/src/parsing/patterns/patterns.dart:69`
- Тест: `test/eight_bit_c1_test.dart`

**Интерфейсы:**
- Даёт заданию 4: `controlCodesRe` со значением
  `RegExp('[\x00-\x1F\x7F-\x9F]')`.

- [ ] **Шаг 1: написать падающие тесты**

Дописать в `test/eight_bit_c1_test.dart` новую группу:

```dart
  group('the eight-bit C1 are control codes all the same:', () {
    test('they are seen and taken out', () {
      expect('aa\u{9B}bb'.ansiHasControlCodes, isTrue);
      expect('aa\u{9B}31mbb'.ansiRemoveControlCodes(), 'aa31mbb');
    });

    test('the whole set is covered', () {
      for (var byte = 0x80; byte <= 0x9F; byte++) {
        final text = 'aa${String.fromCharCode(byte)}bb';

        expect(
          text.ansiHasControlCodes,
          isTrue,
          reason: 'byte 0x${byte.toRadixString(16)}',
        );
        expect(text.ansiRemoveControlCodes(), 'aabb');
      }
    });

    test('the range ends where the controls do', () {
      expect('aa\u{A0}bb'.ansiHasControlCodes, isFalse);
      expect('aa\u{A0}bb'.ansiRemoveControlCodes(), 'aa\u{A0}bb');
    });

    test('the C0 set and DEL are untouched by the widening', () {
      expect('a\nb\tc'.ansiRemoveControlCodes(), 'abc');
      expect('a\x00b\x1Fc\x7Fd'.ansiRemoveControlCodes(), 'abcd');
      expect('плайн текст'.ansiRemoveControlCodes(), 'плайн текст');
    });
  });
```

- [ ] **Шаг 2: убедиться, что они падают**

```bash
dart test test/eight_bit_c1_test.dart -N 'control codes all the same'
```

Ожидается: первые три падают (`has` даёт `false`, удаление ничего не
снимает), четвёртый зелёный — он контрольный и падать не должен ни до,
ни после.

- [ ] **Шаг 3: расширить класс**

В `lib/src/parsing/patterns/patterns.dart` заменить:

```dart
/// Pattern for control codes.
final controlCodesRe = RegExp('[\x00-\x1F\x7F]');
```

на:

```dart
/// Pattern for control codes: the C0 set, `DEL`, and the eight-bit C1.
///
/// The eight-bit C1 are here and nowhere else. They are controls by
/// Unicode's own category and print as rubbish rather than as characters,
/// so what strips and shows controls must know them — but they open no
/// escape sequence in this package, and `escapeCodesRe` does not look for
/// them. The reasoning is in
/// `docs/records/2026-08-12[1]-eight-bit-c1-design.md`.
final controlCodesRe = RegExp('[\x00-\x1F\x7F-\x9F]');
```

- [ ] **Шаг 4: прогнать**

```bash
dart test test/eight_bit_c1_test.dart
dart test
```

Ожидается: новая группа зелёная, весь набор зелёный. **Особое внимание
к `test/remove_control_codes_test.dart` и `test/has_agrees_with_parser_test.dart`**
— если там что-то покраснело, разобраться, что именно изменилось, и
только потом решать, тест устарел или правка неверна.

- [ ] **Шаг 5: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
dart test
git add lib/ test/
git commit
```

---

## Задание 3: показ

**Файлы:**
- Правка: `lib/src/extensions/show_control_codes.dart:68-73`
- Тест: `test/eight_bit_c1_test.dart`

**Интерфейсы:** берёт из задания 2 расширенный `controlCodesRe`, но сам
его не читает — `ansiShowControlCodes` идёт по `codeUnits`.

Сегодня `0x80`–`0x9F` проходят насквозь невидимыми: цикл спрашивает
`ControlFunctionsC0.byIndex(charCode)`, тот отдаёт `null` для всего вне
`0x00`–`0x1F` и `0x7F`, и байт пишется как есть.

- [ ] **Шаг 1: написать падающие тесты**

Дописать группу:

```dart
  group('the eight-bit C1 are shown by their byte:', () {
    test('the default style writes the byte', () {
      expect('aa\u{9B}31mbb'.ansiShowControlCodes(), r'aa\x9B31mbb');
    });

    test('every style writes the byte, having no name to write', () {
      for (final style in ControlCodeStyle.values) {
        expect(
          'aa\u{9B}bb'.ansiShowControlCodes(preferStyle: style),
          r'aa\x9Bbb',
          reason: '$style',
        );
      }
    });

    test('the C0 set keeps its names and pictures', () {
      expect('a\tb'.ansiShowControlCodes(), r'a\tb');
      expect(
        'a\tb'.ansiShowControlCodes(preferStyle: ControlCodeStyle.abbr),
        'a[HT]b',
      );
    });

    test('what is not a control is left alone', () {
      expect('aa\u{A0}bb'.ansiShowControlCodes(), 'aa\u{A0}bb');
    });
  });
```

**Ожидания третьего теста снять пробником до правки** — форма имени
(`[HT]` или иная) взята из чтения кода, а не измерена:

```bash
cat > _probe.dart <<'EOF'
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
void main() {
  print('default: ${'a\tb'.ansiShowControlCodes()}');
  print('abbr:    ${'a\tb'.ansiShowControlCodes(preferStyle: ControlCodeStyle.abbr)}');
  print('uni:     ${'a\tb'.ansiShowControlCodes(preferStyle: ControlCodeStyle.unicode)}');
  print('DEL:     ${'a\u{7F}b'.ansiShowControlCodes()}');
}
EOF
dart run _probe.dart; rm _probe.dart
```

Прав пробник.

- [ ] **Шаг 2: убедиться, что они падают**

```bash
dart test test/eight_bit_c1_test.dart -N 'shown by their byte'
```

Ожидается: первые два падают — байт проходит насквозь; третий и
четвёртый зелёные, они контрольные.

- [ ] **Шаг 3: добавить ветку**

В `lib/src/extensions/show_control_codes.dart` заменить:

```dart
    for (final charCode in codeUnits) {
      final controlCode = ControlFunctionsC0.byIndex(charCode);

      if (controlCode == null) {
        buf.writeCharCode(charCode);
      } else {
```

на:

```dart
    for (final charCode in codeUnits) {
      final controlCode = ControlFunctionsC0.byIndex(charCode);

      if (controlCode == null) {
        // The eight-bit C1 are controls with nothing to call them by. The
        // standard names the function, not the byte — `CSI` is the name of
        // something with two spellings, and this package reads only the
        // other one — and Unicode's pictures stop at `DEL`. The byte is the
        // only honest way to show them, and showing them beats letting them
        // through unseen: they print as rubbish, and whoever is reading a
        // string to find out what is in it cannot see them otherwise.
        if (charCode >= 0x80 && charCode <= 0x9F) {
          charCodeToBuf(charCode);
        } else {
          buf.writeCharCode(charCode);
        }
      } else {
```

- [ ] **Шаг 4: прогнать**

```bash
dart test test/eight_bit_c1_test.dart
dart test
```

- [ ] **Шаг 5: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
dart test
git add lib/ test/
git commit
```

---

## Задание 4: документы и полные ворота

**Файлы:**
- Правка: `lib/src/extensions/remove.dart:49-50`
- Правка: `docs/backlog.md`
- Правка: `README.md` и `README.ru.md`
- Правка: `CHANGELOG.md`

- [ ] **Шаг 1: дартдок `ansiRemoveControlCodes`**

В `lib/src/extensions/remove.dart` абзац

```dart
  /// The eight-bit forms of the C1 controls are not touched: `0x9B` is above
  /// `DEL`, and in a Dart string it is a character of its own.
```

теперь неверен — они трогаются. Переписать так, чтобы он сказал две
вещи: что эти байты снимаются, и что снимаются они **не** потому, что
пакет читает их как escape-коды (он не читает), а потому что они
управляющие по категории Unicode.

Там же документировать асимметрию: `exclude` типизован
`Set<ControlFunctionsC0>`, поэтому исключить 8-битный C1 из удаления
нечем. Это осознанно — перечисления для них у пакета нет и не заводится.

Черновик, из которого стоит исходить (формулировка твоя, смысл этот):

```dart
  /// The eight-bit forms of the C1 controls go too. They are controls by
  /// Unicode's own category and print as rubbish rather than as characters,
  /// so a string cleaned for display is not clean while they stand in it —
  /// and that holds whether or not anything reads them as escape codes.
  /// Nothing here does: they open no sequence in this package, and the
  /// reasoning is in `docs/records/2026-08-12[1]-eight-bit-c1-design.md`.
  ///
  /// [exclude] cannot name them: it takes [ControlFunctionsC0], and the
  /// eight-bit C1 have no enum here to be named by — see the design for why
  /// none is wanted. Excluding one of them is not possible.
```

- [ ] **Шаг 2: бэклог**

В `docs/backlog.md` пункт про 8-битные C1 закрывается **как решённый, а
не как сделанный**. Формулировка обязана прямо говорить, что
распознавание **отклонено**, а не отложено, и ссылаться на
`docs/records/2026-08-12[1]-eight-bit-c1-design.md` — иначе следующая
волна прочтёт «пакет не распознаёт» и починит это как дефект. Ровно так
пункт и появился.

Сказать и то, что сделано: показ и удаление их видят.

- [ ] **Шаг 3: README, обе версии одним коммитом**

Оговорка про 8-битные C1: пакет их не разбирает, и почему; показывает и
удаляет как управляющие. Английский источник, русский перевод, структура
и код примеров одинаковы. Пройти оба файла на другие места, где
перечисляются виды кодов или говорится про управляющие коды, — прошлая
волна нашла такое место сверх названного.

- [ ] **Шаг 4: CHANGELOG**

Правка на месте в записи `4.0.0`, по-английски, не новой секцией.
Сказать про изменившееся поведение `ansiHasControlCodes`,
`ansiRemoveControlCodes` и `ansiShowControlCodes`.

`docs/architecture.md` по замыслу править не надо: устройство не
меняется, появляется одна ветка в существующем цикле. Но карта называет
`controlCodesRe` в разделе про регулярки — **проверь, не стало ли
сказанное там неверным**, и поправь, если стало.

- [ ] **Шаг 5: полные ворота**

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

Ожидается: всё зелёное, `publish --dry-run` 0 предупреждений,
`memory_guard` в полосе (числа — в `docs/handoff.md`). Прогнать примеры
из `example/`. Вывод каждых ворот — в отчёт дословно. `docs/handoff.md`
не трогать — он переписывается после мержа.

- [ ] **Шаг 6: коммит**

```bash
git add lib/ docs/ README.md README.ru.md CHANGELOG.md
git commit
```

---

## Что после плана

Финальное ревью всей ветки, затем локальный `git merge --no-ff` в `main`.
После мержа: строки «влит мержем `<sha>`» в шапки записей `[1]` и `[2]`,
и `docs/handoff.md` переписывается под новое состояние.
