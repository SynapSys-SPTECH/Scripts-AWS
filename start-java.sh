#!/bin/bash

# Nome do container
CONTAINER_NAME="java-synapsys"
LOGDIR="/app/logs"                    # Diretório de logs dentro do container
S3_BUCKET="bucket-synapsys"           # Nome do bucket S3

# Nome do arquivo de log baseado na data e hora atuais
LOG_FILE="jar_log_$(date +'%Y%m%d_%H%M%S').log"

# Verifica se o container já está em execução
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "O container $CONTAINER_NAME já está em execução. Parando e reiniciando..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
fi

# Inicia o container
echo "Iniciando o container com docker-compose..."
docker-compose up --build -d

# Aguarda o container iniciar completamente
sleep 5

# Cria o diretório de logs dentro do container, se não existir
echo "Criando diretório de logs no container..."
docker exec $CONTAINER_NAME mkdir -p "$LOGDIR"

# Executa o comando java -jar dentro do container e redireciona os logs para o arquivo no container
echo "Executando o comando java -jar no container e gerando logs..."
docker exec $CONTAINER_NAME bash -c "java -jar /app/target/java-project-synapsys-2.0-SNAPSHOT-jar-with-dependencies.jar &> $LOGDIR/$LOG_FILE"

# Faz o download do arquivo de log do container para o host
echo "Copiando arquivo de log do container para o host..."
docker cp "$CONTAINER_NAME:$LOGDIR/$LOG_FILE" "./$LOG_FILE"

# Verifica se o arquivo de log foi gerado no host
if [ -f "./$LOG_FILE" ]; then
    echo "Arquivo de log gerado: $LOG_FILE"

    # Faz upload do log para o bucket S3
    echo "Enviando log para o bucket S3..."
    aws s3 cp "./$LOG_FILE" "s3://$S3_BUCKET/logs/"

    if [ $? -eq 0 ]; then
        echo "Log enviado com sucesso para s3://$S3_BUCKET/logs/$LOG_FILE"
    else
        echo "Falha ao enviar o log para o S3." >&2
    fi

    # Remove o arquivo de log local após o upload
    rm -f "./$LOG_FILE"
else
    echo "Erro: Arquivo de log não foi gerado." >&2
fi
