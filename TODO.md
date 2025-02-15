# TODO

## Tests

- tests for stacked parser and printer.
- тестирую 38:2:..., но не тестирую 38;2;...

## Etc

- добавить insert
  Суть в том, чтобы сохранить состояние текста после вставки. Вставляемый текст
  принимает свойства того места, в которое вставляется, но не портит текст
  после него.

- в substring можно искать "концы" и автоматически закрывать/не закрывать.
  но есть вопросы:
    "[italicized] a [italicized] b [resetItalicized]"
    "[bgBlue] a [bgBlue] b [bfDefault]"
  после "a" закрывать?
  наверное, стоит исходить из того, что склеенные обратно подстроки должны
  давать ту же картинку, что и целая строка. хотя и тут есть варианты:
  1:
    1) "[italicized] a"
    2) "[italicized] "
    3) "[italicized] b [resetItalicized]"
  2:
    1) "[italicized] a[resetItalicized]"
    2) "[italicized] [resetItalicized]"
    3) "[italicized] b [resetItalicized]"
  в общем, можно исходить не из того, что надо, а из того, что можно закрыть,
  ничего не потеряв. открытым оставляем только там, где это действительно
  требуется:
    "[italicized] a ":
    1) "[italicized] a"
    2) "[italicized] "

- Switch to the terminal's secondary context	CSI ? 1049 h
- Switch back to the terminal's primary context	CSI ? 1049 l
- CSI ? 47 h save screen?
- CSI ? 47 l restore screen?

- enum for cursorUp/etc
