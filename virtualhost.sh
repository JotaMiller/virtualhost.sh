#!/bin/bash

# Nombre de usuario utilizado en caso de que trabaje directamente con su directorio
USER=''

#si/no en caso de que el usuario cuente con directorio personal o bien, si utiliza directamente /var/www/...
DIRECTORIO_USUARIO=''

# Ruta de archivos
RUTA=''

# Determina si se debe o no crear el directorio
EXISTE_DIRECTORIO=''

# Nombre de dominio
DOMINIO=''

#Representa la extensión que el usuario le quera dar al dominio, Ej: .dev, .local
EXT_DOMINIO=''



echo -n "Tiene un directorio 'public_html' personal? (Y/n): "
read DIRECTORIO_USUARIO
DIRECTORIO_USUARIO=${DIRECTORIO_USUARIO^^}

# En caso de que cuente con directorio personal
if [ $DIRECTORIO_USUARIO == "Y" ] 
then
  while : ;
  do
    echo -n "Ingrese su nombre de usuario: "
    read USER
    if [ -d /home/$USER ]; then
      RUTA="/home/$USER/public_html/"
      break
    else
      echo "$USER no es un nombre de usuario válido"
    fi
  done
else
  RUTA='/var/www/'
fi


# Nombre de dominio
echo -n "Ingrese el nombre de dominio a crear: "
read DOMINIO

#extensión dominio
echo -n "Extensión (Ej: dominio.dev, dominio.local, etc): "
read EXT_DOMINIO

# Crear directorio
echo -n "La ruta '$RUTA$DOMINIO' existe? (Y/n)"
read EXISTE_DIRECTORIO
EXISTE_DIRECTORIO=${EXISTE_DIRECTORIO^^}

# Seleccionar tipo de proyecto
echo "¿Que tipo de proyecto esta creando?"
echo " 1 - Estandar"
echo " 2 - Symfony2"
read TIPO_PROYECTO

# Resumen y confirmación
echo ""
echo ""
echo "# Resumen de tareas a realizar #"
echo " - Se registrara el siguiente dominio: $DOMINIO.$EXT_DOMINIO"
echo " - Apuntara a la ruta: $RUTA$DOMINIO"
if [[ $EXISTE_DIRECTORIO == "N" ]]; then
  echo " - Se creara el directorio '$RUTA$DOMINIO'"
fi
echo ""
echo -n "La información esta corecta? (Y/n): "
read PROCEDER
PROCEDER=${PROCEDER^^}

if [[ $PROCEDER == "Y" ]]; then
  
  echo "Configurando dominio "$DOMINIO
     
  #CREAMOS LA ENTRADA EN /ETC/HOSTS
  echo "127.0.0.1 "$DOMINIO.$EXT_DOMINIO >> /etc/hosts
     
  #CREAMOS EL ARCHIVO DE VIRTUAL HOST
  touch /etc/apache2/sites-available/$DOMINIO.conf
     
  #AGREGAMOS EL VIRTUAL HOST
  case $TIPO_PROYECTO in
    1)
      echo "<VirtualHost *:80>
    ServerName $DOMINIO.$EXT_DOMINIO

    ServerAdmin webmaster@localhost
    DocumentRoot $RUTA$DOMINIO

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    
  </VirtualHost>" > /etc/apache2/sites-available/$DOMINIO.conf
    ;;
    2)
      echo "<VirtualHost *:80>
  ServerName      $DOMINIO.$EXT_DOMINIO
  ServerAlias     www.$DOMINIO.$EXT_DOMINIO

  SetEnv SYMFONY__DATABASE__USER     \"...\"
  SetEnv SYMFONY__DATABASE__PASSWORD \"...\"

  DocumentRoot    \"$RUTA$DOMINIO/web\"
  DirectoryIndex  app.php

  <Directory \"$RUTA$DOMINIO/web\">
    AllowOverride None
    Allow from All

    <IfModule mod_rewrite.c>
      Options -MultiViews
      RewriteEngine On
      RewriteCond %{REQUEST_FILENAME} !-f
      RewriteRule ^(.*)$ app.php [QSA,L]
    </IfModule>
  </Directory>


  KeepAlive            On
  MaxKeepAliveRequests 200
  KeepAliveTimeout     5

  AddOutputFilterByType DEFLATE text/css text/plain text/html application/xhtml+xml text/xml application/xml

  <IfModule mod_headers.c>
    Header append Vary User-Agent env=!dont-vary

    ExpiresActive On
    ExpiresDefault \"now plus 1 week\"
    ExpiresByType image/x-icon \"now plus 1 month\"
    ExpiresByType image/gif    \"now plus 1 month\"
    ExpiresByType image/png    \"now plus 1 month\"
    ExpiresByType image/jpeg   \"now plus 1 month\"
  </IfModule>
</VirtualHost>" > /etc/apache2/sites-available/$DOMINIO.conf
    ;;
    *)
      echo "Opción incorrecta"
    ;;
  esac
     
  #CREAMOS EL DIRECTORIO PARA EL DOMINIO
  if [[ $EXISTE_DIRECTORIO == "N" ]]; then
    mkdir $RUTA$DOMINIO
    chmod 775 $RUTA$DOMINIO
    chown $USER $RUTA$DOMINIO
  fi
     
  #CONFIGURAMOS APACHE
  a2ensite $DOMINIO.conf
     
  #REINICIAMOS APACHE
  /etc/init.d/apache2 reload
     
  echo "Listo!"
fi

