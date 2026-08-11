# План: C1-строковые открыватели

> **Состояние документа**
>
> - **Тип:** план реализации, 2026-08-11, база `feat/c1-control-strings`
>   @ `e697231`
> - **Статус:** написан, реализация впереди
> - **Актуальность:** реализует
>   `docs/records/2026-08-11[4]-c1-control-strings-design.md`; спека
>   старше плана, при расхождении права спека
> - **Чему не верить:** номера строк даны по базе и поедут после первого
>   же задания. Ориентироваться на приведённые куски кода, а не на
>   номера

**Цель:** `DCS`, `SOS`, `PM` и `APC` читаются как управляющие строки —
с телом, которое не является текстом, и терминатором, которого может не
быть, — а не как завершённые двухбайтовые escape.

**Устройство:** одна новая альтернатива в `escapeCodesRe`, новое
sealed-семейство `ControlString` над существующим `Osc`, и четыре места,
спрашивающих сегодня `entity is Osc`, начинают спрашивать про семейство.

**Инструменты:** Dart SDK `^3.6.0`, `package:test`. Новых зависимостей
заход не добавляет.

> **Исполнителю:** задания идут по одному, каждое кончается зелёными
> воротами и коммитом. Шаги помечены `- [ ]` — отмечать по мере
> выполнения.

## Общие ограничения

Действуют в каждом задании, повторять в каждом не буду:

- **Ожидаемые значения в тестах снимаются пробником с живого кода, а не
  выводятся рассуждением.** За прошлые волны они дважды оказались
  неверны даже так. Если тест падает — объяснить, почему падает, и
  только потом решать, кто неправ: тест или код. **Подгонять ожидание
  под вывод кода запрещено.**
- Версия в `pubspec.yaml` **не бампается**. 4.0.0 не издана, правки
  неизданные.
- Один фикс — один коммит, conventional-префикс, тело коммита
  повествовательное по-английски: почему, а не что.
- Код, dartdoc, CHANGELOG и сообщения коммитов — по-английски; рабочие
  бумаги в `docs/` — по-русски.
- Зоны между маркерами `BEGIN`/`END` в `lib/` генерируются
  `tool/generate.dart`; руками не править. Этот заход их не трогает.
- SDK-floor `^3.6.0` не поднимать.
- Ворота перед каждым коммитом:

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
dart test
```

  Полный набор (`generate.dart`, `memory_guard.dart`, `dart doc
  --dry-run`, `dart pub publish --dry-run`) — в задании 5.

## Что где лежит

| файл | что с ним |
|---|---|
| `lib/src/parsing/patterns/patterns.dart` | правится: новая альтернатива `controlStringPattern` и её место в `escapeCodesRe` |
| `lib/src/parsing/parser/entities/control_string.dart` | **создаётся**: семейство `ControlString` и четыре его члена |
| `lib/src/parsing/parser/entities/osc.dart` | правится: `Osc` получает предка, `_oscTerminated` сужается до ссылочных кодов, появляется `_terminatedOpening` |
| `lib/src/parsing/parser/entities/entity.dart` | правится: диспетчер `EscapeCode._parse` |
| `lib/src/parsing/parser/parser.dart` | правится: `part`, три места с `is Osc`, вызовы придержанного открытия |
| `lib/src/parsing/parser/printer.dart` | правится: одно место с `is Osc`, вызовы придержанного открытия |
| `lib/src/extensions/show_escape_codes.dart` | правится: ветка печати имён |
| `test/parser_control_string_test.dart` | **создаётся**: разбор, срез, `optimize`, печать, вставки |
| `docs/architecture.md`, `docs/backlog.md`, `CHANGELOG.md` | правятся в задании 5 |

Точки входа править не нужно: сущности — `part of parser.dart`, а
`parser.dart` уже экспортируется из `ansi_escape_codes.dart` и
`style.dart`. Проверит `check_entry_points.dart`.

---

## Задание 1: строка перестаёт быть текстом

**Файлы:**
- Правка: `lib/src/parsing/patterns/patterns.dart`
- Создание: `lib/src/parsing/parser/entities/control_string.dart`
- Правка: `lib/src/parsing/parser/entities/osc.dart`
- Правка: `lib/src/parsing/parser/entities/entity.dart`
- Правка: `lib/src/parsing/parser/parser.dart` (только строка `part`)
- Тест: `test/parser_control_string_test.dart`

**Интерфейсы:**
- Даёт следующим заданиям: `sealed class ControlString extends
  EscapeCode` с геттером `bool get terminated`; `final class Dcs`,
  `Sos`, `Pm`, `Apc` — все `extends ControlString with
  UnrecognizedEscapeCode`; `Osc extends ControlString`. Группы
  регулярки: `cstr`, `cstr_params`, `cstr_terminator`.

- [ ] **Шаг 1: написать падающий тест**

Создать `test/parser_control_string_test.dart`:

```dart
import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('control strings:', () {
    test('a terminated string is one entity, and its body is not text', () {
      final parser = Parser('aa${DCS}pay${ST}bb');

      expect(parser.matches.map((m) => m.entity.runtimeType).toList(), [
        Text,
        Dcs,
        Text,
      ]);
      expect(parser.removeAll(), 'aabb');
      expect(parser.length, 4);
    });

    test('all four openers are read the same way', () {
      for (final (opener, type) in [
        (DCS, Dcs),
        (SOS, Sos),
        (PM, Pm),
        (APC, Apc),
      ]) {
        final parser = Parser('aa${opener}pay${ST}bb');

        expect(
          parser.matches.elementAt(1).entity.runtimeType,
          type,
          reason: 'opener ${opener.ansiShowEscapeSequences()}',
        );
        expect(parser.removeAll(), 'aabb');
      }
    });

    test('a string that never got its terminator runs to the end', () {
      final parser = Parser('aa${DCS}pay');

      expect(parser.removeAll(), 'aa');
      expect(parser.matches.last.entity, isA<Dcs>());
    });

    test('an unterminated string ends where the next sequence starts', () {
      expect(Parser('${DCS}pay${fgRed}x$reset').removeAll(), 'x');
    });

    test('a BEL does not end anything but an OSC', () {
      expect(
        Parser('aa${DCS}pay${BEL}more').removeAll(),
        'aa',
        reason: 'BEL is xterm’s terminator for OSC alone',
      );
      expect(Parser('aa${OSC}pay${BEL}more').removeAll(), 'aamore');
    });

    test('an empty body is a string all the same', () {
      final parser = Parser('aa$DCS${ST}bb');

      expect(parser.removeAll(), 'aabb');
      expect(parser.matches.elementAt(1).entity, isA<Dcs>());
    });

    test('a lone ST opens nothing', () {
      expect(Parser('aa${ST}bb').matches.elementAt(1).entity, isA<Esc>());
    });

    test('the string comes back byte for byte', () {
      for (final opener in [DCS, SOS, PM, APC]) {
        const body = 'pay';
        final input = 'aa$opener$body${ST}bb';

        expect(
          Parser(input).matches.map((m) => m.entity.string).join(),
          input,
        );
      }
    });
  });
}
```

- [ ] **Шаг 2: убедиться, что тест падает**

```bash
dart test test/parser_control_string_test.dart
```

Ожидается: ошибки компиляции — имена `Dcs`, `Sos`, `Pm`, `Apc` не
определены. Это и есть нужное падение; если компиляция прошла — что-то
уже сделано, разобраться до правок.

- [ ] **Шаг 3: добавить альтернативу в регулярку**

В `lib/src/parsing/patterns/patterns.dart` дописать после `oscPattern`:

```dart
/// Pattern for the C1 string openers other than `OSC`: `DCS`, `SOS`, `PM`
/// and `APC`.
///
/// Each opens a string that runs to its `ST`, and one that never got a
/// terminator ends at the next `ESC` or at the end of the text — the reading
/// `oscPattern` gives, and for the reason it gives it: read as a
/// two-character escape instead, the string would surface its body as text
/// and whatever was written after the opener would be swallowed by the
/// terminal.
///
/// A `BEL` ends none of these. It ends an `OSC`, which is xterm's and not the
/// standard's, and the standard gives all five `ST`.
const String controlStringPattern =
    // P, X, ^ and _: DCS, SOS, PM and APC.
    '(?<cstr>$ESC[\x50\x58\x5E\x5F])'
    '(?<cstr_params>[^$ESC]*)'
    '(?<cstr_terminator>$ESC\\\\)?';
```

И поправить `escapeCodesRe` — **порядок существенный**, новая
альтернатива идёт перед `escPattern`:

```dart
final escapeCodesRe = RegExp(
  '(?<all>($csiPattern|$oscPattern|$controlStringPattern|$escPattern))',
);
```

- [ ] **Шаг 4: создать семейство**

Создать `lib/src/parsing/parser/entities/control_string.dart`:

```dart
part of '../parser.dart';

/// A control string: an opener, a body, and the `ST` that ends it.
///
/// The standard has five — `OSC`, `DCS`, `SOS`, `PM` and `APC` — and what
/// they share is the one thing this parser needs of them: everything written
/// after the opener belongs to the string until its terminator arrives, so a
/// string that never got one swallows whatever is written behind it. That is
/// what [terminated] asks, and the slice, the optimizer, the printers and the
/// insertions all ask it.
sealed class ControlString extends EscapeCode {
  const ControlString._(super.string) : super._();

  /// Whether the string got the terminator that ends it.
  ///
  /// `ST` ends all five. [Osc] takes a `BEL` as well and overrides this to
  /// say so; that terminator is xterm's, not the standard's, and it ends
  /// nothing else.
  bool get terminated => string.endsWith(ST);

  /// The string this opener opens, for the four that are not an [Osc].
  ///
  /// The `]` never arrives here: [EscapeCode._parse] sends it to [Osc._parse]
  /// instead, which has a hyperlink to look for.
  static ControlString _parse<S extends State<S>>(_MatchingState<S> state) {
    final string = state.string;

    return switch (string.codeUnitAt(1)) {
      0x50 => Dcs._(string), // P
      0x58 => Sos._(string), // X
      0x5E => Pm._(string), // ^
      _ => Apc._(string), // _
    };
  }
}

/// A device control string, `DCS ... ST`: what a terminal reads as
/// instructions for a device rather than for the screen — a sixel image, a
/// `DECRQSS` query, a termcap answer.
///
/// The package carries the bytes and does not read them.
final class Dcs extends ControlString with UnrecognizedEscapeCode {
  const Dcs._(super.string) : super._();

  @override
  String toString() => '$Dcs("${toStringAsEscapeSequences()}")';
}

/// A string opened by `SOS`, which the standard leaves for the application to
/// interpret.
///
/// The standard lets its body hold any bytes but `SOS` and `ST`, so by the
/// letter an `ESC` inside it ends nothing. This package ends it at the next
/// `ESC` all the same, the way the terminals' own state machines do and the
/// way it already reads an `OSC`: a string somebody forgot to close then eats
/// what it can reach rather than the whole of the rest of the input. The
/// divergence is deliberate — see
/// `docs/records/2026-08-11[4]-c1-control-strings-design.md`.
final class Sos extends ControlString with UnrecognizedEscapeCode {
  const Sos._(super.string) : super._();

  @override
  String toString() => '$Sos("${toStringAsEscapeSequences()}")';
}

/// A privacy message, `PM ... ST`.
///
/// The package carries the bytes and does not read them.
final class Pm extends ControlString with UnrecognizedEscapeCode {
  const Pm._(super.string) : super._();

  @override
  String toString() => '$Pm("${toStringAsEscapeSequences()}")';
}

/// An application program command, `APC ... ST`.
///
/// The package carries the bytes and does not read them.
final class Apc extends ControlString with UnrecognizedEscapeCode {
  const Apc._(super.string) : super._();

  @override
  String toString() => '$Apc("${toStringAsEscapeSequences()}")';
}
```

Подключить его в `lib/src/parsing/parser/parser.dart`. Список `part`
отсортирован по имени файла, и `control_string` идёт раньше `csi`:

```dart
part 'printer.dart';
part 'entities/control_string.dart';
part 'entities/csi.dart';
part 'entities/entity.dart';
```

- [ ] **Шаг 5: перевесить `Osc` на нового предка**

В `lib/src/parsing/parser/entities/osc.dart` заменить объявление:

```dart
sealed class Osc extends EscapeCode {
  const Osc._(super.string) : super._();
```

на:

```dart
sealed class Osc extends ControlString {
  const Osc._(super.string) : super._();

  /// A `BEL` ends an `OSC` — xterm's terminator, kept because the strings
  /// written with it are everywhere — where it ends no other control string.
  @override
  bool get terminated => string.endsWith(ST) || string.endsWith(BEL);
```

и в `Link` заменить тело `_reopening`:

```dart
String get _reopening => _oscTerminated(string) ? string : '$string$ST';
```

на:

```dart
String get _reopening => terminated ? string : '$string$ST';
```

`_oscTerminated` пока оставить на месте — им ещё пользуются помощники;
сузится он в задании 2.

- [ ] **Шаг 6: научить диспетчер**

В `lib/src/parsing/parser/entities/entity.dart`, в `EscapeCode._parse`,
дописать ветку к `switch (string.codeUnitAt(1))`:

```dart
        case 0x5D: // ]
          return Osc._parse(state);
        case 0x50 || 0x58 || 0x5E || 0x5F: // P, X, ^, _
          return ControlString._parse(state);
```

- [ ] **Шаг 7: прогнать тест**

```bash
dart test test/parser_control_string_test.dart
```

Ожидается: все восемь тестов зелёные.

- [ ] **Шаг 8: прогнать весь набор**

```bash
dart test
```

Ожидается: зелено. Если что-то падает — **не подгонять**: разобраться,
что именно изменилось в чтении, и решить, тест устарел или правка
неверна. Отдельно посмотреть `round_trip_invariant_test.dart` и
`has_agrees_with_parser_test.dart`: они и должны ловить такие сдвиги.

- [ ] **Шаг 9: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
dart test
git add lib/ test/parser_control_string_test.dart
git commit
```

Сообщение — по образцу:

```
feat: the C1 string openers open strings

DCS, SOS, PM and APC were read as finished two-character escapes, which
left their bodies standing in the plain text and let whatever was
written after an opener be swallowed by the terminal that never saw a
terminator. They are control strings, the way OSC is, and now they are
read as ones: a ControlString family over Osc, one regex alternative
for the four openers, and a body that is no longer text.

BEL is left where it was found. It ends an OSC because xterm ends one
with it; the standard gives all five ST, and the other four take only
that.
```

---

## Задание 2: придержанное открытие — не только у `OSC`

**Файлы:**
- Правка: `lib/src/parsing/parser/entities/osc.dart`
- Правка: `lib/src/parsing/parser/parser.dart`
- Правка: `lib/src/parsing/parser/printer.dart`
- Тест: `test/parser_control_string_test.dart`

**Интерфейсы:**
- Берёт из задания 1: `ControlString.terminated`.
- Даёт заданию 3: `String _terminatedOpening(String opening, String
  following, {required bool closing})`.

Здесь ловушка, ради которой задание отделено. Помощники
`_terminatedIfTextFollows` и `_terminatedUnlessCodeFollows` спрашивают
`_oscTerminated(codes)` — «кончается ли эта строка на `ST` или `BEL`».
Для ссылочных кодов это верно: они всегда `OSC`. Для придержанного
открытия — уже нет: незавершённый `DCS`, тело которого кончается на
`BEL`, этот вопрос назовёт завершённым, терминатор не допишется, и
строка съест текст за собой. Поэтому у придержанного открытия свой
помощник, который не переспрашивает: держат только незавершённое.

- [ ] **Шаг 1: написать падающие тесты**

Дописать в `test/parser_control_string_test.dart` новую группу:

```dart
  group('control strings, held openings:', () {
    test('an unterminated string is closed where text follows it', () {
      expect(
        Parser('aa${DCS}pay').optimize(),
        'aa${DCS}pay$ST',
      );
    });

    test('a slice does not leave a string open behind it', () {
      expect(
        Parser('aa${DCS}pay').substring(0, maxLength: 2),
        'aa',
      );
    });

    test('a body ending in BEL still owes a terminator', () {
      expect(
        Parser('aa${DCS}pay$BEL').optimize(),
        'aa${DCS}pay$BEL$ST',
        reason: 'BEL ends an OSC and no other control string',
      );
    });

    test('an OSC ending in BEL owes nothing', () {
      expect(
        Parser('aa${OSC}pay$BEL').optimize(),
        'aa${OSC}pay$BEL',
      );
    });

    test('a slice left open does not close the string either', () {
      expect(
        Parser('aa${DCS}pay').substring(0, maxLength: 2, close: false),
        'aa',
      );
    });

    test('a printed line closes what it left open', () {
      final lines = <String>[];

      Printer(output: lines.add).writeln('aa${DCS}pay');

      expect(lines.single, 'aa${DCS}pay$ST\n');
    });

    test('a sink printer pays the same debt', () {
      final buf = StringBuffer();

      SinkPrinter(buf).writeln('aa${DCS}pay');

      expect(buf.toString(), 'aa${DCS}pay$ST\n');
    });

    test('all four owe the terminator alike', () {
      for (final opener in [DCS, SOS, PM, APC]) {
        expect(
          Parser('aa${opener}pay').optimize(),
          'aa${opener}pay$ST',
          reason: 'opener ${opener.ansiShowEscapeSequences()}',
        );
      }
    });
  });
```

**Ожидания в этой группе сняты пробником с `OSC` на той же форме входа,
а не выведены.** Перед тем как чинить код, прогнать пробник и убедиться,
что `OSC` действительно так себя ведёт:

Пробник кладётся в корень пакета — иначе `package:`-импорты не
разрешаются, — и убирается за собой:

```bash
cat > _probe.dart <<'EOF'
import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

String v(String s) => s.replaceAll('\x1B', '<E>').replaceAll('\n', '\\n');

void main() {
  print('optimize:      ${v(Parser('aa${OSC}pay').optimize())}');
  print('sub close:     ${v(Parser('aa${OSC}pay').substring(0, maxLength: 2))}');
  print('sub open:      '
      '${v(Parser('aa${OSC}pay').substring(0, maxLength: 2, close: false))}');
  print('osc + BEL:     ${v(Parser('aa${OSC}pay$BEL').optimize())}');

  final lines = <String>[];
  Printer(output: lines.add).writeln('aa${OSC}pay');
  print('printer:       ${v(lines.single)}');

  final buf = StringBuffer();
  SinkPrinter(buf).writeln('aa${OSC}pay');
  print('sink printer:  ${v(buf.toString())}');
}
EOF
dart run _probe.dart; rm _probe.dart
```

Смотреть особенно на печать: где именно встаёт `ST` относительно
перевода строки, рассуждением не берётся. Если вывод пробника
расходится с ожиданиями выше — **прав пробник**, поправить ожидания и
написать в отчёте, что разошлось.

- [ ] **Шаг 2: убедиться, что тесты падают**

```bash
dart test test/parser_control_string_test.dart -N 'held openings'
```

Ожидается: падения на `optimize`, срезе и печати — терминатор не
дописывается.

- [ ] **Шаг 3: завести помощник для придержанного открытия**

В `lib/src/parsing/parser/entities/osc.dart` дописать рядом с
существующей парой:

```dart
/// [opening] with the terminator it lacks, where what follows would otherwise
/// be swallowed by it.
///
/// Only an opening the parser found unterminated is ever held back, so this
/// does not ask again whether it ended — and it must not ask: a `BEL` ends an
/// [Osc] and no other control string, so an unterminated [Dcs] whose body
/// happens to end in one would be called finished by that question and left
/// open. [_terminatedIfTextFollows] and [_terminatedUnlessCodeFollows] go on
/// asking it, because what they are given is link codes, and those are always
/// an `OSC`.
///
/// [closing] says what an empty [following] means. Inside a string it means
/// nothing follows the opening at all, so there is nothing to be swallowed
/// and the bytes go out as they came. At the edge of an output that closes —
/// [Parser.substring] or [Parser.optimize] with `close: true`, a printed line
/// — it means the next thing written is whatever the caller prints after, and
/// the terminator is owed for the reason the hyperlink close is.
String _terminatedOpening(
  String opening,
  String following, {
  required bool closing,
}) =>
    opening.isEmpty ||
            following.startsWith(ESC) ||
            (following.isEmpty && !closing)
        ? opening
        : '$opening$ST';
```

И сузить старый предикат — он остаётся только для ссылочных кодов:

```dart
/// Whether [string] ends where an `OSC` is allowed to end.
///
/// Asked of link codes, which are always an `OSC`; the openings held back go
/// through [_terminatedOpening], which must not ask it. An `OSC` runs until a
/// `ST` or a `BEL`; one that got neither runs on to the next `ESC` or to the
/// end of the text — the parser reads it that way on purpose, see
/// `oscPattern`.
bool _oscTerminated(String string) =>
    string.endsWith(ST) || string.endsWith(BEL);
```

- [ ] **Шаг 4: перевести четыре места на семейство**

Три в `lib/src/parsing/parser/parser.dart` (по базе — строки 641, 1036,
1158) и одно в `printer.dart` (строка 370). Форма везде одна:

```dart
if (entity is Osc && !_oscTerminated(entity.string)) {
```

становится:

```dart
if (entity is ControlString && !entity.terminated) {
```

В `printer.dart` переменная называется иначе:

```dart
if (m.entity is ControlString && !(m.entity as ControlString).terminated) {
```

— лучше поднять `final entity = m.entity;` строкой выше и писать так же,
как в парсере; в этом месте `string` уже вычислен из `m.entity.string`.

В `_unfinished` (`parser.dart:1158`) меняется ветка `switch`:

```dart
bool _unfinished(Entity entity) => switch (entity) {
      ControlString() => !entity.terminated,
      Esc() => entity.string == ESC ||
```

и в его дартдоке фраза «An `OSC` without its terminator runs to the next
`ESC`» расширяется на семейство — теперь это верно про все пять.

- [ ] **Шаг 5: перевести вызовы придержанного открытия**

Восемь вызовов. **Ссылочные (`held`, `heldLinkCodes`) не трогать** —
они остаются на `_terminatedIfTextFollows`.

В `parser.dart`, в срезе (около строк 552 и 616) и в `optimize` (около
1023) — там, где первый аргумент `opening` или `heldOpening`:

```dart
                  _terminatedIfTextFollows(
                    opening,
                    _firstNotEmpty(held, reopening, transit, substring),
                  ),
```

становится:

```dart
                  _terminatedOpening(
                    opening,
                    _firstNotEmpty(held, reopening, transit, substring),
                    closing: false,
                  ),
```

В хвосте среза (около 689 и 705) две ветки `if (close)`/`else`
схлопываются в одну форму:

```dart
            _terminatedOpening(
              heldOpening,
              _firstNotEmpty(closingLink, tail),
              closing: close,
            ),
```

— но осторожно: в ветке `close` там своя `closingLink`, в ветке `else`
первым идёт `heldLinkCodes`. Схлопывать структуру `if/else` **не надо**,
менять только вызов внутри каждой ветки: в ветке `close` — `closing:
true`, в `else` — `closing: false`.

В хвосте `optimize` (около 1065):

```dart
        close
            ? _terminatedUnlessCodeFollows(heldOpening, following)
            : _terminatedIfTextFollows(heldOpening, following),
```

становится:

```dart
        _terminatedOpening(heldOpening, following, closing: close),
```

В `printer.dart` — вызов около 356 (`closing: false`) и хвост около
392:

```dart
      endsLine
          ? _terminatedUnlessCodeFollows(heldOpening, following)
          : _terminatedIfTextFollows(heldOpening, following),
```

становится:

```dart
      _terminatedOpening(heldOpening, following, closing: endsLine),
```

- [ ] **Шаг 6: прогнать тесты**

```bash
dart test test/parser_control_string_test.dart
dart test
```

Ожидается: зелено, включая `osc_termination_test.dart` — он и есть
проверка того, что старое поведение `OSC` не поехало.

- [ ] **Шаг 7: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
dart test
git add lib/ test/
git commit
```

Тело коммита должно назвать ловушку с `BEL` — она и есть причина, по
которой у придержанного открытия свой помощник.

---

## Задание 3: вставка

**Файлы:**
- Тест: `test/parser_control_string_test.dart`
- Правка: `lib/src/parsing/parser/parser.dart` — только если тесты
  покажут, что нужна

**Интерфейсы:** берёт из заданий 1 и 2; своих имён не производит.

Задание проверочное. После заданий 1 и 2 вставка должна вести себя
верно **сама**: `_unfinished` уже знает про семейство, а тело строки
перестало быть текстом, значит позиции внутри него нет. Задание
существует, чтобы это было проверено, а не предположено.

- [ ] **Шаг 1: написать тесты**

```dart
  group('control strings, insertions:', () {
    test('an insertion does not land inside a terminated string', () {
      final parser = Parser('aa${DCS}pay${ST}bb');

      expect(parser.insertBefore(2, 'X'), 'aaX${DCS}pay${ST}bb');
      expect(parser.insertAfter(2, 'X'), 'aa${DCS}pay${ST}Xbb');
    });

    test('an insertion stands before a string that never ended', () {
      expect(Parser('aa$DCS').insertAfter(2, 'X'), 'aaX$DCS');
      expect(Parser('aa${DCS}pay').insertAfter(2, 'X'), 'aaX${DCS}pay');
    });

    test('all four keep an insertion out of the body', () {
      for (final opener in [DCS, SOS, PM, APC]) {
        expect(
          Parser('aa${opener}pay${ST}bb').insertAfter(2, 'X'),
          'aa${opener}pay${ST}Xbb',
          reason: 'opener ${opener.ansiShowEscapeSequences()}',
        );
      }
    });

    test('no position falls inside a control string, so none is refused', () {
      final parser = Parser('aa${DCS}pay${ST}bb');

      for (var pos = 0; pos <= parser.length; pos++) {
        expect(() => parser.insertBefore(pos, 'X'), returnsNormally);
        expect(() => parser.insertAfter(pos, 'X'), returnsNormally);
      }
    });
  });
```

- [ ] **Шаг 2: прогнать и посмотреть**

```bash
dart test test/parser_control_string_test.dart -N 'insertions'
```

Два исхода, и оба нормальные:

- **Зелено** — значит задания 1 и 2 закрыли и вставку. Так и записать в
  отчёте, кода не трогать, перейти к шагу 4.
- **Красно** — разобраться, какое именно ожидание не сошлось, и
  **объяснить причину прежде, чем править**. Ожидания выше выведены из
  поведения `OSC`; если `OSC` ведёт себя иначе — прав `OSC`, снять
  пробником и поправить ожидание, написав в отчёте, что разошлось.

- [ ] **Шаг 3: починить, если понадобилось**

Место, где смотреть, — `_insert` и `_seamAt` в `parser.dart` (около
строк 799–930), там же, где живёт `UnfinishedSequenceException`.
Менять контракт вставки этот заход **не имеет права**: если окажется,
что для верного поведения нужна новая семантика — остановиться и
вынести вопрос владельцу, а не решать на месте.

- [ ] **Шаг 4: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
dart test
git add test/ lib/
git commit
```

Если код не менялся — коммит `test:`, и в теле сказать, что вставка
оказалась закрыта разбором и придержанным открытием, а тесты это
закрепляют.

---

## Задание 4: печать имён

**Файлы:**
- Правка: `lib/src/extensions/show_escape_codes.dart`
- Тест: `test/parser_control_string_test.dart`

**Интерфейсы:** читает группы регулярки `cstr`, `cstr_params`,
`cstr_terminator` из задания 1.

Регулярку читают два места: `EscapeCode._parse` и эта функция, которая
берёт именованные группы напрямую. Задание 1 научило первое; без второго
строка разбирается верно, но печатается как набор несвязанных кодов.

- [ ] **Шаг 1: написать падающие тесты**

```dart
  group('control strings, shown:', () {
    test('a string is shown as one code with a body', () {
      expect(
        'aa${DCS}pay${ST}bb'.ansiShowEscapeSequences(),
        'aa[DCS pay ST]bb',
      );
    });

    test('all four are named', () {
      expect('${SOS}x$ST'.ansiShowEscapeSequences(), '[SOS x ST]');
      expect('${PM}x$ST'.ansiShowEscapeSequences(), '[PM x ST]');
      expect('${APC}x$ST'.ansiShowEscapeSequences(), '[APC x ST]');
    });

    test('a string without its terminator shows none', () {
      expect('aa${DCS}pay'.ansiShowEscapeSequences(), 'aa[DCS pay ]');
    });
  });
```

**Внимание: форма вывода здесь не выведена, а снята с `OSC` пробником.**
До правки прогнать:

```bash
cat > _probe.dart <<'EOF'
import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  print('aa${OSC}pay${ST}bb'.ansiShowEscapeSequences());
  print('aa${OSC}pay'.ansiShowEscapeSequences());
  print('aa$OSC$ST'.ansiShowEscapeSequences());
}
EOF
dart run _probe.dart; rm _probe.dart
```

и привести ожидания выше к тому, что `OSC` печатает **байт в байт**,
включая пробелы вокруг тела и вид незавершённого хвоста. Прав пробник.

- [ ] **Шаг 2: убедиться, что тесты падают**

```bash
dart test test/parser_control_string_test.dart -N 'shown'
```

Ожидается: печатается `[ESC P]pay[ESC \]` — три несвязанные вещи.

- [ ] **Шаг 3: добавить ветку**

В `lib/src/extensions/show_escape_codes.dart`, сразу после ветки `osc`
(она кончается на `continue;` около строки 89), вставить:

```dart
      final controlString = m.namedGroup('cstr');
      if (controlString != null) {
        final params = m.namedGroup('cstr_params')!;
        final terminator = m.namedGroup('cstr_terminator');

        buf
          ..write(open)
          ..write(codeOpen)
          ..write(
            ControlFunctionsC1.byCode(controlString)?.name ?? controlString,
          )
          ..write(codeClose)
          ..write(paramsOpen)
          ..write(params)
          ..write(paramsClose)
          ..write(finalOpen)
          // The string was never terminated.
          ..write(terminator == null ? '' : ControlFunctionsC1.ST.name)
          ..write(finalClose)
          ..write(close);

        continue;
      }
```

`ControlFunctionsC1.byCode` берёт двухбайтовую последовательность
целиком и для `ESC P` отдаёт `DCS`; `?? controlString` — страховка на
случай, если регулярка когда-нибудь начнёт ловить байт, которого в
перечислении нет.

- [ ] **Шаг 4: прогнать тесты**

```bash
dart test test/parser_control_string_test.dart
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

## Задание 5: документы и полные ворота

**Файлы:**
- Правка: `docs/architecture.md`
- Правка: `docs/backlog.md`
- Правка: `CHANGELOG.md`

**Интерфейсы:** ничего не производит.

- [ ] **Шаг 1: карта**

В `docs/architecture.md`, механизм 2 («Придержанное открытие») сейчас
описан через `OSC`. Переписать его как описание семейства: придерживается
любая управляющая строка без терминатора, `terminated` — вопрос
семейства, `_terminatedOpening` — помощник придержанного открытия, и
`BEL` закрывает только `OSC`. Инвариант про «открытие пришло первым»
оставить как есть — он не менялся.

В таблице «Кто чем владеет» строка про `parsing/parser/` перечисляет
сущности — дописать `ControlString`.

- [ ] **Шаг 2: бэклог**

В `docs/backlog.md` вычеркнуть 7-битную половину пункта, оставив
8-битную с её причиной. Пункт становится примерно таким:

```markdown
- 8-битные C1 пакет не распознаёт вовсе: `0x9B` он читает как обычный
  текст, а не как `CSI`, `0x9D` — не как `OSC`. Правка — в модели
  разбора, и она отделена от 7-битной половины (закрытой волной
  `docs/records/2026-08-11[4]`/`[5]`) сознательно: `0x9B` — валидный
  символ U+009B, который может стоять в честном тексте, и его
  распознавание меняет чтение строк, не содержащих ни одного
  escape-кода. Это решение о том, чем пакет считает свой вход.

      Parser('aa\x9B31mbb').removeAll()
      // 'aa\x9B31mbb' — для пакета всё это текст, для терминала
      // 'aa' в красном и 'bb'
```

Репро проверить пробником перед тем, как записывать.

- [ ] **Шаг 3: CHANGELOG**

Правка на месте, по-английски, в существующей записи 4.0.0 — не новой
секцией и не breaking-нотой. Сказать, что `DCS`, `SOS`, `PM` и `APC`
читаются как управляющие строки, что их тело больше не входит в плоский
текст и не считается в длине, и что `BEL` из них не закрывает ни одну.

- [ ] **Шаг 4: полные ворота**

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

Ожидается: всё зелёное, `publish --dry-run` с нулём предупреждений,
`memory_guard` в полосе (её актуальные числа — в `docs/handoff.md`).
Прогнать примеры из `example/`.

- [ ] **Шаг 5: коммит**

```bash
git add docs/ CHANGELOG.md
git commit
```

---

## Что после плана

Финальное ревью всей ветки, затем локальный `git merge --no-ff` в `main`
— PR на GitHub не заводится. После мержа: шапки записей `[4]` и `[5]`
получают строку «реализован, влит мержем `<sha>`», а `docs/handoff.md`
переписывается под новое состояние. Публикация 4.0.0 и `git push` — по
слову владельца, не по итогу волны.
