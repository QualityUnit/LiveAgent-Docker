FROM centos:7

RUN yum clean all && \
    yum install epel-release -y && \
    yum install redis-3.2.12 -y && \
    yum clean all

COPY redis.conf /etc/redis.conf

ENV HOME /var/lib/redis

CMD ["/usr/bin/redis-server", "/etc/redis.conf"]
