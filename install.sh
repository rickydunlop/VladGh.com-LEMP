#!/bin/bash
### Ubuntu LEMP Install Script --- VladGh.com
#
####################
###   LICENSE:   ###
####################
# This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
# To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
# or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
#
###################
### DISCLAIMER: ###
###################
# All content provided here including the scripts is provided without
# any warranty. You use it at your own risk. I can not be held responsible
# for any damage that may occur because of it. By using the scripts I
# provide here you accept this terms.
#
# Please bear in mind that this method is intended for development
# and testing purposes only. If you care about stability and security
# you should use the packages provided by your distribution.

### Program Versions:
NGINX_STABLE="1.0.13"
NGINX_DEV="1.1.16"
PHP_VER="5.3.10"
APC_VER="3.1.9"
SUHOSIN_VER="0.9.33"

### Directories
DSTDIR="/opt"
WEBDIR="/var/www"
SRCDIR=`dirname $(readlink -f $0)`
TMPDIR="$SRCDIR/sources"
INSTALL_FILES="$SRCDIR/install_files/*.sh"

### Log file
LOG_FILE="install.log"

### Active user
USER=$(who mom likes | awk '{print $1}')

### Essential Packages
ESSENTIAL_PACKAGES="htop vim-nox binutils cpp flex gcc libarchive-zip-perl libc6-dev libcompress-zlib-perl m4 libpcre3 libpcre3-dev libssl-dev libpopt-dev lynx make perl perl-modules openssl unzip zip autoconf2.13 gnu-standards automake libtool bison build-essential zlib1g-dev ntp ntpdate autotools-dev g++ bc subversion psmisc"

### PHP Libraries
PHP_LIBRARIES="libmysqlclient-dev libcurl4-openssl-dev libgd2-xpm-dev libjpeg62-dev libpng3-dev libxpm-dev libfreetype6-dev libt1-dev libmcrypt-dev libxslt1-dev libbz2-dev libxml2-dev libevent-dev libltdl-dev libmagickwand-dev imagemagick libreadline-dev libc-client-dev libsnmp-dev snmpd snmp"

# Load installation files
for file in ${INSTALL_FILES} ; do
  . ${file}
done

###################################################################################
### RUN ALL THE FUNCTIONS:

check_root
log2file

# Traps CTRL-C
trap ctrl_c INT
function ctrl_c() {
  echo -e '\nCancelled by user' >&3; echo -e '\nCancelled by user'; if [ -n "$!" ]; then kill $!; fi; exit 1
}

clear >&3
echo "=========================================================================" >&3
echo "This script will install the following:" >&3
echo "=========================================================================" >&3
echo "  - Nginx $NGINX_DEV (development) or $NGINX_STABLE (stable);" >&3
echo "  - PHP $PHP_VER;" >&3
echo "  - APC $APC_VER;" >&3
echo "  - Suhosin $SUHOSIN_VER;" >&3
echo "=========================================================================" >&3
echo "For more information please visit:" >&3
echo "https://github.com/vladgh/VladGh.com-LEMP" >&3
echo "=========================================================================" >&3
echo "Do you want to continue[Y/n]:" >&3
read  continue_install
case  $continue_install  in
  'n'|'N'|'No'|'no')
  echo -e "\nCancelled." >&3
  exit 1
  ;;
  *)
esac

echo "Which of the following NginX releases do you want installed:" >&3
echo "1) Latest Development Release ($NGINX_DEV)(default)" >&3
echo "2) Latest Stable Release ($NGINX_STABLE)" >&3
echo -n "Enter your menu choice [1 or 2]: " >&3
read nginxchoice
case $nginxchoice in
  1) NGINX_VER=$NGINX_DEV ;;
  2) NGINX_VER=$NGINX_STABLE ;;
  *) NGINX_VER=$NGINX_DEV ;
esac

prepare_system

install_mysql

install_php
install_apc
install_suhosin
check_php

install_nginx
check_nginx

set_paths
restart_servers

chown -R $USER:$USER $SRCDIR
rm -r $TMPDIR

sleep 5

### Final check
if [ -e "/var/run/nginx.pid" ] && [ -e "/var/run/php-fpm.pid" ] ; then
  echo "=========================================================================" >&3
  echo 'NginX, PHP, APC and Suhosin were successfully installed.' >&3
  echo "If your hosts are setup correctly you should be able to see some stats at:" >&3
  echo "- http://$(hostname -f)/index.php (PHP Status page)" >&3
  echo "- http://$(hostname -f)/apc.php (APC Status page)" >&3
  echo "- http://$(hostname -f)/nginx_status (NginX Status page)" >&3
  echo "- http://$(hostname -f)/status?html (FPM Status page)" >&3
  echo 'Press any key to exit...' >&3
  read -n 1
  exit 0
else
  echo "=========================================================================" >&3
  echo "Errors encountered. Check the install.log." >&3
  echo 'Press any key to exit...' >&3
  read -n 1
  exit 1
fi
