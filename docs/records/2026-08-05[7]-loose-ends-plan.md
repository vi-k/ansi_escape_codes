# Мелкие хвосты — дизайн и план одним документом

> **Состояние документа**
>
> - **Тип:** дизайн и план одним документом, 2026-08-05
> - **Статус:** выполнен, влит в `main` мержем `6acae3a`; закрыл остаток
>   мелочей плана ревью `2026-08-04[1]`
> - **Актуальность:** исторический документ
> - **Пути:** ссылки в тексте старые — записи с тех пор лежат в
>   `docs/records/`, `TODO.md` стал `docs/backlog.md`, текущий handoff —
>   `docs/handoff.md`

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** закрыть хвосты, накопленные леджерами заходов: удаление
дубль-точки `parsing.dart`, гигиена CI, три док-неточности, `homepage`.

**Architecture:** микро-заход — один имплементер, три коммита в ветке
`chore/loose-ends`, одно ревью всей ветки, локальный `merge --no-ff`.
Решения пользователя, зафиксированные до этого документа:
**`lib/parsing.dart` удаляется** (4.0.0 — мажор, не опубликована);
**`homepage:` убирается** из pubspec (остаётся `repository:`).

**Tech Stack:** Dart ≥3, GitHub Actions.

## Global Constraints

- Ветка `chore/loose-ends` от текущего `main`.
- Перед каждым коммитом: `dart format .` идемпотентен, полный
  `dart test`, `dart analyze --fatal-infos`.
- Версия 4.0.0 не трогается. Единственные правки существующих тестов —
  **удаление** `test/entry_point_parsing_test.dart` целиком (его точка
  умирает) — других правок тестов нет.
- Сообщения коммитов: conventional, строчные, английские, + trailer
  `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.

---

### Task 1: Три коммита хвостов

**Files:**
- Delete: `lib/parsing.dart`, `test/entry_point_parsing_test.dart`
- Modify: `README.md` (таблица entry points и текст вокруг),
  `CHANGELOG.md` (Removed), `lib/src/parsing/parser/printer.dart`
  (док `lastState`), `tool/generate.dart` (одна фраза шапки),
  `.github/workflows/dart.yml` (setup-dart, examples-шаг),
  `pubspec.yaml` (минус `homepage:`)

- [ ] **Step 1: Коммит 1 — удаление `parsing.dart`**

1. `git rm lib/parsing.dart test/entry_point_parsing_test.dart`
2. README: удалить строку `parsing.dart` из таблицы entry points;
   поправить окружающий текст — счёт точек (six → five, если назван),
   абзац под таблицей, объясняющий дубль («the same names —
   … whichever of the two is imported»), удалить или переписать: дубля
   больше нет, вводная фраза над таблицей снова честна. Прочитать всю
   секцию целиком и оставить её связной.
3. CHANGELOG `## 4.0.0`, секция `Removed — …`: добавить бుллет в конец:

```markdown
- The `parsing` entry point. After 4.0.0 made it byte-identical to
  `style`, one of the two names had to go: import
  `package:ansi_escape_codes/style.dart` — the same 81 names — or the
  umbrella `ansi_escape_codes.dart`.
```

4. Гейты; коммит:

```
refactor: two names for one entry point become one

lib/parsing.dart grew byte-identical to lib/style.dart once the review
rounds closed the export gaps, and a duplicated public surface is a
maintenance debt with no reader. It goes in the same major that made
it redundant; style.dart carries the same 81 names.
```

- [ ] **Step 2: Коммит 2 — CI-гигиена**

1. setup-dart: разрешить актуальный v1-тег живьём
   (`gh api repos/dart-lang/setup-dart/git/matching-refs/tags --jq '.[].ref'`,
   взять последний v1.x.y; SHA — через
   `gh api repos/dart-lang/setup-dart/git/ref/tags/<tag> --jq .object.sha`,
   разыменовав annotated-tag при необходимости через `.object.type`),
   заменить старый пин `9a04e6d… # v1.0.0` на новый `<SHA>  # v<tag>`.
2. Examples-шаг: `timeout 60 dart run "$f" > /dev/null` →
   `timeout 60 dart run "$f" > /dev/null < /dev/null` — `control.dart`
   читает stdin (`currentCursorPos`) и не должен зависеть от tty
   раннера.
3. Локально: каждый из 8 примеров с `< /dev/null` завершается с кодом 0.
4. Гейты; коммит:

```
ci: setup-dart leaves 2021, and the examples stop reading the runner's stdin

The action was pinned at v1.0.0 since the workflow was born; the pin
moves to the current v1 tag, same SHA discipline as its neighbours.
The examples loop gets stdin from /dev/null, so control.dart's cursor
probe fails fast instead of depending on what the runner happens to
attach.
```

- [ ] **Step 3: Коммит 3 — док-точность и pubspec**

1. `printer.dart`, док `lastState`: клауза о NoStyle расширяется вторым
   кейсом — с `ansiCodesEnabled: false` поле тоже остаётся `null`
   (строка возвращается до присваивания). Одна фраза в духе имеющейся.
2. `tool/generate.dart`, шапка: «a pre-3.7 `dart_style`» → привязать
   номер к SDK/language version, а не к имени dart_style (например
   «the short style of `dart format` before language version 3.7»);
   смысл заметки не менять.
3. `pubspec.yaml`: удалить строку `homepage:` (остаются `repository:` и
   `issue_tracker:`).
4. `rm -rf coverage; dart pub publish --dry-run` — 0 предупреждений.
5. Гейты; коммит:

```
docs: the last two half-truths are spelled out, and pubspec says it once

lastState also stays null when ansiCodesEnabled is off; the generator's
style note pins its version to the language, not to dart_style's name;
homepage leaves pubspec — repository already says it.
```

---

### Task 2: Ревью ветки и merge

- [ ] **Step 1: Полный прогон** — format/analyze/test/publish dry-run/
  generate+diff, всё чистое.
- [ ] **Step 2: Whole-branch ревью** по процессу; находки —
  fixup-коммитами.
- [ ] **Step 3: Merge**

```bash
git checkout main
git merge --no-ff chore/loose-ends -m "merge: the loose ends are tied off"
git push
git branch -d chore/loose-ends
```
