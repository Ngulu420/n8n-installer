#!/bin/bash

# Установка кодировки / Set encoding
export LC_ALL=C.UTF-8

# Проверка прав root / Check root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error / Ошибка: This script must be run as root or with sudo / Скрипт должен быть запущен с правами root или через sudo."
    exit 1
fi

# Выбор языка / Language selection
echo -e "\e[33mSelect installation language / Выберите язык установки:\e[0m"
echo -e "\e[33m1) English\e[0m"
echo -e "\e[33m2) Русский\e[0m"
read -p $'\e[33mChoose (1 or 2) / Выберите (1 или 2): \e[0m' LANG_CHOICE < /dev/tty

# Определение текстов / Define texts
if [ "$LANG_CHOICE" = "1" ]; then
    TITLE="Ngulu - n8n Installation"
    START_MSG="Starting n8n installation..."
    CURL_WGET_MSG="Installing curl and wget..."
    DOMAIN_PROMPT="Enter your domain (e.g., example.com):"
    DOMAIN_EMPTY_MSG="Domain not entered. Choose an action:"
    DOMAIN_RETRY="1) Try again"
    DOMAIN_EXIT="2) Exit"
    INVALID_CHOICE="Invalid choice, try again."
    INVALID_DOMAIN="Invalid domain format."
    DOMAIN_ACCEPTED="Domain accepted: $DOMAIN"
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
    PORT_ERROR="Error: Port 5678 is already in use."
    NGINX_MSG="Installing Nginx..."
    NGINX_CONFIG_MSG="Creating Nginx configuration for domain $DOMAIN..."
    NGINX_ACTIVATE_MSG="Activating Nginx configuration..."
    NGINX_CHECK_MSG="Checking Nginx syntax..."
    NGINX_RESTART_MSG="Restarting Nginx..."
    CERTBOT_MSG="Installing Certbot..."
    CERTBOT_RUN_MSG="Running Certbot for HTTPS with domain $DOMAIN..."
    CERTBOT_INSTRUCTIONS="Follow the instructions:"
    CERTBOT_EMAIL="1. Enter email for notifications (e.g., your@email.com)"
    CERTBOT_TOS="2. Agree to Terms of Service (Y)"
    CERTBOT_EMAIL_PROMPT="Enter your email for urgent renewal and security notices (or 'c' to cancel):"
    PORT_CHECK_MSG="Checking ports..."
    END_TITLE="Ngulu - Completion"
    # END_MSG больше не используется, заменили прямым выводом
    EXIT_MSG="Exiting script."
    CLEAN_MSG="Cleaning up temporary files..."
else
    TITLE="Ngulu - n8n Установка"
    START_MSG="Запуск установки n8n..."
    CURL_WGET_MSG="Установка curl и wget..."
    DOMAIN_PROMPT="Введите ваш домен (например, example.com):"
    DOMAIN_EMPTY_MSG="Домен не введен. Выберите действие:"
    DOMAIN_RETRY="1) Ввести заново"
    DOMAIN_EXIT="2) Выйти"
    INVALID_CHOICE="Неверный выбор, повторите."
    INVALID_DOMAIN="Неверный формат домена."
    DOMAIN_ACCEPTED="Домен принят: $DOMAIN"
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
    PORT_ERROR="Ошибка: порт 5678 уже занят."
    NGINX_MSG="Установка Nginx..."
    NGINX_CONFIG_MSG="Создание конфигурации Nginx для домена $DOMAIN..."
    NGINX_ACTIVATE_MSG="Активация конфигурации Nginx..."
    NGINX_CHECK_MSG="Проверка синтаксиса Nginx..."
    NGINX_RESTART_MSG="Перезапуск Nginx..."
    CERTBOT_MSG="Установка Certbot..."
    CERTBOT_RUN_MSG="Запуск Certbot для HTTPS с доменом $DOMAIN..."
    CERTBOT_INSTRUCTIONS="Следуйте инструкциям:"
    CERTBOT_EMAIL="1. Введите email для уведомлений (например, your@email.com)"
    CERTBOT_TOS="2. Согласитесь с Terms of Service (Y)"
    CERTBOT_EMAIL_PROMPT="Введите ваш email для уведомлений о продлении и безопасности (или 'c' для отмены):"
    PORT_CHECK_MSG="Проверка портов..."
    END_TITLE="Ngulu - Завершение"
    # END_MSG больше не используется, заменили прямым выводом
    EXIT_MSG="Выход из скрипта."
    CLEAN_MSG="Очистка временных файлов..."
fi

# Установка базовых пакетов / Install base packages
install_base() {
    echo "$UPDATE_MSG"
    apt update || { echo "Failed to update package list / Ошибка обновления списка пакетов"; exit 1; }
    apt upgrade -y || { echo "Failed to upgrade packages / Ошибка обновления пакетов"; exit 1; }
    echo "$TOOLS_MSG"
    apt install -y curl git build-essential || { echo "Failed to install base tools / Ошибка установки базовых пакетов"; exit 1; }
    echo "$CURL_WGET_MSG"
    apt install -y curl wget || { echo "Failed to install curl and wget / Ошибка установки curl и wget"; exit 1; }
}

# Установка Node.js / Install Node.js
setup_node() {
    echo "$NODEJS_MSG"
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - || { echo "Failed to setup Node.js / Ошибка настройки Node.js"; exit 1; }
    apt install -y nodejs || { echo "Failed to install Node.js / Ошибка установки Node.js"; exit 1; }
    echo "$NPM_UPDATE_MSG"
    npm install -g npm@latest || { echo "Failed to update npm / Ошибка обновления npm"; exit 1; }
    echo "$VERSION_CHECK_MSG"
    node -v
    npm -v
}

# Установка n8n и PM2 / Install n8n and PM2
install_n8n() {
    echo "$N8N_MSG"
    npm install -g n8n@latest || { echo "Failed to install n8n / Ошибка установки n8n"; exit 1; }
    n8n --version
    echo "$PM2_MSG"
    npm install -g pm2 || { echo "Failed to install PM2 / Ошибка установки PM2"; exit 1; }
    echo "$N8N_START_MSG"
    if ss -tuln | grep -q ":5678"; then
        echo "$PORT_ERROR"
        exit 1
    fi
    pm2 start n8n || { echo "Failed to start n8n / Ошибка запуска n8n"; exit 1; }
    echo "$PM2_SETUP_MSG"
    pm2 startup || { echo "Failed to setup PM2 autostart / Ошибка настройки автозапуска PM2"; exit 1; }
    pm2 save || { echo "Failed to save PM2 configuration / Ошибка сохранения конфигурации PM2"; exit 1; }
    echo "$N8N_CHECK_MSG"
    pm2 list
}

# Настройка Nginx / Configure Nginx
configure_nginx() {
    echo "$NGINX_MSG"
    apt install -y nginx || { echo "Failed to install Nginx / Ошибка установки Nginx"; exit 1; }
    echo "$NGINX_CONFIG_MSG"
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
    ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/ || { echo "Failed to activate Nginx config / Ошибка активации конфигурации Nginx"; exit 1; }
    echo "$NGINX_CHECK_MSG"
    nginx -t || { echo "Nginx configuration test failed / Тест конфигурации Nginx провален"; exit 1; }
    echo "$NGINX_RESTART_MSG"
    systemctl restart nginx || { echo "Failed to restart Nginx / Ошибка перезапуска Nginx"; exit 1; }
}

# Настройка Certbot / Setup Certbot
setup_certbot() {
    echo "$CERTBOT_MSG"
    apt install -y certbot python3-certbot-nginx || { echo "Failed to install Certbot / Ошибка установки Certbot"; exit 1; }
    echo "$CERTBOT_RUN_MSG"
    echo -e "\e[33m$CERTBOT_INSTRUCTIONS\e[0m"
    echo -e "\e[33m$CERTBOT_EMAIL\e[0m"
    echo -e "\e[33m$CERTBOT_TOS\e[0m"
    echo -e "\e[33m$CERTBOT_EMAIL_PROMPT\e[0m"
    echo -e "\e[33mNote: Type your email carefully to avoid invalid characters / Примечание: Вводите email внимательно, чтобы избежать некорректных символов\e[0m"
    # Примечание: Let's Encrypt имеет лимит 5 сертификатов за 7 дней для одного набора доменов / Note: Let's Encrypt has a limit of 5 certificates per 7 days for the same set of domains
    certbot --nginx -d "$DOMAIN" --redirect --no-eff-email < /dev/tty || { echo "Certbot setup failed / Ошибка настройки Certbot"; exit 1; }
}

# Начало установки / Start installation
echo "=================================================="
echo -e "\e[33m             $TITLE             \e[0m"
echo -e "\e[33m   ███    ██  ██████  ██    ██ ██      ██    ██  \e[0m"
echo -e "\e[33m   ████   ██ ██       ██    ██ ██      ██    ██  \e[0m"
echo -e "\e[33m   ██ ██  ██ ██   ███ ██    ██ ██      ██    ██  \e[0m"
echo -e "\e[33m   ██  ██ ██ ██    ██ ██    ██ ██      ██    ██  \e[0m"
echo -e "\e[33m   ██   ████  ██████   █████R  ███████  ██████   \e[0m"
echo "=================================================="
echo -e "\e[36m$START_MSG\e[0m"

# Настройка файрвола / Configure firewall
echo "$UFW_MSG"
ufw allow OpenSSH || { echo "Failed to configure UFW / Ошибка настройки UFW"; exit 1; }
ufw allow 80 || { echo "Failed to configure UFW / Ошибка настройки UFW"; exit 1; }
ufw allow 443 || { echo "Failed to configure UFW / Ошибка настройки UFW"; exit 1; }
ufw allow 5678 || { echo "Failed to configure UFW / Ошибка настройки UFW"; exit 1; }
ufw --force enable || { echo "Failed to enable UFW / Ошибка включения UFW"; exit 1; }
ufw status

# Запрос домена / Domain prompt
while true; do
    echo "--------------------------------------------------"
    echo -e "\e[33m$DOMAIN_PROMPT\e[0m"
    read DOMAIN < /dev/tty
    echo "--------------------------------------------------"
    echo "DEBUG: DOMAIN сейчас = '$DOMAIN'"
    if [ -z "$DOMAIN" ]; then
        echo -e "\e[33m$DOMAIN_EMPTY_MSG\e[0m"
        echo -e "\e[33m$DOMAIN_RETRY\e[0m"
        echo -e "\e[33m$DOMAIN_EXIT\e[0m"
        read -p "Выберите (1 или 2): " CHOICE < /dev/tty
        case $CHOICE in
            1) continue ;;
            2) echo "$EXIT_MSG"; exit 0 ;;
            *) echo "$INVALID_CHOICE" ;;
        esac
    elif ! [[ "$DOMAIN" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}(\.[a-zA-Z0-9][a-zA-Z0-9-]{0,61})*\.[a-zA-Z]{2,}$ ]]; then
        echo -e "\e[33m$INVALID_DOMAIN\e[0m"
        continue
    else
        echo "$DOMAIN_ACCEPTED"
        break
    fi
done

# Установка компонентов / Install components
install_base
setup_node
install_n8n
configure_nginx
setup_certbot

# Проверка портов / Check ports
echo "$PORT_CHECK_MSG"
ss -tuln | grep 80
ss -tuln | grep 443
ss -tuln | grep 5678

# Очистка / Cleanup
echo "$CLEAN_MSG"
apt autoremove -y && apt clean || { echo "Failed to clean up / Ошибка очистки"; exit 1; }

# Завершение / Completion
echo "=================================================="
echo -e "\e[33m             $END_TITLE             \e[0m"
echo -e "\e[33m   ███    ██  ██████  ██    ██ ██      ██    ██  \e[0m"
echo -e "\e[33m   ████   ██ ██       ██    ██ ██      ██    ██  \e[0m"
echo -e "\e[33m   ██ ██  ██ ██   ███ ██    ██ ██      ██    ██  \e[0m"
echo -e "\e[33m   ██  ██ ██ ██    ██ ██    ██ ██      ██    ██  \e[0m"
echo -e "\e[33m   ██   ████  ██████   ██████  ███████  ██████   \e[0m"
echo "=================================================="
if [ "$LANG_CHOICE" = "1" ]; then
    echo -e "\e[36mInstallation completed! Check: https://$DOMAIN\e[0m"
else
    echo -e "\e[36mУстановка завершена! Проверьте: https://$DOMAIN\e[0m"
fi
exit 0
