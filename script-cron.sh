#!/bin/bash

# Caminho do script de start do container
SCRIPT_PATH="/home/ubuntu/start-java.sh"
CRON_ENTRY="*/15 * * * * $SCRIPT_PATH >> /var/log/java_cron.log 2>&1"

# Verifica se o cron já contém a entrada
if crontab -l | grep -Fxq "$CRON_ENTRY"; then
    echo "O cron já está configurado com a entrada: $CRON_ENTRY"
else
    echo "Adicionando entrada ao cron..."
    # Faz backup do crontab atual e adiciona a nova entrada
    (crontab -l; echo "$CRON_ENTRY") | crontab -
    echo "Cron configurado com sucesso!"
fi