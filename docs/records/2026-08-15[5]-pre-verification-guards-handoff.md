# Handoff — состояние пакета и что делать дальше

> **Состояние на 2026-08-16:** отработал и архивирован 2026-08-15 перед
> планированием M6, M7, M8 и M13/L12 — волна, которую он передал, доведена и
> влита в `main` мержем `6b2d1cb`. Проза описывает полностью закрытый H8
> (merge `2db4abd`); разделы «Что делать дальше», «Открыто» и шапка
> репозитория не знают ни о коммите спеки `200d8ec`, ни о выбранной новой
> волне, верить им нельзя.
> **Что это:** переданный в новую сессию снимок пакета после закрытия H8.
> **Связанные записи:** `2026-08-15[4]-verification-guards-design.md`,
> `2026-08-15[6]-verification-guards-plan.md`,
> `2026-08-16[1]-post-verification-guards-handoff.md`,
> `2026-08-15[3]-pre-h8-handoff.md`.

ansi_escape_codes, 2026-08-15. Передача контекста после закрытия H8.

**Коротко:** H8 закрыт и влит в `main` merge-коммитом `2db4abd`.
Все четыре принтера теперь несут один session-wide save-slot `ESC 7` / `ESC 8`
через строки и writes: state, hyperlink и opaque SGR восстанавливаются вместе,
restore без save возвращает terminal defaults, а sink `prepare()` не оставляет
пробного slot. Цельнострочные parser-контракты и публичный API не менялись.
Две task-review и whole-branch review прошли без находок; локальные ворота,
feature CI и main CI зелёные. Версию, тег и публикацию не трогали.

**Где что лежит:** `AGENTS.md` — правила работы; этот файл — текущая точка
входа; `docs/records/2026-08-15[1]-printer-cursor-save-design.md` — принятая
спека H8; `docs/records/2026-08-15[2]-printer-cursor-save-plan.md` —
исполненный TDD-план; `docs/records/2026-08-15[3]-pre-h8-handoff.md` —
состояние перед планом и реализацией; `docs/architecture.md` — устройство
кода; `docs/backlog.md` — список владельца, агенты в него не пишут.

## Состояние репозитория

- `main` влит и запушен на `2db4abd`; перед этим feature HEAD `69333e8`
  запушен как `origin/fix/printer-cursor-save`. Созданный worktree и локальная
  feature-ветка удалены после зелёного merge-result test; remote feature branch
  не удалялась.
- Смысловой код H8 — `6185964`, публичная документация — `69333e8`.
  Подготовительные документы: спека `d34b58a`, pre-H8 handoff `3787952`,
  план `bf0a9ec`; `.worktrees/` исключён коммитом `85e697e`.
- Feature CI зелёный: run `31838360546` на `69333e8`, jobs `94889641110`
  (`build (3.6.0)`, 1m51s) и `94889641224` (`build (stable)`, 2m34s).
- CI merge-коммита на `main` зелёный: run `31838655400` на `2db4abd`, jobs
  `94890549278` (`build (3.6.0)`, 1m43s) и `94890549410`
  (`build (stable)`, 2m25s).
- Финальные локальные ворота сняты на feature HEAD `69333e8`, чьё дерево
  совпадает с merge-результатом: format — 145 файлов, 0 изменений; analyze —
  0 замечаний; 5 entry points замкнуты; generator round-trip не изменил
  `lib/`; **884 теста**; memory guard — **262.2 байта на match** при полосе
  159…332; dartdoc — 0 предупреждений и 0 ошибок; publish dry-run —
  0 предупреждений. После merge все 884 теста запущены ещё раз и прошли.
- Stable CI прошёл memory guard, coverage floor 75% и publishability; SDK
  3.6.0 прошёл свой предусмотренный workflow-набор. Оба run оставили только
  внешние annotations о переводе Node.js 20 actions на Node.js 24; к H8 они не
  относятся и jobs не красят.
- H8 выполнен через `superpowers:subagent-driven-development`: свежий
  implementer на каждую из двух задач, отдельный spec+quality reviewer после
  каждой и самый сильный whole-branch reviewer. Все три review-gate прошли без
  Critical, Important или Minor findings; fix rounds не понадобились.
- Версия в `pubspec.yaml` — **4.0.0**, на pub.dev — 3.1.2. Версию не бампали,
  тег не ставили, пакет не публиковали.

## Что сделано в H8

### Один private slot через parser pipeline

- Внутренний `_CursorSave<S>` хранит `state`, `link` и `_SgrResidual?`.
  Nullable весь record: `null` означает «save ещё не было», а настоящий save
  с `link: null` или `residual: null` остаётся снимком и побеждает fallback.
- Record проходит через `_ParserBase` → `Pieces` → `_ParserIterator` →
  `_PiecesResult`. Итоговый slot доступен только private printer pipeline;
  публичных parameters, getters, constructors и exports не появилось.
- Каждый iterator начинает с принесённого slot; replay кэшированного
  `SaveCursor` переснимает все три канала, а final result публикуется только
  после полного чтения. `ESC 8` выбирает slot или fallback и не потребляет его;
  следующий `ESC 7` заменяет снимок целиком.
- У обычных `Parser`/`StackedParser` restore-fallback по-прежнему равен их
  initial state/link/residual. Прямой разбор вставки получает тот же seam
  fallback и не наследует printer slot.

### Session carry четырёх принтеров

- `_PrinterBase._savedCursor` передаёт final slot следующему разбору рядом с
  `lastState`, `_lastResidual` и `_ambientLink`. Initial state текущего куска
  остаётся перенесённым state, но missing-save fallback принтера всегда
  `(stateDefaults, null, null)`.
- `Printer`, `StackedPrinter`, `SinkPrinter` и `StackedSinkPrinter` сохраняют
  slot через строки, newline и отдельные writes. Stacked-варианты несут полный
  `Stack` со всеми lower frames, а не foreground-проекцию.
- `SinkPrinter.prepare()` и `StackedSinkPrinter.prepare()` откатывают пробный
  slot вместе с прежними carry-полями. `write`, `writeAll`, `writeCharCode` и
  `writeln` обновляют одну сессию по реально записанным кускам.
- Пустой кусок, `NoStyle` и `ansiCodesEnabled: false` остаются ранними bypass:
  первый не меняет slot, `NoStyle` оставляет raw-байты терминалу, disabled ANSI
  удаляет cursor-коды и не создаёт private carry.
- Raw `ESC 7`/`ESC 8`, cursor coordinates, hyperlink-reopening placement,
  terminal/stacked reset-граница H7 и residual-модель H6 не менялись.

### Доказательства и документация

- Новый `test/printer_cursor_save_test.dart` поднял корпус с 865 до 884 тестов.
  Он держит cross-save и no-save на четырёх surfaces, следующий кусок после
  restore, repeated restore, overwrite, полный Stack, saved link, saved-null
  link, opaque residual, оба sink rollback, `writeAll`/`writeCharCode`, пустой
  кусок и bypass-режимы.
- Два прежних accepted-limit теста в `link_continuity_fuzz_test.dart`
  развёрнуты в зелёные no-save регрессии state и link.
- До production-кода новые контракты были красными на известных симптомах.
  После фикса проверены пять точных обратных мутаций: потеря initial slot,
  смешение fallback с seed, отсутствие sink rollback, потребление slot на
  restore, исключение link и residual из снимка. Каждая вернула свой тест в
  красное; восстановленная реализация прошла общий targeted-набор из 81 теста.
- Dartdoc четырёх принтеров и `prepare`, README EN/RU, CHANGELOG и architecture
  описывают session lifetime, replace/non-consuming contract, terminal
  fallback и sink rollback. Структура и примеры двух README синхронны.

## Коммиты H8

| слой | коммит |
|---|---|
| принятая спека | `d34b58a` |
| handoff перед планом | `3787952` |
| исполняемый план | `bf0a9ec` |
| безопасный каталог worktree | `85e697e` |
| private carry и 19 регрессий | `6185964` |
| публичная документация | `69333e8` |
| merge в `main` | `2db4abd` |

## Найдено волнами

Полная исходная опись —
`docs/records/2026-08-13[5]-independent-review.md`. Клетки «сейчас» в том
отчёте исторические; закрытия сверяются с этим handoff и git.

### Закрыто, High

| находка | закрытие |
|---|---|
| H3: управляющие байты из URL проходили в терминал | `835b792`, `f7ba4c1` |
| C1: `Stack` был квадратичен | `6a0a60d` |
| H2: незавершённый код из входа глотал текст четырёх выходов | `cbec9d0` |
| H10: сужение `Stack.underlineColor` не было отмечено breaking | `5b05f05` |
| H5: открытый срез терял выжившую половину парного сброса | `a63cc4d` |
| H9: `Match` перекрывал `dart:core.Match` | `a7978a4` |
| H4: незавершённый код из вставки глотал исходный хвост | `2ea6c77`, merge `d86e75e` |
| H6: немоделируемые SGR исчезали из обратных выходов | feature `4fdd576`, merge `a7d708c` |
| H7: `Style.call` смешивал terminal reset и pop-семантику | feature `418736b`, merge `bbbb210` |
| **H8: printer терял `ESC 7`/`ESC 8` slot на границе разбора** | feature `69333e8`, merge `2db4abd` |

### Открыто, Medium и ниже

- **M6:** `check_entry_points.dart` сам не ловит удалённый `export`; часть
  поверхности страхуют analyze и тесты entry points.
- **M7:** `generate.dart` не замечает новую незарегистрированную зону
  `BEGIN`/`END`.
- **M8:** порог покрытия сильно зависит от генерируемого
  `style_colors.dart`, а комментарий workflow несёт старые числа.
- **M13/L12:** временные стражи чувствительны к загрузке машины; наблюдались
  неповторяемые красные прогоны под параллельной нагрузкой.

Новых находок H8-review и реализация не добавили.

## Что делать дальше

1. Владелец выбирает следующую волну из оставшихся M6, M7, M8, M13/L12 либо
   отдельно решает вопрос публикации 4.0.0.
2. Новый backlog-заход снова начинается с brainstorming → спека → план;
   собственные находки агента идут сюда, не в `docs/backlog.md`.
3. Публикацию 4.0.0 и тег не делать без нового прямого решения владельца.

## Чего не переоткрывать

- H8 использует один session-wide, replaceable и non-consuming slot на
  printer. Restore без save — terminal defaults, не carry предыдущего куска;
  обычный цельнострочный parser сохраняет seeded fallback.
- Cursor slot несёт state, link и residual одним record, но hyperlink остаётся
  отдельным каналом рядом со `State`, не внутри него. `SGR 0` не закрывает
  link и не очищает cursor slot.
- Sink `prepare` — проба без side effects; реальный write обновляет slot.
  `NoStyle` доверяет raw-байты терминалу, disabled ANSI удаляет их.
- H7 закрыт выбранной границей: обычные `Style`/`Parser`/`Printer`/
  `SinkPrinter` моделируют терминал, явно названные `Stack`/`Stacked*` —
  иерархический pop.
- `insertAfter` на unfinished seam, открытый `substring`, 8-битные C1,
  инвариант придержанных opening/link-кодов и потолок скорости `substring`
  закрыты прежними решениями.
- Публичного residual или cursor-save API нет; расширять его без новой спеки и
  решения владельца нельзя.

## Последние волны

| волна | спека / план / архив | merge |
|---|---|---|
| Прогретый обход отвечает как свежий | `2026-08-13[1]`, `[2]` | `0f0080b` |
| Закрытие находок перед публикацией | `2026-08-13[3]`, `[4]` | `206a937` |
| Независимое ревью и разбор находок | `2026-08-13[5]`, `[6]`, `[7]` | `d0723e0` |
| `Match` → `Piece` (H9) | `2026-08-13[8]`, `[9]` | `f1a927d` |
| Незавершённый код во вставке (H4) | `2026-08-14[1]`, `[2]`, `[3]` | `d86e75e` |
| Typed и opaque SGR (H6) | `2026-08-14[4]`, `[5]`, `[6]`, `[9]` | `a7d708c` |
| Terminal и stacked reset (H7) | `2026-08-14[7]`, `[8]`, `[10]` | `bbbb210` |
| **Межстрочный cursor save (H8)** | `2026-08-15[1]`, `[2]`, `[3]` | `2db4abd` |

## Чему верить в этом документе

Документ обновлён после merge `2db4abd`, повторного полного тестового корпуса,
push `main` и зелёного CI `31838655400`. Локальные ворота относятся к feature
HEAD `69333e8`, дерево которого совпадает с merge-результатом; после merge
отдельно повторены все 884 теста. Feature CI `31838360546` и main CI
`31838655400` оба зелёные на SDK 3.6.0 и stable. Если handoff расходится с
кодом, тестами или git, правы они.
