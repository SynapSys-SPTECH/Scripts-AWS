#!/bin/bash

# Parar todos os contêineres em execução
echo "Parando todos os contêineres em execução..."
docker stop $(docker ps -q)

# Remover todos os contêineres
echo "Removendo todos os contêineres..."
docker rm $(docker ps -a -q)

echo "Todos os contêineres foram parados e removidos."