#! /bin/sh

set -ex

# build node exporter
cd /data/prometheus/build/node_exporter
git pull
make

DIR=$(mktemp -d)
trap "rm -r $DIR" EXIT
cd $DIR
cp /data/prometheus/build/node_exporter/node_exporter .

cat >Dockerfile <<__DOCKERFILE__
FROM base:busybox-libc
ADD node_exporter /bin/node_exporter

USER prometheus
EXPOSE 9100
ENTRYPOINT [ "/bin/node_exporter" ]
CMD [ "-collectors.enabled=diskstats,filesystem,loadavg,meminfo,stat,time,netdev,netstat,interrupts,tcpstat" ]
__DOCKERFILE__

sudo docker build -t prometheus:node_exporter .
