# Install PHP for nginx
aptitude -y install php5-cgi php5-mysql

tee << '+++' >/etc/init.d/php-fastcgi
BIND=127.0.0.1:8999
USER=www-data
PHP_FCGI_CHILDREN=15
PHP_FCGI_MAX_REQUESTS=1000

PHP_CGI=/usr/bin/php-cgi
PHP_CGI_NAME=`basename $PHP_CGI`
PHP_CGI_ARGS="- USER=$USER PATH=/usr/bin PHP_FCGI_CHILDREN=$PHP_FCGI_CHILDREN PHP_FCGI_MAX_REQUESTS=$PHP_FCGI_MAX_REQUESTS $PHP_CGI -b $BIND"
RETVAL=0

start() {
   echo -n "Starting PHP FastCGI: "
   start-stop-daemon --quiet --start --background --chuid "$USER" --exec /usr/bin/env -- $PHP_CGI_ARGS
   RETVAL=$?
   echo "$PHP_CGI_NAME."
}
stop() {
   echo -n "Stopping PHP FastCGI: "
   killall -q -w -u $USER $PHP_CGI
   RETVAL=$?
   echo "$PHP_CGI_NAME."
}

case "$1" in
   start)
      start
   ;;
   stop)
      stop
   ;;
   restart)
      stop
      start
   ;;
   *)
      echo "Usage: php-fastcgi {start|stop|restart}"
      exit 1
   ;;
esac
exit $RETVAL
+++

chmod +x /etc/init.d/php-fastcgi
update-rc.d php-fastcgi defaults

service php-fastcgi start
