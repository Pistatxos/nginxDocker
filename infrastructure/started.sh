#!/bin/bash

# Actualizar los paquetes e instalar apache2-utils y fail2ban
apt-get update -y
apt-get install -y apache2-utils fail2ban

# Eliminar el archivo de socket si existe
if [ -e /var/run/fail2ban/fail2ban.sock ]; then
    rm -f /var/run/fail2ban/fail2ban.sock
fi

# Configurar htpasswd - -c crea / -b actualiza
htpasswd -c -b /etc/nginx/.htpasswd $HTPASSWD_USER $HTPASSWD_PASS

# Asegurarse de que el directorio de sockets de fail2ban exista y tenga los permisos correctos
mkdir -p /var/run/fail2ban
chmod 755 /var/run/fail2ban

# Iniciar fail2ban
service fail2ban start

# Ejecutar Certbot si se pasa algún comando relacionado con Certbot
if [[ "$1" == "certbot" ]]; then
  shift
  certbot "$@"
else
  # Iniciar Nginx
  nginx -g 'daemon off;'
fi
