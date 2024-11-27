#!/bin/bash

# Nome do container e configurações de log
CONTAINER_NAME="java-synapsys"
LOG_DIR="/home/ubuntu/java-container-logs"
S3_BUCKET="bucket-synapsys"

# Gera um nome de log baseado na data e hora
LOG_FILE="$LOG_DIR/jar_log_$(date +'%Y%m%d_%H%M%S').log"

# Cria o diretório de logs se não existir
mkdir -p "$LOG_DIR"

# Verifica se o container já está em execução
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "O container $CONTAINER_NAME já está em execução. Parando e removendo..."
    docker stop $CONTAINER_NAME >/dev/null 2>&1
    
fi

# Reinicia o container
echo "Iniciando o container $CONTAINER_NAME..."
docker-compose up --build -d $CONTAINER_NAME

# Aguarda o container iniciar corretamente
echo "Aguardando o container iniciar..."
sleep 10

# Executa o comando Java dentro do container e redireciona os logs
echo "Executando o JAR dentro do container e capturando os logs..."
docker exec $CONTAINER_NAME java -jar /app/target/java-project-synapsys-2.0-SNAPSHOT-jar-with-dependencies.jar &> "$LOG_FILE"

# Verifica se o arquivo de log foi gerado
if [ -f "$LOGDIR/$LOG_FILE" ]; then
    echo "Arquivo de log gerado: $LOG_FILE"

    # Envia os logs para o bucket S3
    echo "Enviando logs para o bucket S3..."
    aws s3 cp "$LOG_FILE" "s3://$S3_BUCKET/logs/"
    if [ $? -eq 0 ]; then
        echo "Log enviado com sucesso para s3://$S3_BUCKET/logs/$(basename $LOG_FILE)"
    else
        echo "Erro ao enviar o log para o bucket S3." >&2
    fi
else
    echo "Erro: o arquivo de log não foi gerado." >&2
fi
