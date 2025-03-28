# n8n-installer
An automated script to install n8n (workflow automation tool) on an Ubuntu server. Installs Node.js, n8n, PM2, Nginx, configures HTTPS via Certbot, and secures the server with UFW. Suitable for beginners and advanced users.
# Скрипт установки n8n на сервер / n8n Server Installation Script

## Описание / Description
**Русский**: Этот скрипт автоматизирует установку n8n на сервер Ubuntu. Устанавливает Node.js, n8n, PM2, Nginx, настраивает HTTPS через Certbot и защищает сервер с помощью UFW.  
**English**: This script automates the installation of n8n on an Ubuntu server. It installs Node.js, n8n, PM2, Nginx, configures HTTPS via Certbot, and secures the server with UFW.

---

## Требования / Requirements
**Русский**:  
- Сервер с Ubuntu (рекомендуется 20.04 или 22.04).  
- Доступ к root или sudo.  
- Зарегистрированный домен (например, example.com).

**English**:  
- Ubuntu server (recommended 20.04 or 22.04).  
- Root or sudo access.  
- Registered domain (e.g., example.com).

---

## Установка / Installation
**Русский**:  
1. Скачайте скрипт: нажмите на `n8n-install.sh` → "Download".  
2. Залейте на сервер: используйте `scp n8n-install.sh root@ВАШ_IP:~` или другой способ.  
3. Выполните: 
chmod +x n8n-install.sh
./n8n-install.sh
4. Следуйте подсказкам: введите домен, настройте Certbot (email, согласие, редирект).  
**English**:  
1. Download the script: click on `n8n-install.sh` → "Download".  
2. Upload to your server: use `scp n8n-install.sh root@YOUR_IP:~` or another method.  
3. Run:  
chmod +x n8n-install.sh
./n8n-install.sh
4. Follow the prompts: enter your domain, configure Certbot (email, agreement, redirect).

---

## Результат / Result
**Русский**: n8n доступен по `https://ВАШ_ДОМЕН`.  
**English**: n8n available at `https://YOUR_DOMAIN`.

---

## Автор / Author
Ngulu
