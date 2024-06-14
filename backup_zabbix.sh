#!/bin/bash

# Variáveis
DB_NAME="NOME-DO-BANCO"
DB_USER="USER"
DB_PASS="SENHA"
BACKUP_DIR="/home/backup"
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_$(date +%F).sql"
ARCHIVE_FILE="${BACKUP_FILE}.gz"
FTP_SERVER="IP-SERVIDOR"
FTP_USER="USER-FTP"
FTP_PASS="SENHA-FTP"
TELEGRAM_CHAT_ID="XXXX"
TELEGRAM_TOKEN="XXXX"

# Função para enviar notificação para o Telegram
send_telegram_message() {
    local message=$1
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${message}" \
        --header "Content-Type: application/x-www-form-urlencoded; charset=UTF-8"
}

# Criar diretório de backup se não existir
mkdir -p ${BACKUP_DIR}

# Notificar início do backup
send_telegram_message "Iniciando backup do banco de dados ${DB_NAME}."

# Realizar o backup sem bloquear o banco de dados
mysqldump --single-transaction -u${DB_USER} -p${DB_PASS} ${DB_NAME} > ${BACKUP_FILE} &

# Obter o PID do processo mysqldump
DUMP_PID=$!

# Aguardar o término do mysqldump
wait ${DUMP_PID}

# Verificar se o backup foi realizado com sucesso
if [ $? -eq 0 ]; then
    echo "Backup realizado com sucesso."

    # Compactar o arquivo de backup
    gzip ${BACKUP_FILE}

    # Enviar para o servidor FTP
    curl -T ${ARCHIVE_FILE} --user ${FTP_USER}:${FTP_PASS} ftp://${FTP_SERVER}/

    # Verificar se o envio ao FTP foi bem-sucedido
    if [ $? -eq 0 ]; then
        echo "Arquivo enviado ao FTP com sucesso."
        send_telegram_message "Backup e envio ao FTP concluídos com sucesso."
    else
        echo "Falha ao enviar o arquivo ao FTP."
        send_telegram_message "Falha ao enviar o arquivo ao FTP."
    fi
else
    echo "Falha ao realizar o backup."
    send_telegram_message "Falha ao realizar o backup do banco de dados."
fi
