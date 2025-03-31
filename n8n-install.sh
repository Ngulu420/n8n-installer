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
sudo apt update
sudo apt install -y curl wget
while true; do
    echo "--------------------------------------------------"
    echo "Введите ваш домен (например, example.com):"
    read DOMAIN
    echo "--------------------------------------------------"
    if [ -z "$DOMAIN" ]; then
        echo "Домен не введен. Выберите действие:"
        echo "1) Ввести заново"
        echo "2) Выйти"
        read -p "Выберите (1 или 2): " CHOICE
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
sudo apt update && sudo apt upgrade -y
echo "Установка базовых пакетов..."
sudo apt install -y curl git build-essential
echo "Настройка файрвола UFW..."
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 5678
sudo ufw --force enable
sudo ufw status
echo "Установка Node.js 20.x..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
echo "Проверка версий Node.js и npm..."
node -v
npm -v
echo "Установка n8n 1.84.3..."
sudo npm install -g n8n@1.84.3
n8n --version
echo "Установка PM2..."
sudo npm install -g pm2
echo "Запуск n8n через PM2..."
pm2 start n8n
echo "Настройка автозапуска PM2..."
pm2 startup
pm2 save
echo "Проверка работы n8n..."
pm2 list
echo "Установка Nginx..."
sudo apt install -y nginx
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
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
echo "Проверка синтаксиса Nginx..."
sudo nginx -t
echo "Перезапуск Nginx..."
sudo systemctl restart nginx
echo "Установка Certbot..."
sudo apt install -y certbot python3-certbot-nginx
echo "Запуск Certbot для HTTPS с доменом ($DOMAIN)..."
echo "Следуйте инструкциям:"
echo "1. Введите email для уведомлений (например, your@email.com)"
echo "2. Согласитесь с Terms of Service (Y)"
echo "3. Откажитесь от рассылки EFF (N)"
echo "4. Включите редирект HTTP → HTTPS (2)"
sudo certbot --nginx -d "$DOMAIN"
echo "Проверка портов..."
sudo ss -tuln | grep 80
sudo ss -tuln | grep 443
sudo ss -tuln | grep 5678
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
echo "Выход из терминала..."
exit
