FROM centos:7

COPY remi-php82.repo /etc/yum.repos.d/remi-php82.repo

RUN yum clean all && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum-config-manager --enable remi-php74-repo && \
    yum-config-manager --enable remi-repo && \
    yum -y install epel-release && \
    yum -y install python3-pip php libwebp7 gd-last php-gd php-mbstring php-bcmath php-xml php-pdo php-soap php-mysqlnd php-opcache php-ldap php-pecl-redis5 php-pecl-yaml php-process php-cli git unzip iproute && \
    pip3 install supervisor && \
    yum clean all

RUN mkdir -p /etc/resque-serial && \
    mkdir -p /opt/qu/php-resque-5

COPY php.ini /etc/resque-serial/php.ini
COPY supervisord.conf /etc/supervisord.conf
COPY resque-5.conf /etc/supervisor.d/resque-5.conf
COPY config-5.yml /etc/resque-serial/config-5.yml

RUN cd /opt/qu && \
    VERSION=5.4.0 && \
    curl -fLOsS https://github.com/QualityUnit/resqu-server/raw/${VERSION}/build/php-resque-serial-${VERSION}.zip && \
    echo "d0db7c4e544891dd4a8da949338a34f3d8bc23756f41e162e80f3b97e872a612  php-resque-serial-${VERSION}.zip" | sha256sum -c && \
    unzip php-resque-serial-${VERSION}.zip -d php-resque-5 && \
    rm php-resque-serial-${VERSION}.zip

CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
