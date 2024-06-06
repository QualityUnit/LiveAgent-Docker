FROM centos:7

COPY varnishcache_varnish41.repo /etc/yum.repos.d/varnishcache_varnish41.repo

RUN yum clean all && \
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
  yum update -y && \
  yum install -y epel-release pygpgme yum-utils && \
  yum -q makecache -y --disablerepo='*' --enablerepo='varnishcache_varnish41' && \
  yum install -y varnish && \
  yum clean all

COPY varnish /etc/sysconfig/
COPY default.vcl /etc/varnish/default.vcl
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
