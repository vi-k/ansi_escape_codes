# TODO

- tests.

- строка может быть закрытой или не закрытой
- insertAfter, insertBefore - вставка текста в другой
- в substring можно искать "концы" и автоматически закрывать/не закрывать
  вопросы:
    "[italic] a [italic] b [notItalic]"
    "[bgBlue] a [bgBlue] b [bfDefault]"
  после "a" закрывать?
  наверное, стоит исходить из того, что склеенные обратно подстроки должны
  давать ту же картинку, что и целая строка. хотя и тут есть варианты:
  1:
    1) "[italic] a"
    2) "[italic] "
    3) "[italic] b [notItalic]"
  2:
    1) "[italic] a[notItalic]"
    2) "[italic] [notItalic]"
    3) "[italic] b [notItalic]"
  в общем, можно исходить не из того, что надо, а из того, что можно закрыть,
  ничего не потеряв. открытым оставляем только там, где это действительно
  требуется:
    "[italic] a ":
    1) "[italic] a"
    2) "[italic] "

- bold и faint, как оказалось, могут быть вместе, но отключаются одним
- CSI s / CSI u - save cursor/restore cursor
- CSI 32 ; 1 m - Green + bold - узнать про это подробней

<!--
Switch to the terminal's secondary context	\x1b[?1049h
Switch back to the terminal's primary context	\x1b[?1049l -->
