FROM centos:7

RUN yum clean all && \
    yum install -y nc iproute && \
#   http://www.filewatcher.com/m/haproxy-1.5.4-2.el7.x86_64.rpm.842524-0.html
    yum -y localinstall ftp://ftp.mirror.anlx.net/centos/7.0/extracted/Packages/haproxy-1.5.4-2.el7.x86_64.rpm && \
    yum clean all

COPY haproxy.cfg /etc/haproxy/
COPY health.lb-app.response.http /srv/utils/health.lb-app.response.http

CMD ["/usr/sbin/haproxy", "-f", "/etc/haproxy/haproxy.cfg"]
