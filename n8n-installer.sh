#!/bin/bash

# Установка кодировки UTF-8 для корректного отображения текста
export LC_ALL=C.UTF-8

# Выбор языка
echo "Select installation language / Выберите язык установки:"
echo "1) English"
echo "2) Русский"
read -p "Enter your choice (1 or 2): " LANG_CHOICE < /dev/tty

# Определение текстов на двух языках
if [ "$LANG_CHOICE" = "1" ]; then
    # English
    TITLE="Ngulu - n8n Installation"
    START_MSG="Starting n8n installation..."
    CURL_WGET_MSG="Installing curl and wget..."
    DOMAIN_PROMPT="Enter your domain (e.g., example.com):"
    DOMAIN_EMPTY_MSG="Domain not entered. Choose an action:"
    DOMAIN_RETRY="1) Try again"
    DOMAIN_EXIT="2) Exit"
    INVALID_CHOICE="Invalid choice, try again."
    DOMAIN_ACCEPTED="Domain accepted: \$DOMAIN"
    UPDATE_MSG="Updating system..."
    TOOLS_MSG="Installing base packages..."
    UFW_MSG="Configuring UFW firewall..."
    NODEJS_MSG="Installing Node.js 20.x..."
    NPM_UPDATE_MSG="Updating npm to the latest version..."
    VERSION_CHECK_MSG="Checking Node.js and npm versions..."
    N8N_MSG="Installing the latest version of n8n..."
    PM2_MSG="Installing PM2..."
    N8N_START_MSG="Starting n8n via PM2..."
    PM2_SETUP_MSG="Setting up PM2 autostart..."
    N8N_CHECK_MSG="Checking n8n status..."
    NGINX_MSG="Installing Nginx..."
    NGINX_CONFIG_MSG="Creating Nginx configuration for domain (\$DOMAIN)..."
    NGINX_ACTIVATE_MSG="Activating Nginx configuration..."
    NGINX_CHECK_MSG="Checking Nginx syntax..."
    NGINX_RESTART_MSG="Restarting Nginx..."
    CERTBOT_MSG="Installing Certbot..."
    CERTBOT_RUN_MSG="Running Certbot for HTTPS with domain (\$DOMAIN)..."
    CERTBOT_INSTRUCTIONS="Follow the instructions:"
    CERTBOT_EMAIL="1. Enter email for notifications (e.g., your@email.com)"
    CERTBOT_TOS="2. Agree to Terms of Service (Y)"
    CERTBOT_EFF="3. Decline EFF newsletter (N)"
    PORT_CHECK_MSG="Checking ports..."
    END_TITLE="Ngulu - Completion"
    END_MSG="Installation completed! Check: https://\$DOMAIN"
    EXIT_MSG="Exiting script."
else
    # Русский (по умолчанию)
    TITLE="Ngulu - n8n Установка"
    START_MSG="Запуск установки n8n..."
    CURL_WGET_MSG="Установка curl и wget..."
    DOMAIN_PROMPT="Введите ваш домен (например, example.com):"
    DOMAIN_EMPTY_MSG="Домен не введен. Выберите действие:"
    DOMAIN_RETRY="1) Ввести заново"
    DOMAIN_EXIT="2) Выйти"
    INVALID_CHOICE="Неверный выбор, повторите."
    DOMAIN_ACCEPTED="Домен принят: \$DOMAIN"
    UPDATE_MSG="Обновление системы..."
    TOOLS_MSG="Установка базовых пакетов..."
    UFW_MSG="Настройка файрвола UFW..."
    NODEJS_MSG="Установка Node.js 20.x..."
    NPM_UPDATE_MSG="Обновление npm до последней версии..."
    VERSION_CHECK_MSG="Проверка версий Node.js и npm..."
    N8N_MSG="Установка последней версии n8n..."
    PM2_MSG="Установка PM2..."
    N8N_START_MSG="Запуск n8n через PM2..."
    PM2_SETUP_MSG="Настройка автозапуска PM2..."
    N8N_CHECK_MSG="Проверка работы n8n..."
    NGINX_MSG="Установка Nginx..."
    NGINX_CONFIG_MSG="Создание конфигурации Nginx для домена (\$DOMAIN)..."
    NGINX_ACTIVATE_MSG="Активация конфигурации Nginx..."
    NGINX_CHECK_MSG="Проверка синтаксиса Nginx..."
    NGINX_RESTART_MSG="Перезапуск Nginx..."
    CERTBOT_MSG="Установка Certbot..."
    CERTBOT_RUN_MSG="Запуск Certbot для HTTPS с доменом (\$DOMAIN)..."
    CERTBOT_INSTRUCTIONS="Следуйте инструкциям:"
    CERTBOT_EMAIL="1. Введите email для уведомлений (например, your@email.com)"
    CERTBOT_TOS="2. Согласитесь с Terms of Service (Y)"
    CERTBOT_EFF="3. Откажитесь от рассылки EFF (N)"
    PORT_CHECK_MSG="Проверка портов..."
    END_TITLE="Ngulu - Завершение"
    END_MSG="Установка завершена! Проверьте: https://\$DOMAIN"
    EXIT_MSG="Выход из скрипта."
fi

# Начало установки
echo "=================================================="
echo "             $TITLE             "
echo "=================================================="
echo "   ███    ██  ██████  ██    ██ ██      ██    ██  "
echo "   ████   ██ ██       ██    ██ ██      ██    ██  "
echo "   ██ ██  ██ ██   ███ ██    ██ ██      ██    ██  "
echo "   ██  ██ ██ ██    ██ ██    ██ ██      ██    ██  "
echo "   ██   ████  ██████   ██████  ███████  ██████   "
echo "=================================================="
echo "$START_MSG"
echo "$CURL_WGET_MSG"
apt update
apt install -y curl wget

while true; do
    echo "--------------------------------------------------"
    echo "$DOMAIN_PROMPT"
    read DOMAIN < /dev/tty
    echo "--------------------------------------------------"
    echo "DEBUG: DOMAIN сейчас = '$DOMAIN'"
    if [ -z "$DOMAIN" ]; then
        echo "$DOMAIN_EMPTY_MSG"
        echo "$DOMAIN_RETRY"
        echo "$DOMAIN_EXIT"
        read -p "Выберите (1 или 2): " CHOICE < /dev/tty
        case $CHOICE in
            1) continue ;;
            2) echo "$EXIT_MSG"; exit 0 ;;
            *) echo "$INVALID_CHOICE" ;;
        esac
    else
        echo "$(eval echo "$DOMAIN_ACCEPTED")"
        break
    fi
done

echo "$UPDATE_MSG"
apt update && apt upgrade -y
echo "$TOOLS_MSG"
apt install -y curl git build-essential
echo "$UFW_MSG"
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw allow 5678
ufw --force enable
ufw status
echo "$NODEJS_MSG"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
echo "$NPM_UPDATE_MSG"
npm install -g npm@latest
echo "$VERSION_CHECK_MSG"
node -v
npm -v
echo "$N8N_MSG"
npm install -g n8n@latest
n8n --version
echo "$PM2_MSG"
npm install -g pm2
echo "$N8N_START_MSG"
pm2 start n8n
echo "$PM2_SETUP_MSG"
pm2 startup
pm2 save
echo "$N8N_CHECK_MSG"
pm2 list
echo "$NGINX_MSG"
apt install -y nginx
echo "$(eval echo "$NGINX_CONFIG_MSG")"
cat << EOF > /etc/nginx/sites-available/n8n
server {
    listen 80;
    server_name $DOMAIN;
    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
echo "$NGINX_ACTIVATE_MSG"
ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
echo "$NGINX_CHECK_MSG"
nginx -t
echo "$NGINX_RESTART_MSG"
systemctl restart nginx
echo "$CERTBOT_MSG"
apt install -y certbot python3-certbot-nginx
echo "$(eval echo "$CERTBOT_RUN_MSG")"
echo "$CERTBOT_INSTRUCTIONS"
echo "$CERTBOT_EMAIL"
echo "$CERTBOT_TOS"
echo "$CERTBOT_EFF"
certbot --nginx -d "$DOMAIN" --redirect --no-eff-email < /dev/tty
echo "$PORT_CHECK_MSG"
ss -tuln | grep 80
ss -tuln | grep 443
ss -tuln | grep 5678
echo "=================================================="
echo "             $END_TITLE              "
echo "=================================================="
echo "   ███    ██  ██████  ██    ██ ██      ██    ██  "
echo "   ████   ██ ██       ██    ██ ██      ██    ██  "
echo "   ██ ██  ██ ██   ███ ██    ██ ██      ██    ██  "
echo "   ██  ██ ██ ██    ██ ██    ██ ██      ██    ██  "
echo "   ██   ████  ██████   ██████  ███████  ██████   "
echo "=================================================="
echo "$(eval echo "$END_MSG")"
exit
