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
COPY resqu-server-5.2.1.zip /opt/qu/resqu-server-5.2.1.zip

RUN cd /opt/qu && unzip /opt/qu/resqu-server-5.2.1.zip && \
    mv php-resqueue-serial-5.2.1/* /opt/qu/php-resque-5/ && \
    rm -rf /opt/qu/resqu-server-5.2.1.zip && \
    cd /opt/qu/php-resque-5 && curl -s http://getcomposer.org/installer | php && \
    cd /opt/qu/php-resque-5 && php composer.phar install --no-dev --no-plugins --no-scripts

CMD ["/usr/bin/php", "-c", "/etc/resque-serial/php.ini" , "/opt/qu/php-resque-5/scripts/startManagers.php" , "/etc/resque-serial/config-5.yml"]


ExecStart=/usr/bin/php -c /etc/resque-serial/php.ini /opt/qu/php-resque-5/scripts/startManagers.php /etc/resque-serial/config-5.yml
