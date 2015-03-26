# HAProxy Firehose Router

This is a HAProxy Docker image for Firehose. It is configured via keys in etcd.

## Configuration

The HAProxy configuration is dynamically configured through [confd](https://github.com/kelseyhightower/confd). Every 30 seconds (configurable through `CONFD_INTERVAL`) it will look at certain keys in etcd. If there are keys changes it will update the configuration and reload HAProxy.

### Environment

* `CONFD_INTERVAL` - The interval in seconds to check for key changes.
* `CONFD_NODE` - The backend servers address (defaults to `172.17.42.1:4001`).
* `CONFD_BACKEND` - The backend type can be `etcd` or `consul` (defaults to `etcd`).

### etcd

The HAProxy template looks for certain keys in etcd. Some are optional and some are required.

* `/firehose/services/rainbows/*` **Required** - The keys under this directory are used as the upstream servers. This is typically populated by [registrator](https://github.com/gliderlabs/registrator).
* `/firehose/put_allow/*` **Required** - The keys under this directory are used to allow PUT calls to Firehose. The key name can be anything. The value of the key should be a single IP or subnet in CIDR format. Examples of this would be `104.12.201.79` or `104.12.201.0/24`.
* `/firehose/healthcheck_path` **Required** - This key should be set to the Firehose health check path. It is used by HAProxy to determine if a particular backend is healthy. The key is typically set to `/firehose-healthcheck`.
* `/firehose/syslog_endpoint` **Optional** - This is the syslog endpoint to log to such as `logs.papertrailapp.com:46352`.
* `/firehose/accept_proxy` **Optional** - If this key exists (can be set to anything) then we enable `accept-proxy` on the HAProxy frontend. See http://cbonte.github.io/haproxy-dconv/configuration-1.5.html#accept-proxy for more ifnormation. This is typically used with [AWS ELB proxy protocol support](http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/enable-proxy-protocol.html) to pass through client IP addresses to HAProxy for authorization.
* 
