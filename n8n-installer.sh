#!/bin/bash
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive

if [ "$EUID" -ne 0 ]; then
    echo "Error: run as root or with sudo. / Запускай от root или через sudo."
    exit 1
fi

INSTALL_DIR="/opt/n8n"

# Выбор языка
echo -e "\e[33mВыберите язык установки / Choose install language:\e[0m"
echo -e "\e[33m1) English\e[0m"
echo -e "\e[33m2) Русский\e[0m"
read -p $'\e[33mВыберите (1 или 2): \e[0m' LANG_CHOICE < /dev/tty

if [ "$LANG_CHOICE" = "1" ]; then
    DOMAIN_PROMPT="Enter your domain (e.g., example.com):"
    INVALID_DOMAIN="Invalid domain format, try again."
    TZ_PROMPT="Timezone (Enter = Etc/UTC, e.g. Europe/London):"
    DOCKER_MSG="Installing Docker..."
    DOCKER_SKIP="Docker already installed, skipping."
    UFW_MSG="Configuring UFW firewall..."
    UFW_SKIP="UFW not found, skipping firewall setup."
    COMPOSE_MSG="Starting containers..."
    COMPOSE_ERROR="Error starting containers"
    NGINX_ERROR="Nginx config test failed"
    RENEW_WARN="Warning: check certificate auto-renewal manually (certbot renew --dry-run)."
    DONE_MSG="Done: https://"
    FILES_MSG="Config files: $INSTALL_DIR (.env contains secrets — keep it safe)"
    CMDS_MSG="Commands: docker compose logs -f n8n | docker compose restart | docker compose pull && docker compose up -d"
else
    DOMAIN_PROMPT="Введите домен (например example.com):"
    INVALID_DOMAIN="Неверный формат домена, попробуй ещё раз."
    TZ_PROMPT="Часовой пояс (Enter = Etc/UTC, пример: Europe/Moscow):"
    DOCKER_MSG="Устанавливаю Docker..."
    DOCKER_SKIP="Docker уже установлен, пропускаю."
    UFW_MSG="Настройка файрвола UFW..."
    UFW_SKIP="UFW не найден, пропускаю настройку файрвола."
    COMPOSE_MSG="Запускаю контейнеры..."
    COMPOSE_ERROR="Ошибка запуска контейнеров"
    NGINX_ERROR="Тест конфигурации Nginx провален"
    RENEW_WARN="Предупреждение: проверь автопродление вручную (certbot renew --dry-run)."
    DONE_MSG="Готово: https://"
    FILES_MSG="Файлы конфига: $INSTALL_DIR (.env содержит пароли — храни в секрете)"
    CMDS_MSG="Команды: docker compose logs -f n8n | docker compose restart | docker compose pull && docker compose up -d"
fi

# ── Домен ─────────────────────────────────────────────
while true; do
    read -p "$DOMAIN_PROMPT " DOMAIN < /dev/tty
    if [[ "$DOMAIN" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}(\.[a-zA-Z0-9][a-zA-Z0-9-]{0,61})*\.[a-zA-Z]{2,}$ ]]; then
        break
    fi
    echo "$INVALID_DOMAIN"
done

read -p "$TZ_PROMPT " TZ_INPUT < /dev/tty
GENERIC_TIMEZONE="${TZ_INPUT:-Etc/UTC}"

# ── Docker Engine + Compose plugin (официальный apt-репозиторий) ──
if ! command -v docker &> /dev/null; then
    echo "$DOCKER_MSG"
    apt update
    apt install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
        || { echo "Docker install failed"; exit 1; }
    systemctl enable --now docker
else
    echo "$DOCKER_SKIP"
fi

# ── UFW ───────────────────────────────────────────────
if command -v ufw &> /dev/null; then
    echo "$UFW_MSG"
    ufw allow OpenSSH
    ufw allow 80
    ufw allow 443
    ufw --force enable
    # Порт 5678 намеренно НЕ открываем — контейнер слушает только 127.0.0.1,
    # доступ снаружи идёт исключительно через Nginx на 443.
else
    echo "$UFW_SKIP"
fi

# ── Секреты и конфиг ─────────────────────────────────
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

POSTGRES_PASSWORD=$(openssl rand -hex 20)
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)

cat > "$INSTALL_DIR/.env" << EOF
DOMAIN=$DOMAIN
GENERIC_TIMEZONE=$GENERIC_TIMEZONE
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY
EOF
chmod 600 "$INSTALL_DIR/.env"

cat > "$INSTALL_DIR/docker-compose.yml" << 'EOF'
services:
  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: n8n
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U n8n"]
      interval: 5s
      timeout: 5s
      retries: 10
    logging:
      driver: "json-file"
      options: { max-size: "10m", max-file: "3" }

  n8n:
    image: docker.n8n.io/n8nio/n8n
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    ports:
      - "127.0.0.1:5678:5678"
    environment:
      N8N_HOST: ${DOMAIN}
      N8N_PROTOCOL: https
      WEBHOOK_URL: https://${DOMAIN}/
      N8N_EDITOR_BASE_URL: https://${DOMAIN}/
      GENERIC_TIMEZONE: ${GENERIC_TIMEZONE}
      TZ: ${GENERIC_TIMEZONE}
      N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS: "true"
      N8N_RUNNERS_ENABLED: "true"
      N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY}
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: n8n
      DB_POSTGRESDB_USER: n8n
      DB_POSTGRESDB_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - n8n_data:/home/node/.n8n
    logging:
      driver: "json-file"
      options: { max-size: "10m", max-file: "3" }

volumes:
  postgres_data:
  n8n_data:
EOF

echo "$COMPOSE_MSG"
docker compose up -d || { echo "$COMPOSE_ERROR"; exit 1; }

# ── Nginx (нативно на хосте) ──────────────────────────
apt install -y nginx
cat << EOF > /etc/nginx/sites-available/n8n
server {
    listen 80;
    server_name $DOMAIN;
    location / {
        proxy_pass http://127.0.0.1:5678;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF
[ -e /etc/nginx/sites-enabled/n8n ] || ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t || { echo "$NGINX_ERROR"; exit 1; }
systemctl restart nginx

# ── Certbot ───────────────────────────────────────────
apt install -y certbot python3-certbot-nginx
certbot --nginx -d "$DOMAIN" --redirect --no-eff-email < /dev/tty
nginx -t || { echo "$NGINX_ERROR"; exit 1; }
systemctl restart nginx
certbot renew --dry-run || echo "$RENEW_WARN"

echo "=================================================="
echo "$DONE_MSG$DOMAIN"
echo "$FILES_MSG"
echo "$CMDS_MSG"
echo "=================================================="
