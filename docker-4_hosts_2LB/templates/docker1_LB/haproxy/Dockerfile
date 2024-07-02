FROM centos:7

RUN yum clean all && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum install -y nc iproute haproxy && \
    yum clean all

COPY haproxy.cfg /etc/haproxy/
COPY health.lb-app.response.http /srv/utils/health.lb-app.response.http

CMD ["/usr/sbin/haproxy", "-f", "/etc/haproxy/haproxy.cfg"]
