#!/bin/bash

# Verificação e instalação do Docker
echo "Verificando se o Docker está instalado..."
if ! [ -x "$(command -v docker)" ]; then
    echo "Docker não está instalado. Instalando Docker..."
    sudo apt update
    sudo apt install -y docker.io
else
    echo "Docker já está instalado. Realizando upgrade..."
    sudo apt update
    sudo apt upgrade -y docker.io
fi

# Verificação e cópia do arquivo SQL
mkdir -p init-db
if [ -f "projeto/bancoProjeto/script-tabelas.sql" ]; then
    echo "Dando Pull e Copiando script-tabelas.sql de projeto/bancoProjeto/script-tabelas.sql para init-db..."
    mkdir -p projeto/bancoProjeto
    cd projeto/bancoProjeto
    rm -rf projeto/bancoProjeto
    git clone https://github.com/SynapSys-SPTECH/Banco-de-Dados.git projeto/bancoProjeto
    git pull
    cp "projeto/bancoProjeto/script-tabelas.sql" ../../init-db/
else
    echo "O arquivo script.sql não foi encontrado. Clonando Repositório de MYSQL-Synapsys."
    mkdir -p projeto/bancoProjeto
    rm -rf projeto/bancoProjeto
    git clone https://github.com/SynapSys-SPTECH/Banco-de-Dados.git projeto/bancoProjeto
    git pull
    cp "projeto/bancoProjeto/script-tabelas.sql" ../../init-db/
fi

cd ../../

# Iniciar os serviços com Docker Compose
docker-compose up --build -d

# Caminho do script a ser executado pelo cron
SCRIPT_PATH="/home/ubuntu/start-java.sh"
CRON_ENTRY="*/10 * * * * $SCRIPT_PATH >> /var/log/java_cron.log 2>&1"

# Verifica se o cron já contém a entrada
if crontab -l | grep -Fxq "$CRON_ENTRY"; then
    echo "O cron já está configurado com a entrada: $CRON_ENTRY"
else
    echo "Adicionando entrada ao cron..."
    # Faz backup do crontab atual e adiciona a nova entrada
    (crontab -l; echo "$CRON_ENTRY") | crontab -
    echo "Cron configurado com sucesso!"
fi