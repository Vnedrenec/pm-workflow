<!-- Шаблон отчёта Reviewer. Вставляется в тело стадии аудита целиком после строки «Формат отчёта:» (pipeline.md#body-from-template). Первая строка отчёта — строка счёта (review-cycle.md#score-line), вторая — Scorecard (review-cycle.md#scorecard). -->
Round: <N> | Stage: <spec|arch|code> | Confirmed findings: <N> | Failed runs: <M> | Coverage: <full|partial|unknown>
Scorecard: <URL PR в репозитории scorecard, файл data/rows.d/<YYYY-MM-DD>-<task-slug>-<agent-slug>.csv>

<!-- Пример строки счёта, проходящей scripts/parse-score-line.sh (держит CI): Round: 1 | Stage: code | Confirmed findings: 0 | Failed runs: 0 | Coverage: full -->

## Панель
| Агент | Вопрос (question_type) | Подтв. | Ложных | Уник. | Срыв (no/repeat/died) |
|---|---|---|---|---|---|

## Находки (реестр)
| # | Заголовок | Где (путь:строка) | Воспроизведено лично (да/нет, чем) | Состояние (open/closed/needs-decision) | Exception (accepted-risk/spun-out/awaiting-owner + реквизит) | Минимальный факт |
|---|---|---|---|---|---|---|

## Чего машина не проверяет
<…>

## Свои промахи
<…>
