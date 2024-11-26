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