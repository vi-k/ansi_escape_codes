# TODO

- tests for stacked parser and printer.
- тестирую 38:2:..., но не тестирую 38;2;...

- insertAfter, insertBefore
  Суть в том, чтобы сохранить состояние текста после вставки. Вставляемый текст
  принимает свойства того места, в которое вставляется, но не портит текст
  после него.
- enum for cursorUp/etc
- independent functions

- Подумать: расширение возможностей Parser для не-SGR кодов:

  Текущая ситуация: Парсер работает с SGR, но для других CSI
  последовательностей (например, $cursorUp) создает общий тип CsiCommon.

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

- Подумать: добавить колбэки для обработки ошибок:

  ```dart
  final parser = AnsiParser(
    text,
    onError: (error, position) {
      log('Странная escape-последовательность на позиции $position');
      return '?'; // Что вставить вместо нее
    },
  );
  ```

- Подумать: интеграция с популярными логгерами: Многие проекты используют
  пакеты для логирования (например, logging).

## Etc

- Switch to the terminal's secondary context	CSI ? 1049 h
- Switch back to the terminal's primary context	CSI ? 1049 l
- CSI ? 47 h save screen?
- CSI ? 47 l restore screen?
