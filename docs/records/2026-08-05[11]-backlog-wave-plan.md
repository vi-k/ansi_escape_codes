# План: волна по бэклогу — TODO минус дизайн-заход

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Закрыть все пункты TODO.md, кроме N5 (переоткрытие ссылок — дизайн-заход с пользователем), плюс запаркованный хвост волны [10]: два предложения dartdoc в printer.dart про carry.

**Architecture:** Одиннадцать независимых задач-коммитов на ветке `chore/backlog-wave`; каждая — red-тест где применимо + фикс + CHANGELOG (только где user-visible) одним коммитом. Финальное whole-branch-ревью → `merge --no-ff` в main → push. Взятые пункты вычеркнуты из TODO.md коммитом плана (остаётся только N5). Публикации в этой волне нет.

**Tech Stack:** Dart 3.6+, `dart test`, `--fatal-infos`; Task 11 добавляет dev-зависимость `analyzer`.

## Global Constraints

- Версию в pubspec НЕ бампать (4.0.0 не опубликована; user-visible правки — в секцию 4.0.0 CHANGELOG).
- Один фикс — один коммит; повествовательные сообщения; трейлер `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.
- После каждой задачи: `dart format --output=none --set-exit-if-changed .`, `dart analyze --fatal-infos`, `dart test` — всё зелёное.
- Комментарии/dartdoc — на английском, в голосе окружающего текста.
- Номера находок (N7, N8, …) — из `docs/2026-08-05[9]-review-verification-report.md`.

---

### Task 1: dependabot для action-пинов

**Files:** Create: `.github/dependabot.yml`

- [ ] **Step 1:** Создать файл:

```yaml
# SHA-pinned actions do not update themselves: setup-dart sat on v1.0.0
# from 2021 until a review noticed. Dependabot moves the pin and the
# version comment together.
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

- [ ] **Step 2:** Ворота (yaml не влияет на dart-ворота, но прогнать обязательно). Commit: `ci: the pins learn to move themselves`

---

### Task 2: имена таблицы пинятся к кубу (N7)

**Files:** Test: `test/colors_test.dart` (рядом с существующими точечными анкерами `rgb000`/`rgb555`/`rgb123`, ~строка 157)

- [ ] **Step 1:** Добавить тест-пин (проходит сразу — это пин существующего поведения; если вдруг красный — STOP, это находка):

```dart
test('every name spells its own cube coordinates', () {
  for (var r = 0; r < 6; r++) {
    for (var g = 0; g < 6; g++) {
      for (var b = 0; b < 6; b++) {
        expect(
          Colors.values.byName('rgb$r$g$b'),
          Colors.values[16 + 36 * r + 6 * g + b],
          reason: 'rgb$r$g$b must sit where the cube formula points',
        );
      }
    }
  }
  for (var level = 0; level < 24; level++) {
    expect(
      Colors.values.byName('gray$level'),
      Colors.values[232 + level],
      reason: 'gray$level must sit where the gray ramp points',
    );
  }
});
```

- [ ] **Step 2:** Ворота (тестов станет 387). Commit: `test: the names answer to the cube`

---

### Task 3: док-хвост N13 — dartdoc договаривает

**Files:** Modify: `lib/src/parsing/state/style.dart` (dartdoc `NoStyle`, ~:429-440), `lib/src/parsing/state/state.dart` (dartdoc `toStyle`, ~:381-383), `lib/src/parsing/parser/parser.dart` (публичный dartdoc `insertBefore`/`insertAfter`)

- [ ] **Step 1:** `NoStyle` dartdoc: дописать — реальное изменение выводит из `NoStyle` безвозвратно (результат — пишущий `Style`), и `.reset` — единственная операция, делающая это без смены поверхности (оба факта уже запиннены `test/no_style_test.dart` — сослаться не нужно, просто сказать словами).
- [ ] **Step 2:** `State.toStyle` dartdoc: одна оговорка — `NoStyle` возвращает себя (он и есть `Style`), «plain» тут не означает «пишущий».
- [ ] **Step 3:** `insertBefore`/`insertAfter` dartdoc: одна строка из внутреннего комментария `_seamAt` («left as they lie») — вход, уже невалидный как UTF-16 (одиночные половины пар), не чинится и не валидируется: половины остаются лежать как лежали.
- [ ] **Step 4:** Ворота (`dart doc --dry-run` тоже — 0 warnings). Commit: `docs: NoStyle, toStyle and the inserts say the last quiet parts`

---

### Task 4: запаркованный хвост волны [10] — проза carry в printer.dart

**Files:** Modify: `lib/src/parsing/parser/printer.dart:148-151` (dartdoc `_PrinterBase.prepare`), `:305-308` (dartdoc `_SinkPrinterBase._closesLinkAtEnd`)

- [ ] **Step 1:** Оба места говорят, что открытая ссылка «is carried to the write that follows» через `prepare` — после hardening это верно только для внутреннего `_prepare`-пути; публичный `prepare` синка состояние ссылки не двигает (save/restore). Переписать оба предложения так, чтобы carry был приписан пути записи (`write`/`writeln`), а про публичный `prepare` синка сказано прямо: он готовит и не пишет, состояние ссылки не трогает.
- [ ] **Step 2:** Ворота. Commit: `docs: the carry belongs to the writes, and prepare says so`

---

### Task 5: L11 — тавтологичные тесты уходят

**Files:** Test: `test/ready_to_use_csi_test.dart` (~:7-50), `test/parser_esc_test.dart` (~:71-73)

- [ ] **Step 1:** Удалить ассерты, сравнивающие константу с её же определением (`cursorUpClose` с `CUU`, `*Open` с `CSI`, ESC-константы с их определениями), ТОЛЬКО там, где рядом есть байт-литеральная проверка того же значения (`'\x1B[A'` и т.п.). Если для какого-то значения байт-литеральной проверки нет — НЕ удалять, а добавить байт-литеральную и удалить тавтологию.
- [ ] **Step 2:** Ворота; число тестов может уменьшиться — зафиксировать сколько. Commit: `test: the constants stop vouching for themselves`

---

### Task 6: known limitations в dartdoc (N10, N11)

**Files:** Modify: `lib/src/extensions/remove.dart` (dartdoc `ansiRemoveForeground`/`ansiRemoveBackground`/`ansiRemoveUnderlineColor`/`ansiRemoveSgr`), `lib/src/parsing/parser/parser.dart` (dartdoc `optimize`)

- [ ] **Step 1:** remove-семейство: одна общая формулировка (в каждом dartdoc или в шапке файла с отсылками — выбрать по структуре файла): параметр SGR, не влезающий в целое, для парсера — нечитаемая последовательность (`CsiUnknown`), а для этих паттернов — по-прежнему цвет: удаление перепишет то, что парсер оставил бы нетронутым.
- [ ] **Step 2:** `optimize` dartdoc: не закрывает открытую ссылку — в отличие от `substring(close: true)`; и дописываемое срезом/принтером закрытие всегда ST-терминировано, даже если ссылку открыли через BEL (эту фразу — туда, где у `substring`/`prepare` говорится о закрытии; одного места достаточно, второе может сослаться).
- [ ] **Step 3:** Ворота + `dart doc --dry-run`. Commit: `docs: the removals and the optimizer name their edges`

---

### Task 7: `lengthWithoutEscapeCodes` без сборки строки (N12)

**Files:** Modify: `lib/src/extensions/remove.dart:~93`; Test: дифференциальный ассерт в существующий файл тестов расширений; CHANGELOG (перф-абзац 4.0.0 — полклаузы)

- [ ] **Step 1:** Красный тест не нужен (поведение не меняется); добавить дифференциальный пин:

```dart
test('lengthWithoutEscapeCodes agrees with the string it never builds', () {
  const inputs = [
    '', 'plain', '\x1B[31mred\x1B[0m', '\x1B[38;5;196mx',
    'a\x1B]8;;http://u/\x1B\\link\x1B]8;;\x1B\\b', '\x1B', 'a\x1B[', '𝄞\x1B[31m𝄞',
  ];
  for (final s in inputs) {
    expect(s.lengthWithoutEscapeCodes, s.ansiRemoveEscapeCodes().length);
  }
});
```

- [ ] **Step 2:** Реализация — считать, не строя:

```dart
int get lengthWithoutEscapeCodes {
  if (!contains(ESC)) {
    return length;
  }
  var removed = 0;
  for (final m in escapeCodesRe.allMatches(this)) {
    removed += m.end - m.start;
  }
  return length - removed;
}
```

(Сверить фактическую сигнатуру/имена по файлу; сохранить существующий dartdoc, дописав, что очищенная строка не строится.)

- [ ] **Step 3:** Ворота. CHANGELOG: в перф-абзац 4.0.0 полклаузы — «`lengthWithoutEscapeCodes` counts without building the cleaned string». Commit: `perf: the length is counted, not built`

---

### Task 8: CI — примеры циклом и порог покрытия (N12)

**Files:** Modify: `.github/workflows/dart.yml` (~:60-68 examples; ~:71-80 coverage)

- [ ] **Step 1:** Захардкоженный список примеров → цикл:

```yaml
      - name: Run examples
        run: |
          for f in example/*.dart; do
            if [ "$f" = "example/utils.dart" ]; then continue; fi
            timeout 60 dart run "$f" > /dev/null < /dev/null
          done
```

(`utils.dart` — без main, комментарий об этом в workflow сохранить/перенести.)

- [ ] **Step 2:** Порог покрытия: после сбора coverage сгенерировать lcov (`dart pub global activate coverage` уже не нужен — пакет coverage в dev-цепочке; использовать `dart run coverage:format_coverage --lcov ...`; если `coverage` не прямая dev-зависимость — добавить её в dev_dependencies) и посчитать процент строк по `lib/`; порог **75.0** (сейчас 76.0; сгенерированный `style_colors.dart` — 0,4 % by design, порог это учитывает). Реализация — маленький шаг с awk/dart-однострочником, падающий при < 75.0 с печатью фактического процента.
- [ ] **Step 3:** Воркфлоу-линт головой: yaml валиден (`dart` не проверит) — прогнать `python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/dart.yml'))"` или аналог; локально исполнить сами команды цикла примеров. Ворота. Commit: `ci: the examples run as a family, and the coverage holds a floor`

---

### Task 9: сторожевой замер удержания памяти (рецепт M5, часть 3)

**Files:** Create: `benchmark/memory_guard.dart`; Modify: `.github/workflows/dart.yml` (новый шаг после тестов, stable)

**Design (зафиксировано планом):** холодный процесс, детерминированный плотный корпус ~4 МБ (генерация в духе `parser_benchmark.dart`), `Parser(...).prepare()`, результат удерживается; метрика — (RSS после − RSS до) / число матчей, байт на матч. Порог задаётся в файле константой с калибровкой в шапке: имплементер меряет ≥5 холодных прогонов локально, берёт максимум и ставит порог с запасом ~35 % (цель: ловить регрессии класса 1c53a02 — ×1.46 удержания — и не флейкать на шуме ±10 %). Скрипт печатает обе величины и выходит с кодом 1 при превышении.

- [ ] **Step 1:** Написать `benchmark/memory_guard.dart` (самодостаточный, без зависимостей кроме пакета; `ProcessInfo.currentRss`; корпус фиксированным сидом).
- [ ] **Step 2:** Калибровка: ≥5 прогонов, числа — в шапку файла и в отчёт задачи; порог = max × 1.35, округлить.
- [ ] **Step 3:** Самопроверка сторожа: в изолированной копии (git archive в scratchpad) вернуть `UnmodifiableListView` в `sgr.dart:26-27` и убедиться, что сторож краснеет; копию удалить, в репозитории ничего не менять. Вывод — в отчёт.
- [ ] **Step 4:** Шаг CI (stable, после тестов): `dart run benchmark/memory_guard.dart`. `.pubignore` уже исключает `benchmark/`? — проверить: `compare.dart` исключён, `parser_benchmark.dart` едет; решить по аналогии (guard в пакет НЕ нужен — добавить в `.pubignore`, если не покрыт).
- [ ] **Step 5:** Ворота + publish dry-run (состав пакета не должен измениться). Commit: `ci: the retained memory answers to a guard`

---

### Task 10: алфавиты фаззеров и пофункциональная сохранность (N8)

**Files:** Test: `test/has_agrees_with_parser_test.dart`

**ВАЖНО:** оракулы не ослаблять. Если расширение алфавита вскроет НОВОЕ расхождение regex-пути с парсером вне двух принятых классов (int-переполнение; изменение разбора соседа при удалении рядом с усечённым/незакрытым куском) — STOP, доложить как находку с минимальным репро, тест не подгонять.

- [ ] **Step 1:** В алфавит фрагментов добавить: `'\x1B]0;unterminated'` (незакрытый OSC) и `'\x1B[58;5;'` (второй усечённый CSI); в `_truncated` — соответствующие записи (изучить, как список используется оракулом удаления, и расширить согласованно).
- [ ] **Step 2:** Добавить в фазз-циклы оракулы `ansiHasSgr` (против «есть ли `Sgr`-сущность у парсера») и `ansiRemoveSgr` (против склейки не-`Sgr`-сущностей, с теми же принятыми исключениями, что у существующих remove-оракулов).
- [ ] **Step 3:** Пофункциональная сохранность: после `ansiRemoveForeground/Background/UnderlineColor` список `SgrFunction` парсера на результате == список до минус функции удалённого рода (сравнение по родам/значениям; исключения — те же принятые классы). Сиды фиксированные, объёмы — в духе существующих (не раздувать время прогона: суммарно ≤ +2 с).
- [ ] **Step 4:** Ворота; время `dart test` зафиксировать до/после. Commit: `test: the fuzzers learn the words they were missing`

---

### Task 11: механическое замыкание точек входа

**Files:** Create: `tool/check_entry_points.dart`; Modify: `pubspec.yaml` (dev_dependencies: `analyzer`), `.github/workflows/dart.yml` (шаг после analyze)

**Design (зафиксировано планом):** скрипт на `package:analyzer` — для каждой точки входа `lib/*.dart`: разрешить библиотеку, взять её экспортное пространство имён; обойти публичные элементы и их ПУБЛИЧНЫЕ сигнатуры (типы возврата, типы параметров, аргументы типов, bounds, extended type у extension'ов; поверхностно — без обхода тел); собрать все элементы-объявления ЭТОГО пакета, на которые сигнатуры ссылаются; каждый такой элемент обязан быть в экспортном пространстве той же точки. Нарушения — списком `точка: элемент — где встречен`; exit 1. `dart:*`/внешние пакеты не проверяются.

- [ ] **Step 1:** Добавить `analyzer: ^8.0.0` в dev_dependencies (совместимость с резолвом проверить; если резолв тянет мажор новее — взять его).
- [ ] **Step 2:** Написать `tool/check_entry_points.dart` (использовать `AnalysisContextCollection`; entry points перечислить динамически: `lib/*.dart`).
- [ ] **Step 3:** Самопроверка: в изолированной копии скрыть `ControlFunctionsC0` из `lib/extensions.dart` — скрипт обязан упасть, назвав `ControlFunctionsC0` и `ansiRemoveControlCodes`; вернуть, скрипт зелёный. Вывод — в отчёт (репозиторий не менять).
- [ ] **Step 4:** Шаг CI (stable, рядом с analyze): `dart run tool/check_entry_points.dart`. `tool/` уже в `.pubignore` — состав пакета не меняется (проверить dry-run).
- [ ] **Step 5:** Ворота. Commit: `ci: every entry point proves its own closure`

---

## Завершение ветки

1. Whole-branch-ревью свежим ревьюером (Opus): дифф ветки против main, с TODO.md и отчётом [9] как контекстом.
2. Блокеры — отдельными коммитами до чистого вердикта; затем `git checkout main && git merge --no-ff chore/backlog-wave`.
3. Ворота на main: format, analyze, test, `dart pub publish --dry-run`, `dart run tool/generate.dart && git diff --exit-code -- lib/`, `dart run benchmark/memory_guard.dart`, `dart run tool/check_entry_points.dart`.
4. `git push origin main`; ветку удалить. Публикации в этой волне нет (ждёт решения пользователя).
