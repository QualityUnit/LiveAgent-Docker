FROM centos:7

COPY MariaDB.repo /etc/yum.repos.d/MariaDB.repo

RUN yum clean all && \
    yum -y install MariaDB-server MariaDB-client && \
    yum clean all

COPY server.cnf /etc/my.cnf.d/server.cnf
COPY createdb.sql /tmp/createdb.sql

ENV HOME /var/lib/mysql

CMD ["mysqld"]
