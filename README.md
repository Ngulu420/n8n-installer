# n8n-installer

n8n-installer — автоматическая установка n8n + Postgres в Docker с Nginx и Let's Encrypt.

Простая установка (одна команда)
--------------------------------
Скопируйте и вставьте эту одну строку в терминал на вашем сервере (будет скачан и запущен скрипт как root):

sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Ngulu420/n8n-installer/main/n8n-installer.sh)"

Кратко (RU)
------------
Что делает
- Устанавливает Docker (официальный репозиторий для Ubuntu), создаёт docker-compose с Postgres + n8n, устанавливает nginx как обратный прокси и запускает certbot (Let's Encrypt).
- Генерирует POSTGRES_PASSWORD и N8N_ENCRYPTION_KEY и записывает их в `/opt/n8n/.env`.
- На хосте конфиг в `/etc/nginx/sites-available/n8n` проксирует запросы на `http://127.0.0.1:5678`.

Ключевые моменты текущей версии
- Скрипт интерактивен: выбор языка (EN / RU), ввод домена и часового пояса.
- Certbot запускается интерактивно и читает с `/dev/tty`.
- .env генерируется и перезаписывается при каждом запуске скрипта (если это нежелательно — сделайте резервную копию `/opt/n8n/.env` перед запуском).
- Nginx конфиг настроен на WebSocket-совместимость и имеет базовые таймауты.
- Скрипт ориентирован на Ubuntu/Debian-подобные системы и использует apt.

Требования
- Ubuntu / Debian-подобная система (apt).
- Домен с A/AAAA-записью, указывающей на сервер.
- Root-права (запуск через sudo).
- Порты 80 и 443 должны быть доступны извне для получения сертификата.

Перед запуском — проверки
- Убедитесь, что у домена есть A/AAAA-запись на IP сервера.
- При проблемах с apt (404) — выполните `sudo apt update` и повторите запуск.
- Скрипт запускает интерактивный certbot; если вы хотите полностью автоматизировать, модифицируйте команду certbot внутри скрипта и добавьте `--agree-tos --non-interactive --email "you@example.com"`.

Краткая инструкция по использованию
1. Склонируйте репозиторий (опционально):
   git clone https://github.com/Ngulu420/n8n-installer.git
2. Запустите (рекомендуемый однострочник):
   sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Ngulu420/n8n-installer/main/n8n-installer.sh)"
3. Следуйте подсказкам: язык → домен → часовой пояс.

Точки внимания / отладка
- Если certbot не может получить сертификат: проверьте DNS и доступность портов 80/443 (провайдер может блокировать).
- Если apt падает с 404: выполните `sudo apt update` и перезапустите скрипт.
- Просмотр логов контейнеров:
  - docker compose logs -f n8n
  - docker compose logs -f postgres

Безопасность
- Файл `/opt/n8n/.env` содержит секреты и создаётся с правами 600.
- Если не хотите перезаписывать существующие секреты, создайте резервную копию `/opt/n8n/.env` перед запуском.
- Рекомендуется регулярно бекапить Postgres-том (pg_dump или экспорт тома).

Обновление и бэкап
- Обновить образы:
  docker compose pull && docker compose up -d
- Бекап Postgres (пример):
  docker exec -t <postgres_container> pg_dumpall -c -U n8n > dump_$(date +%F).sql

------------

README (English)
----------------

Quick install (single command)
------------------------------
Copy and paste this single line into your server terminal (it downloads and runs the script as root):

sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Ngulu420/n8n-installer/main/n8n-installer.sh)"

Overview
--------
What it does
- Installs Docker (official repo for Ubuntu), deploys Postgres + n8n using Docker Compose, configures nginx as a reverse proxy and runs certbot (Let's Encrypt).
- Generates POSTGRES_PASSWORD and N8N_ENCRYPTION_KEY and writes them to `/opt/n8n/.env`.
- Nginx on the host proxies to `http://127.0.0.1:5678` (n8n runs bound to localhost).

Current script behavior
- Interactive: language selection (EN/RU), domain and timezone prompts.
- Certbot is run interactively through `/dev/tty`.
- `.env` is generated/overwritten on each run — back it up if you want to preserve secrets.
- Script targets Ubuntu/Debian-like systems (uses apt).

Requirements
- Ubuntu / Debian-like OS
- Domain name pointing to the server
- Root privileges (use sudo)
- Ports 80 and 443 open and reachable from the internet

Before you run
- Make sure your domain has A/AAAA record to your server IP.
- If apt install fails with 404, run `sudo apt update` and re-run the script.
- For non-interactive certbot, modify the certbot call to include `--agree-tos --non-interactive --email "you@example.com"`.

Usage
1. (optional) git clone https://github.com/Ngulu420/n8n-installer.git
2. Run (recommended single-line):
   sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Ngulu420/n8n-installer/main/n8n-installer.sh)"
3. Follow the prompts.

Troubleshooting
- Certbot fails: check DNS and that ports 80/443 are reachable externally.
- apt 404: run `sudo apt update` then retry.
- Check container logs for n8n and postgres with docker compose logs.

Security & backups
- `/opt/n8n/.env` contains secrets; protect and backup it.
- Backup Postgres data regularly (pg_dump or export the docker volume).

