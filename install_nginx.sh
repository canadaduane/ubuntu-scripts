aptitude -y install nginx libssl-dev libpcre3-dev

./create_account.sh nginx

HOME=/home/nginx

cd $HOME

su nginx -c "wget http://nginx.org/download/nginx-0.8.54.tar.gz"
su nginx -c "tar -xzf nginx-0.8.54.tar.gz"
cd nginx-0.8.54

su nginx -c "git clone https://github.com/agentzh/echo-nginx-module.git"

su nginx -c "./configure --prefix=/home/nginx --add-module=./echo-nginx-module"
su nginx -c "make && make install"

rm $HOME/conf/*.default
su nginx -c "mkdir $HOME/conf/sites-available"
su nginx -c "mkdir $HOME/conf/sites-enabled"

# Set up main nginx conf file
tee << '+++' >$HOME/conf/nginx.conf
user www-data;
worker_processes 4;
pid /var/run/nginx.pid;

events {
	worker_connections 768;
	# multi_accept on;
}

http {
	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	gzip on;
	gzip_disable "msie6";

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}
+++

# Set up nginx proxy include file
tee << '+++' >$HOME/conf/proxy.conf
proxy_redirect          off;
proxy_set_header        Host            $host;
proxy_set_header        X-Real-IP       $remote_addr;
proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
client_max_body_size    10m;
client_body_buffer_size 128k;
proxy_connect_timeout   90;
proxy_send_timeout      90;
proxy_read_timeout      90;
proxy_buffers           32 4k;
+++

tee << +++ >$HOME/conf/sites-available/default
server {
   listen 80 default_server;
   root /usr/share/nginx/www
}
+++

# Copy nginx executable
cp $HOME/sbin/nginx /usr/sbin/nginx

service nginx start
