#!/bin/bash
echo "=================================================="
echo "             Ngulu - n8n Установка             "
echo "=================================================="
echo "   ███    ██  ██████  ██    ██ ██      ██    ██  "
echo "   ████   ██ ██       ██    ██ ██      ██    ██  "
echo "   ██ ██  ██ ██   ███ ██    ██ ██      ██    ██  "
echo "   ██  ██ ██ ██    ██ ██    ██ ██      ██    ██  "
echo "   ██   ████  ██████   ██████  ███████  ██████   "
echo "=================================================="
echo "Запуск установки n8n..."
echo "Установка curl и wget..."
apt update
apt install -y curl wget

while true; do
    echo "--------------------------------------------------"
    echo "Введите ваш домен (например, example.com):"
    read DOMAIN < /dev/tty  # Читаем явно с терминала
    echo "--------------------------------------------------"
    echo "DEBUG: DOMAIN сейчас = '$DOMAIN'"  # Отладка
    if [ -z "$DOMAIN" ]; then
        echo "Домен не введен. Выберите действие:"
        echo "1) Ввести заново"
        echo "2) Выйти"
        read -p "Выберите (1 или 2): " CHOICE < /dev/tty
        case $CHOICE in
            1) continue ;;
            2) echo "Выход из скрипта."; exit 0 ;;
            *) echo "Неверный выбор, повторите." ;;
        esac
    else
        echo "Домен принят: $DOMAIN"
        break
    fi
done

echo "Обновление системы..."
apt update && apt upgrade -y
echo "Установка базовых пакетов..."
apt install -y curl git build-essential
echo "Настройка файрвола UFW..."
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw allow 5678
ufw --force enable
ufw status
echo "Установка Node.js 20.x..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
echo "Обновление npm до последней версии..."
npm install -g npm@latest
echo "Проверка версий Node.js и npm..."
node -v
npm -v
echo "Установка последней версии n8n..."
npm install -g n8n@latest
n8n --version
echo "Установка PM2..."
npm install -g pm2
echo "Запуск n8n через PM2..."
pm2 start n8n
echo "Настройка автозапуска PM2..."
pm2 startup
pm2 save
echo "Проверка работы n8n..."
pm2 list
echo "Установка Nginx..."
apt install -y nginx
echo "Создание конфигурации Nginx для домена ($DOMAIN)..."
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
echo "Активация конфигурации Nginx..."
ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
echo "Проверка синтаксиса Nginx..."
nginx -t
echo "Перезапуск Nginx..."
systemctl restart nginx
echo "Установка Certbot..."
apt install -y certbot python3-certbot-nginx
echo "Запуск Certbot для HTTPS с доменом ($DOMAIN)..."
echo "Следуйте инструкциям:"
echo "1. Введите email для уведомлений (например, your@email.com)"
echo "2. Согласитесь с Terms of Service (Y)"
echo "3. Откажитесь от рассылки EFF (N)"
certbot --nginx -d "$DOMAIN" --redirect --no-eff-email
echo "Проверка портов..."
ss -tuln | grep 80
ss -tuln | grep 443
ss -tuln | grep 5678
echo "=================================================="
echo "             Ngulu - Завершение              "
echo "=================================================="
echo "   ███    ██  ██████  ██    ██ ██      ██    ██  "
echo "   ████   ██ ██       ██    ██ ██      ██    ██  "
echo "   ██ ██  ██ ██   ███ ██    ██ ██      ██    ██  "
echo "   ██  ██ ██ ██    ██ ██    ██ ██      ██    ██  "
echo "   ██   ████  ██████   ██████  ███████  ██████   "
echo "=================================================="
echo "Установка завершена! Проверьте: https://$DOMAIN"
exit
