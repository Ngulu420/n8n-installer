# Скрипт установки n8n на сервер / n8n Server Installation Script (Версия 1.0 / Version 1.0)

Установите `n8n` на ваш сервер за пару минут с помощью этого скрипта! / Install `n8n` on your server in minutes with this script!

---

## Описание / Description
**Русский**:  
- Этот скрипт автоматизирует установку `n8n` на сервер `Ubuntu`.

**English**:  
- This script automates the installation of `n8n` on an `Ubuntu` server.

---

## Зависимости / Dependencies
**Русский**:  
- `curl`, `wget`, `Node.js`, `n8n`, `PM2`, `Nginx`, `Certbot`, `UFW`.

**English**:  
- `curl`, `wget`, `Node.js`, `n8n`, `PM2`, `Nginx`, `Certbot`, `UFW`.

---

## Требования / Requirements
**Русский**:  
- Сервер с `Ubuntu` (рекомендуется `20.04` или `22.04`).  
- Доступ к `root` или `sudo`.  
- Зарегистрированный домен (например, `example.com`).

**English**:  
- `Ubuntu` server (recommended `20.04` or `22.04`).  
- `Root` or `sudo` access.  
- Registered domain (e.g., `example.com`).

---

## Запуск скрипта в одну строку / One-Line Script Execution
**Русский**:  
- Выполните одну из команд в терминале вашего сервера:  
  - С использованием `curl`:  
    ```
    bash -c "sudo apt update && sudo apt install -y curl && curl -fsSL https://raw.githubusercontent.com/Ngulu420/n8n-installer/master/n8n-install.sh | bash"
    ```  
  - С использованием `wget`:  
    ```
    bash -c "sudo apt update && sudo apt install -y wget && wget -qO- https://raw.githubusercontent.com/Ngulu420/n8n-installer/master/n8n-install.sh | bash"
    ```

**English**:  
- Run one of the following commands in your server's terminal:  
  - Using `curl`:  
    ```
    bash -c "sudo apt update && sudo apt install -y curl && curl -fsSL https://raw.githubusercontent.com/Ngulu420/n8n-installer/master/n8n-install.sh | bash"
    ```  
  - Using `wget`:  
    ```
    bash -c "sudo apt update && sudo apt install -y wget && wget -qO- https://raw.githubusercontent.com/Ngulu420/n8n-installer/master/n8n-install.sh | bash"
    ```

---

## Установка / Installation
**Русский**:  
- Скачайте скрипт: нажмите на `n8n-install.sh` → "Download".  
- Залейте на сервер: используйте `scp` или другой способ.  
- Сделайте исполняемым и запустите через терминал.  
- Следуйте подсказкам: введите домен, настройте `Certbot` (email, согласие, редирект).

**English**:  
- Download the script: click on `n8n-install.sh` → "Download".  
- Upload to your server: use `scp` or another method.  
- Make it executable and run it via terminal.  
- Follow the prompts: enter your domain, configure `Certbot` (email, agreement, redirect).

---

## Результат / Result
**Русский**:  
- `n8n` доступен по `https://ВАШ_ДОМЕН`.

**English**:  
- `n8n` available at `https://YOUR_DOMAIN`.

---

## Возможные проблемы / Troubleshooting
**Русский**:  
- Если `Certbot` выдает ошибку: убедитесь, что домен указывает на сервер (проверьте `DNS`).  
- Если установка зависает: проверьте интернет-соединение сервера.

**English**:  
- If `Certbot` fails: ensure your domain points to the server (check `DNS`).  
- If installation hangs: verify your server's internet connection.

---

## Дополнительно / Additional Info
**Русский**:  
- Подробнее о `n8n`: [n8n.io](https://n8n.io).

**English**:  
- Learn more about `n8n`: [n8n.io](https://n8n.io).

---

## Автор / Author
`Ngulu`
