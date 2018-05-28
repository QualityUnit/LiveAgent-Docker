FROM centos:7

COPY nginx-redis-pushstream-1.13.8-1.el7.rpm /var/nginx-redis-pushstream-1.13.8-1.el7.rpm

RUN yum clean all && \
    yum -y localinstall /var/nginx-redis-pushstream-1.13.8-1.el7.rpm && \
    yum install -y iproute && \
    yum clean all

COPY nginx.conf /etc/nginx/nginx.conf

RUN rm -rf /etc/nginx/conf.d/* && \
    mkdir -p /etc/nginx/sites.d && \
    mkdir -p /etc/nginx/ssl/ && \
    openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048

COPY conf.d/* /etc/nginx/conf.d/
COPY liveagent.local.conf /etc/nginx/sites.d/
COPY ssl.crt /etc/nginx/ssl/ssl.crt
COPY ssl.key /etc/nginx/ssl/ssl.key

ENTRYPOINT ["/usr/sbin/nginx","-g","daemon off;"]