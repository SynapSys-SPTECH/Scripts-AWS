#!/bin/bash

# Caminho do script de start do container
SCRIPT_PATH="/home/ubuntu/start-java.sh"
CRON_ENTRY="*/15 * * * * $SCRIPT_PATH >> /var/log/java_cron.log 2>&1"

# Verifica se o cron já contém a entrada
if crontab -l 2>/dev/null | grep -Fxq "$CRON_ENTRY"; then
    echo "O cron já está configurado com a entrada: $CRON_ENTRY"
else
    echo "Adicionando entrada ao cron..."
    # Faz backup do crontab atual e adiciona a nova entrada
    (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
    # Confirma se a entrada foi adicionada
    if crontab -l | grep -Fxq "$CRON_ENTRY"; then
        echo "Cron configurado com sucesso!"
    else
        echo "Falha ao configurar o cron!" >&2
    fi
fi
