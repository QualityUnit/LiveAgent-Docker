FROM centos:7

COPY remi-php70.repo /etc/yum.repos.d/remi-php70.repo

RUN yum clean all && \
    yum-config-manager --enable remi-php70 && \
    yum install -y http://rpms.famillecollet.com/enterprise/7/remi/x86_64//gd-last-2.2.5-5.el7.remi.x86_64.rpm && \
    yum -y install python-setuptools php php-gd php-mbstring php-bcmath php-xml php-pdo php-soap php-mysqlnd php-opcache php-ldap php-pecl-redis php-pecl-yaml php-process php-cli git unzip iproute && \
    easy_install supervisor && \
    yum clean all

RUN mkdir -p /etc/resque-serial && \
    mkdir -p /opt/qu/php-resque-5

COPY php.ini /etc/resque-serial/php.ini
COPY supervisord.conf /etc/supervisord.conf
COPY config-5.yml /etc/resque-serial/config-5.yml
COPY resque-5.conf /etc/supervisor.d/resque-5.conf
COPY php-resqueue-serial-5.1.0.zip /opt/qu/php-resqueue-serial-5.1.0.zip

RUN cd /opt/qu && unzip /opt/qu/php-resqueue-serial-5.1.0.zip && \
    mv php-resqueue-serial-5.1.0/* /opt/qu/php-resque-5/ && \
    rm -rf /opt/qu/php-resqueue-serial-resqu-5.1.0.zip && \
    cd /opt/qu/php-resque-5 && curl -s http://getcomposer.org/installer | php && \
    cd /opt/qu/php-resque-5 && php composer.phar install --no-dev --no-plugins --no-scripts

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
