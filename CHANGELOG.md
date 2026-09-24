# CHANGELOG of the regulation

One entry = one owner decision or one reconciliation. Format: a heading `## YYYY-MM-DD — <gist>`, four lines `Decision / What changed / Incident / Affected` (held by `scripts/check-rules.sh`). New entries on top. Entries before 2026-09-21 keep their original Russian field names; new entries use the English ones — the guard accepts exactly one of the two forms per entry. A rule change in substance is not made without an entry here (`README.md`). Entries up to 2026-09-10 are retroactive: there is no comment, the source is the snapshot of the PM instructions in the private archive. A decision reference is the date and `D-N`; the mapping of `D-N` to the card and comment is in the private workspace registry.

## 2026-09-24 — a blocked stage wakes the PM: mention line in the report, wakeup on the stage card
- Decision: owner, 2026-09-24 (D-12; card 592 comment — mapping in the private registry): the owner had to nudge the PM after an executor blocked a stage; the PM must react to a block before the owner sees the problem.
- What changed: new rules `docs/pipeline.md#blocked-mentions-pm` (a `blocked` report carries a PM mention-link) and `docs/pipeline.md#stage-wakeup` (at every promotion the PM sets a continuous `task.completed`/`task.failed` wakeup on the stage sub-issue, disabled at barrier closure); `templates/subtask.md` Report block — the blocked-report line, held by `scripts/required-lines/subtask.txt`; `docs/incidents.md` — incident [Y](docs/incidents.md#inc-y); `docs/rule-index.tsv` — two rows.
- Incident: [Y](docs/incidents.md#inc-y).
- Affected: `docs/pipeline.md`, `docs/incidents.md`, `docs/rule-index.tsv`, `templates/subtask.md`, `scripts/required-lines/subtask.txt`, `skills/pm-workflow/references/` (rebuilt).

## 2026-09-22 — sequential acceptance: the next card is raised on the owner's `done`, not on `in_review`
- Decision: owner, 2026-09-22 (D-11; card 381 comment — mapping in the private registry): the queue of cards raised on `in_review` stacked unaccepted work and caused acceptance errors; roll back to sequential acceptance — one card at a time, accepted by the owner before the next is raised.
- What changed: `docs/pipeline.md#next-card-on-in-review` retitled to sequential acceptance — promote nothing on `in_review`, a run may end with an empty conveyor; the PM leaves an `issue.status_changed` wakeup filtered to the owner on each parent in `in_review`, so the owner's `done` wakes the PM and only then is the next queue card promoted (no parent `in_progress`, `in_review` queue empty); `docs/rule-index.tsv` key updated; the project routing note (layer 3) records the same rollback with a transition regime until the accumulated `in_review` queue drains.
- Incident: none (prevention; the original idle [L](docs/incidents.md#inc-l) is covered by the wakeup).
- Affected: `docs/pipeline.md`, `docs/rule-index.tsv`, `CHANGELOG.md`, the project routing note (layer 3).

## 2026-09-21 — content translated to English
- Decision: owner, 2026-09-21 (D-10; card 448 comment — mapping in the private registry): the regulation is read in agent runs at every round, and Russian text costs roughly twice the English tokens; translate the repository content to English.
- What changed: all content translated (docs/, skills/, templates/, script comments and guard messages, workflow display names); rule-index.tsv keys translated with targets and row order unchanged; guards re-aimed at the English strings (labels, incident lines, gotchas fields, CHANGELOG fields, required lines) — bilingual CHANGELOG check; impact-class values hygiene/money/customers/availability; stop-word dictionaries, score-line format and fixtures, CHANGELOG history, and the 2026-09-18 sanitization plan untouched; stop-word history scan: GitHub-generated test-merge commits exempt from the author check (false-positive fix from the specification PR, see the plan §5.6).
- Incident: none.
- Affected: the whole tree except scripts/stop-words.txt, scripts/stop-words-allow.txt, CHANGELOG history entries, docs/superpowers/plans/2026-09-18-sanitize-pm-workflow.md, scripts/fixtures/.

## 2026-09-18 — обезличивание перед публикацией
- Решение: владелец, 2026-09-18 (D-9; класс `гигиена`; ADR `docs/adr/0002-public-repository-sanitization.md`).
- Что изменилось: идентификаторы карточек и комментариев → буквы инцидентов `inc-<буква>` и реквизиты `D-N`; соответствие буквам, датам и карточкам — в приватном реестре воркспейса; сторож стоп-слов в `scripts/check-rules.sh` (публичные шаблоны `scripts/stop-words.txt` + приватный список секретом CI) вместо проверки резолвинга идентификаторов; публичное дерево переезжает в новый репозиторий одним коммитом, прежний — приватный архив; снимок инструкций PM, исходная постановка о выносе и заметки воркспейса — в приватном архиве и приватном реестре.
- Инцидент: нет карточки; см. [N](docs/incidents.md#inc-n) как запись о выносе.
- Затронуто: всё дерево.

## 2026-09-18 — контракт required checks для branch protection `main`
- Решение: владелец, 2026-09-18 (D-8; В4: branch protection на `main` с required check `check`).
- Что изменилось: список required checks зафиксирован контрактным файлом `docs/required-checks.md` (job `check` · `.github/workflows/check.yml` · required с 2026-09-18); переименование job — правка контракта и branch protection в том же PR.
- Инцидент: [N](docs/incidents.md#inc-n).
- Затронуто: `docs/required-checks.md`, `README.md`.

## 2026-09-18 — правила без инцидента: «кандидат на пересмотр» вместо прежней формулировки об удалении
- Решение: владелец, 2026-09-18 (D-8).
- Что изменилось: правило без инцидента — кандидат на пересмотр, не на удаление; удаляются только правила, которые не используются, и только по согласованию с владельцем. Формулировка заменена во всех местах: `README.md`, `docs/autopilots/rules-without-incident.md`, шаблоны, эта запись.
- Инцидент: [N](docs/incidents.md#inc-n).
- Затронуто: `README.md`, `docs/autopilots/rules-without-incident.md`, заметки воркспейса (в приватном реестре).

## 2026-09-18 — В6 снят: часовой пояс расписаний автопилотов в git не документируется
- Решение: владелец, 2026-09-18 (D-8).
- Что изменилось: `docs/autopilots/*.md` описывают расписание словами («ежедневно ночью», «раз в квартал») без UTC и без `Europe/Kyiv`; пояс настраивается в самом автопилоте при создании (операция 2 постановки).
- Инцидент: [N](docs/incidents.md#inc-n).
- Затронуто: `docs/autopilots/refresh-skills.md`, `docs/autopilots/rules-without-incident.md`.

## 2026-09-18 — В5: бэкфилл приватного реестра по инцидентам B, C, E, F, G
- Решение: владелец, 2026-09-18 (D-8).
- Что изменилось: пять строк в приватном реестре воркспейса с пометкой «пересказ, первичка утрачена»; в приватной таблице соответствий столбец «Первичная запись» этих инцидентов ссылается на строки бэкфилла по файлу и первым словам.
- Инцидент: [N](docs/incidents.md#inc-n).
- Затронуто: `docs/incidents.md`.

## 2026-09-18 — В4: branch protection на `pm-workflow` заводится после мержа PR-1; В3: исключение из превью агентов не вводится
- Решение: владелец, 2026-09-18 (D-8).
- Что изменилось: `docs/required-checks.md` не заводится; required check `check` настраивает владелец после мержа PR-1 (операция владельца, не PR). Исключение из превью перед созданием агентов (В3, предложение PM №5) в регламент не входит.
- Инцидент: [N](docs/incidents.md#inc-n).
- Затронуто: `.github/workflows/check.yml` (job `check` информационный до настройки protection).

## 2026-09-18 — В2: `деньги` как `клиенты`; в первом круге Reviewer обязан включить Architecture Auditor
- Решение: владелец, 2026-09-18 (D-8).
- Что изменилось: строка `деньги` в таблице лимитов = строка `клиенты` (до сходимости, предохранитель 3, без четвёртого круга); новое правило `impact-class.md#money-arch-auditor` `[ревью: PM @ промоция стадии аудита]` — в первом круге по классу `деньги` Reviewer включает Architecture Auditor (`Stage: arch` в строке счёта того прогона). Предложение PM «4 круга + обязательный arch-круг» не принято.
- Инцидент: [N](docs/incidents.md#inc-n).
- Затронуто: `docs/impact-class.md`.

## 2026-09-18 — сверка снимка инструкций PM и файла проекта-источника: канон лимита кругов (В1)
- Решение: владелец, 2026-09-18 (D-8) — подтверждено владельцем 18.09.2026.
- Что изменилось: для `клиенты`/`деньги`/`доступность` действует цикл до сходимости с предохранителем 3 (владелец 2026-08-13): круг с нулём подтверждённых при `Coverage: full` и пустом реестре закрывает цикл — один чистый круг достаточен. «Минимум два круга, если первый нашёл — три» из файла проекта-источника (`docs/engineering/pm-workflow.md` §2.6) упразднено (правится отдельным PR в проект). Нумерация правил 2.1–2.9 упразднена: адрес правила = `<файл>#<якорь>`; в файле проекта-источника номера §2.4–§2.9 остаются заглушками-адресами.
- Инцидент: [N](docs/incidents.md#inc-n).
- Затронуто: `docs/review-cycle.md#closure`, `docs/impact-class.md#limits-table`, `docs/rule-index.tsv`.

## 2026-09-18 — три слоя регламента, вынос в `pm-workflow`
- Решение: владелец, 2026-09-18 (D-7; класс `гигиена`).
- Что изменилось: регламент живёт в `docs/` этого репозитория; заметки воркспейса и `instructions` PM — указатель (текст — в приватном реестре, применяет PM после приёмки); файл проекта-источника `docs/engineering/pm-workflow.md` — проектное + указатель (отдельный PR в проект). Скилл `agent-runtime-gotchas` переехал в `skills/` с условиями снятия; PM получает регламент скиллом `pm-workflow`. Инциденты адресуются резолвером `docs/incidents.md`. У каждого правила метка держателя и строка `Инцидент:`.
- Инцидент: [N](docs/incidents.md#inc-n).
- Затронуто: все файлы `docs/`, `templates/`, `skills/`, `scripts/`, `.github/workflows/check.yml`.

## 2026-09-14 — барьер стадии кода = зелёный CI на голове PR; предмет аудита — весь дифф, включая текст
- Решение: владелец, 2026-09-14 (D-6).
- Что изменилось: стадия кода/механики закрывается только зелёным `gh pr checks` по голове последнего коммита; красное — `blocked` с выводом в отчёте; PM проверяет приложенный вывод, не CI. Докблоки, шапки, сообщения коммитов, заголовок PR — предмет аудита наравне с кодом.
- Инцидент: [H](docs/incidents.md#inc-h).
- Затронуто: `docs/pipeline.md#code-barrier`, `docs/review-cycle.md#audit-subject`.

## 2026-09-12 — класс влияния карточки и предел кругов; `гигиена` — по одному кругу
- Решение: владелец, 2026-09-12 (D-5; «ресурсов мало, решение по таким вопросам принимать раньше»).
- Что изменилось: класс `клиенты`/`деньги`/`доступность`/`гигиена` ставится до промоции стадии 1 — первой строкой «Конвейера» и ключом `impact_class`; для `гигиена` — один круг постановки, один круг кода, доработка одной стадией, остаток → `accepted-risk` с реквизитом = комментарий о классе; предохранитель не применяется.
- Инцидент: [I](docs/incidents.md#inc-i).
- Затронуто: `docs/impact-class.md#classify-first`, `#hygiene`, `#limits-table`; `docs/ownership.md#class-doubt`.

## 2026-09-08 — возобновление работы поднимает исполнителя только упоминанием
- Решение: владелец, 2026-09-08 (D-4; прежний воркспейс, комментария нет; источник — снимок инструкций PM в приватном архиве).
- Что изменилось: смена статуса — запись, не команда; комментарий, возобновляющий работу, обязан упоминать исполнителя `mention://agent/<id>`; порядок — комментарий с упоминанием → `todo` → проверка `multica agent tasks`.
- Инцидент: [G](docs/incidents.md#inc-g).
- Затронуто: `docs/pipeline.md#resume-by-mention`, `#mention-policy`; `skills/agent-runtime-gotchas/SKILL.md#mention-is-run`.

## 2026-08-30 — `Stage: arch` в строке счёта
- Решение: владелец, 2026-08-30 (D-3; прежний воркспейс, комментария нет; источник — снимок инструкций PM в приватном архиве).
- Что изменилось: `arch` — законное значение поля `Stage` (Architecture Auditor), считается кругом стадии постановки; отчёт со `Stage: arch` не возвращается.
- Инцидент: нет карточки; см. [N](docs/incidents.md#inc-n) как запись о сверке.
- Затронуто: `docs/review-cycle.md#score-line`, `scripts/parse-score-line.sh`.

## 2026-08-18 — пара (агент, вопрос) не повторяется два круга подряд
- Решение: владелец, 2026-08-18 (D-2; замер на Sol; прежний воркспейс, комментария нет; источник — скилл `agent-runtime-gotchas` на 18.09.2026).
- Что изменилось: при сборке каждого круга меняется либо агент, либо угол вопроса; через круг пара снова допустима.
- Инцидент: нет карточки; см. [N](docs/incidents.md#inc-n) как запись о сверке.
- Затронуто: `docs/review-cycle.md#panel`.

## 2026-08-13 — закрытие цикла по двум условиям и предохранитель три круга
- Решение: владелец, 2026-08-13 (D-1; прежний воркспейс, комментария нет; источник — снимок инструкций PM в приватном архиве).
- Что изменилось: круг без подтверждённых находок при `Coverage: full` и пустом реестре закрывает цикл; три круга без сходимости — стоп и владелец, четвёртый не начинать; строка счёта — первая строка отчёта Reviewer, посимвольно.
- Инцидент: нет карточки; см. [N](docs/incidents.md#inc-n) как запись о сверке.
- Затронуто: `docs/review-cycle.md#score-line`, `#closure`, `#fuse`.
