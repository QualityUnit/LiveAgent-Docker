# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

# Default backend definition. Set this to point to your content server.

backend default {
    .first_byte_timeout = 60s;
    .connect_timeout = 60s;
    .between_bytes_timeout = 60s;
    .host = "apache-fpm";
    .port = "800";
}

sub vcl_recv {
     if (req.method == "BAN") {
        if (req.http.host) {
            ban("req.http.host ~ " + req.http.host);
            return (synth(200, "OK"));
        } else {
            return (synth(400, "Bad Request"));
        }
     }

     set req.backend_hint = default;
     if(req.http.X-Backend == "default") {
        set req.backend_hint = default;
     }

     if (req.http.x-forwarded-for) {
        set req.http.X-Forwarded-For = req.http.X-Forwarded-For +",+ "+ client.ip;
     } else {
        set req.http.X-Forwarded-For = client.ip;
     }

     if (req.http.Accept-Encoding) {
        if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|mp4|swf)") {
          # No point in compressing these
          unset req.http.Accept-Encoding;
        } else if (req.http.Accept-Encoding ~ "gzip") {
          set req.http.Accept-Encoding = "gzip";
        } else if (req.http.Accept-Encoding ~ "deflate") {
          set req.http.Accept-Encoding = "deflate";
        } else {
          # unknown algorithm
          unset req.http.Accept-Encoding;
        }
      }



     if (req.method != "GET" &&
       req.method != "HEAD" &&
       req.method != "PUT" &&
       req.method != "POST" &&
       req.method != "TRACE" &&
       req.method != "OPTIONS" &&
       req.method != "DELETE") {
         /* Non-RFC2616 or CONNECT which is weird. */
         return (pipe);
     }

     if (req.method != "GET" && req.method != "HEAD") {
         /* We only deal with GET and HEAD by default */
         return (pass);
     }

     if (req.http.Cookie ~ "be_typo_user") {
         return (pass);
     }

     if (req.url ~ "^[^?]*\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|mp4|swf|html|js|css|zip|pdf|svg)(\?.*)?$") {
        if (req.http.Cookie) {
            set req.http.Cookie = ";" + req.http.Cookie;
            set req.http.Cookie = regsuball(req.http.Cookie, "; +", ";");
            set req.http.Cookie = regsuball(req.http.Cookie, ";(STICKYSESSION)=", "; \1=");
            set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
            set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");

            if (req.http.Cookie == "") {
                unset req.http.Cookie;
            }
        }
     }

     return (hash);
}

 sub vcl_pipe {
     set req.http.connection = "close";
     set bereq.http.connection = "close";
     return (pipe);
 }

  sub vcl_pass {
     return (fetch);
 }

sub vcl_backend_response {
    unset beresp.http.X-Varnish;

    if (beresp.ttl < 2m) {
       set beresp.grace = 5m;
    } else {
       set beresp.grace = 15s;
    }

    if (beresp.http.content-type ~ "(text|javascript|svg)") {
      set beresp.do_gzip = true;
      set beresp.do_stream = false
    }

    if (beresp.ttl > 14400s) {
      set beresp.ttl=14400s;
    }

    # These status codes should always pass through and never cache.
    if (beresp.status >= 400 || !(beresp.ttl > 0s) || beresp.http.Cache-Control ~ "(private|no-cache|no-store)") {
       set beresp.ttl=0s;
       set beresp.uncacheable = true;
       return (deliver);
    }

    if (bereq.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|mp4|swf|html|js|css|zip|pdf|svg)") {
       unset beresp.http.set-cookie;
    }

    return (deliver);
}

sub vcl_deliver {
   set resp.http.Vary= "Accept-Encoding";
   set resp.http.Via= "1.1 varnish";
}

sub vcl_miss {
    return (fetch);
}

sub vcl_backend_error {
    set beresp.http.Content-Type = "text/html; charset=utf-8";
    set beresp.http.Retry-After = "60";
    synthetic( {"
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title>"} + beresp.status + " " + beresp.reason + {"</title>
  </head>
  <body>
    <h1>Error "} + beresp.status + " " + beresp.reason + {"</h1>
    <p>"} + beresp.reason + {"</p>
    <h3>Guru Meditation:</h3>
    <p>XID: "} + bereq.xid + {"</p>
    <hr>
    <p>Varnish cache server</p>
  </body>
</html>
"} );
    return (deliver);
}
