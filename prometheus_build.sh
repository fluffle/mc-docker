#! /bin/sh

set -ex

[ -z "$1" ] && echo "Usage: $0 VERSION" && exit 1
VERSION="$1"
DL="https://github.com/prometheus/prometheus/releases/download/"
TAR="$DL/$VERSION/prometheus-${VERSION}.linux-amd64.tar.gz"

DIR=$(mktemp -d)
trap "rm -r $DIR" EXIT
cd $DIR

# Create a layer with slightly less EWW than a RUN command
mkdir -p root/srv/prometheus/timeseries root/bin
wget -O- "$TAR" | tar -C root/srv/prometheus -xz
mv root/srv/prometheus/prometheus root/srv/prometheus/promtool root/bin
tar -C root -czf prometheus.tgz .
rm -r root

cat >Dockerfile <<__DOCKERFILE__
FROM base:busybox-libc
ADD prometheus.tgz /

USER prometheus
WORKDIR /srv/prometheus
EXPOSE 9090
ENTRYPOINT [ "/bin/prometheus" ]
CMD [\
  "-config.file=/srv/prometheus/prometheus.yml", \
  "-storage.local.path=/srv/prometheus/timeseries", \
  "-web.console.libraries=/srv/prometheus/console_libraries", \
  "-web.console.templates=/srv/prometheus/consoles" \
]
__DOCKERFILE__

sudo docker build -t prometheus:prometheus-$(echo -n $VERSION | tr . _) .
