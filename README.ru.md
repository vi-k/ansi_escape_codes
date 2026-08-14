[![Dart CI](https://github.com/vi-k/ansi_escape_codes/actions/workflows/dart.yml/badge.svg)](https://github.com/vi-k/ansi_escape_codes/actions/workflows/dart.yml)
[![Pub Publisher](https://img.shields.io/pub/publisher/ansi_escape_codes)](https://pub.dev/publishers/yet-another.dev/packages)
![Pub Version](https://img.shields.io/pub/v/ansi_escape_codes)
![GitHub License](https://img.shields.io/github/license/vi-k/ansi_escape_codes)

> Русский перевод [README.md](README.md). В пакет не входит и на pub.dev не
> публикуется. Английский текст — источник: если переводу и ему есть в чём
> разойтись, прав английский.

Инструментарий для работы с **ANSI escape codes** и разбора строк, которые
их содержат.

> ANSI escape sequences — стандарт внутриполосной сигнализации, управляющий
> положением курсора, цветом, начертанием шрифта и прочими возможностями
> текстовых терминалов и их эмуляторов. Определённые последовательности
> байтов, большинство из которых начинается с ASCII-символа escape и
> квадратной скобки, встраиваются в текст. Терминал читает их как команды, а
> не как текст для вывода. [Википедия](https://en.wikipedia.org/wiki/ANSI_escape_code)

Обе половины — одним импортом:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

// Запись: стилем или константами, которые в рантайме не стоят ничего.
print('${Styles.red.bold('ERROR')} the roof is on fire');
print('${fgCyan}the same in cyan$reset');

// Чтение: что строка говорит, какой длины она без кодов и какой стиль
// действует в любой её точке.
const line = '${fgRed}ERROR$reset: the roof is on fire';
final parser = Parser(line);

print(parser.removeAll()); // ERROR: the roof is on fire
print(parser.length); // 26
print(parser.stateAt(3).foregroundColor?.id); // fgRed
print(parser.showControlFunctions()); // [fgRed]ERROR[reset]: the roof is on fire
```


## Возможности

- раскраска: готовые значения дают константные строки и
  [максимальную производительность](#максимальная-производительность), а
  [стили](#сила-стилей) — полную силу;
- управление курсором и терминалом;
- [чтение](#чтение) строк с escape-кодами: что в них написано, какой они
  длины без кодов, какой стиль действует в каждой точке;
- [гиперссылки](#гиперссылки), которые переживают разрез: ссылка, внутрь
  которой попал срез или перенос строки, открывается заново и остаётся одной
  ссылкой;
- [стиль по умолчанию](#printer) для всего, что печатает приложение.


## Оглавление

- [Быстрый старт](#быстрый-старт)
  - [Как раскрасить текст](#как-раскрасить-текст)
- [Имена, которые приносит пакет](#имена-которые-приносит-пакет)
- [Запись](#запись)
  - [Константы и строки из них](#константы-и-строки-из-них)
  - [Готовые функции и константы](#готовые-функции-и-константы)
  - [Стили](#стили)
  - [Printer](#printer)
  - [StackedPrinter](#stackedprinter)
  - [Печать в sink](#печать-в-sink)
  - [Стиль по умолчанию для всего вывода](#стиль-по-умолчанию-для-всего-вывода)
  - [Логирование](#логирование)
- [Чтение](#чтение)
  - [Parser](#parser)
  - [Быстрый анализ](#быстрый-анализ)
  - [Типы последовательностей](#типы-последовательностей)
  - [Неизвестные последовательности](#неизвестные-последовательности)
- [Гиперссылки](#гиперссылки)
- [Утилиты](#утилиты)
- [Байты и что они значат](doc/reference.md) — таблицы стандарта


## Быстрый старт

### Как раскрасить текст

Раскрашивать можно на разных уровнях.

#### Близко к стандарту ANSI

Если нужен уровень, максимально близкий к ANSI, есть готовые константы,
соответствующие стандарту.

```dart
import 'package:ansi_escape_codes/ansi.dart';

void main() {
  const text = '$CSI$FG_GREEN$SGR Green text $CSI$FG_DEFAULT$SGR$LF'
    '$CSI$FOREGROUND;$COLOR_256;$RGB_520$SGR Orange text $CSI$RESET$SGR';

  print(text);
}
```

Скорее всего, этот вариант интересен только знатокам стандарта.

Все они перечислены в [справочнике](doc/reference.md) и живут в
[lib/src/ansi](https://github.com/vi-k/ansi_escape_codes/tree/main/lib/src/ansi).

#### Максимальная производительность

Удобный и очень эффективный вариант — готовые значения, скрывающие сложность
ANSI:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  const text = '$fgGreen Green text $resetFg'
    '$bgYellow Yellow background $resetBg'
    '$bold Bold text $resetBoldAndDim'
    '$italic Italic text $resetItalic'
    '$underline Underline text $resetUnderline'
    '$reset';

  print(text);
}
```

Главная их особенность в том, что из них получаются готовые к употреблению
константные строки.

`fgGreen` — это ANSI-последовательность, задающая зелёный цвет текста.
`bgYellow` задаёт жёлтый цвет фона. И так далее.

`resetFg` возвращает цвет текста к тому, который задан по умолчанию в вашем
терминале. `resetBg` возвращает к умолчанию цвет фона. И так далее.

> [!NOTE]
> Обратите внимание на такой пример:
>
> ```dart
> print('$fgGreen Green text $fgYellow Yellow text $resetFg Default text');
> ```
>
> После `resetFg` цвет текста вернётся не к `fgGreen`, а к стандартному цвету
> текста терминала!
>
> Если нужна возможность откатиться к предыдущему цвету, используйте
> [стили](#сила-стилей) или [StackedPrinter](#stackedprinter).

`bold` и `dim` — два конца одного свойства, яркости, и ANSI возвращает её к
обычной одним кодом: `resetBoldAndDim`. Включены они могут быть и оба сразу —
этот код снимает любой из них.

`reset` возвращает к умолчанию все настройки.

Справочник называет их рядом с кодами, которые они пишут, а живут они в
[lib/src/ready_to_use](https://github.com/vi-k/ansi_escape_codes/tree/main/lib/src/ready_to_use).

#### Сила стилей

```dart
import 'package:ansi_escape_codes/style.dart';

void main() {
  final defaultStyle = Styles.gray12;
  final greenStyle = Styles.green.bold;
  final highlighedStyle = Styles.red.bgYellow.underline;

  print(
    defaultStyle(
      'Normal text'
      ' ${greenStyle('Green ${highlighedStyle('Highlighted text')} text')}'
      ' Normal text',
    ),
  );
}
```

Во-первых, свой стиль можно собрать из любых частей. Каждый стиль, несущий
одно свойство, — это константа в `Styles` (свойство или цвет таблицы), и
цепочка продолжается с любой из них:

```dart
final mine = Styles.rgb050.bgRgb010.bold.italic.underline;
final warning = Styles.red.bold;
```

Во-вторых, стили вкладываются друг в друга: закончив действие, вложенный
стиль возвращает текст к родительскому.


## Имена, которые приносит пакет

Каждая точка входа приносит свою часть пакета:

| Импорт | Имён | Что приносит |
|:---|---:|:---|
| `ansi_escape_codes.dart` | ~1000 | всё: готовые строки (`fgRed`, `cursorUp`), стили, парсер, состояние, таблицы управляющих функций, расширения `String` и две утилиты терминала |
| `ansi.dart` | ~500 | байты, названные стандартом: `CSI`, `CUU`, `BOLD`, `RESERVED_5F`. Единственная, которая не входит в первую: готовые строки построены из этих констант, но ни одна не приносит другую |
| `style.dart` | 82 | стили, состояние и парсер с таблицами управляющих функций — без таблиц готовых строк |
| `extensions.dart` | 8 | расширения `String`, два перечисления, названные в их сигнатурах, и исключение, которым бросаются обе вставки |
| `utils.dart` | 2 | только `tabs` и `currentCursorPos` |

Три нижние — части первой и существуют для тех случаев, когда пространство
имён поменьше стоит отдельного импорта: программе, которая только читает
escape-коды, ни к чему 900 констант для их записи. Стили и парсер живут в
одной библиотеке, поэтому `style.dart` приносит оба: написать стиль и
прочитать его обратно — две половины одной поверхности.

Обычно хватает одного импорта:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

print('${bold}by the string$reset');
print(Styles.bold('by the style'));
```

Строка и стиль различаются местом: `bold` — это `String` из escape-кодов,
`Styles.bold` — стиль. Из стилей ничего не пишется со строчной буквы, так что
эти двое не сталкиваются.

Пакет экспортирует и имена, которые Flutter считает своими: `Text`, `State`,
`Stack`, `Colors` и `Color`. Ничего не ломается, пока одно из них не написано;
тогда компилятор спросит, что имелось в виду, — Flutter импортируют явно, а
между двумя явными импортами вопрос остаётся вам. Во Flutter-приложении
спрячьте ту сторону, которую этим именем не зовёте:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart'
    hide Color, Colors, Stack, State, Text;
```

То же сокрытие нужно и для `style.dart`: эти пять имён определяет парсер, а
оба импорта его приносят. Свободны от них только `ansi.dart`,
`extensions.dart` и `utils.dart`: первый приносит константы, второй — свои две
функции, третий — расширения и два перечисления из их сигнатур,
`ControlCodeStyle` и `ControlFunctionsC0`.

Имён из `dart:core` здесь не перекрывает ничто, и это сделано намеренно: то,
что выдаёт парсер, до 4.0.0 звалось `Match` и перекрывало `dart:core.Match`
**молча** — явный импорт старше неявного, поэтому компилятор ничего не
спрашивал, а обычный код с регулярным выражением падал с ошибками, ни одна из
которых не называла пакет. Теперь это `Piece`, а `Matches` — `Pieces`.

Со строчной буквы экспортируются готовые строки — `fgRed`, `cursorUp`,
`bold` — и `tabs`. Стилей среди них нет: они константы в `Styles`. Поэтому
имя, с которым скорее всего встретится ваше собственное, — это `tabs`, и
решается это тем же `hide` или префиксом.


## Запись

Константы и стили — два способа одеть строку; принтеры — способ одеть всё,
что печатает программа, независимо от того, просила она об этом или нет.

### Константы и строки из них

Строки с ANSI escape codes могут быть константами:

```dart
const text = '$fgGreen Green text $resetFg'
    '$bgYellow Yellow background $resetBg'
    '$bold Bold text $resetBoldAndDim'
    '$italic Italic text $resetItalic'
    '$underline Underline text $resetUnderline';
print(text);
```

Для сложных случаев есть функции:

```dart
final nonConstantText = '${fgRgb(255, 128, 0)} Orange text $resetFg';
print(nonConstantText);
```

Но даже здесь можно перейти на константы:

```dart
const constantText = '${fgRgbOpen}255;128;0$fgRgbClose Orange text $resetFg';
print(constantText);
```

Разумеется, ничто не мешает пользоваться самими escape-кодами напрямую. Но и
в этом случае предопределённые константы делают текст читаемее.

Все примеры ниже равнозначны:

```dart
import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

print('\x1B[38;2;255;128;0m Orange text \x1B[0m');
print('$ESC[38;2;255;128;0m Orange text $ESC[0m');
print('${CSI}38;2;255;128;0$SGR Orange text ${CSI}0$SGR');
print('$CSI$FOREGROUND;$COLOR_RGB;255;128;0$SGR Orange text $CSI$RESET$SGR');
print('${fgRgbOpen}255;128;0$fgRgbClose Orange text $reset');
print('${fgRgb(255, 128, 0)} Orange text $reset'); // Не константа!
```

Управляющие коды намеренно названы в **SCREAMING_SNAKE_CASE**, а не в
привычном для Dart **camelCase**. Во-первых, так они названы в стандарте.
Во-вторых, в таком виде они не помешают вам называть свои переменные.
**В-третьих и в главных, большинству они напрямую не нужны.**

Все они перечислены в [справочнике](doc/reference.md) — наборы C0 и C1,
финальные байты управляющих последовательностей, независимые функции, все
параметры SGR, 256-цветная таблица и 24-битные цвета — с тем, что каждый
делает, и с готовым именем рядом. Ниже — та таблица, к которой тянутся по
ходу письма, а не та, в которой ищут.

### Готовые функции и константы

Готовые функции и константы заменяют работу с управляющими функциями в
принятом для Dart стиле.

| Цель                               | Как                           | Описание          |
|:-----------------------------------|:------------------------------|:------------------|
| Курсор вверх                       | **шаблон:** `${cursorUpOpen}$n$cursorUpClose`              <br>**функция:** `cursorUpN(int n)`                <br>**константа по умолчанию:** `cursorUp`             | Двигает курсор на `n` (по умолчанию 1) строк вверх. |
| Курсор вниз                        | **шаблон:** `${cursorDownOpen}$n$cursorDownClose`          <br>**функция:** `cursorDownN(int n)`              <br>**константа по умолчанию:** `cursorDown`           | Двигает курсор на `n` (по умолчанию 1) строк вниз. |
| Курсор вперёд                      | **шаблон:** `${cursorRightOpen}$n$cursorRightClose`        <br>**функция:** `cursorRightN(int n)`             <br>**константа по умолчанию:** `cursorRight`          | Двигает курсор на `n` (по умолчанию 1) символов вправо. |
| Курсор назад                       | **шаблон:** `${cursorLeftOpen}$n$cursorLeftClose`          <br>**функция:** `cursorLeftN(int n)`              <br>**константа по умолчанию:** `cursorLeft`           | Двигает курсор на `n` (по умолчанию 1) символов влево. |
| Курсор на следующую строку         | **шаблон:** `${cursorNextLineOpen}$n$cursorNextLineClose`  <br>**функция:** `cursorNextLineN(int n)`          <br>**константа по умолчанию:** `cursorNextLine`       | Переводит курсор в начало строки на `n` (по умолчанию 1) строк ниже. |
| Курсор на предыдущую строку        | **шаблон:** `${cursorPrevLineOpen}$n$cursorPrevLineClose`  <br>**функция:** `cursorPrevLineN(int n)`          <br>**константа по умолчанию:** `cursorPrevLine`       | Переводит курсор в начало строки на `n` (по умолчанию 1) строк выше. |
| Курсор по горизонтали              | **шаблон:** `${cursorHPosOpen}$n$cursorHPosClose`          <br>**функция:** `cursorHPosTo(int n)`             <br>**константа по умолчанию:** `cursorHPosToBegin`    | Переводит курсор в колонку `n` (по умолчанию 1). |
| Позиция курсора                    | **шаблон:** `${cursorPosOpen}$row;$col$cursorPosClose`     <br>**функция:** `cursorPosTo(int row, int col)`   <br>**константа по умолчанию:** `cursorPosToTopLeft`   | Переводит курсор в строку `row` и колонку `col`. |
| Позиция курсора по горизонтали и вертикали | **шаблон:** `${cursorHVPosOpen}$row;$col$cursorHVPosClose` <br>**функция:** `cursorHVPosTo(int row, int col)` <br>**константа по умолчанию:** `cursorHVPosToTopLeft` | То же, что `cursorPosTo`, с небольшими отличиями. |
| Очистить страницу                  | **шаблон:** `${eraseInPageOpen}$s$eraseInPageClose`        <br>**функция:**                                   <br>**константы по умолчанию:** `erasePage`, `eraseInPageToBegin`, `eraseInPageToEnd` | Стирает часть страницы: `s`=0 (или пусто) — до конца, `s`=1 — до начала, `s`=2 — всю страницу. |
| Очистить строку                    | **шаблон:** `${eraseInLineOpen}$s$eraseInLineClose`        <br>**функция:**                                   <br>**константы по умолчанию:** `eraseLine`, `eraseInLineToBegin`, `eraseInLineToEnd` | Стирает часть строки: `s`=0 (или пусто) — до конца, `s`=1 — до начала, `s`=2 — всю строку. |
| Прокрутка вверх                    | **шаблон:** `${scrollUpOpen}$n$scrollUpClose`              <br>**функция:** `scrollUpN(int n)`                <br>**константа по умолчанию:** `scrollUp`             | Прокручивает страницу на `n` (по умолчанию 1) строк вверх. Новые строки добавляются снизу. |
| Прокрутка вниз                     | **шаблон:** `${scrollDownOpen}$n$scrollDownClose`          <br>**функция:** `scrollDownN(int n)`              <br>**константа по умолчанию:** `scrollDown`           | Прокручивает страницу на `n` (по умолчанию 1) строк вниз. Новые строки добавляются сверху. |
| Спрятать курсор                    | **константа:** `hideCursor`    | Прячет курсор. |
| Показать курсор                    | **константа:** `showCursor`    | Показывает курсор. |
| Сохранить курсор                   | **константа:** `saveCursor`    | Сохраняет позицию курсора вместе с состоянием кодировки и атрибутами оформления. |
| Восстановить курсор                | **константа:** `restoreCursor` | Восстанавливает позицию курсора, состояние кодировки и атрибуты оформления из предыдущего `saveCursor`, а если его не было — сбрасывает всё это к умолчаниям. |
| Альтернативный экран               | **константа:** `useAlternateScreen` | Переключает на экран, на котором рисует полноэкранная программа: курсор сохраняется, альтернативный экран очищается, а тот, с которого программа запущена, остаётся нетронутым. |
| Основной экран                     | **константа:** `useMainScreen` | Возвращает на экран, с которого программа запущена, вместе со всей его историей прокрутки; курсор — там, где его оставил `useAlternateScreen`. |

Все примеры ниже равнозначны:

```dart
print('\x1B[4A');
print('${CSI}4$CUU');
print('${cursorUpOpen}4$cursorUpClose');
print(cursorUpN(4)); // Не константа!
```

### Стили

`Styles` держит каждый стиль, несущий одно свойство, и таких 783: пятнадцать
свойств — `Styles.bold`, `Styles.italic` — и 256-цветная таблица трижды:
`Styles.red` для цвета текста, `Styles.bgRed` для цвета за ним,
`Styles.underlineRed` для цвета подчёркивания. Все они константы, так что и
стиль можно держать в константе: `const error = Styles.red`.

Цепочка строится на них — `Styles.red.bold.bgYellow`, — а цвета, которых
таблица не называет, передаются значениями:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

final mine = Styles.underline
    .foreground(Color256.rgb(5, 2, 0)) // куб 6x6x6
    .background(ColorRgb(0x33, 0x66, 0x99)) // 24 бита
    .underlineColor(Color256.gray(12)) // один из 24 серых
    .underline;

print(mine('text').ansiShowEscapeSequences());
// [CSI 0 SGR][CSI 38;5;208 SGR][CSI 48;2;51;102;153 SGR][CSI 58;5;244 SGR]
// [CSI 4 SGR]text[CSI 0 SGR]
```

У каждой записи таблицы есть и собственное имя — `Color256.rgb520`,
`Color256.gray12`, `Color256.red`, — а `Color16` держит те шестнадцать,
которые терминал называет сам и которые пишутся короткой формой `CSI 31`.
Подчёркивание — единственное, что `Color16` не берёт: шестнадцатицветной формы
стандарт для него не даёт, поэтому `underlineColor` просит `ExtendedColor`.

Цвета стиль отдаёт под именем того гнезда, в котором они лежат, — как бы
стиль ни был собран:

```dart
print(mine.foregroundColor?.id); // fg256Rgb520
print(mine.backgroundColor?.id); // bgRgb(51,102,153)
print(mine.underlineColorValue?.id); // underline256Gray12

// То же от стиля, написанного константой, где ничего нельзя было позвать,
// чтобы задать гнездо.
print(const Style(foreground: Color16.red).foregroundColor?.id); // fgRed
```

Для этого и нужен `ColorTarget`. У цвета самого по себе гнезда нет, и он
говорит об этом знаком `?`; имя ему даёт как раз попадание в гнездо:

```dart
print(Color256.rgb(5, 2, 0).id); // ?256Rgb520
print(Style(background: Color256.rgb(5, 2, 0)).backgroundColor?.id);
// bg256Rgb520
```

Вызов стиля оборачивает строку. Там, где нужны обе половины по отдельности —
буфер, в который пишут кусками, стиль, живущий дольше одного вызова, — они
называются `open` и `close`:

```dart
final warning = Styles.red.bold;

print(warning.open.ansiShowEscapeSequences()); // [CSI 38;5;1 SGR][CSI 1 SGR]
print(warning.close.ansiShowEscapeSequences()); // [CSI 0 SGR]
print(warning('text').ansiShowEscapeSequences());
// [CSI 0 SGR][CSI 38;5;1 SGR][CSI 1 SGR]text[CSI 0 SGR]
```

`open` не начинается со сброса: он пишет разницу с собственными цветами
терминала и считает, что терминал в них и находится. Форма вызова пишет сброс
первым. `NoStyle` на оба отвечает пустой строкой, так что коду, держащему
стиль, проверка на него не нужна.

### Printer

Escape-коды не позволяют задать для текста значения по умолчанию. Цвет текста
и цвет фона зависят от реализации вашего терминала. И если нужны другие
значения, `resetFg` (CSI FOREGROUND_DEFAULT SGR) и `resetBg` (CSI
BACKGROUND_DEFAULT SGR) не годятся: каждый раз придётся подставлять свои:

```dart
const text =
    '$bg256Rgb113$fg256Rgb442 Default text '
    '$bgWhite$fgBlack Highlighted text '
    '$bg256Rgb113$fg256Rgb442 Default text again $reset';
print(text);
```

Установку цвета можно вынести в константы и пользоваться ими везде:

```dart
const defaultStyle = '$bg256Rgb113$fg256Rgb442';
const text = '$defaultStyle Default text '
    '$bgWhite$fgBlack Highlighted text '
    '$defaultStyle Default text again $reset';
print(text);
```

А можно взять `Printer`:

```dart
const text = ' Default text '
    '$bgWhite$fgBlack Highlighted text $reset'
    ' Default text again';
final printer = Printer(
  defaultStyle: const Style(
    background: Color256.rgb113,
    foreground: Color256.rgb442,
  ),
);
printer.print(text);
```

Принтер сам подставит нужные значения там, где состояние возвращается к
умолчанию. Тексты останутся чистыми, а значения по умолчанию можно в любой
момент поменять или убрать вовсе.

Вдобавок Dart позволяет спрятать использование принтера под капот с помощью
зон:

```dart
void main() {
  runZonedPrinter(
    defaultStyle: const Style(
    background: Color256.rgb113,
    foreground: Color256.rgb442,
    ),
    () {
      // … Код вашего приложения …

      const text = ' Default text '
          '$bgWhite$fgBlack Highlighted text $reset'
          ' Default text again';

      print(text); // Обычный print
    },
  );
}
```

Все вызовы `print` будут перехвачены и изменены так, чтобы использовать нужные
вам значения.

Если коды нужны для отладки Flutter-приложений, вы заметите, что при отладке
под iOS в консоль приходят сообщения с экранированными escape-кодами. Это
известная проблема, на сегодня (02.2025) не решённая:
https://github.com/flutter/flutter/issues/20663. Обойти её нельзя, но можно
уменьшить ущерб двумя способами.

Первый — метод `log` из 'dart:developer'. Он выводит escape-коды на iOS
правильно:

```dart
import 'dart:developer';

…

runZonedPrinter(
  defaultStyle: const Style(
    background: Color16.green,
    foreground: Color16.yellow,
  ),
  output: log,
  () {
    const text = ' Default text '
        '$bgWhite$fgBlack Highlighted text $resetBg$resetFg'
        ' Default text again $reset';
    print(text);
  },
);
```

К сожалению, длинные сообщения (больше 128 символов) `log` выводит как
`<collected>`. А с escape-кодами превысить этот размер легко: в примере выше
`text` в него не влезает, если использовать RGB-цвета.

И во-вторых, `log` работает только из IDE. Тестировщики, которые IDE не
пользуются, не увидят в консоли ничего.

Так что в большинстве случаев на iOS остаётся по большей части отключить
escape-коды:

```dart
runZonedPrinter(
  defaultStyle: …,
  ansiCodesEnabled: !Platform.isIOS,
  () {
    const text = ' Default text '
        '$bgWhite$fgBlack Highlighted text $reset'
        ' Default text again';
    print(text);
  },
);
```

### StackedPrinter

Escape-коды позволяют просто оформить текст. Но чуть более сложное оформление
требует куда больших усилий. Один пример уже был выше — когда нужен стиль по
умолчанию, отличный от терминального.

Представьте, что у вас есть шаблон текста, в который вы вставляете другой
текст, пришедший извне. А приславший решил его выделить:

```dart
String makeMessage(String name) {
  const template = 'Dear {name}! We are pleased to present to you …';

  return template.replaceAll('{name}', name);
}

…

const name = '${bold}Sam$resetBoldAndDim';

…

final text = makeMessage(name);
print(text);
// Dear [bold]Sam[resetBoldAndDim]! We are pleased to present to you …
```

А потом дизайнер, ничего не подозревая, вносит изменения в шаблон:

```dart
const template = '${bold}Dear {name}, welcome to us!$resetBoldAndDim We are pleased to present to you …';

…

final text = makeMessage(name);
print(text);
// [bold]Dear [bold]Sam[resetBoldAndDim], welcome to us![resetBoldAndDim] We are pleased to present to you …
```

Но escape-коды не накапливаются: двойной `bold` равен одинарному. И первый же
`resetBoldAndDim` отменяет жирность. И получается совсем не то, что хотелось.
Чтобы это исправить, нужно возвращать состояние текста после вставки к тому,
каким оно было до неё. А это сильно усложняет работу с escape-кодами. Решить
задачу помогает `StackedPrinter`:

```dart
final printer = StackedPrinter();
printer.print(text);
// [reset][bold]Dear Sam, welcome to us![reset] We are pleased to present to you …
```

`StackedPrinter` накапливает изменения состояния и снимает их по очереди,
переводя текущее состояние в стандартную escape-последовательность на выводе:

```dart
const text = '$bold 1 $bold 2 $bold 3 $resetBoldAndDim 2 $resetBoldAndDim 1 $resetBoldAndDim';
final printer1 = Printer();
final printer2 = StackedPrinter();
printer1.print(text); // '[reset][bold] 1  2  3 [reset] 2  1 '
printer2.print(text); // '[reset][bold] 1  2  3  2  1 [reset]'
```

### Печать в sink

`Printer` и `StackedPrinter` отдают вывод функции печати. `SinkPrinter` и
`StackedSinkPrinter` вместо этого пишут в `StringSink` — `StringBuffer`, файл,
`stdout` — и держат стиль между записями:

```dart
final buf = StringBuffer();
SinkPrinter(buf, defaultStyle: Styles.bgGray3)
  ..write('one ')
  ..write('${fgRed}two$reset');

print(Parser(buf.toString()).showControlFunctions());
// [reset][bg256Gray3]one [reset][reset][bg256Gray3][fgRed]two[reset]
```

Оба берут тот же `defaultStyle`, что и остальные, и оба берут
`ansiCodesEnabled`. Со значением `false` текст пишется вообще без
escape-кодов — включая те, которые он нёс сам:

```dart
final plain = StringBuffer();
SinkPrinter(plain, ansiCodesEnabled: false).write('${fgRed}two$reset');
print(plain); // two
```

Это выключатель для вывода, который не является терминалом. `NoStyle` — вещь
другая: он не даёт принтеру навязывать тексту свой стиль, но коды, которые
текст несёт сам, проходят насквозь.

### Стиль по умолчанию для всего вывода

Задать цвета по умолчанию для всего терминала нельзя. Зато Dart позволяет
перехватывать вызовы `print` и подменять в них стиль по умолчанию.

Пример (если вы пользуетесь стилями):

```dart
import 'package:ansi_escape_codes/style.dart';

void main() {
  final greenStyle = Styles.green.bold;
  final highlighedStyle = Styles.red.bgYellow.underline;

  runZonedPrinter(
    defaultStyle: Styles.gray12,
    () {
      print(
        'Normal text'
        ' ${greenStyle('Green ${highlighedStyle('Highlighted text')} text')}'
        ' Normal text',
      );
    },
  );
}
```

Если вы пользуетесь [готовыми значениями](#максимальная-производительность),
`runZonedPrinter` тоже подойдёт. Но тогда все функции `reset...` будут
возвращать к `defaultStyle`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  runZonedPrinter(
    defaultStyle: const Style(
      foreground: Color256.gray12,
    ),
    () {
      print(
        'Normal text'
        ' ${fgGreen}Green text ${fgRed}Highlighted text$resetFg Not a green text$resetFg'
        ' Normal text',
      );
    },
  );
}
```

Если нужны вложенные стили, берите `runZonedStackedPrinter`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  runZonedStackedPrinter(
    defaultStyle: const Style(
      foreground: Color256.gray12,
    ),
    () {
      print(
        'Normal text'
        ' ${fgGreen}Green text ${fgRed}Highlighted text$resetFg Green text$resetFg'
        ' Normal text',
      );
    },
  );
}
```

> [!NOTE]
>
> Два способа записать цвет можно использовать рядом, и
> `ansi_escape_codes.dart` приносит оба: `bold` — строка escape-кодов,
> `Styles.bold` — стиль. См. [имена, которые приносит
> пакет](#имена-которые-приносит-пакет).

### Логирование

Ни к какому пакету логирования привязываться не нужно: запись — это строка, и
константы — строки, так что раскрасить имя уровня можно и без посторонней
помощи. Помощь нужна в двух местах, где escape-коды кусаются.

Первое — ширина. `String.length` считает и escape-коды, поэтому выравнивание
раскрашенного имени уровня выйдет не на ту ширину. `Parser` считает те же
кодовые единицы UTF-16, но без кодов: `𝄞` по-прежнему две, как и везде в
Dart, а вставка никогда не попадает внутрь суррогатной пары:

```dart
const level = '${fgRed}SEVERE$reset';
print(level.length); // 15
print(Parser(level).length); // 6
print('[${level.padRight(10)}]'); // [SEVERE] — коды съели выравнивание
print('[${Parser(level).padRight(10)}]'); // [SEVERE    ]
print('[${Parser(level).padLeft(10)}]'); // [    SEVERE]
```

Заполнитель длиннее одного символа перебирает ширину — ровно так же, как
перебирает её `String.padRight`: он пишется по разу на каждый недостающий
символ, а не по разу на каждое место, которое он занимает.

Второе — приёмник. Терминал коды читает, а лог-файл хранит их байтами,
которые никто не прочтёт, — поэтому одна и та же строка уходит дважды и в
двух видах:

```dart
void write(String line) {
  stdout.writeln(line);
  logFile.writeAsStringSync('${line.ansiRemoveEscapeCodes()}\n',
      mode: FileMode.append);
}
```

А сообщение, пришедшее уже оформленным со стороны, — это тот самый случай,
ради которого написан [StackedPrinter](#stackedprinter): что бы сообщение ни
открыло, в конце оно будет закрыто, и следующая строка начнётся в том стиле,
в каком должна.


## Чтение

Строка, которая уже несёт escape-коды, — это работа для `Parser`: что в ней
написано без кодов, какой она длины без них, какой стиль действует в любой её
точке и что означает каждая её последовательность.

### Parser

`Parser` позволяет разбирать текст с escape-кодами. Парсеров два, и всё
сказанное ниже верно для обоих: `Parser` держит стиль, действующий в каждой
точке, `StackedParser` — историю того, как до него дошли, так что `resetFg`
возвращает к цвету, бывшему до последнего, а не к собственному цвету
терминала. Разница между ними — та же, что между
[Printer и StackedPrinter](#stackedprinter), и состояние он отдаёт `Stack`, а
не `Style`.

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

const text = '$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ';
final parser = Parser(text);
parser.pieces.forEach(print);
// Piece<Style>(start: 0, end: 4, entity: Sgr(bold), state: Style(bold))
// Piece<Style>(start: 4, end: 10, entity: Text(' Bold '), state: Style(bold))
// Piece<Style>(start: 10, end: 15, entity: Sgr(fgCyan), state: Style(bold, foreground: Color16.cyan))
// Piece<Style>(start: 15, end: 26, entity: Text(' Bold+cyan '), state: Style(bold, foreground: Color16.cyan))
// Piece<Style>(start: 26, end: 31, entity: Sgr(resetBoldAndDim), state: Style(foreground: Color16.cyan))
// Piece<Style>(start: 31, end: 37, entity: Text(' Cyan '), state: Style(foreground: Color16.cyan))
```

Так можно, например, убрать все escape-коды:

```dart
final parser = Parser('$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ');
final buf = StringBuffer();
for (final m in parser.pieces) {
  switch (m.entity) {
    case Text(:final string):
      buf.write(string);
    case EscapeCode():
      break;
  }
}
print(buf); // ' Bold  Bold+cyan  Cyan '
```

Для этого есть готовый метод:

```dart
print(parser.removeAll());
```

Или заменить escape-коды на читаемую форму:

```dart
final parser = Parser('$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ');
final buf = StringBuffer();
for (final m in parser.pieces) {
  final result = switch (m.entity) {
    EscapeCode(:final id) => '[$id]',
    Text(:final string) => string,
  };
  buf.write(result);
}
print(buf); // [bold] Bold [fgCyan] Bold+cyan [resetBoldAndDim] Cyan
```

И для этого есть готовые методы:

```dart
print(parser.replaceAll((e) => '[${e.id}]'));
print(parser.showControlFunctions());
```

Длину чистого текста без escape-кодов даёт `length`:

```dart
print(parser.length == parser.removeAll().length); // true
print(parser.length); // 23
```

Стиль в конкретной позиции находится через `stateAt`:

```dart
final parser = Parser('$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ');
final atSeven = parser.stateAt(7);
print(atSeven); // Style(bold, foreground: Color16.cyan)
print(atSeven.isBold); // true
print(atSeven.isItalic); // false
print(atSeven.foregroundColor?.id); // fgCyan
print(atSeven.backgroundColor?.id); // null
```

Позиция в `stateAt` задаётся в координатах чистого текста
(`pos` < `parser.length`) и может указывать на место за текстом
(`pos` == `parser.length`) — чтобы узнать конечное состояние. Конечное
состояние отдаёт и `finalState`:

```dart
print(parser.stateAt(23) == parser.finalState); // true
print(parser.finalState); // Style(foreground: Color16.cyan)
```

Гиперссылка — состояние, но не стиль, поэтому в ответе `stateAt` её нет:
`linkAt` и `finalLink` — та же пара вопросов на отдельной колее. См.
[гиперссылки](#гиперссылки).

Чтение происходит настолько поздно, насколько возможно. `stateAt` читает
строку до спрошенной позиции и там останавливается, а прочитанное сохраняет,
так что следующий вопрос продолжает с того места, где кончился предыдущий, а
не начинает заново:

```dart
final parser = Parser('$bold one $fgCyan two $resetBoldAndDim three ');
parser.stateAt(2); // читает до третьего символа
parser.finalState; // читает дальше с этого места, а не с начала
```

Парсер держит и своё место, и прочитанное, так что вопросы о позиции за
позицией — а именно это делает вёрстка текста — стоят одного прохода по
строке на всех, а не по проходу на каждый. Идти назад можно, но проход
начинается заново.

`prepare` читает строку целиком за раз и строит чистый текст, с которым
работают `length`, `indexOf`, `contains` и остальные строковые методы:

```dart
final parser = Parser(text)..prepare();
```

Ради них он и нужен. `stateAt`, `linkAt` и `substring` от него не выигрывают,
а проигрывают там, где вопросы до конца строки не дойдут. Оба случая меряет
`benchmark/`.

В примере выше состояние текста не возвращалось к умолчанию, то есть текст не
был закрыт:

```dart
const text = '$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ';
final parser = Parser(text);
print(parser.isClosed); // false
```

Проще всего закрыть текст, добавив в конец `reset`:

```dart
const closedText = '$text$reset';
print(Parser(closedText).isClosed); // true
```

Метод `substring` достаёт кусок текста, попутно вычисляя его состояние:

```dart
final parser = Parser('$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ');
final substr = parser.substring(7, maxLength: 9); // "Bold+cyan"
print(Parser(substr).showControlFunctions()); // [fgCyan;bold]Bold+cyan[reset]
```

По умолчанию срез закрыт. Escape-коды всегда попадают в строку в
оптимизированном виде:

```dart
final parser = Parser('$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ');
final substr = parser.substring(7, maxLength: 9); // "Bold+cyan"
const test1 = '$fgCyan$bold';
final test2 = substr.substring(0, substr.indexOf('Bold'));
print(test1.ansiShowEscapeSequences()); // [CSI 36 SGR][CSI 1 SGR]
print(test2.ansiShowEscapeSequences()); // [CSI 36;1 SGR]
print(Parser(test1).showControlFunctions()); // [fgCyan][bold]
print(Parser(test2).showControlFunctions()); // [fgCyan;bold]
print(test1.length); // 9
print(test2.length); // 7
```

Чтобы оптимизировать строку целиком, есть метод `optimize`:

```dart
const text = '$fgWhite$bold$resetBoldAndDim$fgGreen$underline'
    "$resetUnderline$dim$dim What's in here? $resetBoldAndDim$resetFg";
print(text.length); // 63
final parser = Parser(text);
print(parser.showControlFunctions());
// [fgWhite][bold][resetBoldAndDim][fgGreen][underline][resetUnderline][dim][dim] What's in here? [resetBoldAndDim][resetFg]

final optimizedText = parser.optimize();
print(optimizedText.length); // 28
print(Parser(optimizedText).showControlFunctions());
// [fgGreen;dim] What's in here? [reset]
```

Методы `insertBefore` и `insertAfter` вставляют текст в строку, не трогая
того, что в ней уже есть. Вставленный текст принимает стиль того места, куда
попал, а коды, которые он нёс сам, закрываются за ним, так что остальная
строка сохраняет прежний вид:

```dart
const text = '${fgRed}Hello world$reset';
final inserted = Parser(text).insertBefore(6, '${fgGreen}brave ');
print(Parser(inserted).showControlFunctions());
// [fgRed]Hello [fgGreen]brave [fgRed]world[reset]
```

Если сам вставляемый текст кончается внутри escape-последовательности, которую
парсер не смог закончить, перед исходным хвостом последовательность получает
терминатор. Это вторая сторона описанного ниже правила незавершённого входа:
то правило не пускает вставку внутрь последовательности исходника, а это —
исходный хвост внутрь последовательности вставки.

Позиция считается в строке без escape-кодов, как и везде в `Parser`. Эти два
метода расходятся только тогда, когда ровно в этой позиции стоят escape-коды:
один встаёт перед ними, другой за ними:

```dart
const text = '${fgRed}Hello$reset world';
print(Parser(text).insertBefore(5, '!').ansiShowControlFunctions());
// [fgRed]Hello![reset] world
print(Parser(text).insertAfter(5, '!').ansiShowControlFunctions());
// [fgRed]Hello[reset]! world
```

Ни одна из вставок не попадает внутрь последовательности, которую парсер не смог
закончить, — управляющей строки без терминатора, будь то `OSC`, `DCS`, `SOS`,
`PM` или `APC`; голого `ESC`; `CSI` без финального байта; `ESC`, оставшегося на
промежуточном байте. Всё написанное среди её байтов читается как её часть,
поэтому текст встаёт перед последовательностью, а хвост копируется как пришёл:

```dart
print(Parser('aa\x1B]0;title').insertAfter(2, 'X')); // 'aaX\x1B]0;title'
```

Когда таких кодов стоит несколько подряд, текст встаёт перед всей чередой:
промежуток между двумя незавершёнными кодами — не шов, а нутро первого.
Законченный код завершает череду и проходится вместе с тем, что стоит перед
ним, — то есть череда, перед которой встаёт текст, это та, что достаёт до
текста, а не всё незавершённое в строке:

```dart
print(Parser('aa\x1B]0;title\x1B(B').insertAfter(2, 'X'));
// 'aa\x1B]0;title\x1B(BX'
```

Последние байты такой последовательности парсер отдаёт текстом, хотя терминал
читает их как её часть. Параметры `CSI` без финального байта — случай, который
стоит назвать, но и любой байт, из которого не построить последовательности, —
`LF`, `DEL`, буква вне ASCII, — обрывает шаблон точно так же и оставляет
стоящий перед ним код ждать своего окончания. У позиции среди этих байтов
верного ответа нет — перед последовательностью это раньше символов, которые
для вызывающего идут до неё, а на запрошенном месте это внутри
последовательности, — поэтому обе вставки её отклоняют:

```dart
Parser('aa\x1B[31').insertAfter(3, 'X'); // бросает UnfinishedSequenceException
```

Сам шов отклоняется, когда он и есть одна из таких позиций: череда,
начинающаяся за таким куском текста, начинается среди байтов, которые
последовательность перед этим текстом всё ещё дочитывает, — и место перед
чередой это там, где был бы написан её финальный байт. Законченный код между
текстом и чередой даёт череде собственный шов, и он обслуживается как прежде.

Исключение несёт запрошенную позицию и смещение, с которого начинается
последовательность, частью которой текст был бы прочитан. Позиция вне плоского
текста — по-прежнему `RangeError`, как и везде.

Для строки, которую разбирают один раз, есть расширения `ansiInsertBefore` и
`ansiInsertAfter` — как и остальные сокращения ниже.

### Быстрый анализ

Строку можно быстро разобрать и без `Parser` — расширениями. Они работают
регулярным выражением, тогда как `Parser` строит сущность на каждый
встреченный код, и разница между ними видна там, где нужен всего один ответ:
вопрос `ansiHas` останавливается на первом же коде, который на него отвечает,
а строку вовсе без кодов отсекает `contains(ESC)` — парсер просматривает её
так же быстро, но ему ещё строить список кусков, а расширению строить нечего.
Там же, где строку всё равно проходить целиком, парсер не дороже: на странице
цветного лога `ansiRemoveEscapeCodes` стоит чуть больше, чем
`Parser.removeAll`, а разбор, однажды сделанный, ответит и на всё остальное.

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

…

const text = '${fgRed}ERROR$reset';
print(text.ansiHasEscapeCodes); // true
print(text.ansiHasCsi); // true
print(text.ansiHasSgr); // true
print(text.ansiHasForeground); // true
print(text.ansiHasBackground); // false
print(text.ansiShowEscapeSequences()); // [CSI 31 SGR]ERROR[CSI 0 SGR]
```

Метод `ansiShowControlCodes` показывает в строке все управляющие коды —
набор C0, `DEL` и восьмибитные C1:

```dart
const text = 'Tab: \t Line feed: \n Carriage return: \r Bell: \x07';

print(text.ansiShowControlCodes()); // preferStyle: ControlCodeStyle.escapeOrCharCode
// Tab: \t Line feed: \n Carriage return: \r Bell: \x07

print(text.ansiShowControlCodes(preferStyle: ControlCodeStyle.charCode));
// Tab: \x09 Line feed: \x0A Carriage return: \x0D Bell: \x07


print(text.ansiShowControlCodes(preferStyle: ControlCodeStyle.abbr));
// Tab: [HT] Line feed: [LF] Carriage return: [CR] Bell: [BEL]

print(text.ansiShowControlCodes(preferStyle: ControlCodeStyle.escapeOrAbbr));
// Tab: \t Line feed: \n Carriage return: \r Bell: [BEL]

print(text.ansiShowControlCodes(preferStyle: ControlCodeStyle.unicode));
// Tab: ␉ Line feed: ␊ Carriage return: ␍ Bell: ␇

print(text.ansiShowControlCodes(preferStyle: ControlCodeStyle.escapeOrUnicode));
// Tab: \t Line feed: \n Carriage return: \r Bell: ␇
```

Восьмибитные формы управляющих C1 — байты с `0x80` по `0x9F` — показываются
тоже, числом байта и одинаково во всех стилях: ни аббревиатуры, ни картинки
Unicode у них нет:

```dart
print('a\u{9B}b'.ansiShowControlCodes()); // a\x9Bb
print('a\u{9B}b'.ansiShowControlCodes(preferStyle: ControlCodeStyle.abbr)); // a\x9Bb
print('a\u{9B}b'.ansiHasControlCodes); // true
print('a\u{9B}b'.ansiRemoveControlCodes()); // ab
```

Они управляющие по категории самого Unicode, и терминал, которому такой байт
достался, печатает мусор, а не символ, — поэтому строка, очищенная для показа,
не очищена, пока они в ней стоят. `0xA0` и выше управляющими не являются и не
трогаются.

Но то, что они управляющие, не делает их здесь escape-кодами, и пакет их так
не читает: `Parser` видит в `0x9B` текст, а не `CSI`, и
`ansiRemoveEscapeCodes` оставляет его на месте. Это решение, а не упущение.
Разбираются здесь декодированные Dart-строки, а не байтовые потоки, и
настоящий восьмибитный C1 не переживает UTF-8-декодирования — целым он
доезжает только из потока, декодированного как latin1, где вызывающий и сам
знает, что держит восьмибитные байты. Терминалы по умолчанию пишут семибитную
форму `ESC [`, так что чтение `0x9B` как `CSI` ломало бы честный текст чаще,
чем помогало.

Быстро убрать коды можно этими методами:

```dart
const text =
    '$saveCursor$cursorRight$italic$bgGreen$fgYellow Text $resetFg$resetBg$resetItalic$restoreCursor';
print(Parser(text).showControlFunctions());
// [saveCursor][CSI CUF][italic][bgGreen][fgYellow] Text [resetFg][resetBg][resetItalic][restoreCursor]

final withoutBackground = text.ansiRemoveBackground();
print(Parser(withoutBackground).showControlFunctions());
// [saveCursor][CSI CUF][italic][fgYellow] Text [resetFg][resetItalic][restoreCursor]

final andWithoutForeground = withoutBackground.ansiRemoveForeground();
print(Parser(andWithoutForeground).showControlFunctions());
// [saveCursor][CSI CUF][italic] Text [resetItalic][restoreCursor]

final andWithoutSgr = andWithoutForeground.ansiRemoveSgr();
print(Parser(andWithoutSgr).showControlFunctions());
// [saveCursor][CSI CUF] Text [restoreCursor]

final andWithoutCsi = andWithoutSgr.ansiRemoveCsi();
print(Parser(andWithoutCsi).showControlFunctions());
// [saveCursor] Text [restoreCursor]

final withoutAllEscapeCodes = text.ansiRemoveEscapeCodes();
print(withoutAllEscapeCodes.ansiShowEscapeSequences());
// ' Text '
```

Остальные расширения, одним духом: `ansiHasUnderlineColor` и
`ansiRemoveUnderlineColor` делают для цвета подчёркивания то же, что пары выше
делают для цвета текста и фона; `ansiHasControlCodes` и
`ansiRemoveControlCodes` спрашивают и убирают управляющие коды — байты C0,
`DEL` и восьмибитные C1, — а не escape-коды; `ESC` как раз один из этих
байтов, поэтому сначала уберите escape-коды, иначе их тела останутся текстом,
а те, что нужно сохранить, назовите через `exclude: {ControlFunctionsC0.LF}`,
который называет членов C0 и потому восьмибитный C1 пощадить не может;
`lengthWithoutEscapeCodes` —
это `Parser.length` для строки, читаемой один раз; `ansiShowControlFunctions` и
`ansiOptimizeControlFunctions` — это `Parser.showControlFunctions` и
`Parser.optimize` для строки, читаемой один раз.

### Типы последовательностей

Последовательности, несущие что-то стоящее чтения, говорят это сами, так что
`switch` по `pieces` может спросить и про саму последовательность, и про то,
что она держит, одним шаблоном:

```dart
final text = '${cursorUpN(4)}$erasePage Hello $hideCursor';

for (final m in Parser(text).pieces) {
  switch (m.entity) {
    case CursorUp(:final n):
      print('the cursor goes up $n lines');
    case EraseInPage(:final part):
      print('the page is erased: $part');
    case HideCursor():
      print('the cursor is hidden');
    case Text(:final string):
      print('the text says "$string"');
    default:
  }
}
// the cursor goes up 4 lines
// the page is erased: ErasePart.all
// the text says " Hello "
// the cursor is hidden
```

`CursorUp`, `CursorDown`, `CursorRight`, `CursorLeft`, `CursorNextLine`,
`CursorPrevLine`, `CursorHPos`, `ScrollUp` и `ScrollDown` несут `n` — на
сколько мест сдвинуться, — и это `1`, когда последовательность его не задаёт.
`CursorPos` и `CursorHVPos` несут `row` и `col`. `EraseInPage` и
`EraseInLine` несут `ErasePart` — `toEnd`, `toBegin` или `all`. `ShowCursor`,
`HideCursor`, `UseAlternateScreen` и `UseMainScreen` стоят за четыре приватных
режима, которые пакет пишет сам.

Все, кроме последних четырёх, наследуют `CsiCommon`, поэтому `is CsiCommon`,
`controlSequence` и идентификаторы, под которыми они показываются, остались
прежними; четыре приватных режима стоят рядом с `CsiPrivate` — так же, как
`SaveCursor` стоит рядом с остальными ESC-последовательностями, — и
показываются по имени константы, которой они пишутся.

Последовательность, несущая не то, что обещает её тип, — два параметра там,
где берётся один, или часть, которой у `ErasePart` нет имени, вроде
xterm'овского `CSI 3 J`, — сохраняет свои параметры и остаётся обычным
`CsiCommon`, а не получает выдуманные значения.

Каждая распознанная последовательность хранит свои параметры такими, какими
они были написаны, в `params`: `CsiParamNumber`, где параметр — число,
`CsiParamDefault`, где он опущен, и `CsiParamNumbers`, где за ним через
двоеточие идут подпараметры. Форма с двоеточием читается так, как её понимает
стандарт: `CSI 4:3 m` — это подчёркивание, а `CSI 38:2::51:102:153 m` — цвет
RGB; а то, что подпараметры говорят сверх этого — например, что подчёркивание
волнистое, а не прямое, — лежит в `params`, а не в стиле:

```dart
const text = '\x1B[4:3m wavy \x1B[;5H\x1B[38:2::51:102:153m';

for (final m in Parser(text).pieces) {
  if (m.entity case Sgr(:final params, :final id) ||
      CsiCommon(:final params, :final id)) {
    print('$id  $params');
  }
}
// underline  [4:3]
// CSI ;5 CUP  [, 5]
// fgRgb(51,102,153)  [38:2:0:51:102:153]
```

### Неизвестные последовательности

На том, чего парсер назвать не может, он никогда не бросает исключение. Всё
нераспознанное возвращается отдельной сущностью с сохранёнными исходными
байтами: `CsiUnknown`, `EscUnknown`, `OscUnknown` и `UnknownEscapeCode` — для
того, что здесь не имеет смысла, `Dcs`, `Sos`, `Pm` и `Apc` — для управляющих
строк, которые пакет носит, не читая, и `CsiPrivate` — для последовательностей
приватного применения, смысл которых стандарт оставляет терминалу. Все они
несут миксин `UnrecognizedEscapeCode`, так что хватает одной проверки:

```dart
const text = 'a\x1B[!pb\x1B[?7hc';
for (final m in Parser(text).pieces) {
  if (m.entity case final UnrecognizedEscapeCode e) {
    print('${m.start}..${m.end}: ${e.id}');
  }
}
// 1..5: CSI !p
// 6..11: CSI ?7 SM
```

`start` и `end` — позиции в исходной строке, так что жалоба может показать на
те самые байты, о которых она.

Чтобы поставить на их место что-то другое, `replaceAll` проходит строку один
раз и записывает обратно всё, что вернули:

```dart
print(Parser(text).replaceAll((e) => e is UnrecognizedEscapeCode ? '?' : e.string));
// a?b?c
```


## Гиперссылки

Кликабельным текст делает `OSC 8`, а `link` пишет его целиком — открытие,
показываемый текст и закрытие:

```dart
print(link('https://dart.dev').ansiShowControlFunctions());
// [link(https://dart.dev)]https://dart.dev[linkClose]
print(link('https://dart.dev', text: 'the site').ansiShowControlFunctions());
// [link(https://dart.dev)]the site[linkClose]
```

У частей есть и собственные имена — для ссылки, собранной константой:
`${linkOpen}$url$linkTextOpen$text$linkClose`. А `linkBel` пишет старую форму,
которая кончается `BEL` там, где другая кончается `ST`. Терминалы принимают
обе.

Управляющий байт в адресе пишется своим percent-escape. `ESC` в теле `OSC 8`
закрывает последовательность на месте, и то, что задумывалось остатком
адреса, дошло бы до терминала собственными кодами. Адрес, в котором таких
байтов нет — а это всякий настоящий адрес, — выходит байт в байт, вместе со
своими percent-escape. Части выше кладут url в последовательность без
проверки, поэтому для адреса из неподконтрольного источника нужен `link`, а не
константы. Показываемый текст пишется как пришёл, со стилями и всем прочим.

Ссылка — это состояние, как и стиль: всё написанное после открытия находится
внутри неё до закрытия. Ссылки не вкладываются — открытие вытесняет
предыдущее, а одно закрытие завершает то, что было открыто, — поэтому парсер
держит их на колее рядом со стилем, а не внутри него, и отвечает про них
отдельно:

```dart
final parser = Parser('see ${link('https://dart.dev', text: 'the site')} now');
print(parser.linkAt(4)?.url); // https://dart.dev
print(parser.linkAt(0)); // null
print(parser.finalLink); // null
```

`linkAt` принимает позицию текста без escape-кодов, как и `stateAt`, и
отвечает той ссылкой, внутри которой стоит символ в этом месте. Оба читают из
одного прохода, поэтому спросить каждого из них про череду позиций стоит
одного прохода по строке на всех. `finalLink` — это то, что строка оставила
открытым; здесь `null`, потому что текст закрыл то, что открыл. А если
обходить куски самому, каждый `Piece` несёт свою `link` рядом со `state`.

`isClosed` — вопрос про один только стиль: строка, кончающаяся в том же
состоянии, в каком началась, но оставившая гиперссылку открытой, ответит
`true`. Поэтому рядом с ним и спрашивают `finalLink`.

Срез сохраняет текст кликабельным. Тот, что начинается внутри ссылки, открывает
её заново перед первым своим куском текста и закрывает в конце, так что
вырезанная из документа строка стоит сама по себе:

```dart
final parser = Parser('see ${link('https://dart.dev', text: 'the site')} now');
print(Parser(parser.substring(4, maxLength: 3)).showControlFunctions());
// [link(https://dart.dev)]the[linkClose]
```

Открытие пишется заново теми же байтами, какими было написано в первый раз:
ссылка, открытая с `BEL`, снова открывается с `BEL`, и `id=` — то, что `OSC 8`
даёт ссылке, разорванной переносом строки, — путешествует вместе с ней.
Закрытие всегда то, что кончается на `ST`, и терминалы принимают его после
любого открытия:

```dart
final parser = Parser('see ${linkBel('https://dart.dev', text: 'the site')} now');
print(parser.substring(4, maxLength: 3).ansiShowEscapeSequences());
// [OSC 8;;https://dart.dev BEL]the[OSC 8;; ST]
```

`substring(close: false)` оставляет ссылку открытой — так же, как оставляет
открытым стиль, — а `optimize` закрывает оставленную строкой ссылку тем же
способом, что и `substring`.

Принтеры переносят ссылку со строки на строку. Строка закрывает то, что
оставила открытым (напечатанное после неё не должно оставаться кликабельным на
тот же URL), а следующая открывает заново, так что ссылка, внутрь которой
попал перенос строки, остаётся одной ссылкой:

```dart
final lines = <String>[];
Printer(output: lines.add)
    .print('${linkOpen}https://dart.dev${linkTextOpen}first\nsecond$linkClose');
for (final line in lines) {
  print(Parser(line).showControlFunctions());
}
// [reset][link(https://dart.dev)]first[linkClose]
// [reset][link(https://dart.dev)]second[linkClose]
```

`SinkPrinter` и `StackedSinkPrinter` принимают по записи за раз, а строка тут
может состоять из нескольких: ссылка, открытая одной записью, остаётся
открытой в следующих, и закрытие приходится туда, где строка действительно
кончается, — на `writeln` или на `'\n'` внутри написанного. Вставка отдаёт
ссылку так же: то, что идёт после `insertBefore` или `insertAfter`,
по-прежнему указывает туда же, куда указывало, что бы вставленный текст ни
открыл своего.

`example/links.dart` показывает настоящему терминалу ссылку, разорванную на
три строки, — напечатанную и нарезанную, — чтобы по ней можно было кликнуть, а
не только прочитать про это.


## Утилиты

Две вещи, которые терминал скажет и примет только лично; обе — в `utils.dart`.

`tabs` задаёт позиции табуляции. Прежние позиции всегда сначала сбрасываются,
так что вызов без аргументов оставляет терминал вовсе без них — те, с которыми
он начинал, не возвращаются:

```dart
tabs(defaultTab: 4); // позиция каждые 4 колонки, на всю ширину терминала
tabs(tabs: [8, 4, 4]); // позиции на 8, 12 и 16
```

Когда `stdout` не терминал, не пишется ничего: позиции задавать некому, а
ширины, в которую их укладывать, нет.

`currentCursorPos` спрашивает у терминала, где курсор: наружу `CSI 6 n`,
обратно через stdin `CSI n ; m R`:

```dart
final (row, col) = await currentCursorPos(stdout, stdin);
```

По умолчанию терминалу даётся 100 миллисекунд на ответ; терминал, который не
отвечает вовсе, получает `UnsupportedError`. Stdin можно слушать только один
раз, поэтому чтобы спросить дважды — или чтобы читать ввод и дальше — передайте
в `input` broadcast-поток над ним.
