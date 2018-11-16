FROM centos:7

COPY varnishcache_varnish41.repo /etc/yum.repos.d/varnishcache_varnish41.repo

RUN yum update -y && \
  yum install -y epel-release pygpgme yum-utils && \
  yum -q makecache -y --disablerepo='*' --enablerepo='varnishcache_varnish41' && \
  yum install -y varnish && \
  yum clean all

COPY varnish /etc/sysconfig/
COPY default.vcl /etc/varnish/default.vcl
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
