FROM ubuntu:trusty

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 505d97a41c61b9cd \
  && echo "deb http://ppa.launchpad.net/vbernat/haproxy-1.5/ubuntu trusty main" > /etc/apt/sources.list.d/haproxy.list \
  && apt-get update -q \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y -q haproxy \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://github.com/kelseyhightower/confd/releases/download/v0.6.0-alpha3/confd-0.6.0-alpha3-linux-amd64 /usr/local/bin/confd
ADD confd /etc/confd
ADD start_haproxy /usr/local/bin/start_haproxy

RUN chmod +x /usr/local/bin/confd /usr/local/bin/start_haproxy

EXPOSE 80

CMD start_haproxy
