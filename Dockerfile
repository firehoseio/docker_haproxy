FROM ubuntu-debootstrap:trusty

ENV CONFD_VERSION 0.7.1
ENV CONFD_INTERVAL 30
ENV CONFD_NODE 172.17.42.1:4001
ENV CONFD_BACKEND etcd

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 505d97a41c61b9cd \
  && echo "deb http://ppa.launchpad.net/vbernat/haproxy-1.5/ubuntu trusty main" > /etc/apt/sources.list.d/haproxy.list \
  && apt-get update -q \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y -q haproxy \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists /tmp/* /var/tmp/*

ADD https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION/confd-$CONFD_VERSION-linux-amd64 /usr/local/bin/confd
ADD confd /etc/confd
ADD codep /usr/local/bin/codep
ADD haproxy.cfg /etc/haproxy/haproxy.cfg

RUN chmod +x /usr/local/bin/confd /usr/local/bin/codep

EXPOSE 80

CMD codep \
  "/usr/local/bin/confd -verbose -interval $CONFD_INTERVAL -backend $CONFD_BACKEND -node $CONFD_NODE -config-file /etc/confd/conf.d/firehose-haproxy.toml" \
  "/usr/sbin/haproxy-systemd-wrapper -p /var/run/haproxy.pid -f /etc/haproxy/haproxy.cfg"
