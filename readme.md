# A primeira coisa que você irá executar na sua ec2, será o git clone https://github.com/SynapSys-SPTECH/Scripts-AWS.git para clonar este repositório na sua máquina.


- Após a clonagem, você poderá criar as suas imagens a partir do script-criacao-imagens.sh, porém, este foi utilizado para configurar as imagens, e depois subir elas no docker hub, facilitando assim, a criação posterior, com o docker compose.

- Portanto, nós poderemos utilizar o nosso docker compose, para criar as imagens sem problemas, a partir do momento que estas imagens estão bem designadas.

## Caso o seu ec2 já tenha os containers criados, você poderá rodar o script start-containers.sh para iniciar todos os que não tiverem sido iniciados.

- Caso queira atualizar as informaçoes de algum dos containers, você pode executar um dos seguintes scripts:

## Para atualizar o projeto front-end
- atualizar-container-node.sh

## Para atualizar o projeto mysql
- ........

## Para atualizar o projeto java
- ........

---

# Quando um container estiver com uma imagem que é a mais recente funcional, você pode atualizar o docker hub utilizando os seguintes comandos:


- sudo docker login 
* deve fazer o processo de login

# Para subir a imagem de node:
- sudo docker tag node-synapsys gavassa/node-synapsys:latest

- sudo docker push gavassa/node-synapsys:latest

# Para subir a imagem de mysql:
- sudo docker tag mysql-synapsys gavassa/mysql-synapsys:latest

- sudo docker push gavassa/mysql-synapsys:latest

# Para subir a imagem de java:
- sudo docker tag java-synapsys gavassa/java-synapsys:latest

- sudo docker push gavassa/java-synapsys:latest

---


