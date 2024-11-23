#!/bin/bash

echo "=----------------------------------------------="
echo "Copiando scripts para pasta principal da EC2"
echo "=----------------------------------------------="
cp -r * ..

cd


echo "=-----------------------------------------------="
echo "Dando permissão de execução para todos os scripts"
echo "=-----------------------------------------------="
sudo chmod +x *.sh

