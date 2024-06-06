FROM centos:7

COPY MariaDB.repo /etc/yum.repos.d/MariaDB.repo

RUN yum clean all && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum -y install MariaDB-server MariaDB-client && \
    yum clean all

COPY server.cnf /etc/my.cnf.d/server.cnf
COPY createdb.sql /tmp/createdb.sql

ENV HOME /var/lib/mysql

CMD ["mysqld"]
