SERVER_NAME=$1

# Set up scuttle user
useradd -U -m scuttle
cd /home/scuttle

# Set up scuttle mysql user
echo "CREATE USER 'scuttle'@'localhost' IDENTIFIED BY 'sct^pw54';" | mysql
echo "CREATE DATABASE scuttle;" | mysql
echo "GRANT ALL ON scuttle.* TO 'scuttle'@'localhost';" | mysql

# Install scuttle bookmarking site
wget https://downloads.sourceforge.net/project/scuttle/scuttle/0.9.0/scuttle-0.9.0.tar.gz?r=\&ts=1297905900\&use_mirror=iweb -O scuttle.tar.gz
tar -xzf scuttle.tar.gz
rm scuttle.tar.gz
mv scronide-scuttle-9ce0bb5 scuttle-app
chown -R scuttle:scuttle scuttle-app

cd scuttle-app
chmod 0777 ./cache

# Load the scuttle tables into the scuttle db
cat tables.sql | mysql -D scuttle

# Configuration for scuttle
tee << '+++' >/home/scuttle/scuttle-app/config.inc.php
<?php
$dbtype = 'mysql';
$dbhost = '127.0.0.1';
$dbport = '3306';
$dbuser = 'scuttle';
$dbpass = 'sct^pw54';
$dbname = 'scuttle';

$sitename   = 'Tipscale Bookmarks';
$locale     = 'en_US';
$adminemail = 'admin@tipscale.org';

$top_include       = 'top.inc.php';
$bottom_include    = 'bottom.inc.php';
$shortdate         = 'm-d-Y';
$longdate          = 'j F Y';
$nofollow          = TRUE;
$defaultPerPage    = 100;
$defaultRecentDays = 14;
$defaultOrderBy    = 'date_desc';
$TEMPLATES_DIR     = dirname(__FILE__) .'/templates/';
$root              = NULL;
$cookieprefix      = 'SCUTTLE';
$tableprefix       = 'sc_';
$cleanurls         = TRUE;
$usecache          = FALSE;
$dir_cache         = dirname(__FILE__) .'/cache/';
$useredir          = FALSE;
$url_redir         = 'http://www.google.com/url?sa=D&q=';
$filetypes         = array(
                      'audio'      => array('aac', 'mp3', 'm4a', 'oga', 'ogg', 'wav'),
                      'document'   => array('doc', 'docx', 'odt', 'pages', 'pdf', 'txt'),
                      'image'      => array('gif', 'jpe', 'jpeg', 'jpg', 'png', 'svg'),
                      'bittorrent' => array('torrent'),
                      'video'      => array('avi', 'flv', 'mov', 'mp4', 'mpeg', 'mpg', 'm4v', 'ogv', 'wmv')
                     );
$reservedusers     = array('all', 'watchlist');
$email_whitelist   = NULL;
$email_blacklist   = array( '/(.*-){2,}/', '/mailinator\.com/i' );

include_once 'debug.inc.php';
+++

# Set up nginx for scuttle
mkdir -p /etc/nginx/sites-available/
tee << '+++'' | sed "s/[TOPDOMAIN]/$SERVER_NAME/" >/etc/nginx/sites-available/scuttle
server {
   server_name [TOPDOMAIN];
   root /home/scuttle/scuttle-app;

   index index.php;
   try_files $uri @php_rewrite;

   # pass the PHP scripts to FastCGI server listening on 127.0.0.1:8999
   location @php_rewrite {
      rewrite ^(/[^/]+)/?(.*)$ $1.php/$2;
   }

   location ~ \.php.*$ {
      include fastcgi_params;
      keepalive_timeout 0;
      fastcgi_param   SCRIPT_FILENAME  $document_root$fastcgi_script_name;
      fastcgi_pass 127.0.0.1:8999;
   }
}
+++
