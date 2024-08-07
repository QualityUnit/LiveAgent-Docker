FROM centos:7

COPY remi-php82.repo /etc/yum.repos.d/remi-php82.repo

RUN yum clean all && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum-config-manager --enable remi-php74-repo && \
    yum-config-manager --enable remi-repo && \
    yum -y install epel-release && \
    yum -y install httpd php-fpm libwebp7 gd-last php-pecl-redis5 php-pecl-yaml php-cli php-xml php-pdo php-mysqlnd php-gd php-opcache php-bcmath php-mbstring php-soap php-ldap php-process iproute unzip && \
    yum clean all

RUN mkdir -p /var/www/health_check/ && \
    mkdir -p /var/www/socket/ && \
    mkdir -p /etc/httpd/sites.d/ && \
    mkdir -p /etc/httpd/conf/ && \
    mkdir -p /var/run/php-fpm/ && \
    rm /etc/httpd/conf.d/welcome.conf /etc/php-fpm.d/www.conf

COPY httpd.conf /etc/httpd/conf/httpd.conf
COPY php-fpm.conf /etc/php-fpm.conf
COPY common_pool.conf /etc/php-fpm.d/common_pool.conf
COPY health_check.php-fpm.conf /etc/php-fpm.d/health_check.php-fpm.conf
COPY support_php-fpm.conf /etc/php-fpm.d/support_php-fpm.conf
COPY mime.types /etc/httpd/conf/mime.types
COPY check.php /var/www/health_check/check.php
COPY health_check.conf /etc/httpd/sites.d/health_check.conf
COPY php.ini /etc/php.ini

#LIVEAGENT
COPY la* /var/www/
RUN unzip /var/www/la* -d /var/www/liveagent
COPY liveagent.conf /etc/httpd/sites.d/liveagent.conf
COPY settings.php /var/www/liveagent/accounts/settings.php
RUN chmod -R 777 /var/www/liveagent/accounts && \
    chown -R apache:apache /var/www/liveagent/accounts && \
    mkdir -p /var/www/liveagent/var && \
    chmod -R 777 /var/www/liveagent/var

#LA INSTALL/UPDATE
COPY install.sh /install.sh
RUN chmod +x /install.sh

#GEOIP
RUN ln -s /opt/geoip/GeoLiteCity.dat /var/www/liveagent/plugins/GeoIp/GeoLiteCity.dat

# Simple startup script to avoid some issues observed with container restart
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
