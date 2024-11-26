FROM openjdk:21-jdk-bullseye
SHELL ["/bin/bash", "-c"]

# Instalar dependências
RUN apt-get update && apt-get install -y git cron awscli

# Clonar o repositório
RUN git clone -b feature/BD-AWS https://github.com/SynapSys-SPTECH/Java.git /app

RUN echo "Adicionando logs ao script de gerenciamento de logs"
# Copiar script para gerenciamento de logs
COPY ./manage_logs.sh /app/manage_logs.sh
RUN chmod +x /app/manage_logs.sh

# Configurar o cron para executar o script de logs a cada 10 minutos
RUN echo "*/10 * * * * /app/manage_logs.sh" > /etc/cron.d/manage_logs \
    && chmod 0644 /etc/cron.d/manage_logs \
    && crontab /etc/cron.d/manage_logs

# Diretório de trabalho
WORKDIR /app/target

# Iniciar o cron no início do container
CMD ["bash", "-c", "cron -f && java -jar java-project-synapsys-2.0-SNAPSHOT-jar-with-dependencies.jar"]
