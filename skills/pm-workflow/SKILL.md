---
name: pm-workflow
description: Загружай на каждом прогоне по карточке-родителю и на барьере — порядок старта, барьеры, строка счёта, реестр и коды исключений, лимит кругов по классу, шаблоны тел подзадач. Регламент конвейера воркспейса (слой 2); references/ — собранная копия docs/ и templates/ репозитория pm-workflow.
---

Регламент конвейера читать отсюда, не из памяти. `references/` — копия `docs/`, `templates/` и `scripts/parse-score-line.sh` из репозитория `pm-workflow` (ревизия — `CHANGELOG.md` от 2026-09-18; собирает `scripts/build-skills.sh`, тождество держит CI). Править только в `docs/` репозитория через PR; после мержа скилл обновляется `multica skill refresh`. Адрес правила — `<файл>#<якорь>`; инцидент — `references/incidents.md#<якорь>`.

| Ситуация | Читать |
|---|---|
| Новая карточка-родитель: класс, порядок старта, метаданные | `references/impact-class.md` (`#classify-first`), `references/pipeline.md` (`#start-order`, `#metadata-keys`) |
| Любое пробуждение | `references/pipeline.md#children-first`, затем `#barrier-procedure` |
| Создание стадии: роли, кто исполнитель, конфликт интересов | `references/roles.md` |
| Тело подзадачи (любой стадии) | `references/subtask.md` — блоки вставлять дословно (`references/pipeline.md#body-from-template`, `#self-sufficient-body`) |
| Тело стадии кода | `references/pipeline.md`: `#code-stage-body`, `#no-subagents`, `#mutation-by-run`, `#builder-report`, `#backup-executor`, `#one-writer` |
| Тело стадии аудита: конверт, панель | `references/pipeline.md#audit-envelope`, `references/review-cycle.md` (`#panel`, `#one-per-family`), формат отчёта — `references/review-report.md` целиком |
| Отчёт Reviewer пришёл: строка счёта | `bash references/parse-score-line.sh "<первая строка>"`; формат — `references/review-cycle.md#score-line`; `Scorecard:` — `#scorecard` |
| Закрыть или продолжить цикл | `references/review-cycle.md`: `#closure`, `#registry`, `#exception-codes`, `#closure-comment`, `#dead-run-zero`, `#fuse` |
| Сколько кругов допустимо | `references/impact-class.md` (`#limits-table`, `#hygiene`, `#money-arch-auditor`) |
| Стадия закрыта, отчёта Reviewer нет | `references/pipeline.md#synthesis-stage` |
| Барьер стадии кода: CI, мерж, доклад | `references/pipeline.md`: `#code-barrier`, `#merge-and-report`, `#spec-in-commit`, `#pr-slug`, `#comment-with-report` |
| Промоция стадии: запись о передаче | `references/handoff-comment.md`; `references/pipeline.md#handoff-record` |
| Возобновление после `blocked`/решения владельца | `references/pipeline.md#resume-by-mention`, `#mention-policy` |
| Родитель ушёл в `in_review`; следующая карточка | `references/pipeline.md#next-card-on-in-review`; `references/ownership.md#parent-done` |
| Что решает только владелец; scope; исключения; доклад владельцу | `references/ownership.md` |
| Инцидент по букве (`inc-<буква>`: симптом, следствие, правила) | `references/incidents.md` |
| Обходы рантайма (упоминание = прогон, rerun, cancelled, модель) | скилл `agent-runtime-gotchas` |
