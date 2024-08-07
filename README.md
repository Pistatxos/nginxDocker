# Nginx con Docker

Proyecto para el uso de nginx con docker y sus extras como htpasswd, fail2ban y Certbot.

Este proyecto configura un servidor Nginx dentro de un contenedor Docker con autenticación básica utilizando `htpasswd`, protección contra ataques de fuerza bruta con `fail2ban`, y generación automática de certificados SSL mediante `certbot`.

## Descripción de Archivos y Directorios

```
nginx_project/
│
├── infrastructure/                    # Carpeta para la infraestructura del proyecto.
│   ├── certbot-conf/                  # Carpeta para la configuración certbot.
│   ├── config_nginx/                  # Carpeta para la configuración de Nginx.
│   │   ├── nginx.conf                 # Archivo principal de configuración de Nginx.
│   │   ├── sites-enabled/             # Carpeta para la configuración de sitios de Nginx.
│   │   │   └── plantillaSSL.conf      # Plantilla de configuración SSL para Nginx.
│   │   ├── PlantillasConf/            # Carpeta para plantillas de configuración.
│   │   │   ├── plantillaSSL.conf      # Plantilla de configuración SSL, completa.
│   │   │   └── plantillaCertBot.conf  # Plantilla de configuración de CertBot.
│   │  
│   ├── fail2ban/                      # Carpeta que contiene la configuración de fail2ban.
│   │   ├── jail.local                 # Configuración específica de jail para Nginx.
│   │   └── nginx-http-auth.conf       # Filtro personalizado para fail2ban.
│   │  
│   ├── ssl/zerossl/                   # Carpeta para almacenar certificados extra, ejemplo ZeroSSL.
│   │  
│   ├── Dockerfile                     # Archivo Docker para construir la imagen personalizada de Nginx.
│   └── started.sh                     # Script para iniciar el servidor.
│  
├── LOGS/                              # Carpeta para almacenar los archivos de log de Nginx.
│   └── nginx/.gitkeep                 # Archivo para mantener el directorio en el control de versiones.
│  
├── .env                               # Archivo para almacenar variables de entorno (no incluido en git).  
├── .env.dist                          # Archivo de ejemplo para las variables de entorno.
├── .gitignore                         # Archivo para ignorar los archivos en Git.  
└── docker-compose.yml                 # Archivo de configuración para Docker Compose.
```


## Configuración y Despliegue

### Prerrequisitos
Tener instalado:
- Docker
- Docker Compose

### Configuración rápida
1. Clona el repositorio.
2. Asegúrate de que la estructura de directorios sea correcta como se muestra arriba.
3. Prepara el archivo de configuración nginx para tu dominio:
  - Puedes usar las plantillas:
    - `plantillaCertBot.conf`: Plantilla para configurar el SSL certbot por primera vez. Reemplazar lo que se comenta el mismo archivo.
    - `plantillaSSL.conf`: Plantilla completa. Para usar con certbot una vez creado los certificados o por si queremos usar certificados descargados tipo ZeroSSL.
4. Asegúrate de que el sitio web tenga conexión vía puerto 80.
5. Antes de ejecutar Nginx, asegúrate de que los sitios que vas a redireccionar estén operativos.
6. Modifica la red del docker-compose con la red que tengas ya en uso en otros contenedores.
7. Revisa el script started.sh por si quieres crear usuarios de acceso. 
8. Ejecutar NGINX desde docker-compose

### Errores varios
 - 502: Bad Gateway nginx
   - Posible error en la dirección, comprobar si conecta por uwsgi o por el backend de requests.
- Permisos:
  - chmod +x ./infrastructure/archivo
  - chmod -R 777 ./carpeta

### Generar Certificado SSL gratuito

#### Certbot

Certbot pertenece a Let's Encrypt.

- **¿Cómo usar certbot?**
  - Primero, carga tu web, luego configura `plantillaCertBot.conf` y arranca nginx. Seguidamente, ejecuta el comando:
    ```
    docker-compose run --rm --entrypoint "certbot certonly --webroot -w /etc/letsencrypt --email tu@email.es --agree-tos --no-eff-email -d dominio.com" certbot
    ```
    * Reemplaza `tu@email.es` con tu dirección de correo electrónico y `dominio.com` con tu dominio.
  - Cuando de el Ok de realizado, ya podrás preparar la plantillassl que es la completa para tener tu redirección a punto.

- **¿Cuándo se actualiza certbot?**
  - Se actualiza automáticamente. Puedes configurar una tarea cron para ejecutar la renovación.

#### ZeroSSL

ZeroSSL ofrece certificados gratuitos (hasta 3).

- **¿Cómo usar ZeroSSL?**
  - Manual:
    - Regístrate en [ZeroSSL](https://zerossl.com)
    - Crea un certificado nuevo:
      - Ve a Certificados / Nuevo certificado / Añade el dominio / 90-Day Certificate / Addons (nada seleccionado) / CSR & Contact: Auto-Generate CSR / Sigue las instrucciones y verifica tu dominio.
    - Descarga los certificados.
    - Crea una carpeta nueva dentro de `/infrastructure/ssl/zerossl/` (para mantener el orden).
    - Guarda en la carpeta los 3 archivos descargados: `certificate.crt`, `private.key` y `ca_bundle.crt`.
    - Configura la ruta en la parte de certificados en el archivo .conf (está comentado donde hay que cambiarlo).

- **¿Cuándo se actualiza ZeroSSL?**
  - Manualmente cada 90 días.


### Despliegue

Una vez cambiado esto, ya podemos construir y levantar los contenedores con Docker Compose:

  ```
  docker-compose up
  ```

El servidor Nginx estará disponible en [http://localhost](http://localhost) y [https://localhost](https://localhost) después de que Certbot genere los certificados SSL.

## Explicación de los Servicios

### Nginx

El servicio Nginx se configura para utilizar autenticación básica con `htpasswd` y está protegido por `fail2ban` para evitar ataques de fuerza bruta. La configuración de Nginx se encuentra en `infrastructure/config_nginx`.

### Certbot

Certbot se utiliza para generar y renovar automáticamente los certificados SSL. La configuración y los certificados se almacenan en `certbot-conf`.

### fail2ban

Fail2ban está configurado para proteger el servicio Nginx contra ataques de fuerza bruta en la autenticación básica. La configuración específica se encuentra en `infrastructure/fail2ban`.

## Uso de autentificación para acceder a una Web con Nginx

Nginx dispone de la opción de login que es útil cuando se instalan contenedores con paneles web sin login.

Para crear las credenciales de acceso usaremos el script `started.sh`.

### Configurar Password
Para configurar usuario y password:

1. Añadir Variables de Entorno:
  - Previamente, añade las variables de entorno en el archivo .env.
  - Si no tienes el archivo, renombra .env.dist a .env.
2. Crear Archivos de Credenciales:
  - Puedes crear varios archivos para diferentes usuarios y contenedores, como por ejemplo .htpasswd o .htpasswd2.
  - En el archivo .env deberás tener las variables de entorno para usuario y password.
3. Editar started.sh:
  - En el started.sh puedes crear los archivos necesarios. Con -c se crea el archivo y con -b se actualizan los datos.
  - Se pueden tener varios usuarios por archivo. Por ejemplo:
    ```
      htpasswd -c -b /etc/nginx/.htpasswd $HTPASSWD_USER $HTPASSWD_PASS
      htpasswd -c -b /etc/nginx/.htpasswd $HTPASSWD_USER3 $HTPASSWD_PASS3
      htpasswd -c -b /etc/nginx/.htpasswd2 $HTPASSWD_USER_2 $HTPASSWD_PASS_2
    ```
4. Configurar Nginx:
  - En el archivo de configuración de Nginx, añade la configuración de autentificación:
    ```
    ## --------- Control de contraseña --------- ## 
    ## *Comenta si no quieres usarlo
    auth_basic "Area Restringida";
    auth_basic_user_file /etc/nginx/.htpasswd;
    ## ---------
    ```
  - Tan solo añade el archivo correspondiente.
5. Ejemplo del archivo .env:
    ```
    HTPASSWD_USER=user1
    HTPASSWD_PASS=password1
    HTPASSWD_USER2=user2
    HTPASSWD_PASS2=password2
    HTPASSWD_USER3=user3
    HTPASSWD_PASS3=password3
    ```

6. Notas de htpasswd para ejecutar desde la terminal (el contenedor en este caso):
 - Para crear archivo con contraseña y usuario
    ```
    sudo htpasswd -c /etc/nginx/.htpasswd tu_usuario
    ```
 - Añadir más usuarios (omitimos -c para no sobrescribir el archivo):
    ```
    sudo htpasswd /etc/nginx/.htpasswd otro_usuario
    ```
- Verificar Archivo de Contraseñas
  ```
  cat /etc/nginx/.htpasswd
  ```
  * El archivo debe contener una línea con el nombre de usuario y la contraseña cifrada.
- Cambiar la contraseña de un usuario ya creado
  ```
  htpasswd /etc/nginx/.htpasswd nombre_de_usuario
  ```
- Para eliminar un usuario:
  ```
  htpasswd -D /etc/nginx/.htpasswd nombre_de_usuario
  ```

### Control de Ataques con fail2ban

Fail2ban ya está preparado en el contenedor. 

#### Configuración accesos
Para configurar los accesos, podemos hacerlo tipo universal para todos o bien por proyectos.
En la parte de `/fail2ban/jail.local`:
  ```
  [auth-proyecto1]
  enabled  = true
  port     = http,https
  filter   = nginx-http-auth
  action   = iptables-multiport[name=auth-proyecto1, port="http,https", protocol=tcp]
  logpath  = /var/log/nginx/error_nombreProyecto.log
            /var/log/nginx/access_nombreProyecto.log
  maxretry = 3
  ```

- El nombre del proyecto podremos cambiarlo a nuestro gusto en el título [auth-proyecto1] y en el `name` del `action`.
- Podremos ir añadiendo tantas configuraciones como webs que queramos controlar. Organiza y cambia el nombre por proyectos.
- logpath: Donde buscará los intentos de conexión lo hará en los `.log` que asociempos en el archivo de configuración del nginx.
- Los intentos máximos en la parte de: `maxretry = 3`.

###### Verificar Usuarios Bloqueados
Para verificar qué usuarios están bloqueados, usa el siguiente comando:
  ```
  docker-compose exec nginx fail2ban-client status auth-proyecto1
  ```
Reemplaza `auth-proyecto1` por el nombre del proyecto y listará las IPs bloqueadas.

#### Desbloquear Usuarios Bloqueados
Si un usuario ha sido bloqueado por error, puedes desbloquearlo con el siguiente comando:
  ```
  docker-compose exec nginx fail2ban-client set auth-proyecto1 unbanip <IP_DEL_USUARIO>
  ```
Reemplaza `<IP_DEL_USUARIO>` con la dirección IP del usuario bloqueado.

###### Verificar log
Para verificar el log, usa el siguiente comando:
  ```
  docker-compose exec nginx tail -f /var/log/fail2ban.log
  ```

