# pm-workflow

Регламент воркспейса конвейера агентов: роли, конвейер, цикл ревью, классы влияния, владение, шаблоны. Источник истины для заметок воркспейса Multica и скиллов PM. Решения — `docs/adr/0001-three-layer-regulation.md` (три слоя), `docs/adr/0002-public-repository-sanitization.md` (публичный репозиторий без внутренней кухни); постановка о выносе регламента — в приватном архиве, постановка об обезличивании — `docs/superpowers/plans/2026-09-18-sanitize-pm-workflow.md`.

## Карта слоёв

| Слой | Что | Где живёт | Кто правит | Как доставляется |
|---|---|---|---|---|
| 0 | платформа Multica: системные инструкции, рантайм-бриф | продукт | никто из воркспейса | автоматически, каждый прогон |
| 1 | обходы рантайма, каждый с условием снятия | `skills/agent-runtime-gotchas/SKILL.md` | PR сюда | `multica skill import --url … --on-conflict overwrite` один раз, дальше `multica skill refresh <id>` (автопилот после мержа) |
| 2 | регламент конвейера: `docs/roles.md`, `docs/pipeline.md`, `docs/review-cycle.md`, `docs/impact-class.md`, `docs/ownership.md`, `templates/`, `CHANGELOG.md` | `docs/`, `templates/` — канон; `skills/pm-workflow/references/` — собранная копия, тождество держит CI | PR сюда; изменение по существу — только с записью в `CHANGELOG.md` и решением владельца | PM — скилл `pm-workflow`; аудиторы и билдеры — блоки шаблонов, вставленные в тело подзадачи; Architect — строка «читать» в теле; владелец — git |
| 3 | проектное: трекер проекта, машина, выкладка, секреты, контракт required checks | репозиторий проекта (файл регламента проекта, напр. `docs/engineering/pm-workflow.md`, `AGENTS.md`) | PR в проект | как раньше |

Зависимости только сверху вниз: слой 2 не переопределяет слой 0. Текст для заметок воркспейса и `instructions` PM — в приватном реестре воркспейса (применяет PM после приёмки владельцем). Снимок `instructions` PM до выноса — в приватном архиве (точка отката).

## Формат правила

Одно правило — один заголовок `###` с меткой держателя в конце, один якорь `<a id="…">`, строка `Инцидент:`:

```markdown
### <Имя правила> `[ревью: PM @ барьер стадии]`
<a id="code-barrier"></a>

<Текст: что делает кто и когда; что считается нарушением.>

Инцидент: [H](incidents.md#inc-h) — решение владельца 2026-09-14.
```

Метка — одна из двух: `[CI: check]` (держит `scripts/check-rules.sh` в job `check`) или `[ревью: <роль> @ <точка>]`, роль ∈ {PM, Reviewer, Architect, владелец}. Третьего нет; правило без держателя не существует. Метка меняется тем же PR, что и проверка. Адрес правила — `<файл>#<якорь>`, сквозных номеров нет; индекс — `docs/rule-index.tsv`. Формат пункта слоя 1 (пять строк: Симптом / Причина / Обход / Инцидент / Условие снятия) — в самом `skills/agent-runtime-gotchas/SKILL.md`.

## Правило без инцидента — кандидат на пересмотр

Строка `Инцидент: нет` допустима, но такое правило — кандидат на пересмотр (список: `bash scripts/check-rules.sh --list-no-incident`; раз в квартал его поднимает автопилот, `docs/autopilots/rules-without-incident.md`). Удаляются только правила, которые не используются, и только по согласованию с владельцем — записью в `CHANGELOG.md`. Решение владельца 2026-09-18 (D-8).

## Как ссылаться на инцидент

`docs/incidents.md` — публичный резолвер: якорь `inc-<буква>` → буква → симптом → следствие → правила. Из `docs/*.md` — `incidents.md#inc-b`; из `README.md`/`CHANGELOG.md` — `docs/incidents.md#inc-b`; из скилла — текстом `docs/incidents.md#inc-b`. Идентификаторов карточек трекера, комментариев, людей и проектов в публичном дереве нет — их держит сторож (`scripts/check-rules.sh`, критерий «стоп-слова»). Соответствие буквы карточке, дате и первичной записи, а реквизита решения владельца `D-N` — карточке и комментарию хранится в приватном реестре воркспейса (`pm-workflow/incidents-private.md` там), вне этого репозитория.

Новый инцидент — новая буква (следующая по алфавиту; после `Z` — `AA`) и две строки: публичная здесь (симптом · следствие · правила, без стоп-слов) и приватная в реестре (карточка, дата, первичная запись). Новое решение владельца — новый `D-N`: публично дата и номер в `CHANGELOG.md`, приватно карточка и комментарий. Новое имя (проект, агент, человек, репозиторий) — строка в приватный словарь стоп-слов и обновление секрета `STOP_WORDS_PRIVATE` (см. «Как править»).

## Как править

1. PR в этот репозиторий; заголовок — со слагом карточки в форме номера без префикса трекера: `<type>(<scope>): <суть> (card N)` (правило `pipeline.md#pr-slug`; форма слага — конвенция этого репозитория: префикс трекера — стоп-слово). CI (`.github/workflows/check.yml`, job `check`) гоняет `scripts/check-rules.sh` (критерии постановки, внутри — `scripts/build-skills.sh --check` и сторож стоп-слов) и `scripts/parse-score-line.sh --self-test`.
2. Сторож стоп-слов: публичные структурные шаблоны — `scripts/stop-words.txt` (идентификаторы карточек, UUID, e-mail, URL GitHub, ссылки `владелец/репозиторий#N`), разрешённые исключения — `scripts/stop-words-allow.txt`; приватный литеральный список подаётся в CI секретом `STOP_WORDS_PRIVATE` (локально — `STOP_WORDS_PRIVATE_FILE=<путь> bash scripts/check-rules.sh --show`). Сторож проверяет дерево, имена файлов, заголовок PR и сообщения коммитов диапазона; в CI печатает только `файл:строка` и номер шаблона. Законный токен покраснел — строка в `stop-words-allow.txt`, шаблон не ослаблять. Новое имя — строка в приватный список и `gh secret set STOP_WORDS_PRIVATE -R <владелец>/<репозиторий> < <приватный список>`.
3. Правишь `docs/` или `templates/` — запускаешь `bash scripts/build-skills.sh` и коммитишь `skills/pm-workflow/references/`; руками `references/` не править.
4. Изменение правила по существу — запись в `CHANGELOG.md` (формат там) со ссылкой на решение владельца; без записи — не менять.
5. После мержа скиллы обновляет автопилот `pm-workflow: refresh skills` (`docs/autopilots/refresh-skills.md`) командой `multica skill refresh`. `multica skill update` для скиллов из `skills/` запрещён; расхождение `content_hash` с `main` при refresh — инцидент.

## Дерево

`docs/` — правила слоя 2, `docs/incidents.md`, `docs/rule-index.tsv`, `docs/required-checks.md` (контракт required checks для branch protection `main`), `docs/adr/`, `docs/autopilots/`, `docs/superpowers/plans/`; `templates/subtask.md`, `templates/review-report.md`, `templates/handoff-comment.md`; `skills/agent-runtime-gotchas/`, `skills/pm-workflow/` (+ `references/`); `scripts/check-rules.sh`, `scripts/build-skills.sh`, `scripts/parse-score-line.sh`, `scripts/stop-words.txt`, `scripts/stop-words-allow.txt`, `scripts/required-lines/subtask.txt`, `scripts/fixtures/score-line/`; `.github/workflows/check.yml`; `CHANGELOG.md`.
