# Контракт required checks — branch protection `main`

Правило воркспейса: список required checks — контрактный файл в репозитории, не память PM и не настройка в UI GitHub сама по себе. Этот файл — единственный источник истины о том, какие job обязаны быть зелёными до мержа в `main` `pm-workflow`. Branch protection на `main` включена владельцем 2026-09-18 (решение В4, D-8).

| job | workflow-файл | что проверяет | с какой даты required |
|---|---|---|---|
| `check` | `.github/workflows/check.yml` | `scripts/check-rules.sh` (внутри — `scripts/build-skills.sh --check` и сторож стоп-слов; шаг `--history` — по переменной `SANITIZED_HISTORY`) + `scripts/parse-score-line.sh --self-test` | 2026-09-18 |

Переименовал job — правь этот контракт в том же PR и настройку branch protection (required status checks на `main`) до мержа: GitHub сверяет имя job буквально, и PR с переименованным job либо не мержится, либо — если старое имя забыли снять — мержится без проверки. Добавил или убрал required check — та же процедура: строка в таблице, настройка branch protection, один PR.
