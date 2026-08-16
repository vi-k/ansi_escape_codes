## 4.0.0

Added:

- `State`, `Style`, `Stack` and `Styles` now model the standard primary and
  nine alternative fonts, fraktur, curly/dotted/dashed underline,
  proportional spacing and five ideogram renditions. Existing enum case
  names and style APIs remain source-compatible.
- `insertBefore` and `insertAfter` on `Parser` and `StackedParser`, with the
  `ansiInsertBefore` and `ansiInsertAfter` string extensions. Text put into a
  styled string takes the style of the place it lands in and gives it back, so
  the rest of the string is left as it was: the style it opened of its own is
  closed after it, and the hyperlink it landed inside — links do not nest, and
  the inserted text may have superseded it with one of its own — is opened
  again behind it. Text inserted outside every link is closed off instead, so
  what follows it stays outside whatever the insertion pointed at.
- The hyperlink a string has open, read back the way the style is: `linkAt` and
  `finalLink` on `Parser` and `StackedParser`, and `link` on `Match`, beside
  its `state`, for a walk over the matches. A link is state but not style — it
  carries no rendition, and `SGR 0` does not close it — so it travels on a
  channel of its own and is answered on its own: `linkAt(pos)` for the link the
  character at `pos` sits inside, `finalLink` for what the string leaves open.
- The independent control functions, ESC Fs: constants for all ten of them,
  `ControlFunctionsEscFs`, `EscCommon` — the entity a `switch` over them
  matches — and `resetTerminal` for RIS.
- `DEL`, which the C0 set was missing.
- `useAlternateScreen` and `useMainScreen`, the screen a full-screen program
  draws on.
- Types for the control sequences that carry something worth reading:
  `CursorUp`, `CursorDown`, `CursorRight`, `CursorLeft`, `CursorNextLine`,
  `CursorPrevLine`, `CursorHPos`, `ScrollUp` and `ScrollDown` carry `n`;
  `CursorPos` and `CursorHVPos` carry `row` and `col`; `EraseInPage` and
  `EraseInLine` carry an `ErasePart`; `ShowCursor`, `HideCursor`,
  `UseAlternateScreen` and `UseMainScreen` stand for the four private modes
  this package writes itself.
- `ControlString`, what the five strings of the standard have in common, with
  `Dcs`, `Sos`, `Pm` and `Apc` beside the `Osc` that was there already, and
  `terminated` to ask whether one of them got the terminator that ends it.
  `Osc` is a `ControlString` now rather than a direct child of `EscapeCode`,
  which leaves a `switch` matching it by name as it was, and the four new
  entities carry `UnrecognizedEscapeCode` like the other codes this package
  keeps without reading.
- `ansiHasUnderlineColor` and `ansiRemoveUnderlineColor`: the extensions knew
  the foreground and the background but not the underline colour.
- `ansiRemoveControlCodes`, the other half of `ansiHasControlCodes`: the C0
  set, `DEL` and the eight-bit C1 taken out, with `exclude` for the ones to
  keep — a text that is to stay in lines keeps its `LF`. `ESC` is one of them,
  so the escape codes come out first or their bodies are left behind as text.
  `exclude` names members of `ControlFunctionsC0` and so cannot spare an
  eight-bit C1: this package gives those no names, on the reasoning below.
- `Colors implements Comparable`, so a list of them can be sorted.
- `ansiShowControlFunctions` and `ansiOptimizeControlFunctions`, which used to
  live in the tests though the README and the examples took them for public.
- The control function types the API returns — `ControlFunctionsSGR`,
  `ControlSequencesFunctions` and the rest — are exported from the main entry
  point.
- `ansi_escape_codes.dart` brings the `String` extensions as well, so it is
  one import for all the string work: the ready-to-use strings, the styles,
  the parser, the state, the control function tables and the extensions. Two
  things stand outside it. `ansi.dart` always did — the ready-to-use strings
  are built from its raw byte tables, and neither import brings the other. And
  `utils.dart` does, because `tabs` and `currentCursorPos` talk to a terminal
  in person through `dart:io`, and nothing else in the package touches a
  platform library: bringing them in through the umbrella would tag the whole
  package native-only for the sake of two names, and take the web and
  WebAssembly away from the thousand that run anywhere. A test walks the
  directives of each entry point and holds that line. `extensions.dart` and
  `style.dart` still bring their smaller namespaces, which is what they are
  for — not for reaching something the main import lacks.

Verification:

- Entry-point signature closure is now backed by an exact exported-namespace
  snapshot, and neither is asked anything until `lib/` has been swept for
  analysis errors and warnings: a library that fails to analyse still has an
  element model, only a smaller one. The generator preflights its eight
  registered marker zones before writing any generated file.
- Stable CI gates 95.0% hand-written `lib/` coverage while retaining the full
  coverage artifact, and runs a separate warmed complexity guard. The ordinary
  complexity assertions in `test/performance_guards_test.dart` remain
  deterministic and timer-free.
- The complexity guard times the single implementation each scenario side has,
  checks the work that implementation produced both before and after the timing
  series, and holds the band against the median of the paired ratios rather
  than against a ratio of separately sorted medians.

Performance:

- The scanner finds the next escape code by `indexOf` rather than by the
  regex engine: text with no escape codes at all is parsed and stripped well
  over a hundred times faster (about 1 ms down to under 9 µs), a coloured
  page parses roughly 45-50 % faster across `matches`, `removeAll`,
  `optimize` and `showControlFunctions`, and a page that is mostly escape
  codes is not worse — about a fifth faster rather than a wash.
  `ansiHasEscapeCodes` and friends answer a clean string with
  `contains(ESC)` outright, without touching a pattern, and
  `lengthWithoutEscapeCodes` counts without building the cleaned string —
  the same walk over the same matches, so what is saved is the copy and not
  the time: a 5 MB page is measured with megabytes less at the peak — some
  8 to some 20, depending on the page — and takes about as long as it
  did.
- `substring` and the insert seams keep their place the way `stateAt`
  always did, instead of walking from the start each time: slicing a
  200-line document through one parser is about three times faster (3.95 ms
  down to 1.33 ms), and the shape of the cost is linear now, not quadratic
  — the guard that doubles the input and watches the time saw a cost of ×3.73
  where it now sees ×1.65, a linear cost being ×2.
- An escape code is told apart by its second byte instead of four named
  regex groups, a simple SGR function comes from a cached table instead of
  being rebuilt, and the matched text is read out of the match once: a
  simpler, more correct hot path, though its own saving lands inside the
  numbers above rather than as one of its own — isolated, it measures at
  noise level once the scanner and slicing fixes are in. One visible side
  effect: two `SgrSimpleFunction`s built for the same code used to be two
  separate objects, and were never `==` to each other either, since the
  class defines neither `==` nor `hashCode`; now they are the same cached
  instance, so both `identical()` and `==` see them as one and the same.
- A full parse retains the match list once, not twice, and a `Text` piece
  cuts its own substring out of the input only the first time something
  reads it, so a piece nobody reads keeps no copy of its own — `stateAt`,
  which never asks a piece for its `string`, is the concrete beneficiary:
  a walk that never reads a piece's string leaves tens of megabytes on the
  table against one that reads every piece, on the benchmark's 5000-line
  page. A scenario that forces everything to materialize up front, the way
  `prepare` does, is unaffected — full materialization was never what this
  bought. The saving is not free of a cost, though: a `Text` kept alive
  past its `Parser` pins the whole original input in memory for as long as
  the `Text` itself lives, whether or not its `string` is ever read.
- What has been read of a string is kept, instead of being read again by
  every question asked of it. Call `prepare` when there are many.
- A control sequence is looked up in a map rather than by walking the list.
- A `Stack` keeps its histories as frames with a shared tail rather than as
  lists. Immutable lists had to be copied to be grown — twice, once to build
  the new one and once to seal it — so a push cost the whole depth so far, and
  a parse, which keeps every state it passed, kept every one of those copies
  with it. Text that switches attributes without resetting them, which is what
  `ls --color` and most syntax highlighters write, made that quadratic in time
  and in memory both: 320 kB of it took 15 s and 7.6 GB through
  `StackedParser`, where `Parser` took 51 ms and nothing above the floor. The
  same string now takes 55 ms, level with `Parser`, and 2.5 MB of that shape
  takes 299 ms. A push and a pop are one small allocation each, and every
  version of a stack shares the whole of its own tail with the versions it
  came from. Nothing a `Stack` answers has moved: its histories were only ever
  asked what was on top and whether they were empty.

- `flush` on all four printers: it writes out whatever is being held back
  without ending the line. `Printer` and `StackedPrinter` hold a line until a
  `writeln` ends it, and until now nothing could make them let go of one --- a
  `write` with no `writeln` behind it was lost for good. `SinkPrinter` and
  `StackedSinkPrinter` hold the tail of a write that stopped in the middle of a
  sequence, and this says that the write which would have finished it is not
  coming.

Fixed:

- `ansiHasSgr` and `ansiRemoveSgr` disagreed with the parser about the same
  sequences: `'\x1B[1<m'.ansiHasSgr` was false while the parser read it as a
  rendition, and `ansiRemoveSgr` left behind what `ansiRemoveEscapeCodes` took
  out. They read `sgrPattern`, whose parameter class excluded `<`, `=`, `>`
  and `?` everywhere rather than only in the first place, where alone they
  make a sequence private use. The pattern now says what the parser says.
- `ansiShowEscapeSequences` wrote a dangling separator where a control string
  had no terminator to name: `\x1B]0;title` showed as `[OSC 0;title ]`. The
  separator goes with the name now, so it shows as `[OSC 0;title]` and a
  terminated one is unchanged.
- `Parser.substring` refused a `maxLength` too large to add to `start`. Asking
  for everything from anywhere but the beginning --- `substring(1, maxLength:
  <a very large number>)` --- took the sum round through the negatives and came
  back a `RangeError` for a slice that was only asking for the rest of the
  string. A length reaching past the end is the rest of it, and stays so where
  no sum can hold it.
- An `SGR` carrying a private byte past the first --- `CSI 1 < m`, `CSI 99 ; < m`
  --- was written to the terminal twice. Only the first byte of a parameter
  string makes a sequence private use, so these are ordinary `CSI ... m` whose
  parameters cannot be read: the parser puts them in the opaque rendition
  branch and the branch writes them again, while the output also copied their
  bytes over as they came. Two places were answering "is this a rendition?"
  --- the parser where it reads the sequence, and a pattern whose parameter
  class knew nothing of a private byte past the first --- and the answers could
  differ. Only the parser answers it now.
- A write to `SinkPrinter` or `StackedSinkPrinter` that stopped in the middle
  of a sequence corrupted it. Every write is dressed on its own and the
  dressing opens with a reset, so that reset landed between the halves and the
  terminal read it followed by the rest of the sequence as text: `\x1B[31m`
  cut anywhere inside it showed `[31m` and no colour, a hyperlink cut inside
  its url showed the url, and a surrogate pair cut between its halves came out
  as two replacement characters. A write is now cut where no sequence is open
  across it and what is left waits for the write that finishes it, so the same
  bytes read the same however the writes fall across them. An unterminated
  control string is part of this: it now waits for the write that goes on with
  it, where before it went out at once and was ended by the next write's
  reset --- which made `write('a' + title)` then `write('b')` show a `b` that
  the same bytes written in one go make part of the title.
- `ESC 8` with no `ESC 7` in front of it left a non-default `defaultStyle`
  behind. DECRC without DECSC clears the rendition, taking the terminal to its
  own defaults rather than to the printer's, and the printer went on believing
  its default style was still on --- so the transition for the text after it
  wrote nothing and that text came out bare. The printer's own `Parser` read
  its own output as saying so. The model now goes where the terminal goes and
  writes the default style back on.
- `ESC 7` / `ESC 8` lost their saved rendition, hyperlink and opaque SGR at
  every printer line or sink-write boundary, and a restore with no preceding
  save incorrectly used the previous chunk's seeded state. All four printers
  now keep one non-consuming, replaceable cursor save slot for their session;
  sink `prepare` rolls a probed slot back with its other carry.
- `Style.call` read its inner ANSI through `Stack`, so a selective reset after
  two setters revealed the earlier inner value instead of returning to the
  caller's default style. Style wrappers now use the same terminal reset
  semantics as `Printer`; the explicitly selected `Stack` and `Stacked*` APIs
  keep their hierarchical pop contract.
- `optimize`, `substring`, insertions and all printers silently discarded an
  ordinary SGR function that `State` did not model, and collapsed decorated
  underline to a single line. Known standard functions now have typed state;
  truly unknown SGR is carried by a private ordered residual channel through
  cuts, branches and printer resets until a real `SGR 0` clears it.
- `ESC 7` and `ESC 8` carried no style. A terminal saves the rendition along
  with the cursor and restores both, so `${fgRed}ESC7${fgBlue}ESC8` shows red
  where the parser said blue — and every question asked after it was answered
  from the wrong state. The hyperlink travels in that same bundle: a terminal
  keeps it among the attributes it saves, so what a restore brings back is
  clickable again exactly where the save was, and a save made where no link was
  open puts that away as readily — the restore leaves no link behind it, rather
  than the one the string was started inside.
- An insertion left a hyperlink open. `OscLink` carries no style, and the closing
  was worked out from the style alone, so text inserted with an unclosed
  `OSC 8` swallowed everything after it.
- An unfinished escape sequence in the inserted text swallowed the original
  tail: a truncated `OSC` consumed it whole, while a truncated `CSI` took its
  first byte as the missing final byte. Insertions now preserve the same text
  model as `optimize`, `substring` and the printers, without rewriting
  completed escape codes.
- `cursorDown` moved the cursor left, and the cursor functions built sequences
  out of any number, `-1` included.
- `runZonedStackedPrinter` printed only the first line.
- `currentCursorPos` left the terminal in raw mode, read the answer as one
  chunk it does not always arrive in, and took the first CSI that came for the
  report — an arrow key is a CSI as well, so a key pressed while the terminal
  answered threw away a report that had in fact arrived. The report is looked
  for in what comes now, rather than assumed to be at the front of it.
- `tabs` looped forever on a tab width that never advances, and wrote over the
  line it was called on.
- `Stack` threw where a reset had no style to pop, and took a colour it cannot
  hold in `underlineColor`.
- `faint` stood for `bold` instead of `dim`.
- An ESC sequence was cut after two characters, and one carrying intermediate
  bytes was shown without them: `ESC ( B` and `ESC ) B` came out alike. A
  bare `ESC` at the end of a string was swallowed as text — shown as nothing
  and counted in the length — and is a code of its own now: it shows as
  `[ESC]`, and `Parser('abc\x1B').length` says 3 where it said 4.
- `optimize` and `substring` dropped every code that was not SGR, and they,
  with `isClosed`, ignored the state the parser started from.
- The printers dropped them as well: `prepare('${cursorUp}x')` gave back
  `[CSI 0 SGR]x`, the cursor movement gone, and a hyperlink came out as the
  bare text it was written over. What is not a style passes through them
  untouched now.
- An empty sub-parameter threw the whole sequence away, an RGB colour cancelled
  the rest of it, a broken colour took the rest with it, and `CSI 4:0 m`
  switched the underline on.
- An OSC string ended at the wrong place, or nowhere; a URL carrying `;` was
  refused.
- `ESC P`, `ESC X`, `ESC ^` and `ESC _` — `DCS`, `SOS`, `PM` and `APC` — were
  read as finished two-character escape sequences, so the body the standard
  gives each of them came back as text. Each of the four opens a control string
  that runs to its `ST`, the way an `OSC` does, and one that never got a
  terminator ends at the next `ESC` or at the end of the text. What such a
  string carries — a sixel image, a `DECRQSS` answer, a termcap reply — is part
  of the escape code now rather than of the plain text, and is no longer
  counted in the length: `Parser('a\x1BPq#0;2;0;0;0\x1B\\b').length` says 2
  where it said 13, and neither a slice nor an insertion cuts through the body,
  an unfinished code ending the string included. `ST` ends all five; the `BEL`
  that ends an `OSC` is xterm's and not the standard's, and it ends none of the
  other four, so a `DCS` whose body happens to end in one is unterminated still
  — and one left unterminated is held back and given its terminator the way an
  unterminated `OSC` is.
- `SaveCursor`, `RestoreCursor` and `OscLink` carried a `reset` as their text, so
  all three were equal to one another — an `Entity` compares by what it is
  written with — and none of them equalled the same entity read back by the
  parser.
- `ansiHasForeground`, `ansiRemoveForeground` and their background pair only
  saw a colour that was the whole parameter list. `CSI 1;31 SGR`, which is the
  shape this package's own `optimize` writes, matched nothing, and neither did
  the colon form `CSI 38:5:196 SGR` the parser has always read. Removal now
  keeps the functions standing beside the colour: `CSI 1;31 SGR` becomes
  `CSI 1 SGR` rather than going whole.
- A colour held by a `Stack` named itself `?256Red`, where the same colour from
  a `Parser` said `fg256Red`. A `Style` written as a constant said the same,
  and a colour set on one target and then held in another slot answered under
  the target rather than the slot — `bg256Red` for the colour of the text. The
  slot names it now, whichever way the style was built.
- `NoStyle` passed for the colours of the terminal.
- A private-use sequence was reported as an unknown one.
- `Color256.rgb` and `Color256.gray` checked their arguments in an assert only,
  which release builds leave out.
- The superscript and subscript pair picked its winner the other way round from
  every other pair.
- `DEL` counted as a control code but was never shown as one.
- Entities and functions described themselves wrongly in `toString`.
- On Windows the terminal modes were put back in an order the console
  refuses — echo first, line mode still off — so `currentCursorPos` threw
  and left the terminal raw. Line mode now comes back first, and each mode
  is restored even when the other throws. Turning them off is guarded the
  same way now: when a stdin refuses one change, the one already made is
  undone instead of being left behind.
- `substring` cut a hyperlink in two and kept neither half right: a slice that
  began inside one came out unclickable, the opening having been left behind on
  the other side of the cut, and a slice that ended inside one left it open, so
  everything printed after the slice was clickable on the slice's URL. A slice
  is self-contained now, the way it always was in the style: one that began
  inside a link opens that link again in front of its first piece of text, and
  `close: true` closes at the end what the slice has open. With `close: false`
  the link is left open, as the style is. Cutting a document into lines this
  way gives lines that are each clickable on their own.

  The opening is written again in the bytes it came in, parameters and all: a
  link opened `BEL`-terminated stays `BEL`-terminated, and an `id=` — which is
  what `OSC 8` gives for a link a line break cuts in two — travels with it. The
  close written is `OSC 8;; ST` whatever form the opening took; terminals take
  either.
- Once a link passed through them at all, the printers had the gap the slice
  had: a printed line that opened a hyperlink left it open, and everything
  printed after was part of it. A line now closes the link it leaves open, and
  the line after opens it again — in the bytes it was opened with, as the slice
  does it — so a link a line break falls inside of goes on being one link,
  which is what the `id=` of `OSC 8` is for. `SinkPrinter` and
  `StackedSinkPrinter` take a write at a time and one line may be composed of
  several, so there an open link is carried across the writes and closed where
  the line really ends — at a `writeln`, or at a `'\n'` in what is written. A
  styled call goes through a printer and changed with them: `Styles.red('…')`
  now closes a link its text left open, and in a multi-line string the link
  reaches the end of the text instead of ending with the first line of it.
- `optimize` left a hyperlink open where `substring` closed one. With
  `close: true` it now ends the string outside every link as well as in the
  default style: a string that opened a link and never closed it comes back
  closed, so that what is printed after it is not clickable. With
  `close: false` both are left as the string leaves them.
- Copying a control string out of the string it was read from could swallow the
  text behind it. One that never got its terminator — an `OSC`, a `DCS`, an
  `SOS`, a `PM` or an `APC`, a hyperlink opening no less than a window title or
  anything else the terminal answers to — runs on to the next `ESC` or to the
  end of the text, which is how the parser reads it on purpose, and written
  again in front of text that had not followed it there, by a slice, by
  `optimize` or by a printed line, it read that text as part of the sequence
  and showed nothing. The terminator it lacks is supplied where text follows
  it. That is of the codes copied over as they stand: there an escape code
  following leaves the bytes exactly as they came, the `ESC` of what stands
  behind being terminator enough. At the edge of an output that closes — a
  slice or an `optimize` with `close: true`, a printed line — the terminator is
  written although nothing follows it there, for the reason the hyperlink close
  is written in the same place: what is printed after must not be read as more
  of the sequence. With `close: false` the bytes are left as they came.
  `SinkPrinter` and `StackedSinkPrinter` pay the same debt where the line
  really ends — at a `writeln`, or at a `'\n'` in what is written — and owe
  nothing at the end of a `write` the line goes on past.
  An opening written again for a slice or a line that began inside the link
  carries its terminator whatever follows it.
- The insertions reached the same mechanism last. `insertAfter` goes past the
  codes standing at the seam, and where the string ended inside a sequence
  that never finished it went past those bytes as well —
  `Parser('aa\x1B]0;title').insertAfter(2, 'X')` handed back a string whose
  plain text was still `aa`, the `X` having become part of the window title,
  and a hyperlink opening swallowed it no differently. A bare `ESC` turned the
  insertion into an `SOS` and a `CSI` with no final byte into an `ECH`. Both
  insertions now stand in front of such a sequence rather than inside it, and
  the tail is copied on as it came: no byte of the input is invented, which is
  why no terminator is supplied here as it is for a slice. A finished code
  ends the run and is passed along with what stands before it — the run stood
  in front of is the one reaching the text, not everything unfinished in the
  string.

  A sequence still waiting for the byte that ends it hands the bytes it waits
  through back as text — the parameters of a truncated `CSI` are the case
  worth naming, but a `LF`, a `DEL` or a letter outside ASCII breaks off the
  pattern of a bare `ESC` and of an `ESC` on an intermediate byte the same
  way — and a position among them has no right answer: in front of the
  sequence is before characters counted in front of it, and where it was
  asked for is inside the sequence. Both insertions refuse it with an
  `UnfinishedSequenceException`, which carries the position asked for and the
  offset of the sequence the text would have been read as part of. Before
  this the same position quietly ate what stood there:
  `Parser('aa\x1B[31').insertAfter(3, 'X')` answered a string whose plain
  text was `aa1`, the `3` having become a parameter. `insertBefore` was no
  better, though the backlog had it down as safe everywhere.

  Unfinished codes come in runs, and the seam is in front of a whole run
  rather than in a gap between two of them — a gap between two of them is the
  inside of the first. `Parser('aa\x1BPpay\x1B[31').insertAfter(2, 'X')`
  answers `'aaX\x1BPpay\x1B[31'`, where before it answered
  `'aa\x1BPpayX\x1B[31'`, whose plain text was `aa31`: the `X` had gone into
  the body of the `DCS`.

  Where such a run begins behind a piece of text a sequence in front of it is
  still reading, the place before the run is where that sequence's ending
  would be written, so the seam has no end to serve and is refused along with
  everything past it. This takes back answers that used to come:
  `Parser('aa\x1B[31\x1BPpay\x1B').insertAfter(4, 'X')` throws where it
  answered `'aa\x1B[31\x1BPpayX\x1B'` — plain text `aa31`, the `X` swallowed
  by the body of the `DCS`. A code that stands finished between the text and
  the run gives the run a seam of its own, and that one is served.
- `insertBefore` and `insertAfter` could put text between the halves of a
  surrogate pair and hand back a string that is no longer valid UTF-16. A
  position inside a pair now shifts to its edge — `insertBefore` to the
  front, `insertAfter` past it. Positions, `length` and the paddings are
  UTF-16 code units, as `String` counts them, and the docs now say so
  instead of promising what is seen.
- `ansiHasSgr` and `ansiRemoveSgr` counted private control sequences
  ending in `m` — xterm's modifyOtherKeys, SGR mouse reports — as SGR,
  and removing styles removed them too. The pattern now takes digits,
  `;` and `:` only, the way the parser classifies them.
- `ansiRemoveForeground` and its background and underline siblings ate
  the parameters after a colour cut short: `\x1B[38;2;1;2m` lost its
  bold and dim along with the broken colour. A colour missing arguments
  now gives up only its introducer and kind, the way the parser reads
  it — and the same goes for a kind the package does not know. It reads
  the other direction too: the parameter after a bare `38`, `48` or
  `58` is that colour's kind and goes with it, so `\x1B[38;41m` loses
  its `41` and `\x1B[38;4:3m` its curly underline where both used to be
  left standing. The `ansiHas*` answers moved together with the split —
  `\x1B[38;41m` no longer has a background.
- Leading zeroes hid a colour from the same functions: removing the
  colour from `\x1B[38;05;196m` removed everything but it. Parameters
  are now read as numbers, as ECMA-48 allows them to be written.
- A style operation with nothing to change built a new object anyway,
  and a `NoStyle` asked for a pointless reset came back a `Style` that
  writes: `NoStyle().resetItalic('x')` opened with a reset. Nothing to
  change now answers itself, as `State` promised all along.
- `NoStyle().transitTo(Style.terminalColors)` wrote a reset between two
  surfaces that are both the terminal's own. A transition between equal
  surfaces is empty.
- A `Printer` given `defaultStyle: NoStyle()` still opened every line
  with a reset and unwound it at the end. It now imposes nothing: the
  line goes out as it came, its own codes included —
  `ansiCodesEnabled: false` remains the way to take those out.
- The `style` entry point returned types it could not name:
  `ControlFunctionsSGR` and its four control-function siblings were
  reachable from the entities but undefined to the importer. The five
  exports are now part of the point, and every entry point carries an
  exports test. The `extensions` point had the same gap:
  `ansiRemoveControlCodes` takes a `Set<ControlFunctionsC0>` its own
  importer could not name, so the enum is now part of the point.
- `prepare` on `SinkPrinter` and `StackedSinkPrinter` coloured the writes that
  came after it. The piece it is asked about never reaches the sink, and the
  link open in the output, the link open in the text and the terminator an
  unterminated control string owes were all put back for that reason — the
  style the piece ended in was not, so `prepare('${bold}asked')` left the
  printer reading the next `write` as if the bold had been sent. All four
  carries are put back now.
- The eight-bit forms of the C1 controls — the bytes `0x80` through `0x9F` —
  went through the control-code extensions unseen. `ansiHasControlCodes`
  answered `false` for a string made of them, `ansiRemoveControlCodes` left
  them where they stood and `ansiShowControlCodes` showed nothing, so a string
  cleaned or spelt out for display still carried bytes a terminal prints as
  rubbish. All three know them now, and the display writes them as the number
  of the byte in every style: they have neither an abbreviation nor a Unicode
  picture of their own, and this package gives them no names, since a name
  would suggest it reads them as sequences. It does not, and that has not
  changed: `Parser` reads `0x9B` as text rather than as a `CSI`, and
  `ansiRemoveEscapeCodes` leaves it standing. What is parsed here are decoded
  Dart strings rather than byte streams, where a genuine eight-bit C1 does not
  survive UTF-8 decoding and terminals emit the seven-bit `ESC [` form anyway.
  `0xA0` and above are not controls and are untouched.
- `substring(close: false)` took an attribute off that was meant to survive.
  A slice left open is written by asking `transitTo` for the reset half
  alone — it unwinds what the string took off by the cut and does not put on
  what belongs to the character after it. But `CSI 22` takes bold and dim off
  together, so `transitTo` writes it wherever one of the pair goes off and
  leans on the other half to bring the survivor back: `CSI 22;1`. That `1`
  belongs to the reset rather than being a set of its own, and going out
  without it left `\x1B[1;2mAB\x1B[22;1m` sliced open at `\x1B[22m` — a slice
  standing in neither its own state nor the string's. `skipSet` leaves it in
  place now. The four other pairs are unaffected: `24`, `25`, `54` and `75`
  are written only where the far end carries nothing at all, so a change from
  one kind to the other is a plain set and an open slice goes on leaving it
  out.
- `optimize`, `substring` and the printers swallowed the text behind a code
  the parser could not finish. All four held a code back only where it was an
  unterminated control string, while three other shapes wait for a byte just
  as surely — a bare `ESC`, a `CSI` with no final byte, an `ESC` left on an
  intermediate byte. In the string each of those was ended by the `ESC` of
  whatever stood behind it, and where that was an `SGR` these loops do not
  copy it but write it again as a transition — which, for a redundant `SGR`,
  writes nothing at all. The code then stood against the text and read it as
  its own: `Parser('\x1B[3\x1B[0m1m!').optimize()` gave `\x1B[31m!`, three
  characters of text turned into a colour, and a truncated `CSI` went on
  eating until it found a final byte. A redundant `SGR` is what `optimize`
  exists to remove, so the defect was the feature working. All four now hold
  back whatever the parser could not finish and supply an `ST` where what
  follows would otherwise be swallowed — an `ST` is an `ESC` and a `\`, so
  its `ESC` breaks off the waiting sequence exactly as the string's own did,
  and an `ST` that closes nothing does nothing. What `removeAll` calls the
  text is what comes out of all four; see `docs/records/2026-08-13[6]` for
  the invariant and for what it costs on a truncated `CSI`, where this
  package's reading of the input and a terminal's already differed.
- `link` and `linkBel` wrote the address into the body of an `OSC 8`
  unchecked. An `ESC` there ends the sequence where it stands, so a url
  carrying one handed the rest of itself to the terminal as codes of its own:
  `link('https://ok\x1B\\\x1B[2J…')` cleared the screen, and the parser read
  the result as seven entities where three were meant. Urls in a command-line
  tool arrive from git remotes, HTTP answers and registries, so the bytes are
  rarely the caller's. Both functions percent-escape what an `OSC 8` cannot
  carry — the C0 controls and `DEL` — and nothing else: an address that
  carries none, which is every address that is one, comes out byte for byte,
  its own percent-escapes untouched. `Uri.encodeFull`, which the `OSC 8` note
  asks for, escapes the `%` as well and would turn an already-encoded address
  into `%2520`. The eight-bit C1 are deliberately not escaped: one of them is
  a single code unit in a Dart string and two bytes in UTF-8, so a single-byte
  escape would name the wrong byte, and this package does not read them as
  control codes anyway. The `text` of a link is written as it came — styling
  it is what the codes are for — and where none is given the encoded address
  stands for it.

Renamed:

- `Match` is `Piece`, `Matches` is `Pieces`, and `parser.matches` is
  `parser.pieces`. The old name shadowed `dart:core.Match`, and shadowed it
  **silently**: an explicit import outranks the implicit one, so the compiler
  never asked which was meant. Ordinary code written beside this package —
  `for (final Match m in RegExp(r'\w+').allMatches(s))` — failed with two
  errors that named no package, and the advice this README gave for the
  Flutter names did not cover it, because the Flutter names do raise the
  question and this one did not. `Piece` is the word the package already used
  for the thing: the class dartdoc opened with "one piece of a parsed string",
  and `_pieceAt`, `nextPiece` and `takePiece` were there before the rename.
  There is deliberately no `typedef Match<S> = Piece<S>` to ease the move — it
  would reintroduce the shadowing this removes. A test holds the name open
  from the outside: it uses `dart:core.Match` beside a single import of this
  package, and stops compiling if the name is ever taken back.
- `rgb` and `gray` are `rgb256` and `gray256`. Both answer with an index into
  the 256-colour table --- the 6×6×6 cube and the 24-step grey ramp, taking
  0..5 and 0..23 --- and stood one name away from `fgRgb` and its pair, which
  take a truecolour triple of 0..255 and write it into the sequence itself.
  `fg256(rgb(255, 0, 0))` is the mistake the old names invited, and it throws
  rather than showing the wrong colour, but the new names say which of the two
  kinds of red is being asked for. They are also two very general words to
  have been taking out of a caller's namespace. `Color256.rgb` and
  `Color256.gray` keep their names: a named constructor says whose they are.
- The hyperlink entity is `OscLink`, not `Link`. `Link` shadowed `dart:io.Link`
  --- a symbolic link --- and shadowed it the silent way `Match` used to shadow
  `dart:core.Match`: an explicit import outranks the implicit one, so a
  command-line tool, which almost always imports `dart:io`, got two errors that
  named no package. The new name says which sequence it is, the way `EscCommon`
  and `CsiCommon` do. A test holds `dart:io.Link` open from the outside and
  stops compiling if the name is ever taken back.
- `RESERVED` to `RESERVED_5F`, named after its byte rather than claiming a word
  that plain in the namespace this package exports.
- `toStringAsEscapeSquences` to `toStringAsEscapeSequences`, which was missing
  a letter.
- The `standart_colors` directory is spelt `standard_colors`.

Removed — every name deprecated in an earlier release, and some that never were:

- The style constants renamed in 2.0.0: `faint`, `resetBoldAndFaint`,
  `italicized`, `resetItalicized`, `singlyUnderlined`, `doublyUnderlined`,
  `resetUnderlined`, `slowlyBlinking`, `rapidlyBlinking`, `resetBlinking`,
  `negative`, `resetNegative`, `concealed`, `resetConcealed`, `crossedOut`,
  `resetCrossedOut`, `framed`, `encircled`, `resetFramedAndEncircled`,
  `overlined`, `resetOverlined`, `superscripted`, `subscripted` and
  `resetSuperAndSubscripted`. Use `dim`, `italic`, `underline`, `blink`,
  `inverse`, `invisible`, `strikethrough`, `frame`, `encircle`, `overline`,
  `superscript`, `subscript` and their `reset…` counterparts.
- The string extensions without the `ansi` prefix: `hasEscapeCodes`, `hasCsi`,
  `hasSgr`, `hasForeground`, `hasBackground`, `removeEscapeCodes`,
  `removeCsi`, `removeSgr`, `removeForeground`, `removeBackground`,
  `showEscapeCodes` and `showControlCodes`. Use the `ansi…` names.
- The typedefs left behind by the renaming in 3.0.0: `AnsiParser`,
  `AnsiPrinter`, `SgrState`, `SgrPlainState` and `SgrStackedState`. Use
  `Parser`, `Printer`, `State`, `Style` and `Stack`.
- `Style.defaults` and `Stack.defaults`. Use `terminalColors`, or `NoStyle`
  where nothing at all should be written.
- `Parser.stateAtPos` and `runZonedAnsiPrinter`. Use `stateAt` and
  `runZonedPrinter`.
- `foregroundPattern` and `backgroundPattern`, the regular expressions that
  encoded the assumption a colour is the whole parameter list. Nothing else
  used them.
- `MatchingState`, `MatchesResult` and `ParserIterator`, which the parser
  passes to and gets back from its own private methods and nothing else could
  reach. `Matches` and `Match` are unchanged.
- `IntensityStyle` left the public API. It is the element a `Stack`'s
  intensity history holds; nothing public takes or returns it, and bold
  and dim — unlike the other pairs — can be on at once, so no getter
  could honestly answer with one of them.
- The `parsing` entry point. After 4.0.0 made it byte-identical to
  `style`, one of the two names had to go: import
  `package:ansi_escape_codes/style.dart` — the same 81 names — or the
  umbrella `ansi_escape_codes.dart`.

Breaking changes:

- `Stack.underlineColor` takes an `ExtendedColor` where it took a `Color`.
  `SGR 58` carries a 256-colour index or a truecolour triple and has no
  16-colour form at all, so a `Color16` was a colour the sequence could not
  be written with — `Style.underlineColor` had always taken the narrower
  type, and the two now agree. Narrowing a parameter is source-breaking:
  `stack.underlineColor(Color16.red)` no longer compiles, and
  `Color256.red`, whose index is the same colour, is what it becomes. The
  Fixed list below mentions the change as part of the bug it belongs to; it
  is named here because the compiler will name it first.
- `OscLink(url)` — `Link(url)` before the rename above — is no longer `const`.
  It percent-escapes a control byte in the address, as `link` does and for the
  same reason, and a `const` initializer admits neither a function call nor a
  `contains` — so the address could there be neither encoded nor so much as
  checked. A `const Link('…')` has to lose the keyword along with the name;
  nothing else about it moves. `OscLink.url` reads back the encoded
  address rather than the bytes handed in, so that it agrees with a parse of
  `OscLink.string` and with the equality an `Entity` takes from those bytes.
- The named control sequences print as themselves: `CursorUp(4)`,
  `CursorPos(3, 7)`, `EraseInPage(ErasePart.all)` where `Csi([CSI 4 CUU])` was
  written before. Nothing reads `toString` but a person and a golden test.
- `Csi`, `Esc` and `EscapeCode` are sealed, and this release adds types under
  them. A `switch` that covers them exhaustively has to name the new ones. `is`
  checks, casts and the identifiers entities are shown by are unchanged.
- `Color.withPrefix(String)` is gone, and nothing public stands in its place:
  a colour is named by the slot of the state it is held in, so
  `Style(background: c).backgroundColor?.id` is what `c.withPrefix('bg256')`
  was for. The string was a way to be wrong — `withPrefix('bg256')` gave
  `bg256256Gray5` — and it let the name of a target be written out by hand,
  which is how the colour of the underline came to call itself
  `underlineColor256Red` where the constant is `underline256Red`. `ColorTarget`
  names the three slots now, and takes the name from the SGR function that sets
  them, so there is one place for it.
- The colours on `Style` — `red`, `bgYellow`, `rgb531` and the rest of that
  table — now come from an extension, `StyleColors`, rather than from the class
  itself. Written the usual way they behave as they did; what an extension
  cannot do is answer a `dynamic` receiver.
- The predefined styles are constants of one class, `Styles`, and there are 783
  of them: the fifteen properties — `Styles.bold`, `Styles.italic` — and the
  256-colour table three times over, `Styles.red` for the colour of the text,
  `Styles.bgRed` for the colour behind it, and `Styles.underlineRed` for the
  colour of the underline, which had a name in neither the 530 nor the getters.
  Being constants, a style can be held in one: `const error = Styles.red`.

  The 530 top-level names are gone, among them `foreground`, `background` and
  `underlineColor`. A chain that starts at nothing at all starts at
  `Style.terminalColors`; the three functions are the constructor,
  `Style(foreground: c)`, or the methods of the same name on a style.

  The colours are still getters as well — the `StyleColors` extension — so
  `Styles.red.bold.bgYellow` is one chain, as `red.bold.bgYellow` was.

  This is what took the 31 names that `style.dart` and `ansi_escape_codes.dart`
  both claimed out of the way, and the second now exports the styles as well:
  one import where there were two.

## 3.1.2

- Add operators <, <=, >, >= for `Colors` enum.

## 3.1.0-3.1.1

- Add `NoStyle`.
- Rename `defaults` to `terminalColors`.

## 3.0.7-3.0.8

- Add string extensions: `ansiHasControlCodes` and `lengthWithoutEscapeCodes`.

## 3.0.6

- Add `open` and `close` to `Style`.

## 3.0.4-3.0.5

- Add `padLeft` and `padRight` to `Parser` and `StackedParser`.

## 3.0.3

- Fix multiline output by `Style`.

## 3.0.0-3.0.2

- [breaking changes] Total renaming:
  - `AnsiPrinter` to `Printer`, `StackedPrinter`, `SinkPrinter` and
    `StackedSinkPrinter`
  - `AnsiParser` to `Parser` and `StackedParser`
  - `SgrState` to `State`
  - `SgrStackState` to `Stack`
  - and etc.
- Add styles.

## 2.2.1

- Fix SDK constraint.
- Add `Color256.rgb` and `Color256.gray`.

## 2.2.0

- Fix README.
- Add predefined colors: `Color256.rgb123`, etc.
- Add `Color256.rgb` and `Color256.gray`.
- Update `example/colors256.dart`.

## 2.1.0

- Add methods `indexOf`, `lastIndexOf`, `contains`, `startsWith`, `endsWith`
  that work with a plain string.

## 2.0.1-2.0.3

- Fix multiline output by AnsiPrinter.
- Minor changes.

## 2.0.0

- Shift package focus to parsing and standardization.
- Add `AnsiParser`.
- Add `AnsiPrinter`.
- Add stacked `AnsiPrinter`.
- Add their corresponding functions to intercept the `print` function using
  zones: `runZonedAnsiParser`.

Breaking changes:
- The names of some constants have changed: `italic` to `italicized`,
  `blinking` to `slowlyBlinking`. All constants of the form `not…` are
  renamed to `reset…`. `(fg/bg/underline)Bright…` ara renamed to
  `(fg/bg/underline)High…`.
- Removed methods: `handle…`, `all…`. Use `AnsiParser` instead.


## 1.4.1

- Add handleEscapeSequences and handlePlainText.

## 1.4.0

- Add analysis escape sequences (showEscapeSequences).
- Add all control codes (0x00-0x1F).

## 1.3.2

- Refactor methods: allSgr, foregroundColors, backgroundColors.
- Add methods: allCsi, removeCsi, removeSgr, removeForegroundColors,
  removeBackgroundColors. Mark the methods as experimental.

## 1.3.0-1.3.1

- Add several functions to the utilities.
- Update example.
- Refactor constant name.

## 1.2.0

- Add dart doc comments.
- Update README.
- Refactor.

## 1.1.0

- Add saveCursor and restoreCursor.
- Add progress_example.dart.
- Refactor.

## 1.0.0

- Initial version.
