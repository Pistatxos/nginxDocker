# Usar la imagen oficial de Nginx como base
FROM nginx:latest

# Actualizar paquetes e instalar apache2-utils, fail2ban y apt-utils
RUN apt-get update && \
    apt-get install -y apt-utils apache2-utils fail2ban iptables && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Entrypoint para iniciar fail2ban y Nginx
ENTRYPOINT ["/usr/local/bin/started.sh"]
