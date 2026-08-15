# Handoff — состояние пакета и что делать дальше

ansi_escape_codes, 2026-08-15. Точка рестарта незавершённой волны
verification guards.

**Коротко:** реализация M6, M7, M8 и кластера M13/L12 выполнена в отдельном
worktree на ветке `fix/verification-guards`. Финальный whole-branch review
остановлен: `tool/check_entry_points.dart` всё ещё не доказывает отсутствие
ошибки анализатора в экспортируемом `lib/src/...`-файле, поэтому режим
`--update-snapshot` может перезаписать snapshot после такой ошибки. Ветка не
отправлялась, CI не запускался, merge в `main` не делался. Для нового раунда
нужна явная воля владельца; до неё код не менять.

**Где что лежит:** `AGENTS.md` — правила; этот файл — текущая точка входа;
`docs/records/2026-08-15[4]-verification-guards-design.md` — спека
волны; `docs/records/2026-08-15[6]-verification-guards-plan.md` — её план;
`docs/records/2026-08-15[5]-pre-verification-guards-handoff.md` — архив
закрытого H8; `docs/architecture.md` — устройство кода;
`docs/backlog.md` — список владельца, агенты в него не пишут.

## Точная точка рестарта

- Рабочее дерево: `.worktrees/fix-verification-guards`, ветка
  `fix/verification-guards`, `HEAD e658130` (`docs: record verification guard
  restart state`). Implementation base — `c2d6c3c`; дерево чистое. Локальный
  `main` — `623d1c6`,
  `origin/main` — `c6eda18`.
- Реализационные commits: M6 `5e4238c`, M7 `1ddb072`, M8 `53d9c36`,
  anchors `2c53313`, complexity `08ffedd`, lint `95c3a4d`, документация
  `2f278a3`/`293cd35`, финальная правка путей и прямого entry-point fixture
  `c2d6c3c`.
- До последнего review локальные ворота были сняты: 900 тестов, format,
  entry-point check, generator round-trip, memory guard, complexity guard,
  dartdoc и publish dry-run (0 предупреждений). Это не заменяет feature CI:
  ветка не push-нута и на SDK 3.6.0 не проверена.
- Блокер подтверждён повторно whole-branch reviewer: тест проверяет ошибку,
  добавленную прямо в `lib/extensions.dart`, но не ошибку в подключённом
  `lib/src/extensions/has.dart`; analyzer diagnostic может остаться
  необнаруженным до записи snapshot. Предыдущий допустимый финальный fix-wave
  исчерпан, поэтому следующий patch требует решения владельца.
- В рабочем дереве есть неотслеживаемый `.DS_Store`. Это не часть волны и не
  агентская правка: не добавлять, не удалять и не включать в commit без нового
  решения владельца.

## Правило ведения состояния

Актуальная точка старта, блокеры и следующий разрешённый шаг ведутся в этом
`docs/handoff.md`. `.superpowers/.../progress.md` — только внутренний ledger
исполнения плана и не источник состояния для нового захода; после каждого
существенного изменения handoff обновляется первым.

## Выбранная волна: verification guards

### M6 — public namespace snapshot

`check_entry_points.dart` сохраняет прежний closure-walk публичных сигнатур и
получает второй, независимый oracle: точный JSON snapshot имён, экспортируемых
каждой из пяти точек входа. Обычный запуск ловит missing, unexpected и
несовпадение самого множества `lib/*.dart`; явный `--update-snapshot` нужен
только для принятого API-diff и не используется в CI.

На живой базе namespace counts: `ansi.dart` 510, зонтичный entry point 1037,
`extensions.dart` 8, `style.dart` 91, `utils.dart` 2. Мутация удаления
`has.dart` export должна красить специальное ворото и называть
`StringHasEscapeCodesExtension`.

### M7 — generator registry preflight

Генератор сначала сравнивает registry восьми известных путей с рекурсивно
обнаруженными marker-файлами в `lib/`. Лишняя, отсутствующая, повторная либо
непарная marker-зона завершает процесс до первой записи. Успешный запуск
пишет и сообщает ровно восемь зон; повторный запуск идемпотентен.

### M8 — coverage рукописного кода

Workflow сохраняет полный `lcov.info` для artifact и строит отдельный
`lcov.gated.info` с `--ignore-files=**/style_colors.dart`. Новый floor —
95.0% и применяется только ко второму файлу. Живой probe дал 79.646%
(`2387/2997`) полного и 95.976% (`2385/2485`) filtered coverage. Нулевой
знаменатель остаётся красным.

### M13/L12 — complexity отдельно от общего test process

Детерминированные semantic anchors остаются в обычном тестовом корпусе:
parse, slicing, Stack и insert доказывают точный результат и объём работы.
Wall-clock ratios уезжают в отдельный `benchmark/complexity_guard.dart`:
stable-only, прогрев, попарно чередуемые small/large замеры, медиана 5–7 пар,
достаточно большие batches и калибровка на живом коде с обратными мутациями.
Он не объединяется с cold `memory_guard.dart`.

Пороговые значения, corpus sizes и counts выбраны пробником и зафиксированы в
`benchmark/complexity_guard.dart`; их не следует менять, чтобы замаскировать
красную мутацию.

## Следующий безопасный шаг

1. Владелец решает, разрешать ли ещё один implementation/review round для
   blocker выше. Без этого не менять `tool/check_entry_points.dart` или его
   тесты и не переписывать историю.
2. Если round разрешён, сначала добавить regression на ошибку в экспортируемом
   `lib/src/...`-файле и доказать, что snapshot bytes не меняются; затем
   повторить whole-branch review и локальные ворота.
3. Только после зелёного review: push feature branch, дождаться CI на SDK
   3.6.0/stable, затем обычный `git merge --no-ff` в `main`, push `main` и
   записать новый handoff.

## Чего не делать

- Не публиковать 4.0.0, не ставить тег и не бампать версию.
- Не менять публичный API, `lib/`, SDK-floor `^3.6.0` или marker text этой
  волной.
- Не брать другие Medium/Low находки и не заводить пункты в
  `docs/backlog.md`.
- Не подменять обязательный review written spec устным одобрением дизайна.
- Не стирать или добавлять `.DS_Store` без воли владельца.

## Последние волны

| волна | спека / план / архив | merge |
|---|---|---|
| Terminal и stacked reset (H7) | `2026-08-14[7]`, `[8]`, `[10]` | `bbbb210` |
| Межстрочный cursor save (H8) | `2026-08-15[1]`, `[2]`, `[3]` | `2db4abd` |
| **Verification guards (M6, M7, M8, M13/L12)** | спека `[4]`, план `[6]`; реализация в `fix/verification-guards` | blocked before push |

## Чему верить в этом документе

Этот файл — стартовый handoff и отражает состояние на `HEAD e658130` в
worktree `fix/verification-guards`; внутренний `.superpowers/.../progress.md`
может содержать более подробный ledger, но не заменяет этот документ. Если
handoff расходится с кодом, тестами или git, правы они.
