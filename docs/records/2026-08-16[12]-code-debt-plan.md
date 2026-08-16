> **Состояние на 2026-08-16:** план написан, работа не начата.
> **Что это:** план работ по спеке волны 8 — пять коммитов: два дефекта
> качества, сокрытие двух флагов из публичной сигнатуры, один лишний байт
> и одна оптимизация горячего пути.
> **Связанные записи:** `2026-08-16[11]-code-debt-design.md` (спека),
> `2026-08-16[5]-project-review.md` (откуда находки).

# План волны 8: код-долг

> **Исполнителю:** задания идут **по порядку** — третье обязано быть до
> четвёртого, иначе правка байта окажется правкой публичного обещания.
> Ожидаемые значения здесь **сняты пробником с живого кода**; если шаг
> «убедиться, что тест падает» даёт не то, что написано, это находка, а не
> повод подогнать ожидание.

**Цель:** закрыть четыре пункта код-долга и сузить публичную сигнатуру
`transitTo`, пока пакет не опубликован.

**Устройство:** три правки поведенчески нейтральны (L7 меняет только
значения хешей, L8 убирает нечитаемый параметр, L23 — порядок вычислений).
Меняется ровно один байт вывода — в случае, недостижимом изнутри пакета.

**Стек:** Dart 3.6.0+, `package:test`, `package:meta` (уже в зависимостях).
Новых зависимостей нет.

**Спека:** `docs/records/2026-08-16[11]-code-debt-design.md`

## Общие ограничения

- **Ветка `fix/code-debt`.**
- **Версию не бампать**, `pubspec.yaml` не трогать.
- **Языки:** дартдок, комментарии в `lib/` и тексты ошибок — **по-английски**;
  `docs/` — по-русски.
- **Коммиты:** один пункт — один коммит, conventional-префикс, тело
  повествовательное по-английски. Писать через `git commit -F -` с
  закавыченным heredoc (`<<'EOF'`); `git merge` так **не умеет** — для
  мержа писать сообщение во временный файл.
- **В индекс — только своё, поимённо.** `git add -A` не использовать.
- Перед каждым коммитом: `dart format --output=none --set-exit-if-changed .`
  и `dart analyze --fatal-infos`.
- **`dart test` может упасть с кодом 137** — это SIGKILL от нехватки
  памяти, а не провал. Проверить `sysctl vm.swapusage` и повторить.

## Что должно остаться неизменным всю волну

| ворота | значение |
|---|---|
| `check_entry_points.dart` | 5 входов, **1646** имён, closed |
| `check_readme_sync.dart` | 24 заголовка, 72 блока |
| `generate.dart` + `git diff` | 8 зон, без диффа |
| `memory_guard` | в полосе 159…332 |
| `complexity_guard` | полосы < 2.5, < 2.5, < 3.5, > 24.0 |

`1646` не сдвинется и после задания 3: снапшот держит top-level имена, а
`transitTo` — член класса. `--update-snapshot` в этой волне не нужен
**ни разу**; если он понадобился, что-то пошло не так.

---

## Задание 1: L7 — засолить хеши цветов их типом

**Файлы:**
- Правка: `lib/src/parsing/colors/color_16.dart:65`
- Правка: `lib/src/parsing/colors/color_256.dart:315`
- Правка: `lib/src/parsing/colors/color_rgb.dart:39`
- Тест: `test/state_equality_contract_test.dart`

**Что даёт дальше:** ничего; задания независимы по коду.

- [ ] **Шаг 1: написать падающий тест**

Дописать в `test/state_equality_contract_test.dart` перед закрывающей
скобкой `main`:

```dart
  group('a colour hashes as itself and not as its neighbour:', () {
    test('the sixteen and the 256 do not share a hash', () {
      // Both hold the same `Colors` value, so hashing the field alone put
      // every one of the 256 pairs in one bucket. Equality told them apart,
      // which is why nothing misbehaved and nothing noticed.
      expect(Color16.red == Color256.red, isFalse);
      expect(Color16.red.hashCode, isNot(Color256.red.hashCode));
    });

    test('and the same holds through a style', () {
      const sixteen = Style(foreground: Color16.red);
      const extended = Style(foreground: Color256.red);

      expect(sixteen == extended, isFalse);
      expect(sixteen.hashCode, isNot(extended.hashCode));
    });

    test('equal colours still hash alike', () {
      // The half that must not break: hashCode is only allowed to tell
      // apart what == tells apart.
      expect(Color16.red, Color16.red);
      expect(Color16.red.hashCode, Color16.red.hashCode);
      expect(Color256.red.hashCode, Color256.red.hashCode);
      expect(ColorRgb(1, 2, 3).hashCode, ColorRgb(1, 2, 3).hashCode);
    });
  });
```

- [ ] **Шаг 2: убедиться, что тест падает**

```bash
dart test test/state_equality_contract_test.dart
```

Ожидается: два первых кейса красные. Хеш `Color16.red` и `Color256.red`
сегодня совпадает — пробником снято значение **4552149** на этой машине
(конкретное число зависит от прогона, важно только совпадение). Третий
кейс зелёный уже сейчас.

- [ ] **Шаг 3: засолить три хеша**

`lib/src/parsing/colors/color_16.dart`:

```dart
  @override
  int get hashCode => Object.hash(Color16, color);
```

`lib/src/parsing/colors/color_256.dart`:

```dart
  @override
  int get hashCode => Object.hash(Color256, color);
```

`lib/src/parsing/colors/color_rgb.dart`:

```dart
  @override
  int get hashCode => Object.hash(ColorRgb, _value);
```

`ColorRgb` правится не потому, что сегодня с кем-то коллидирует, а чтобы
правило было одно на три класса.

**`_target` в соль не входит.** Он не участвует в `==` — намеренно, — и
включение его в хеш нарушило бы контракт «равные объекты дают равный хеш».

- [ ] **Шаг 4: убедиться, что тест проходит**

```bash
dart test test/state_equality_contract_test.dart
```

Ожидается: все кейсы зелёные, включая прежние — в частности
`expect(stack.hashCode, style.hashCode)`, который требует, чтобы `Stack` и
`Style` одного состояния хешировались одинаково. Оба несут один и тот же
экземпляр цвета, поэтому засолка их не разводит.

- [ ] **Шаг 5: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test
git add lib/src/parsing/colors/color_16.dart \
  lib/src/parsing/colors/color_256.dart \
  lib/src/parsing/colors/color_rgb.dart \
  test/state_equality_contract_test.dart
git commit -F - <<'EOF'
fix: let a colour hash as itself rather than as its neighbour

Color16 and Color256 hold a value of the same enum and both hashed that
value alone, so every one of the 256 pairs shared a hash while == told them
apart. Nothing misbehaved — a Set holds both and a Map looks up both,
because equality settles it inside the bucket — which is exactly why it
went unnoticed. What it cost was buckets, systematically, and it reached
State.hashCode, where colours are folded in with everything else.

Each of the three colour classes now salts its hash with its own type.
ColorRgb is in not because it collides with anything today but so that the
rule is one rule: the next colour added should have an obvious form to
copy. The target a colour is painted on stays out of the hash, as it stays
out of ==.
EOF
```

---

## Задание 2: L8 — убрать параметр, который никто не читает

**Файлы:**
- Правка: `lib/src/parsing/state/state.dart:554` (объявление `_color`)
- Правка: `lib/src/parsing/state/state.dart:387,390,393` (три вызова)

**Что берёт из задания 1:** ничего.

- [ ] **Шаг 1: убедиться, что параметр действительно мёртв**

```bash
sed -n '554,559p' lib/src/parsing/state/state.dart
```

Ожидается ровно это — `highOffset` не встречается в теле:

```dart
  String _color(int offset, int highOffset, ExtendedColor color) =>
      switch (color) {
        Color256(:final index) => '$CSI${offset + 8};$COLOR_256;$index$SGR',
        ColorRgb(:final r, :final g, :final b) =>
          '$CSI${offset + 8};$COLOR_RGB;$r;$g;$b$SGR',
      };
```

Если тело изменилось и параметр читается — остановиться и сказать
владельцу: находка устарела.

- [ ] **Шаг 2: убрать параметр из объявления**

```dart
  String _color(int offset, ExtendedColor color) => switch (color) {
        Color256(:final index) => '$CSI${offset + 8};$COLOR_256;$index$SGR',
        ColorRgb(:final r, :final g, :final b) =>
          '$CSI${offset + 8};$COLOR_RGB;$r;$g;$b$SGR',
      };
```

- [ ] **Шаг 3: поправить три вызова**

Строки 387, 390 и 393 сейчас:

```dart
              _color(30, 90, otherForeground),
              _color(40, 100, otherBackground),
              _color(50, 0, otherUnderlineColor),
```

становятся:

```dart
              _color(30, otherForeground),
              _color(40, otherBackground),
              _color(50, otherUnderlineColor),
```

Третий и был тем самым, где `0` не значил ничего.

**Не трогать `_colorIndex`** — соседний метод с той же формой сигнатуры
использует оба параметра (`color.index(offset, highOffset)`), и именно
поэтому мёртвый близнец выглядел живым.

- [ ] **Шаг 4: убедиться, что ничего не сдвинулось**

```bash
dart analyze --fatal-infos
dart test
```

Ожидается: **1104 + кейсы задания 1** зелёных, ни одного изменения в
ожиданиях. Параметр не читался, значит вывод не мог измениться. Любое
движение здесь — находка.

- [ ] **Шаг 5: ворота и коммит**

```bash
dart format --output=none --set-exit-if-changed .
git add lib/src/parsing/state/state.dart
git commit -F - <<'EOF'
refactor: drop the parameter _color never read

Its neighbour _colorIndex takes the same pair and uses both — the offset
for the first eight and the high one for the rest — so _color looked like
it did the same. It does not: an extended colour is written as offset + 8
and then its index, and the high offset has no part in that. One of the
three calls had been passing 0 for it, a number that meant nothing and
could not be told from one that did.
EOF
```

---

## Задание 3: сокрытие `skipReset` и `skipSet`

Решение владельца. Публичной остаётся форма без флагов; флаги переезжают
в `@internal`-метод.

**Файлы:**
- Правка: `lib/src/parsing/state/state.dart:305-325` (дартдок и сигнатура)
- Правка: `lib/src/parsing/state/style.dart:674` (`Style.open`)
- Правка: `lib/src/parsing/parser/sgr_residual.dart:103,124,143,154`
- Правка: `test/substring_open_state_test.dart:26`
- **Не трогается:** `lib/src/parsing/parser/parser.dart` — его `skipSet: true`
  на строке 769 адресован `_renditionTransit`, а не `transitTo`, и остаётся
  как есть.

**Производит для задания 4:** метод
`@internal String transitToPart(State<void> other, {bool skipSet = false, bool skipReset = false})`
— именно в нём задание 4 правит условие.

- [ ] **Шаг 1: переименовать нынешний метод и оставить публичную обёртку**

В `lib/src/parsing/state/state.dart` нынешнее объявление

```dart
  String transitTo(
    State<void> other, {
    bool skipSet = false,
    bool skipReset = false,
  }) {
```

становится

```dart
  String transitToPart(
    State<void> other, {
    bool skipSet = false,
    bool skipReset = false,
  }) {
```

**Тело не трогается вовсе.** Над ним ставится `@internal` и его дартдок
(ниже), а публичная обёртка добавляется рядом.

- [ ] **Шаг 2: написать дартдок обоим**

Нынешний дартдок `transitTo` (строки 305-319) делится надвое. Публичному
достаётся всё, кроме абзаца про флаги:

```dart
  /// The codes that take a terminal from this state to [other].
  ///
  /// Only the difference is written: going from bold red to bold green is one
  /// colour code, not a reset and two. The result is empty where the two
  /// states are the same, and where [other] is a [NoStyle], which is the
  /// state that writes nothing by definition.
  ///
  /// Where the standard has no code for the difference, what it does have is
  /// written instead: bold and dim are taken off together by `CSI 22`, so
  /// going from both to bold alone is `CSI 22;1` — the pair off, then the
  /// bold back on.
  String transitTo(State<void> other) => transitToPart(other);

  /// Half of [transitTo]: [skipReset] leaves out the codes that take
  /// properties off and [skipSet] the ones that put them on.
  ///
  /// Of use where the far end is known to need only the other half — this
  /// package writes the opening of a style, the tail of a slice and the
  /// base of a residual that way. It is not part of the public surface: the
  /// useful case is already [Style.open], and the two halves have edges a
  /// caller would have to be told about rather than discover.
  @internal
  String transitToPart(
    State<void> other, {
    bool skipSet = false,
    bool skipReset = false,
  }) {
```

Проверить, что `package:meta` уже импортирован в `state.dart`; если нет —
добавить `import 'package:meta/meta.dart';`. Прецедент `@internal` на члене
публичного класса в репозитории есть: `Color16.on`.

- [ ] **Шаг 3: перевести внутренние вызовы**

Четыре места, все с флагами:

```bash
grep -n "transitTo(" lib/src/parsing/state/style.dart lib/src/parsing/parser/sgr_residual.dart
```

- `style.dart:674` → `Style.terminalColors.transitToPart(this, skipReset: true)`
- `sgr_residual.dart:103` → `from.transitToPart(to, skipSet: skipSet, skipReset: skipReset)`
- `sgr_residual.dart:121-125` → `from.transitToPart(...)`
- `sgr_residual.dart:141-146` → `effective.transitToPart(...)`
- `sgr_residual.dart:152-157` → `Style.terminalColors.transitToPart(...)`

**`sgr_residual.dart:210` не трогать** — там `rawAfter.transitTo(desired)`
без флагов, и публичная форма ему подходит.

- [ ] **Шаг 4: перевести единственный тест, пользующийся флагом**

`test/substring_open_state_test.dart:26` — было:

```dart
      expect(
        from.transitTo(to, skipSet: true),
        '\x1B[22;1m',
        reason: 'the 1 is the other half of the 22, not a set of its own',
      );
```

стало:

```dart
      expect(
        from.transitToPart(to, skipSet: true),
        '\x1B[22;1m',
        reason: 'the 1 is the other half of the 22, not a set of its own',
      );
```

Ожидание `'\x1B[22;1m'` **не меняется**: это ветвь `skipSet`, где сброс
выдаётся, а задание 4 трогает только ветвь `skipReset`.

- [ ] **Шаг 5: убедиться, что снаружи флагов больше нет**

```bash
grep -rn "transitTo(.*skip" lib/ test/ example/ | grep -v transitToPart
```

Ожидается: пусто.

```bash
dart analyze --fatal-infos
dart run tool/check_entry_points.dart
```

Ожидается: анализ чист; `5 entry points, 1646 public names, closed` —
число **то же**, потому что снапшот держит top-level имена, а не члены.
Если число сдвинулось, остановиться: значит правка задела что-то ещё.

- [ ] **Шаг 6: полный прогон и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart test
git add lib/src/parsing/state/state.dart lib/src/parsing/state/style.dart \
  lib/src/parsing/parser/sgr_residual.dart test/substring_open_state_test.dart
git commit -F - <<'EOF'
refactor: keep the two halves of a transit out of the public surface

transitTo offered skipSet and skipReset to anybody holding a State, and
the flags are worth having — this package writes the opening of a style,
the tail of a slice and the base of a residual with one half each. What is
not worth having is promising them. Their edges need explaining rather
than discovering, and the case a caller actually wants is already a getter:
Style.open is terminalColors transited with the resets left out.

So the public form loses them and an @internal one beside it keeps them,
the way Color16.on is already marked. Nothing about the bytes changes here.
The gates cannot see this: the entry-point snapshot holds top-level names,
so a method losing two parameters passes it in silence — which is a finding
for the handoff and the reason this is done by hand and by eye.

Free today only because 4.0.0 is unpublished. After the tag it would be a
breaking change.
EOF
```

---

## Задание 4: L12 — убрать байт, который теперь ничего не обещает

**Файлы:**
- Правка: `lib/src/parsing/state/state.dart:411-416`
- Тест: `test/substring_open_state_test.dart`

**Берёт из задания 3:** `transitToPart` — правка идёт в его теле, и тест
зовёт его же.

- [ ] **Шаг 1: снять пробником, что выдаётся сейчас**

Записать перед правкой, чтобы было с чем сравнивать:

```bash
cat > .dart_tool/l12_probe.dart <<'PROBE'
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  const boldDim = Style(bold: true, dim: true);
  const boldOnly = Style(bold: true);
  const dimOnly = Style(dim: true);

  for (final (name, from, to) in <(String, Style, Style)>[
    ('bold+dim -> bold', boldDim, boldOnly),
    ('bold+dim -> dim', boldDim, dimOnly),
    ('bold -> dim', boldOnly, dimOnly),
    ('dim -> bold', dimOnly, boldOnly),
    ('bold+dim -> plain', boldDim, Style()),
  ]) {
    print('$name');
    print('  full      = ${from.transitTo(to).ansiShowEscapeSequences()}');
    print('  skipReset = ${from.transitToPart(to, skipReset: true).ansiShowEscapeSequences()}');
    print('  skipSet   = ${from.transitToPart(to, skipSet: true).ansiShowEscapeSequences()}');
  }
}
PROBE
dart run .dart_tool/l12_probe.dart
```

Ожидается ровно это (снято 2026-08-16 до правки):

```
bold+dim -> bold
  full      = [CSI 22;1 SGR]
  skipReset = [CSI 1 SGR]
  skipSet   = [CSI 22;1 SGR]
bold+dim -> dim
  full      = [CSI 22;2 SGR]
  skipReset = [CSI 2 SGR]
  skipSet   = [CSI 22;2 SGR]
bold -> dim
  full      = [CSI 22;2 SGR]
  skipReset = [CSI 2 SGR]
  skipSet   = [CSI 22;2 SGR]
dim -> bold
  full      = [CSI 22;1 SGR]
  skipReset = [CSI 1 SGR]
  skipSet   = [CSI 22;1 SGR]
bold+dim -> plain
  full      = [CSI 0 SGR]
  skipReset =
  skipSet   = [CSI 0 SGR]
```

Лишние здесь два: `bold+dim -> bold` и `bold+dim -> dim` под `skipReset` —
там выживающее свойство и не снималось.

- [ ] **Шаг 2: написать падающий тест**

Дописать в `test/substring_open_state_test.dart`, в ту же группу
`'the survivor of a joint reset comes back:'`:

```dart
    test('but not where the reset it survives was skipped', () {
      // With skipReset the CSI 22 is not written, so nothing took the
      // survivor off and nothing has to put it back. Where the property
      // was not on to begin with the set is still needed.
      const boldDim = Style(bold: true, dim: true);
      const boldOnly = Style(bold: true);
      const dimOnly = Style(dim: true);

      expect(
        boldDim.transitToPart(boldOnly, skipReset: true),
        isEmpty,
        reason: 'bold was on and stayed on',
      );
      expect(
        boldDim.transitToPart(dimOnly, skipReset: true),
        isEmpty,
        reason: 'dim was on and stayed on',
      );
      expect(
        boldOnly.transitToPart(dimOnly, skipReset: true),
        '\x1B[2m',
        reason: 'dim was not on, so it has to be set',
      );
      expect(
        dimOnly.transitToPart(boldOnly, skipReset: true),
        '\x1B[1m',
        reason: 'bold was not on, so it has to be set',
      );
    });
```

- [ ] **Шаг 3: убедиться, что тест падает**

```bash
dart test test/substring_open_state_test.dart
```

Ожидается: первые два `expect` красные — сейчас там `'\x1B[1m'` и
`'\x1B[2m'` вместо пустой строки. Два последних зелёные уже сейчас.

- [ ] **Шаг 4: поправить условие**

В `lib/src/parsing/state/state.dart` блок

```dart
      if (jointIntensityReset) ...[
        if (other.isBold) '1',
        if (other.isDim) '2',
      ] else if (!skipSet) ...[
```

становится

```dart
      if (jointIntensityReset && !skipReset) ...[
        if (other.isBold) '1',
        if (other.isDim) '2',
      ] else if (!skipSet) ...[
```

Комментарий над `jointIntensityReset` (строки 396-400) дополнить абзацем:

```dart
    // Where the reset itself is skipped there is nothing to survive: the
    // `CSI 22` was not written, so whatever was on is still on, and putting
    // it back would be a byte saying what the terminal already knows.
```

- [ ] **Шаг 5: убедиться, что тест проходит, и что изменился ровно один случай**

```bash
dart test test/substring_open_state_test.dart
dart run .dart_tool/l12_probe.dart
rm -f .dart_tool/l12_probe.dart
```

Ожидается: пробник даёт **ту же таблицу, что в шаге 1, с двумя
изменениями** — `bold+dim -> bold` и `bold+dim -> dim` под `skipReset`
становятся пустыми. Все `full` и все `skipSet` — прежние. Если сдвинулось
что-то ещё, остановиться и разобраться.

- [ ] **Шаг 6: полный прогон и коммит**

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test
```

Ожидается: зелено, **без единого изменённого ожидания** — `skipReset` не
упоминал ни один тест до этой волны, а внутренние вызовы идут от
`Style.terminalColors`, где нет ни жирности, ни тусклости, так что ветка
изнутри недостижима. Любое движение — находка: объяснить, а не подогнать.

```bash
git add lib/src/parsing/state/state.dart test/substring_open_state_test.dart
git commit -F - <<'EOF'
fix: stop restoring an intensity the skipped reset never took off

CSI 22 takes bold and dim off together, so where one of the pair goes off
the other has to be written back behind it. That is why the branch does not
look at what is already on — after the reset, nothing is. But with
skipReset the reset is not written, and the survivor was never in danger:
the byte says what the terminal already knows.

Two of the five intensity transitions were paying it. Neither was reachable
from inside the package — every internal caller of the skipping form starts
from terminalColors, which has neither bold nor dim, so the joint branch is
never entered there. It reached only a caller using the flag directly, and
as of the commit before this one there is no such caller to promise
anything to.
EOF
```

---

## Задание 5: L23 — решать до постройки

**Файлы:**
- Правка: `lib/src/parsing/parser/sgr_residual.dart:58-82` (`_advanceSgrResidual`)
- Правка: `lib/src/parsing/parser/entities/sgr.dart:318-333` (`commitFunction`)

**Берёт из заданий 1-4:** ничего.

**Производит:** `bool _residualKeeps(_SgrResidual? residual, SgrFunction? function)`
в `sgr_residual.dart` — единственный источник истины о том, сохранится ли
операция.

- [ ] **Шаг 1: снять базу бенчмарка ДО правки**

**На этом же дереве, сразу перед правкой.** Числа из спеки и из прошлых
заходов для сравнения не годятся — машина уходит в своп.

```bash
sysctl vm.swapusage
dart run benchmark/parser_benchmark.dart > /tmp/bench-before.txt 2>&1
tail -40 /tmp/bench-before.txt
```

Сохранить вывод: он идёт в отчёт волны вместе с «после».

- [ ] **Шаг 2: ввести общий предикат**

В `lib/src/parsing/parser/sgr_residual.dart`, рядом с `_isFullSgrReset`
и `_isUnknownSgrFunction`:

```dart
/// Whether an operation carrying [function] would be kept by
/// [_advanceSgrResidual], given the [residual] it would extend.
///
/// The answer needs nothing but the function and whether a residual is
/// already open, which is what lets the caller decide before building an
/// operation it may be about to throw away. Kept as the one authority: it
/// is the first thing [_advanceSgrResidual] asks, so the guard and the
/// advance cannot come to disagree.
bool _residualKeeps(_SgrResidual? residual, SgrFunction? function) =>
    !_isFullSgrReset(function) &&
    (residual != null ||
        function == null ||
        _isUnknownSgrFunction(function));
```

- [ ] **Шаг 3: сделать предикат первой проверкой `_advanceSgrResidual`**

Было:

```dart
_SgrResidual? _advanceSgrResidual(
  _SgrResidual? residual,
  Style before,
  _SgrOperation operation,
) {
  if (_isFullSgrReset(operation.function)) {
    return null;
  }

  if (residual == null) {
    if (!operation.isUnknown) {
      return null;
    }

    final root = _SgrResidualRoot(before);
    return _SgrResidual._(root, null, operation, 1);
  }

  return _SgrResidual._(
    residual.root,
    residual,
    operation,
    residual.depth + 1,
  );
}
```

Стало:

```dart
_SgrResidual? _advanceSgrResidual(
  _SgrResidual? residual,
  Style before,
  _SgrOperation operation,
) {
  if (!_residualKeeps(residual, operation.function)) {
    return null;
  }

  if (residual == null) {
    final root = _SgrResidualRoot(before);
    return _SgrResidual._(root, null, operation, 1);
  }

  return _SgrResidual._(
    residual.root,
    residual,
    operation,
    residual.depth + 1,
  );
}
```

Поведение то же: `_residualKeeps` — это в точности отрицание двух прежних
ранних выходов. `operation.isUnknown` есть
`function == null || _isUnknownSgrFunction(function!)`, что и раскрыто в
предикате.

- [ ] **Шаг 4: поставить охрану в `commitFunction`**

В `lib/src/parsing/parser/entities/sgr.dart` было:

```dart
  void commitFunction(SgrFunction function) {
    state = _applyKnownSgrFunction(state, function);
    functions.add(function);

    final rawParameters =
        _rawParams.sublist(_operationStart, _index + 1).join(';');
    final operation = _SgrOperation(
      string: '$CSI$rawParameters$SGR',
      function: function,
      state: state.toStyle(),
    );
    residual = _advanceSgrResidual(residual, _operationBefore, operation);

    _index++;
    _savedIndex = null;
  }
```

Стало:

```dart
  void commitFunction(SgrFunction function) {
    state = _applyKnownSgrFunction(state, function);
    functions.add(function);

    // The operation is thrown away for every known function while no
    // residual is open, which is most of what an ordinary string holds. The
    // string it carries costs a sublist, a join and an interpolation, and
    // its state costs a whole Style where the parser is a stacked one, so
    // the question is asked before any of that is built.
    if (_residualKeeps(residual, function)) {
      final rawParameters =
          _rawParams.sublist(_operationStart, _index + 1).join(';');
      residual = _advanceSgrResidual(
        residual,
        _operationBefore,
        _SgrOperation(
          string: '$CSI$rawParameters$SGR',
          function: function,
          state: state.toStyle(),
        ),
      );
    } else {
      residual = null;
    }

    _index++;
    _savedIndex = null;
  }
```

Ветвь `else` даёт `null` — ровно то, что возвращал
`_advanceSgrResidual` в этих случаях.

**`csi.dart:47` не трогать.** Второй вызывающий — непрозрачная ветвь, где
`function == null`, операция сохраняется всегда и строить её всё равно
надо.

- [ ] **Шаг 5: убедиться, что поведение не изменилось**

```bash
dart analyze --fatal-infos
dart test
```

Ожидается: зелено, **ни одного изменённого ожидания**. Это перестановка
порядка вычислений, а не смена поведения; любое движение — находка.

- [ ] **Шаг 6: снять бенчмарк ПОСЛЕ и сравнить**

```bash
sysctl vm.swapusage
dart run benchmark/parser_benchmark.dart > /tmp/bench-after.txt 2>&1
diff -y --width=160 /tmp/bench-before.txt /tmp/bench-after.txt | head -60
```

Ревью заявляло **~15 %** горячего пути. Записать в отчёт то, что вышло, —
и если вышло существенно меньше, это тоже результат: значит оценка была
завышена, а правка всё равно оправдана тем, что убирает работу, которая
выбрасывалась.

- [ ] **Шаг 7: полосы guard'ов**

```bash
dart run benchmark/memory_guard.dart
dart run benchmark/complexity_guard.dart
```

Ожидается: обе в полосах. `complexity_guard` меряет **форму** роста, а не
цену, поэтому ускорение константы он показать не должен. **Полосы не
трогать ни при каком исходе** — это прямо запрещено в `AGENTS.md`.

- [ ] **Шаг 8: коммит**

```bash
dart format --output=none --set-exit-if-changed .
git add lib/src/parsing/parser/sgr_residual.dart \
  lib/src/parsing/parser/entities/sgr.dart
git commit -F - <<'EOF'
perf: decide whether an SGR operation is wanted before building it

Every SGR function committed built an operation: a sublist of the raw
parameters, a join, an interpolation, and the state converted to a Style —
free for a plain parser, a whole new object for a stacked one. Then the
residual threw it away for every known function while no residual was open,
which is most of what an ordinary coloured line contains.

The decision needs only the function and whether a residual is already
open, so it is asked first. It lives in one predicate that the advance
itself uses as its opening question, rather than being copied into the
caller — a condition kept in two places is the defect the wave before this
one spent its time correcting.
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

Ожидается: `check_entry_points` — 5 входов, **1646** имён; `generate.dart`
— 8 зон без диффа; `check_readme_sync` — 24 и 72; `dart test` — 1104 плюс
кейсы заданий 1 и 4 (число сверить прогоном, а не сложением); guard'ы в
полосах; `dart doc` и `dart pub publish` — по 0 предупреждений.

`dart pub publish --dry-run` гонять **на чистом дереве**: незакоммиченный
файл, входящий в архив, он считает предупреждением.

- [ ] **Шаг 2: пуш ветки и зелёный CI на обеих ногах**

```bash
git push -u origin fix/code-debt
```

Нога `3.6.0` — единственное место, где проверяется пол SDK.

- [ ] **Шаг 3: ревью всей ветки**

```bash
git diff main...fix/code-debt
```

Смотреть особенно за заданием 3: **ворота его не видят**, снапшот держит
top-level имена.

- [ ] **Шаг 4: мерж и пуш**

`git merge` не читает сообщение со stdin (`-F -` даёт
`error: could not read file '-'`, код 129), поэтому через временный файл:

```bash
git checkout main
msg=$(mktemp)
cat > "$msg" <<'EOF'
merge: pay off the code debt the review found

Four findings of debt and one narrowing of the public surface. The colours
hash as themselves now rather than sharing a bucket with their neighbour;
_color has lost the parameter it never read; the two halves of a transit
are internal, which is what made the byte they argued over free to remove;
and an SGR operation is no longer built to be thrown away.

This closes the programme of fixes the pre-publication review opened.
EOF
git merge --no-ff fix/code-debt -F "$msg"
rm -f "$msg"
git push origin main
```

- [ ] **Шаг 5: документы**

- отчёт волны — записью жанра `report` в `docs/records/`, с обеими
  колонками бенчмарка;
- `docs/handoff.md` переписать: **программа правок по ревью закончена**,
  открытых волн нет; в «Найдено волнами» добавить, что
  `check_entry_points` не пинит сигнатуры членов;
- шапки спеки и этого плана — на «сделано и смержено (коммит)».

---

## Чего этот план не делает

- **Не пинит сигнатуры членов.** То, что задание 3 проходит мимо ворот, —
  находка для handoff, а не задача волны: закрыть её значит завести третий
  инструмент и отдельный заход.
- **Не трогает `_target` в равенстве цветов.** Он исключён из `==`
  намеренно.
- **Не расширяет полосы guard'ов** ни при каком исходе бенчмарка.
- **Не публикует и не бампает версию.** Тег и публикация — решение
  владельца, не менявшееся с 2026-08-05.
