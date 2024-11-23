#!/bin/bash

echo"Entrando na pasta INIT-DB"
cd init-db

echo"Apagando arquivo script-tabelas.sql"
sudo rm script-tabelas.sql

echo"Voltando para pasta raiz da EC2"
cd ..

echo"Parando container de mysql"
sudo docker stop mysql-synapsys

echo"Apagando container de mysql"
sudo docker rm mysql-synapsys

echo"Apagando volumes de containers nao utilizados"
sudo docker volume prune -y 

echo"Criando containers novos, com novo script de mysql"
sudo ./start-containers.sh


echo "Com isto, o container foi reiniciado e criado com a atualização do script"