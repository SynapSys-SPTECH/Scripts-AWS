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

# Iniciar os serviços com Docker Compose
docker-compose up --build