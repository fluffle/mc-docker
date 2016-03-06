#! /bin/sh

set -x

# temporary root dir
DIR=$(mktemp -d)
trap "rm -r $DIR" EXIT
cd $DIR

# packages
apt-get download busybox-static openjdk-8-jre-headless \
  libc6 libstdc++6 libgcc1 zlib1g
for i in *.deb; do dpkg-deb -x $i .; done
rm -r usr/share *.deb
(cd bin; for i in $(./busybox --list) ; do ln -s busybox $i ; done)

# users/groups/nss
cp /etc/passwd etc/passwd
cp /etc/group etc/group
cp /etc/nsswitch.conf etc/nsswitch.conf

# CA certs from system, because ca-certificates-java installs a hook :/
mkdir -p etc/ssl/certs/java
cp /etc/ssl/certs/java/cacerts etc/ssl/certs/java

# Somewhere to put services
mkdir srv

tar c . | docker import - base:java-jre8
