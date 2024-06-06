FROM centos:7

RUN yum clean all && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum install epel-release -y && \
    yum install redis-3.2.12 -y && \
    yum clean all

COPY redis.conf /etc/redis.conf

ENV HOME /var/lib/redis

CMD ["/usr/bin/redis-server", "/etc/redis.conf"]
