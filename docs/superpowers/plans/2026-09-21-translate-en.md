# Постановка: перевод регламента pm-workflow на английский

> Стадия кода конвейера перевода, класс `hygiene` (гигиена). Родительский конвейер — card 573;
> решение владельца — 2026-09-21 (реквизит D-N в приватном реестре; публично — дата и номер,
> как у D-1…D-9). Архитектурных развилок нет: это перевод, а не пересмотр правил.
>
> Написано для исполнителя, который не видит ни чата, ни трекера. Всё нужное — в этом файле.
> Смысл каждого правила сохраняется посимвольно по якорям против `origin/main`; меняется язык,
> не содержание. Каждый машинный литерал (обязательные строки, шаблоны сторожа, форматы вывода)
> зафиксирован здесь дословно — копируй, а не придумывай формулировки.

## 0. Инвариант эквивалентности

Набор якорей и адресное пространство правил неизменны; `docs/rule-index.tsv` сохраняет число,
порядок и столбец целей; сторожа остаются зелёными на переведённом дереве. Проверка — машинная:

```bash
# (I1) якоря до и после — множества совпадают; вывод пуст
diff <(git grep -ho 'id="[^"]*"' origin/main -- docs skills templates | sort) \
     <(git grep -ho 'id="[^"]*"'           -- docs skills templates | sort)

# (I2) rule-index.tsv: столбец целей (2-й) байт-в-байт, число и порядок строк прежние; вывод пуст
diff <(git show origin/main:docs/rule-index.tsv | grep -v '^#' | cut -f2) \
     <(grep -v '^#' docs/rule-index.tsv | cut -f2)

# (I3) число правил прежнее (70): CI печатает `rules in index: 70`
```

Разрешено менять в `docs/rule-index.tsv`: комментарий-шапку и 1-й столбец (ключ правила — он
генерируется из заголовка, заголовки переведены). Запрещено: 2-й столбец, порядок строк, число строк.

## 1. Объём перевода

Полный перечень файлов дерева. «Переводим» — всё содержательное текстовое содержимое файла,
включая комментарии кода, шапки, сообщения вывода и frontmatter `description`. «Исключение» —
файл не переводится (и почему). «Пересборка» — файл не правится руками, воспроизводится сборкой.

| Файл | Действие | Почему |
|---|---|---|
| `README.md` | переводим | содержательное содержимое; в том числе блок «Формат правила» (метка `[ревью: …]` → `[review: …]`) |
| `docs/roles.md` | переводим | правила слоя 2 |
| `docs/pipeline.md` | переводим | правила слоя 2 |
| `docs/review-cycle.md` | переводим | правила слоя 2; формат строки счёта уже EN — не трогать |
| `docs/impact-class.md` | переводим | правила слоя 2; значения классов — по глоссарию (§2.3) |
| `docs/ownership.md` | переводим | правила слоя 2 |
| `docs/incidents.md` | переводим | резолвер; якоря `inc-<буква>` и структура таблицы неизменны; заголовки столбцов — по глоссарию |
| `docs/required-checks.md` | переводим | контракт; имя job `check` — литерал, не переводится |
| `docs/adr/0001-three-layer-regulation.md` | переводим | ADR — живой документ, на него ссылается README |
| `docs/adr/0002-public-repository-sanitization.md` | переводим | то же |
| `docs/autopilots/refresh-skills.md` | переводим | команды в блоках кода не переводятся |
| `docs/autopilots/rules-without-incident.md` | переводим | то же |
| `docs/superpowers/plans/2026-09-18-sanitize-pm-workflow.md` | переводим, с оговоркой | завершённый исторический документ, но живёт в дереве и переводится по классу «содержательное содержимое»: проза и таблицы — переводятся. Оговорка: дословные цитаты артефактов-исключений остаются как есть — цитаты словарей `stop-words*.txt` и образцы строк резолвера в блоках кода, встроенные в обратные кавычки формы строк истории (`- Решение: …`, `- Инцидент: …`, «нет карточки; см. …») |
| `docs/rule-index.tsv` | переводим частично | шапка и 1-й столбец (ключи) — по заголовкам правил; 2-й столбец, порядок, число строк — байт-в-байт (инвариант I2) |
| `templates/subtask.md` | переводим | обязательные строки — только литералами из §4.1 |
| `templates/review-report.md` | переводим | строка счёта и `Scorecard:` — литералы, не переводятся; пример строки счёта в комментарии не трогать по содержанию |
| `templates/handoff-comment.md` | переводим | шаблон записи о передаче |
| `skills/agent-runtime-gotchas/SKILL.md` | переводим | включая frontmatter `description`; буквы секций A/B/C в заголовках `## A.`/`## B.`/`## C.` сохраняются (сторож §4.2-6); маркеры пяти строк — только литералами из §4.2 |
| `skills/pm-workflow/SKILL.md` | переводим | включая frontmatter `description`; `name: pm-workflow` не переводится; пути `references/…` не переводятся |
| `skills/pm-workflow/references/*` (10 файлов) | пересборка | копии; после перевода источников — `bash scripts/build-skills.sh`; тождество держит сторож §4.2-19 |
| `scripts/check-rules.sh` | переводим | комментарии, совпадаемые литералы и тексты сообщений — по §4.2; логика проверок не меняется |
| `scripts/build-skills.sh` | переводим | только комментарии (6 строк RU); список PAIRS и вывод уже EN |
| `scripts/parse-score-line.sh` | переводим | только комментарии (8 строк RU); SCORE_RE, сообщения и self-test уже EN — не трогать |
| `.github/workflows/check.yml` | переводим | комментарии (3 строки RU) и человекочитаемое имя шага; `name: check` (job), условия `if:`, имена переменных — не переводятся |
| `scripts/required-lines/subtask.txt` | синхронизация | не «перевод» в смысле смысла, а замена литералов на EN-литералы из §4.1, байт-в-байт с шаблоном |
| `CHANGELOG.md` | исключение + новая запись | история не переписывается; одна новая запись сверху — на английском, формат в §6 |
| `scripts/stop-words.txt` | исключение | функциональный словарь (решение владельца); комментарии в нём остаются RU |
| `scripts/stop-words-allow.txt` | исключение | функциональный словарь; то же |
| `scripts/fixtures/score-line/*.txt` (7 файлов) | исключение | уже EN, байт-в-байт; `git diff origin/main...HEAD -- scripts/fixtures` пуст |
| `docs/superpowers/plans/2026-09-21-translate-en.md` | исключение | этот файл: рабочий документ действующего конвейера, пишется по-русски; после закрытия цикла может переводиться отдельным решением |
| имена файлов, каталогов, якоря `<a id="…">`, имена скиллов, ключи метаданных (`impact_class`, `findings_registry_issue`, …), статусные значения, CLI-литералы, формат строки счёта | исключение | идентификаторы не переводятся |

Контроль полноты: `git diff origin/main...HEAD --name-only` ⊆ объединению строк таблицы.
Файл, не попавший в таблицу, — стоп: вопрос владельцу, самодеятельность запрещена.

## 2. Глоссарий RU→EN

Один термин — один перевод, во всех файлах: docs/, skills/, templates/, сообщения сторожей.
Двух переводов одного термина быть не может. В скобках — запрещённые варианты.

### 2.1. Конвейер и стадии

| RU | EN |
|---|---|
| конвейер | pipeline (conveyor) |
| стадия | stage |
| барьер (стадии) | stage barrier |
| подзадача | subtask (sub-issue) |
| карточка | card |
| родитель | parent |
| промоция | promotion |
| приёмка | acceptance |
| передача стадии | stage handoff |
| исполнитель | executor |
| запасной исполнитель | backup executor |
| прогон | run |
| мёртвый прогон | dead run |
| владелец | owner |
| воркспейс | workspace |
| приватный реестр (воркспейса) | private workspace registry |
| приватный архив | private archive |
| постановка | spec (translation) |
| замер | measurement |
| бриф | brief |
| подагент | subagent |
| гейт | gate |
| трекер | tracker |
| сборка | build |
| доработка (стадия доработки) | remediation (remediation stage) |
| сверка | reconciliation |

### 2.2. Цикл ревью

| RU | EN |
|---|---|
| круг | round (cycle) |
| цикл ревью | review cycle |
| сходимость; до сходимости | convergence; until convergence |
| чистый круг | clean round |
| предел кругов | round limit |
| строка счёта; счётная строка | score line — единый перевод (score string) |
| реестр находок | findings registry |
| находка; подтверждённая находка | finding; confirmed finding |
| коды исключений | exception codes |
| реквизит (решения) | reference (decision reference) |
| предохранитель | circuit breaker (fuse, guard valve) |
| панель | panel |
| конверт круга | round envelope |
| синтез круга | round synthesis |
| пара (агент, вопрос) | (agent, question) pair |
| семейство моделей | model family |
| scorecard | scorecard — уже EN |
| мутация | mutation |
| кейс с островом | island case |
| правило | rule |
| якорь | anchor |
| метка держателя | holder label |
| инцидент | incident |
| резолвер инцидентов | incident resolver |
| симптом | symptom |
| следствие | consequence |
| первичная запись | primary record |
| пересказ | paraphrase |
| пересмотр (кандидат на пересмотр) | revision (candidate for revision) |
| вынос регламента | regulation extraction |
| обезличивание | sanitization |
| слой (0/1/2/3) | layer (0/1/2/3) |
| регламент | regulation |
| сторож (сторож стоп-слов) | guard (stop-word guard) (sentinel, watchdog) |
| обход (рантайма) | workaround (bypass) |
| условие снятия | removal condition |

### 2.3. Классы влияния (значения — новый канонический словарь)

| RU | EN |
|---|---|
| класс влияния | impact class |
| `клиенты` | `customers` |
| `деньги` | `money` |
| `доступность` | `availability` |
| `гигиена` | `hygiene` |

Значения классов — словарь регламента, а не идентификатор: в переведённом дереве каноничны EN
формы; RU формы остаются только в непереводимой истории `CHANGELOG.md` и цитатах §1. Ключ
метаданных `impact_class` не меняется.

### 2.4. Метки держателей `[ревью: …]` → `[review: <роль> @ <точка>]`

Роли уже EN (`PM`, `Reviewer`, `Architect`, `Builder`, `Mechanic`); `владелец` → `owner`.
Точки: создание родителя → parent creation; создание стадии/стадий → stage creation;
пробуждение → wake-up; барьер стадии → stage barrier; барьер стадии кода → code-stage barrier;
барьер стадии аудита → audit-stage barrier; промоция стадии → stage promotion; промоция стадии
кода → code-stage promotion; промоция стадии аудита → audit-stage promotion; закрытие круга →
round closure; синтез круга → round synthesis; сборка панели → panel assembly; круг кода →
code round; комментарий → comment; комментарий приёмки → acceptance comment; комментарий
возобновления → resume comment; приёмка → acceptance; технический вердикт → technical verdict.

### 2.5. Блоки шаблона подзадачи (заголовки, на которые ссылаются правила)

| RU | EN |
|---|---|
| `## Конвейер` | `## Pipeline` |
| `## Цель` | `## Goal` |
| `## Входы` | `## Inputs` |
| `## Что сделать` | `## What to do` |
| `## Что НЕ делается` | `## What is NOT done` |
| `## Что легко испортить` | `## What is easy to break` |
| `## Результат и приёмка` | `## Result and acceptance` |
| `## Запасной исполнитель` | `## Backup executor` |
| `## Отчёт` | `## Report` |
| `## Конверт круга` | `## Round envelope` |
| `## Завершение` | `## Completion` |

Правила `pipeline.md` ссылаются на эти имена блоков текстом — переводить по этой таблице.
Термин вне глоссария, встречающийся больше одного раза, — добавить пару в этот глоссарий тем же
PR (добавлять строки можно, менять существующие — нельзя).

## 3. Что не переводится (полный список классов)

1. Имена файлов и каталогов; структура дерева.
2. Якоря `<a id="…">` во всех файлах; якоря `inc-<буква>`; адрес правила `<файл>#<якорь>`.
3. Имена скиллов (`pm-workflow`, `agent-runtime-gotchas`, `test-guard-discipline`,
   `project-bootstrap-checklist`, `audit-run-hygiene`) и `name:` во frontmatter.
4. Ключи метаданных родителя (`impact_class`, `review_rounds_spec`, `review_rounds_code`,
   `last_round_findings`, `converging`, `findings_registry_issue`, `owner_decision`, `repo`).
5. Формат строки счёта и её литералы: `Round:`, `Stage:`, `Confirmed findings:`, `Failed runs:`,
   `Coverage:`, значения `spec|arch|code`, `full|partial|unknown`; файл `scripts/parse-score-line.sh`
   (регулярка), фикстуры `scripts/fixtures/score-line/*`.
6. Функциональные словари `scripts/stop-words.txt`, `scripts/stop-words-allow.txt` — целиком.
7. История `CHANGELOG.md` (все записи до 2026-09-21 включительно).
8. CLI-литералы (`multica …`, `gh …`, `git …`), команды в блоках кода, статусы
   (`todo/in_progress/in_review/done/backlog/cancelled/blocked`), `failure_reason`-значения,
   коды исключений `accepted-risk`/`spun-out`/`awaiting-owner`, состояние `needs-decision`.
9. Job/step-идентификаторы CI: `name: check`, переменные `STOP_WORDS_PRIVATE`,
   `SANITIZED_HISTORY`, `PR_TITLE`, `PR_BASE_SHA`.
10. Имена моделей и провайдеров (`gpt-5.6-luna`, `glm-5.3`, `grok-4.6`, `gemini-3.7-*`, `Claude`),
    значения `multica runtime usage`.

## 4. Синхронизация сторожей

Сторож правится в том же коммите, что и охраняемый им контент; на голове PR всё зелёное.
Все машинные литералы ниже — дословные.

### 4.1. `scripts/required-lines/subtask.txt` — новый состав, ровно 10 строк

Каждая строка обязана встречаться в `templates/subtask.md` ровно один раз (`grep -cF` == 1,
проверяет check-rules §18; порог `REQUIRED_MIN=10` не меняется):

```
multica issue status <id> done
## What is easy to break
## Report
Subagents: none spawned
Mutations are proven by run, not prediction
`skipped` = 0
Island cases
different from the spec
promised and not delivered
Own misses
```

Соответствие в переведённом шаблоне (куски строк с литералами):

- `## What is easy to break` — заголовок блока стадии кода;
- `## Report` — заголовок блока отчёта;
- `Subagents: none spawned` — первая строка отчёта (блок Report);
- `Mutations are proven by run, not prediction` — начало строки «Мутации проверять прогоном…»
  (EN: `Mutations are proven by run, not prediction: every case is a command and its output.`);
- `` `skipped` = 0 `` — в разделе (1) гейтов;
- `Island cases` — начало строки (2) (EN: `Island cases: case → mutation → run result.`);
- `different from the spec` — в строке (3) (EN: `Where I decided different from the spec, and why.`);
- `promised and not delivered` — в строке (4) (EN: `What was promised and not delivered.`);
- `Own misses` — начало строки (5) (EN: `Own misses. A report without misses is suspicious.`).

Строки `multica issue status <id> done` и `` `skipped` = 0 `` не меняются — они уже EN.

### 4.2. `scripts/check-rules.sh` — перечень правок (логика не меняется)

1. Шапка-комментарии (строки 2–15) — перевести; форматы вызова и предупреждение о
   `STOP_WORDS_PRIVATE` сохранить по смыслу.
2. Режим `--list-no-incident`: awk-шаблон `/^Инцидент: нет/` → `/^Incident: none/`.
3. §2 (метки): регулярка `` `\[(CI: check|ревью: [^]]+ @ [^]]+)\]`$ `` →
   `` `\[(CI: check|review: [^]]+ @ [^]]+)\]`$ ``.
4. §3 (строка «Инцидент:»): `/^Инцидент: /` → `/^Incident: /`; `/^Инцидент: нет$/` →
   `/^Incident: none$/`; текст сообщения — EN, формат `file: rule "%s" has %d "Incident:" lines,
   expected 1` (и аналогично для якорей и malformed).
5. §5 (резолвер): проверка позиционная, не меняется; комментарий-пояснение о столбцах — EN.
6. §6 (структура скилла обходов): литералы маркеров — `- Симптом:` → `- Symptom:`,
   `- Причина:` → `- Cause:`, `- Обход:` → `- Workaround:`, `- Инцидент:` → `- Incident:`,
   `- Условие снятия:` → `- Removal condition:`; заголовки секций обязаны сохранять префиксы
   `## A.` / `## B.` / `## C.` (EN: `## A. Multica platform workarounds`,
   `## B. Runtimes and providers`, `## C. What moved from this skill to layer 2`);
   проверка даты в `- Removal condition:` (YYYY-MM-DD) — без изменений; сообщения — EN.
7. §7 (строка счёта): без изменений — шаблон, пример, фикстуры уже EN.
8. §8 (`multica issue status <id> done`, ровно 1): без изменений.
9. §9 (CHANGELOG) — двуязычный приём: каждая запись обязана иметь по одной строке каждой пары:
   `/^- (Решение|Decision):/`, `/^- (Что изменилось|What changed):/`, `/^- (Инцидент|Incident):/`,
   `/^- (Затронуто|Affected):/`. История остаётся RU и продолжает проходить; новые записи — EN
   литералами из §6. Формат заголовка записи `^## YYYY-MM-DD — <суть>` (EM DASH) — без изменений.
10. §10 (слой 1 без слоя 2): `'решение владельца'` → `'owner decision'`;
    `'предохранител|три кода'` → `'circuit[- ]breaker|three codes'` (ERE, регистронезависимо).
11. Все сообщения `FAIL`/`WARN` скрипта — EN; формат координат `файл:строка` и
    `stop-word <kind>#<n>` — без изменений.
12. Списки `RULE_FILES`, `GOTCHAS`, `INCIDENTS`, `REQUIRED_LINES`, `REQUIRED_MIN=10` — без изменений.
13. Сторож стоп-слов (шаги 0–5) — без изменений: словари не переводятся, логика не трогается.

### 4.3. Прочее

- `scripts/build-skills.sh`: перевести только комментарии; PAIRS и сообщения (`build-skills:
  N files copied…`, `build-skills --check: 10 files identical`) — уже EN, не менять.
- `scripts/parse-score-line.sh`: перевести только комментарии; SCORE_RE, сообщение
  `score line does not match format:`, self-test — не менять.
- `.github/workflows/check.yml`: перевести комментарии env и человекочитаемое имя шага
  `check-rules (внутри — …)` → `check-rules (includes build-skills.sh --check and the stop-word
  guard)`; job `check`, шаг `stop-words in history`, `parse-score-line self-test`, условия `if:` —
  не менять.
- Фикстуры `scripts/fixtures/score-line/*` — не трогаются: они проверяют уже-EN формат строки
  счёта; перевод на них не влияет (подтверждается self-test на PR).

### 4.4. Ожидаемые числа зелёного CI на голове PR

```
stop-words: 0 matches
rules in index: 70
incident rows in resolver: 24
gotchas: section A 13 items, section B 7 items
changelog entries: 16            # 15 исторических + 1 новая (§6)
required lines checked: 10
build-skills --check: 10 files identical
score-line self-test: fixtures 7, passed 7, failed 0, skipped 0
check-rules: 0 errors
```

## 5. Провокации стадии кода (доказательство мутациями, не предсказанием)

Каждая провокация: сломать → красный с ожидаемым текстом → вернуть → зелёный. В отчёт — команда
и вывод каждой. Локально достаточно `bash scripts/check-rules.sh`; приватный словарь не нужен
(WARN допустим).

| # | Мутация | Ожидаемый красный |
|---|---|---|
| P1 | убрать строку `Island cases` из EN `templates/subtask.md` | `required line occurs 0 times in templates/subtask.md (expected 1): Island cases` |
| P2 | оставить старый RU-литерал в `required-lines/subtask.txt` (например `Кейсы с островом`) вместо EN | `required line occurs 0 times … : Кейсы с островом` — доказывает, что список синхронизирован именно с EN-шаблоном |
| P3 | снять метку `[review: …]` с одного заголовка правила в `docs/roles.md` | `label missing on rule heading in docs/roles.md` |
| P4 | заменить `Incident: none` на `No incidents.` у одного правила | `rule "…" incident line malformed: …` |
| P5 | в одном пункте раздела A скилла заменить `- Removal condition:` на `- Removal:` | `A/…: "- Removal condition:" lines = 0` |
| P6 | испортить пример строки счёта в `templates/review-report.md` (например `Coverage: Full`) | `example score line in templates/review-report.md does not parse` |
| P7 | продублировать строку `multica issue status <id> done` в шаблоне | `'multica issue status <id> done' occurs 2 times, expected 1` |
| P8 | добавить EN-запись в CHANGELOG без строки `- Affected:` | `CHANGELOG.md: "- Затронуто/Affected:" = 0`; старые RU-записи при этом остаются зелёными (двуязычный приём §4.2-9) |
| P9 | править `docs/pipeline.md` и не пересобрать references | `build-skills --check: DIFFERS: docs/pipeline.md != …`; после `bash scripts/build-skills.sh` — зелёный |
| P10 | вставить слово `тест` в переведённый файл и прогнать sweep (§7.3) | sweep находит строку; после возврата — пусто |
| P11 | `bash scripts/parse-score-line.sh --self-test` на неизменённых фикстурах | `fixtures 7, passed 7, failed 0, skipped 0` — доказывает, что перевод не задел формат строки счёта |

## 6. Формат новой записи CHANGELOG (английский, сверху файла)

```
## 2026-09-21 — translation of the regulation to English
- Decision: owner, 2026-09-21 (D-10; class `hygiene`; decision on the pipeline parent card for the translation).
- What changed: user-facing content of the tree (docs/, skills/, templates/, guard messages) translated to English; anchors, rule-index targets, skill names, file names, metadata keys, stop-word dictionaries and the score-line format unchanged; guards (check-rules.sh, required-lines, build-skills.sh) synced with the translated templates in the same PR.
- Incident: [N](docs/incidents.md#inc-n).
- Affected: the whole tree.
```

Правила записи:

- Литералы строк: `- Decision:`, `- What changed:`, `- Incident:`, `- Affected:` — по одному,
  в этом порядке (держит check-rules §9 в двуязычной форме §4.2-9).
- `D-10` — следующий свободный номер приватного реестра решений (после D-9); перед мержем
  сверить с приватным реестром: если реестр присвоил другой номер — поправить строку в этом же PR.
- Ссылка на комментарий владельца (UUID) в публичное дерево не попадает — UUID входит в сторож
  стоп-слов; связь «D-N ↔ карточка ↔ комментарий» пишет PM в приватный реестр. Это тот же
  механизм, что у D-1…D-9.
- Заголовок записи: `## YYYY-MM-DD — <суть на английском>`, EM DASH после даты — как в истории.
- История ниже новой записи не меняется ни на символ.

## 7. Критерии приёмки (машинные, с командами)

### 7.1. CI зелёный на голове PR

```bash
gh pr checks <pr>    # одна проверка, без --watch; вывод приложить к отчёту
```

Ожидаемые числа — §4.4.

### 7.2. Инвариант эквивалентности

Команды (I1)–(I3) из §0 — вывод пуст (I1, I2), `rules in index: 70` (I3).
Дополнительно: `git diff origin/main...HEAD -- scripts/fixtures` пуст; в диффе CHANGELOG нет
удалённых или изменённых строк истории:

```bash
git diff origin/main...HEAD -- CHANGELOG.md | grep -c '^-[^-]'   # 0
```

### 7.3. Кириллица вне исключений — 0

Переводимые файлы: всё дерево, кроме `CHANGELOG.md`, `scripts/stop-words.txt`,
`scripts/stop-words-allow.txt`, этого файла. В CI (GNU grep):

```bash
git grep -nP '[А-Яа-яЁё]' -- \
  ':!CHANGELOG.md' \
  ':!scripts/stop-words.txt' \
  ':!scripts/stop-words-allow.txt' \
  ':!docs/superpowers/plans/2026-09-21-translate-en.md'
# пусто, КРОМЕ плана обезличивания; для него отдельная проверка:
awk '/^```/{f=!f; next} !f' docs/superpowers/plans/2026-09-18-sanitize-pm-workflow.md \
  | grep -nP '[А-Яа-яЁё]'
# ожидание: НЕ ноль, а только строки со встроенными цитатами форм строк истории CHANGELOG
# (в плане — §6.3; проверено: строгий шаблон ниже сегодня даёт 2 строки);
# таких строк ≤ 3, каждая содержит одну из цитат: `- Решение:`, `- Инцидент:`,
# `нет карточки; см. …`. Список строк приложить в отчёте. Кириллица в блоках кода
# (цитаты словарей, образцы строк резолвера) допустима без ограничений.
```

Локально на macOS (BSD grep без `-P`) — эквивалент через perl:

```bash
git ls-files | grep -vE '^(CHANGELOG.md|scripts/stop-words.txt|scripts/stop-words-allow.txt|docs/superpowers/plans/2026-09-21-translate-en.md)$' \
  | xargs perl -e 'for my $path (@ARGV) { open my $f, "<", $path or next; while (my $l = <$f>) { print "$path:$.: $l" if $l =~ /[А-Яа-яЁё]/; } close $f; }'
```

### 7.4. Полнота объёма

```bash
git diff origin/main...HEAD --name-only
```
Каждый файл диффа — строка таблицы §1 (переводим / исключение / пересборка / синхронизация).
Файлы-исключения — байт-в-байт с `origin/main` (кроме CHANGELOG: только вставка новой записи сверху).

### 7.5. Провокации

Все мутации P1–P11 из §5 — красные на сломе, зелёные после возврата; команды и вывод — в отчёте.

### 7.6. Руками (аудитор, один круг)

- Смысл каждого правила сохранён: чтение диффа по каждому правилу против `origin/main` — перевод,
  не пересказ и не правка; в диффе файлов правил нет ни одного изменения якоря, метки-формата,
  списка holders, ссылки на инцидент.
- Глоссарий применён последовательно: один термин — один перевод (выборочный поиск синонимов
  по дереву: `git grep -i '<вариант>'` для 5–6 ключевых терминов).
- Глоссарий не расширен противоречиво: добавленные пары не конфликтуют с существующими.

## 8. Порядок работы стадии кода

1. Ветка от свежего `origin/main`; заголовок PR: `docs: translate pm-workflow content to English
   (card 573)` — номер без префикса трекера: префикс трекера — стоп-слово этого репозитория
   (README «Как править»; проверено на стороже: заголовок с префиксом трекера даёт
   `FAIL: stop-word public#1 in PR title`). Коммиты в той же форме `docs: … (card 573)`, без
   стоп-слов в сообщениях. Внимание: не писать префикс трекера с номером НИГДЕ в дереве —
   в том числе как «пример нарушенного» в комментариях и цитатах: сторож литеральный.
   Коммиты агентов несут платформенный трейлер `Co-authored-by` с адресом платформы — он
   совпадает с шаблоном e-mail сторожа; законный токен добавлен в `stop-words-allow.txt`
   (решение §10.8), трейлер не удалять и адрес платформы в содержимое файлов не переносить.
   Шаг CI `stop-words in history` сканирует патчи ВСЕХ коммитов (`git log --all -p`) и авторов
   (`%an %ae %cn %ce`): коммит с личным e-mail автора даёт красный; сторож освобождает только
   форму noreply `<id>+<логин>@users.noreply.github.com` с именем автора, совпадающим с логином.
   Перед коммитами выставить identity через `git config --worktree` (значения — не из этого
   файла: и логин учётной записи, и любая форма e-mail — стоп-слова дерева; id и логин взять
   командой `gh api user --jq '"\(.id)+\(.login)"'`): `user.name` = логин, `user.email` =
   `<id>+<логин>@users.noreply.github.com` (решение В3 плана обезличивания; так подписан
   коммит в `main`). Если стоп-слово попало хотя бы в один промежуточный коммит ветки — новый
   коммит его не вылечит, ветка переписывается до открытия PR (проверено: попадание литерала
   в патч промежуточного коммита дало красный шага истории и потребовало переписать ветку
   одним чистым коммитом). Отдельно: GitHub создаёт авто-merge коммит `refs/pull/<N>/merge`
   от имени автора PR с primary e-mail аккаунта, пока включена настройка «Keep my email
   addresses private» OFF — сторож истории краснеет на таком авторе независимо от содержимого
   ветки; лечение — настройка аккаунта владельца (В3), не правка репозитория.
2. Сторожа и синхронизация: `required-lines/subtask.txt` + `check-rules.sh` (§4.2) +
   комментарии `build-skills.sh` / `parse-score-line.sh` / `check.yml` — одним коммитом с
   шаблонами (§4.1), чтобы не оставлять красное состояние между коммитами необязательно — CI
   смотрит только голову PR, но атомарные пары «шаблон ↔ список литералов» держать вместе.
3. Контент: docs/ → templates/ → skills/ (источники), по глоссарию §2.
4. `docs/rule-index.tsv`: шапка и ключи; столбец целей не трогать.
5. `bash scripts/build-skills.sh`; закоммитить `skills/pm-workflow/references/`.
6. Новая запись CHANGELOG (§6).
7. Sweep (§7.3), инвариант (§7.2), провокации (§5), `rules in index: 70` — локально.
8. PR; `gh pr checks <pr>` один раз без `--watch`; зелёный вывод — в отчёт по форме
   `pipeline.md#builder-report` (первая строка `Subagents: none spawned`).

## 9. Что НЕ делается

- Изменение смысла, объёма или нумерации правил; добавление и удаление правил; правка якорей.
- Перевод идентификаторов (§3), словарей стоп-слов, истории CHANGELOG.
- Переименование файлов, скиллов, job `check`.
- Мерж PR (его делает владелец/PM после аудита), правки branch protection, операции с секретами.
- Любые операции со скиллами Multica (`multica skill refresh` —.ops-стадия конвейера).
- Перевод этого файла и переписывание переведённых исторических цитат в плане обезличивания.

## 10. Решения, принятые постановкой (проверяет аудитор)

1. `docs/rule-index.tsv`: «неизменен» трактован по операционному определению задачи — столбец
   целей, порядок и число строк байт-в-байт; ключи (1-й столбец) и шапка переведены, потому что
   они генерируются из заголовков и без перевода в дереве остаётся кириллица.
2. Заголовок PR: `(card 573)` вместо буквальной формы с префиксом трекера из формулировки
   задачи — доказано на стороже: вариант с префиксом даёт `FAIL: stop-word public#1 in PR
   title`, а префикс трекера в заголовках этого репозитория запрещён README («Как править»,
   п. 1); литерал с префиксом в это дерево не пишется (см. §8.1).
3. Значения классов влияния переведены (`гигиена` → `hygiene` и т.д.) как словарь регламента;
   ключ метаданных `impact_class` не меняется; RU-формы остаются только в истории CHANGELOG.
4. Метка `[ревью: …]` → `[review: …]` с синхронной правкой регулярки check-rules §2 — иначе
   в дереве остаётся кириллица в каждом заголовке правил.
5. Сторож CHANGELOG — двуязычный (§4.2-9): история RU остаётся зелёной, новые записи EN.
6. Реквизит решения в новой записи — дата + `D-10` (сверить с приватным реестром перед мержем);
   UUID комментария владельца в публичное дерево не попадает (сторож стоп-слов).
7. Этот файл — исключение из sweep по кириллице как рабочий документ действующего конвейера.
8. `scripts/stop-words-allow.txt` дополнен адресом платформы из трейлера `Co-authored-by`
   коммитов агентов: адрес совпадает с шаблоном e-mail сторожа, но законен (README «Как
   править», п. 2: законный токен — строка в allow, шаблон не ослаблять). Словарь остаётся
   файлом-исключением перевода; добавленная строка — единственная правка словаря в этом PR.
9. Ветка постановки переписана в один коммит: промежуточные коммиты содержали литерал
   с префиксом трекера в патчах (спецификация документировала провокацию заголовка), шаг
   `stop-words in history` красный на таких патчах навсегда; переписывание — до аудита,
   force-push только собственной ветки постановки, `main` не тронут. Автор коммитов —
   noreply-форма (см. §8.1): личный e-mail из конфига машины сторож истории не пропускает.
