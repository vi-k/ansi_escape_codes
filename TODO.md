# TODO

## Deepseek

- Предложение: Создать "лайтовую" версию API для 80% случаев использования: (???)

  ```dart
  import 'package:ansi_escape_codes/easy.dart';

  void main() {
    print(green('Успех!'));  // Просто и понятно
    print(red.bold('Ошибка!'));
    print(rgb(255, 128, 0)('Оранжевый'));
  }
  ```

  ```dart
  final style = Style()
    .foreground('#FF8000')
    .bold()
    .italic();

  final errorStyle = Style(parent: style)
    .background('red');

  print(style('Важное сообщение'));
  print(errorStyle('Ошибка!'));
  ```

- Предложение: Добавить колбэки для обработки ошибок: (???)

  ```dart
  final parser = AnsiParser(
    text,
    onError: (error, position) {
      log('Странная escape-последовательность на позиции $position');
      return '?'; // Что вставить вместо нее
    },
  );
  ```

- Интеграция с популярными логгерами: Многие проекты используют пакеты для
  логирования (например, logging). (???)

- Расширение возможностей AnsiParser для не-SGR кодов:

  Текущая ситуация: Парсер отлично работает с SGR (стили), но для других CSI
  последовательностей (например, $cursorUp) он создает общий тип CsiCommon.

  Предложение: Добавить больше конкретных типов сущностей, например CursorUp
  (наследник EscapeCode). Это позволит пользователям писать более точные
  и типобезопасные паттерны при обработке:

  ```dart
  for (final match in parser.matches) {
    if (match.entity is CursorUp) {
      // сделать что-то специфичное для курсора вверх
    }
  }
  ```

## Tests

- tests for stacked parser and printer.
- тестирую 38:2:..., но не тестирую 38;2;...

## Wish list

- insertAfter, insertBefore
  Суть в том, чтобы сохранить состояние текста после вставки. Вставляемый текст
  принимает свойства того места, в которое вставляется, но не портит текст
  после него.
- enum for cursorUp/etc
- independent functions

## Doc

- doc for AnsiParser, AnsiPrinter

## Etc

- Switch to the terminal's secondary context	CSI ? 1049 h
- Switch back to the terminal's primary context	CSI ? 1049 l
- CSI ? 47 h save screen?
- CSI ? 47 l restore screen?
