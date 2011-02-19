SERVER_NAME=$1

# Packages for etherpad
aptitude -y install mysql-client mysql-server
aptitude -y install po-debconf debhelper dbconfig-common libmysql-java scala scala-library

# Set up etherpad user
./account_for_app.sh etherpad
cd /home/etherpad

# Setup etherpad user for MySQL
echo "CREATE USER 'etherpad'@'localhost' IDENTIFIED BY 'ep^pw29';" | mysql
echo "CREATE DATABASE etherpad;" | mysql
echo "GRANT ALL ON etherpad.* TO 'etherpad'@'localhost';" | mysql

# Install etherpad
mkdir ether
chown etherpad:etherpad ether
cd ether
su etherpad -c "git clone https://github.com/canadaduane/pad.git pad"
cd pad; git pull
su etherpad -c "git checkout 46104a6cfe75fa839accabe701b4009d59af07f4"
# Etherpad config file
tee << '+++' | sed "s/\[TOPDOMAIN\]/$SERVER_NAME/" >etherpad/etc/etherpad.local.properties
alwaysHttps = false
ajstdlibHome = ../infrastructure/framework-src/modules
appjetHome = ./data/appjet
devMode = true
etherpad.adminPass = anisthor#3
etherpad.fakeProduction = false
etherpad.isProduction = true
etherpad.proAccounts = true
etherpad.SQL_JDBC_DRIVER = com.mysql.jdbc.Driver
etherpad.SQL_JDBC_URL = jdbc:mysql://localhost:3306/etherpad
etherpad.SQL_PASSWORD = ep^pw29
etherpad.SQL_USERNAME = etherpad
hidePorts = false
listen = 9000
logDir = ./data/logs
modulePath = ./src
motdPage = /ep/pad/view/ro.n0zeTdyTuXF/latest?fullScreen=1&slider=0&sidebar=0
topdomains = [TOPDOMAIN],localhost,localbox.info
transportPrefix = /comet
transportUseWildcardSubdomains = true
useHttpsUrls = false
useVirtualFileRoot = ./src
theme = default
etherpad.soffice = /usr/bin/soffice
customBrandingName = Tipscale Pad
customEmailAddress = admin@tipscale.org
showLinkandLicense = true
+++

chown etherpad:etherpad etherpad/etc/etherpad.local.properties

su etherpad -c "bin/build.sh"

# Set up etherpad init script
tee << '+++' >/etc/init.d/etherpad
ETHERPAD=/home/etherpad/ether/pad
if [ "x$1" = "xstart" ]; then
	cd $ETHERPAD
	bin/run.sh >> /var/log/etherpad.log 2>&1 &
	sleep 1.0
	PID=`ps auxww|grep etherpad.local.properties|grep -v grep|awk '{print $2}'`
	echo $PID >/var/run/etherpad.pid
	echo "Started etherpad with pid $PID"
fi

if [ "x$1" = "xstop" ]; then
	ps auxww|grep etherpad.local.properties|grep -v grep|awk '{print $2}'|xargs kill -HUP
fi
+++

chmod +x /etc/init.d/etherpad 
update-rc.d etherpad defaults

service etherpad start


# Set up etherpad for nginx
mkdir -p /etc/nginx/sites-available/
tee << '+++' >/etc/nginx/sites-available/etherpad
server {
   server_name $SERVER_NAME *.$SERVER_NAME;
   
   access_log /var/log/nginx/etherpad.access.log;
   error_log /var/log/nginx/etherpad.error.log;
   
   location / {
       proxy_pass http://localhost:9000/;
       include /etc/nginx/proxy.conf;
   }
}
+++
