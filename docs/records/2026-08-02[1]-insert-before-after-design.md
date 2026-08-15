# insertBefore / insertAfter — design

> **Состояние на 2026-08-16:** доведён и влит — код в `86d4a9d`, дизайн
> `insertBefore` / `insertAfter` действует до сих пор. Дефект, о котором
> предупреждала прежняя шапка (вставка в самый конец строки, кончающейся
> незавершённой последовательностью, уходила внутрь неё), закрыт волной
> 2026-08-11, мерж `00fe2ca`; в `docs/backlog.md` этого пункта больше
> нет. `TODO.md` в прозе — нынешний `docs/backlog.md`.
> **Что это:** дизайн вставки текста до и после позиции: вставленное
> принимает стиль места и не портит текст после него.
> **Связанные записи:**
> `2026-08-11[2]-insert-unfinished-sequence-design.md`,
> `2026-08-11[3]-insert-unfinished-sequence-plan.md`.

ansi_escape_codes, 2026-08-02. Written before the code, shipped in `86d4a9d`.
It closed the first item of TODO.md:

> insertAfter, insertBefore. Суть в том, чтобы сохранить состояние текста после
> вставки. Вставляемый текст принимает свойства того места, в которое
> вставляется, но не портит текст после него.

## Surface

Two methods on `_ParserBase<S>`, next to `substring`, so both `Parser` and
`StackedParser` get them:

```dart
String insertBefore(int pos, String text)
String insertAfter(int pos, String text)
```

Two shortcuts on `String` in `StringParsingExtension`, following
`ansiShowControlFunctions` and `ansiOptimizeControlFunctions`, including the
note that each call parses the string anew:

```dart
String ansiInsertBefore(int pos, String text)
String ansiInsertAfter(int pos, String text)
```

## Semantics

`pos` is a position in the string **without** escape codes, as in `stateAt` and
`substring`. Out of range throws `RangeError`, as `stateAt` does.

Both methods put `text` at the same plain-text position. They differ in which
side of the escape codes standing on that seam it lands:

```dart
const s = '${fgRed}Hello${reset} world';   // plain text: 'Hello world'

s.ansiInsertBefore(5, '!')  // '${fgRed}Hello!${reset} world' — '!' is red
s.ansiInsertAfter(5, '!')   // '${fgRed}Hello${reset}! world' — '!' is plain
```

A seam holds every escape code between the plain character at `pos - 1` and the
one at `pos`. `insertBefore` goes in front of all of them, `insertAfter` behind
all of them.

## Inheriting the style

Nothing is written to open the inserted text. Standing on the seam it is
already under the surrounding style — that is what "принимает свойства того
места" means, and it costs no bytes.

## Keeping the tail intact

The inserted text is parsed with `Matches._(text, ambient)`, where `ambient` is
the state on the seam — the state before the seam's codes for `insertBefore`,
after them for `insertAfter`. If the result's `finalState` differs from
`ambient`, `finalState.transitTo(ambient)` is appended after the insertion.

When the inserted text carries no escape codes nothing is appended: the result
is byte-for-byte a plain concatenation. The same rule covers a `reset` in the
middle of the inserted text and the stack of `StackedParser`.

No `close` flag, unlike `substring`: closing is not an option here, it is the
whole of "не портит текст после него". No `insertAt` either — the two names
already cover both sides of the seam.

## Tests

- a plain insertion, no codes on either side;
- an insertion carrying codes — the tail keeps its own style;
- a seam with a code on it — `insertBefore` and `insertAfter` differ;
- `pos` = 0 and `pos` = length;
- `pos` out of range — `RangeError`;
- a `reset` inside the inserted text;
- the same through `StackedParser`;
- the `String` shortcuts.
