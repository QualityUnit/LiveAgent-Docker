FROM centos:7

COPY nginx-lua-redis-pushstream-1.20.2-1.el7.rpm /var/nginx-lua-redis-pushstream-1.20.2-1.el7.rpm

RUN yum clean all && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum -y localinstall /var/nginx-lua-redis-pushstream-1.20.2-1.el7.rpm && \
    yum install -y iproute && \
    yum clean all

COPY nginx.conf /etc/nginx/nginx.conf

RUN rm -rf /etc/nginx/conf.d/* && \
    mkdir -p /etc/nginx/sites.d && \
    mkdir -p /etc/nginx/ssl/ && \
    openssl dhparam -out /etc/nginx/ssl/dhparams.pem 2048

COPY conf.d/* /etc/nginx/conf.d/
COPY liveagent.conf /etc/nginx/sites.d/
COPY pushstream_subscriber.conf /etc/nginx/sites.d/
COPY ssl.crt /etc/nginx/ssl/ssl.crt
COPY ssl.key /etc/nginx/ssl/ssl.key

ENTRYPOINT ["/usr/sbin/nginx","-g","daemon off;"]
