#!/bin/bash

echo "=----------------------------------------------="
echo "Copiando scripts para pasta principal da EC2"
echo "=----------------------------------------------="
cp -rf * ..

cd ..


echo "=-----------------------------------------------="
echo "Dando permissão de execução para todos os scripts"
echo "=-----------------------------------------------="
sudo chmod +x *.sh

cd Scripts-AWS
git restore .

