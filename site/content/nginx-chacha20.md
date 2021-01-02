+++
title = "Compiling NGINX with ChaCha20 support"
date = 2020-01-03

[taxonomies]
tags = ["nginx", "homelab", "crypto"]
+++

Make a working directory

```
mkdir ~/nginx
cd ~/nginx
```

Install some dependencies

```
pkg install -y ca_root_nss pcre perl5
```

Pull the source files

```
fetch https://nginx.org/download/nginx-1.13.0.tar.gz
fetch https://www.openssl.org/source/openssl-1.1.0e.tar.gz
```

Extract the tarballs

```
tar -xzvf nginx-1.13.0.tar.gz
tar -xzvf openssl-1.1.0e.tar.gz
rm *.tar.gz
```

Compile openssl

```
cd ~/nginx/openssl-1.1.0e.tar.gz
./config
make
make install
```

The compiled OpenSSL binary should be located in /usr/local/bin by default, unless the prefixdir variable has been set

```
/usr/local/bin/openssl version
# Should output OpenSSL 1.1.0e
```

Compile NGINX

```
#!/bin/sh
cd ~/nginx/nginx-1.13.0/
#make clean

./configure \
	--with-http_ssl_module \
	--with-http_gzip_static_module \
	--with-file-aio \
	--with-ld-opt="-L /usr/local/lib" \

	--without-http_browser_module \
	--without-http_fastcgi_module \
	--without-http_geo_module \
	--without-http_map_module \
	--without-http_proxy_module \
	--without-http_memcached_module \
	--without-http_ssi_module \
	--without-http_userid_module \
	--without-http_split_clients_module \
	--without-http_uwsgi_module \
	--without-http_scgi_module \
	--without-http_limit_conn_module \
	--without-http_referer_module \
	--without-http_http-cache \
	--without_upstream_ip_hash_module \
	--without-mail_pop3_module \
	--without-mail-imap_module \
	--without-mail_smtp_module

	--with-openssl=~/nginx/openssl-1.1.0e/

make
make install
```

After running the compile script, NGINX should be installed in /usr/local/nginx

Start the service

```
/usr/local/nginx/sbin/nginx
```

If there are no issues, update the config file as appropriate in `/usr/local/nginx/conf/nginx.conf`

Reload NGINX to apply the new config

```
/usr/local/nginx/sbin/nginx -s reload
```

Generate a self-signed certificate

Current NGINX config

```
worker_processes  1;

events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  localhost;
        location / {
            root   /usr/local/www/;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

    }

    server {
        listen       443 ssl;
        server_name  localhost;

	ssl on;
        #ssl_certificate      /root/nginx/server.pem;
        #ssl_certificate_key  /root/nginx/private.pem;
	ssl_certificate /usr/local/www/nginx-selfsigned.crt;
	ssl_certificate_key /usr/local/www/nginx-selfsigned.key;
	ssl_ciphers "ECDHE-RSA-CHACHA20-POLY1305";
        ssl_prefer_server_ciphers  on;
	ssl_protocols TLSv1.2;
	ssl_ecdh_curve X25519;
	
	location / {
            root   /usr/local/www/;
            index  index.html index.htm;
        }
    }

}
```

