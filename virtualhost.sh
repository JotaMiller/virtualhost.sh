#!/bin/bash
   
if [ -z $1 ]
then
  echo "Debe ingresar el nombre del dominio"
  exit 1
else
  DOMINIO=$1
fi
   
if [ -z $2 ]
then
  RUTA="/home/jotamiller/public_html/"
else
  RUTA=$2
fi
   
echo "Configurando dominio "$DOMINIO
   
#CREAMOS LA ENTRADA EN /ETC/HOSTS
echo "127.0.0.1 "$DOMINIO.dev >> /etc/hosts
   
#CREAMOS EL ARCHIVO DE VIRTUAL HOST
touch /etc/apache2/sites-available/$DOMINIO.conf
   
#AGREGAMOS EL VIRTUAL HOST
echo "<VirtualHost *:80>
  ServerName $DOMINIO.dev

  ServerAdmin webmaster@localhost
  DocumentRoot $RUTA$DOMINIO

  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined
  
</VirtualHost>" >  /etc/apache2/sites-available/$DOMINIO.conf
   
#CREAMOS EL DIRECTORIO PARA EL DOMINIO
mkdir $RUTA$DOMINIO
chmod 775 $RUTA$DOMINIO
chown jotamiller $RUTA$DOMINIO
   
#CONFIGURAMOS APACHE
a2ensite $DOMINIO.conf
   
#REINICIAMOS APACHE
/etc/init.d/apache2 reload
   
echo "Listo!"