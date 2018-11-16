FROM centos:7

RUN yum clean all && \
    yum install epel-release -y && \
    yum install redis -y && \
    yum clean all

COPY redis-sentinel.conf /etc/redis-sentinel.conf
RUN chown redis:redis /etc/redis-sentinel.conf

CMD ["/usr/bin/redis-server", "/etc/redis-sentinel.conf", "--sentinel"]
