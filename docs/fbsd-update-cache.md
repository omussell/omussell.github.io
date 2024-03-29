# Caching freebsd-update and pkg files

Change the domains as appropriate. The proxy_store location is where the cached files will be placed. This directory needs to be accessible by the user that NGINX is running as (defaults to www).

NGINX config:

```
# pkg
server {

  listen *:80;

  server_name           pkg.mydomain.local;

  access_log            /var/log/nginx/pkg.access.log;
  error_log             /var/log/nginx/pkg.error.log;

  location / {
    root      /var/cache/packages/freebsd;
    try_files $uri @pkg_cache;
  }

  location @pkg_cache {
  	proxy_pass            		https://pkg.freebsd.org;
  	proxy_set_header      		Host $host;
  	proxy_cache_lock         	on;
  	proxy_cache_lock_timeout 	20s;
  	proxy_cache_revalidate 		on;
  	proxy_cache_valid 			200 301 302 30d;
  	proxy_store 				/var/cache/packages/freebsd/$request_uri;
  }

}
 
# freebsd-update
server {

  listen *:80;

  server_name           freebsd-update.mydomain.local;

  access_log            /var/log/nginx/freebsd_update.access.log;
  error_log             /var/log/nginx/freebsd_update.error.log;

  location / {
    root      /var/cache/freebsd-update;
    try_files $uri @freebsd_update_cache;
  }

  location @freebsd_update_cache {
    proxy_pass            		http://update.freebsd.org;
    proxy_set_header      		Host update.freebsd.org;
    proxy_cache_lock         	on;
    proxy_cache_lock_timeout 	20s;
    proxy_cache_revalidate 		on;
    proxy_cache_valid 			200 301 302 30d;
    proxy_store 				/var/cache/freebsd-update/$request_uri;
  }

}
```

Client config:

Create `/usr/local/etc/pkg/repos/FreeBSD.conf` with this content:

```
FreeBSD: { enabled: NO }
MyRepo: {
    url: "pkg+http://pkg.mydomain.local/${ABI}/latest",
    enabled:	true,
    signature_type: "fingerprints",
    fingerprints: "/usr/share/keys/pkg",
    mirror_type: "srv"
}
```

Edit `/etc/freebsd-update.conf`, change `ServerName` value to `freebsd-update.mydomain.local`.
