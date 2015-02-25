FROM gliderlabs/alpine:3.1

ENV CONSUL_AGENT 172.17.42.1:8500

RUN apk-install -t deps wget ca-certificates tar gzip \
  && apk-install -X http://alpine.gliderlabs.com/alpine/edge/main haproxy bash \
  && wget -qO- https://github.com/hashicorp/consul-template/releases/download/v0.7.0/consul-template_0.7.0_linux_amd64.tar.gz \
  | tar --strip-components=1 -z -x -f - -C /bin \
  && apk del deps

COPY haproxy.ctmpl /etc/haproxy.ctmpl
COPY codep /bin/codep
COPY haproxy.cfg /etc/haproxy/haproxy.cfg

RUN chmod +x /bin/codep

EXPOSE 80

CMD codep \
  "consul-template -log-level debug -consul $CONSUL_AGENT -template /etc/haproxy.ctmpl:/etc/haproxy/haproxy.cfg pkill -SIGUSR2 ^haproxy-systemd.*" \
  "haproxy-systemd-wrapper -p /var/run/haproxy.pid -f /etc/haproxy/haproxy.cfg"
