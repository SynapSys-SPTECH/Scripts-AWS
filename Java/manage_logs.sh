#!/bin/bash

# Diretório de logs no container
LOGDIR="/app/logs"
S3_BUCKET="bucket-synapsys"

# Nome do arquivo de log baseado na data e hora atuais
LOG_FILE="jar_log_$(date +'%Y%m%d_%H%M%S').log"

# Cria o diretório de logs se não existir
mkdir -p "$LOGDIR"

# Executa o comando para obter logs do Java (simulado para este exemplo)
# Ajuste este comando conforme a necessidade para capturar logs reais.
java -jar /app/target/java-project-synapsys-2.0-SNAPSHOT-jar-with-dependencies.jar &> "$LOGDIR/$LOG_FILE"

# Verifica se o arquivo de log foi gerado
if [ -f "$LOGDIR/$LOG_FILE" ]; then
    # Envia o arquivo para o bucket S3
    aws s3 cp "$LOGDIR/$LOG_FILE" "s3://$S3_BUCKET/logs/"
    echo "Log enviado para s3://$S3_BUCKET/logs/$LOG_FILE"
else
    echo "Arquivo de log não foi gerado." >&2
fi