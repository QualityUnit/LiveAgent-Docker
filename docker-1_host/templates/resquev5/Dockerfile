FROM centos:7

COPY remi-php72.repo /etc/yum.repos.d/remi-php72.repo

RUN yum clean all && \
    yum-config-manager --enable remi-php72-repo && \
    yum-config-manager --enable remi-repo && \
    yum -y install python-setuptools php libwebp7 gd-last php-gd php-mbstring php-bcmath php-xml php-pdo php-soap php-mysqlnd php-opcache php-ldap php-pecl-redis php-pecl-yaml php-process php-cli git unzip iproute && \
    easy_install supervisor && \
    yum clean all

RUN mkdir -p /etc/resque-serial && \
    mkdir -p /opt/qu/php-resque-5

COPY php.ini /etc/resque-serial/php.ini
COPY supervisord.conf /etc/supervisord.conf
COPY resque-5.conf /etc/supervisor.d/resque-5.conf
COPY config-5.yml /etc/resque-serial/config-5.yml
COPY resqu-server-5.2.1.zip /opt/qu/resqu-server-5.2.1.zip

RUN cd /opt/qu && unzip /opt/qu/resqu-server-5.2.1.zip && \
    mv resqu-server-5.2.1/* /opt/qu/php-resque-5/ && \
    rm -rf /opt/qu/resqu-server-5.2.1.zip && \
    cd /opt/qu/php-resque-5 && curl -s http://getcomposer.org/installer | php && \
    cd /opt/qu/php-resque-5 && php composer.phar install --no-dev --no-plugins --no-scripts

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
