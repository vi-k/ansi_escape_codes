# Handoff — состояние пакета и что делать дальше

ansi_escape_codes, 2026-08-15. Безопасная точка рестарта перед планированием
волны verification guards.

**Коротко:** H8 остаётся закрыт, влит и проверен. Владелец выбрал одну новую
волну для M6, M7, M8 и кластера M13/L12, устно утвердил её дизайн, а
утверждённая спека записана commit `200d8ec`. Реализация, worktree, TDD-план и
правки production/tool/CI ещё не начались. По обязательному
`superpowers:brainstorming` review-gate следующий заход сначала ждёт явного
подтверждения владельцем **написанной** спеки; только затем пишется план и
стартуют сабагенты.

**Где что лежит:** `AGENTS.md` — правила; этот файл — текущая точка входа;
`docs/records/2026-08-15[4]-verification-guards-design.md` — принятая спека
новой волны, ожидающая финального просмотра владельцем;
`docs/records/2026-08-15[5]-pre-verification-guards-handoff.md` — архив
закрытого H8; `docs/architecture.md` — устройство кода;
`docs/backlog.md` — список владельца, агенты в него не пишут.

## Точная точка рестарта

- Локальный `main` содержит `200d8ec docs: specify verification guard
  hardening` поверх закрытого H8. Этот commit добавляет только спеку;
  `lib/`, `tool/`, `test/`, workflow и package metadata не менялись.
- До restart-handoff commit ветка была на один commit впереди `origin/main`;
  этот handoff должен быть закоммичен и отправлен вместе со спекой. После
  push сверять `HEAD` с `origin/main`, не полагаться на эту строку.
- Полная база после H8: 884 теста; format — 0 изменений; analyze — 0
  замечаний; 5 entry points замкнуты; generator round-trip не изменил `lib/`;
  memory guard — 262.2 bytes/match в полосе 159…332; dartdoc и publish
  dry-run — 0 предупреждений. H8 feature CI `31838360546` и main CI
  `31838655400` зелёные на SDK 3.6.0 и stable.
- В рабочем дереве есть неотслеживаемый `.DS_Store`. Это не часть волны и не
  агентская правка: не добавлять, не удалять и не включать в commit без нового
  решения владельца.

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

Номера порогов, corpus sizes и counts ещё не выбраны: план обязан получить их
пробником и объяснить красные обратные мутации, а не вывести рассуждением.

## Следующий безопасный шаг

1. Владелец просматривает и подтверждает
   `docs/records/2026-08-15[4]-verification-guards-design.md` либо задаёт
   правки. Это единственный блокер; новых решений не нужно.
2. После подтверждения применить `superpowers:writing-plans`, записать
   `docs/records/2026-08-15[6]-verification-guards-plan.md`, провести
   plan self-review и закоммитить его.
3. До первой правки создать изолированный `fix/verification-guards` worktree,
   снять baseline и выполнить пять задач: M6, M7, M8, semantic anchors,
   standalone complexity guard. Задачи 4 и 5 последовательны; остальные
   получают свежих implementer/reviewer сабагентов без пересечения workflow
   и документационных файлов.
4. После всех task-review — whole-branch review, локальные ворота с новым
   complexity guard, feature CI на SDK 3.6.0/stable, `git merge --no-ff`,
   push `main`, main CI и новый handoff.

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
| **Verification guards (M6, M7, M8, M13/L12)** | спека `[4]`, архив `[5]`; план ждёт review written spec | ещё не начат |

## Чему верить в этом документе

Документ написан после commit `200d8ec` и перед реализацией новой волны. Он
намеренно не называет будущие performance thresholds, task commits и CI runs.
Если handoff расходится с кодом, тестами или git, правы они.
