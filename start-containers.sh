#!/bin/bash

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verificando se o Docker está instalado
if ! command_exists docker; then
    echo "Docker não está instalado. Instalando..."
    sudo apt-get update
    sudo apt-get install -y docker.io
else
    echo "Docker já está instalado."
fi

# Verificando se o Docker Compose está instalado
if ! command_exists docker-compose; then
    echo "Docker Compose não está instalado. Instalando..."
    sudo apt-get install -y docker-compose
else
    echo "Docker Compose já está instalado."
fi

# Função para verificar se um container está em execução
check_container_running() {
  docker ps --filter "name=$1" --format '{{.Names}}' | grep -w "$1" > /dev/null
}

# Função para verificar se um container existe
check_container_exists() {
  docker ps -a --filter "name=$1" --format '{{.Names}}' | grep -w "$1" > /dev/null
}

# Nome dos serviços definidos no docker-compose.yml
service_names=("mysql-synapsys" "node-synapsys" "java-synapsys")

# Loop pelos serviços para verificar se precisam ser construídos ou iniciados
for service in "${service_names[@]}"; do
  if check_container_exists "$service"; then
    echo "O container $service já existe."

    if check_container_running "$service"; then
      echo "O container $service já está em execução."
    else
      echo "Iniciando container $service..."
      sudo docker start "$service"
    fi

  else
    echo "Containers não estão criados! CRIANDO a partir do arquivo docker-compose e iniciando os containers $service..."
    sudo docker-compose build "$service"
    sudo docker-compose up -d "$service"
  fi
done


# Verificando o status dos containers
echo "Verificando o status dos containers..." 
docker-compose ps -a


echo "=--------------------------------------------------------------------------------="
echo "=--------------------------------------------------------------------------------="
echo "Você pode atualizar o container de Node em: Scripts-AWS/atualizar-node-synapsys.sh"
echo "=--------------------------------------------------------------------------------="
echo "=--------------------------------------------------------------------------------="

# Fim do script
echo "Tudo configurado e containers estão em execução!"
