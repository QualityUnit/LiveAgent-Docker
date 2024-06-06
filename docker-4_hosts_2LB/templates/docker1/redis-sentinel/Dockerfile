FROM centos:7

RUN yum clean all && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum install epel-release -y && \
    yum install redis -y && \
    yum clean all

COPY redis-sentinel.conf /etc/redis-sentinel.conf
RUN chown redis:redis /etc/redis-sentinel.conf

CMD ["/usr/bin/redis-server", "/etc/redis-sentinel.conf", "--sentinel"]
