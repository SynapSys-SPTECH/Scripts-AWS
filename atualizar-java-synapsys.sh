#!/bin/bash

# Nome do container Node.js
CONTAINER_NAME="java-synapsys"

# Diretório dentro do container onde o projeto está localizado
PROJECT_DIR="/usr/src/app"

# Verificar se o container está em execução
if docker ps --filter "name=$CONTAINER_NAME" --format '{{.Names}}' | grep -w "$CONTAINER_NAME" > /dev/null; then
    echo "O container $CONTAINER_NAME está em execução. Entrando no container..."
else
    echo "O container $CONTAINER_NAME não está em execução. Por favor, inicie-o antes de rodar este script."
    exit 1
fi

# Comando para executar o git pull dentro do container
echo "Executando 'git pull' no diretório $PROJECT_DIR dentro do container..."
docker exec -it "$CONTAINER_NAME" bash -c "git pull"

# Mensagem de conclusão
echo "Atualização do projeto no container $CONTAINER_NAME concluída!"