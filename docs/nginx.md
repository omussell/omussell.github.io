# NGINX

## TLS 1.3 0-RTT with NGINX

[NGINX Docs](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_early_data)
[Early data var](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#var_ssl_early_data)

```
ssl_early_data on;
proxy_set_header Early-Data $ssl_early_data;
limit_except GET {
    deny  all;
}
```

0-RTT is vulnerable to replay attacks, so we should only use this with requests using the GET method. If passing the request to a backend, you can set a header with `proxy_set_header Early-Data $ssl_early_data;`. The value of the $ssl_early_data variable is "1" if early data is used, otherwise "". This header is passed to the upstream, so it can be used by the upstream application to determine the response.


## Only allow certain HTTP methods with NGINX

[NGNX Docs](https://nginx.org/en/docs/http/ngx_http_core_module.html#limit_except)

```
limit_except GET {
    deny  all;
}
```

Only allows GET requests through, denies all other methods, with the exception of HEAD because if GET is allowed HEAD is too.

## Dynamic Certificate loading with NGINX

[NGINX Announcement](https://www.nginx.com/blog/nginx-plus-r18-released/)
[NGINX Docs](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_certificate)

If you have a lot of NGINX servers/vhosts all served from the same box, you probably want to secure them with TLS. Normally this would mean a lot of duplicate configuration to specify which certificate is needed for each server_name. With Dynamic Certificate Loading, you can use a NGINX variable as part of the certificate name. So if you have certificate/key files named after the server name, you can load them dynamically with NGINX.

```
server_name  omuss.net omuss-test.net;

ssl_certificate      /usr/local/etc/nginx/ssl/$ssl_server_name.crt;
ssl_certificate_key  /usr/local/etc/nginx/ssl/$ssl_server_name.key;
```

With certificate and key files named appropriately:

```
/usr/local/etc/nginx/ssl/omuss.net.crt
/usr/local/etc/nginx/ssl/omuss.net.key
/usr/local/etc/nginx/ssl/omuss-test.net.crt
/usr/local/etc/nginx/ssl/omuss-test.net.key
```

Note that certificates are lazy loaded, as in they are only loaded when a request comes in. So all certificates aren't loaded into memory, which means less resource usage, but there is some overhead for the TLS negotiation because NGINX has to load the certificate from disk. TLS session caching may help alleviate this though.

You would probably want the certificates stored on a fast disk to eliminate I/O overhead.


## Brotli Compression with NGINX

Brotli can be used as an alternative to GZIP. It can give better compression in some cases.

[NGINX Brotli Docs](https://docs.nginx.com/nginx/admin-guide/dynamic-modules/brotli/)
[Module Docs](https://github.com/google/ngx_brotli/)

The normal `nginx` package does not include the brotli module. You can either compile NGINX yourself and include the Brotli module, or otherwise install the `nginx-full` package (though the package is big because of lots of dependencies and includes lots of other modules).

Once you have a NGINX binary with the Brotli module included, you need to load the module in the NGINX configuration:

```
load_module /usr/local/libexec/nginx/ngx_http_brotli_static_module.so;
load_module /usr/local/libexec/nginx/ngx_http_brotli_filter_module.so;
```

Also an important note, you MUST use HTTPS for Brotli to work. So make sure you set a server block to use HTTPS and set up a certificate etc.

Now you have two options, compress you static files manually and put them where NGINX can find them, or let NGINX compress them on-the-fly. 

### Static
With `brotli_static` set to `on` or `always`, the files must already be compressed. This can be done by installing the `brotli` package on FreeBSD, or otherwise you can do it quick and dirty with python like:

```
# pip install brotli

import brotli
with open('index.html', 'rb') as f:
    with open('index.html.br', 'wb') as brotted:
        brotted.write(brotli.compress(f.read()))
```

Note that brotli prefers bytestrings.

With the `brotli_static` option turned on, I found that using `index.html.br` didn't work, but if I set the filename to `index.html` but with Brotli-fied contents, it loaded correctly.

You should also make sure to set `add_header Content-Encoding "br";` so that the browser knows that it is Brotli encoded.

### Dynamic

Otherwise, set `brotli on;` and it will compress file on-the-fly.

## NGINX TCP/UDP proxy

NGINX needs to be compiled with the --with-stream option. It can't be dynamic, which is the default. In the config file you need to add:

```
load_module /usr/local/libexec/nginx/ngx_stream_module.so;
```

Then in the config file:

```
stream {

  server {

    listen 80;
    proxy_pass 192.168.1.15:80;

  }

  server {

    # Override the default stream type of TCP with UDP
    listen 53;
    proxy_pass 192.168.1.15:53 udp;

  }

}
```
