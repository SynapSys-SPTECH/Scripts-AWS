#!/bin/bash

# Variáveis de containers e rede
MYSQL_CONTAINER="mysql-synapsys"
NODE_CONTAINER="node-synapsys"
JAVA_CONTAINER="java-synapsys"
NETWORK_NAME="redeSynapsys"

# Variáveis de configuração do MySQL
MYSQL_ROOT_PASSWORD="urubu100"
MYSQL_DATABASE="Synapsys"

# Variáveis de ambiente para o container Java
DB_URL="jdbc:mysql://mysql-synapsys:3306/Synapsys"
DB_USERNAME="root"
DB_PASSWORD="urubu100"
NAME_BUCKET="bucket-synapsys"

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

# Função para verificar se o container existe
function container_exists() {
    docker ps -a --format '{{.Names}}' | grep -Eq "^${1}$"
}

# Criar rede se não existir
if ! docker network ls --format '{{.Name}}' | grep -Eq "^${NETWORK_NAME}$"; then
    echo "Criando rede $NETWORK_NAME..."
    docker network create $NETWORK_NAME
else
    echo "Rede $NETWORK_NAME já existe."
fi

# Verificação e cópia do arquivo SQL
mkdir -p init-db
if [ -f "projeto/bancoProjeto/script-tabelas.sql" ]; then
    echo "Dando Pull e Copiando script-tabelas.sql de projeto/bancoProjeto/script-tabelas.sql para init-db..."
    mkdir -p projeto/bancoProjeto
    cd projeto/bancoProjeto
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

# Criação e verificação do container MySQL
if container_exists $MYSQL_CONTAINER; then
    if docker ps --format '{{.Names}}' | grep -Eq "^${MYSQL_CONTAINER}$"; then
        echo "Container $MYSQL_CONTAINER já está rodando."
    else
        echo "Iniciando container $MYSQL_CONTAINER..."
        docker start $MYSQL_CONTAINER
    fi
else
    echo "Criando e rodando container $MYSQL_CONTAINER..."
    docker run -d \
        --name $MYSQL_CONTAINER \
        --network $NETWORK_NAME \
        -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
        -e MYSQL_DATABASE=$MYSQL_DATABASE \
        -v $(pwd)/init-db:/docker-entrypoint-initdb.d \
        -p 3306:3306 \
        mysql:8.0
    echo "Aguardando MySQL iniciar..."
    sleep 5
fi


# Criação e verificação do container Node
if container_exists $NODE_CONTAINER; then
    if docker ps --format '{{.Names}}' | grep -Eq "^${NODE_CONTAINER}$"; then
        echo "Container $NODE_CONTAINER já está rodando. Atualizando o repositório..."
        sudo ./atualizar-node-synapsys.sh
    else
        echo "Iniciando container $NODE_CONTAINER e atualizando o repositório..."
        docker start $NODE_CONTAINER
    fi
else
    echo "Clonando repositório e configurando container Node..."
    mkdir -p projeto
    rm -rf projeto/Projeto-Synapsys
    git clone -b dev-sprint-3 https://github.com/SynapSys-SPTECH/Site-Institucional.git projeto/Projeto-Synapsys

    cat <<EOF > projeto/Projeto-Synapsys/Dockerfile
FROM node:20

# Define o diretório de trabalho na raiz do projeto
WORKDIR /app

# Instala git e clona o repositório diretamente no Dockerfile
RUN apt-get update && apt-get install -y git && \
    git clone -b dev-sprint-3 https://github.com/SynapSys-SPTECH/Site-Institucional.git .

RUN git pull

# Instala as dependências
RUN npm install

# Exponha a porta necessária
EXPOSE 3333

# Comando de inicialização
CMD ["npm", "start"]
EOF

    # Constrói e executa o container Node
    cd projeto/Projeto-Synapsys
    docker build -t node-synapsys-image .
    docker run -d --name $NODE_CONTAINER --network $NETWORK_NAME -p 3333:3333 node-synapsys-image
fi

# Criação e verificação do container Java
if container_exists $JAVA_CONTAINER; then
    echo "Container $JAVA_CONTAINER já existe. Iniciando..."
    docker start $JAVA_CONTAINER
else
    echo "Configurando container Java..."
    mkdir -p javaProjeto/Synapsys-Java
    sudo rm -rf javaProjeto/Synapsys-Java/*

cat <<EOF > javaProjeto/Synapsys-Java/Dockerfile
FROM openjdk:21-jdk-bullseye
SHELL ["/bin/bash", "-c"]

# Instalar dependências
RUN apt-get update && apt-get install -y git cron awscli

# Clonar o repositório
RUN git clone -b feature/BD-AWS https://github.com/SynapSys-SPTECH/Java.git /app

# Diretório de trabalho
WORKDIR /app/target

# Copiar script para gerenciamento de logs
RUN chmod +x /script-logs/manage_logs.sh

# Configurar o cron para executar o script de logs a cada 10 minutos
RUN echo "*/10 * * * * /script-logs/manage_logs.sh" > /etc/cron.d/manage_logs \
    && chmod 0644 /etc/cron.d/manage_logs \
    && crontab /etc/cron.d/manage_logs

# Iniciar o cron no início do container
CMD ["bash", "-c", "cron -f && java -jar java-project-synapsys-2.0-SNAPSHOT-jar-with-dependencies.jar"]

EOF



    

    cd javaProjeto/Synapsys-Java
    docker build -t script-java .
    docker run -d --name $JAVA_CONTAINER --network $NETWORK_NAME -e DB_URL=$DB_URL -e DB_USERNAME=$DB_USERNAME -e DB_PASSWORD=$DB_PASSWORD script-java
fi

echo "Containers MySQL, Node e Java foram verificados e iniciados (ou criados, se necessário)."
