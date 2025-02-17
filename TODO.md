# TODO

## Tests

- tests for stacked parser and printer.
- тестирую 38:2:..., но не тестирую 38;2;...

## Etc

- добавить insertAfter, insertBefore
  Суть в том, чтобы сохранить состояние текста после вставки. Вставляемый текст
  принимает свойства того места, в которое вставляется, но не портит текст
  после него.

- Switch to the terminal's secondary context	CSI ? 1049 h
- Switch back to the terminal's primary context	CSI ? 1049 l
- CSI ? 47 h save screen?
- CSI ? 47 l restore screen?

- enum for cursorUp/etc

- doc for AnsiParser, AnsiPrinter
