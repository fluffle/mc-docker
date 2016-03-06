#! /bin/sh

set -x

# temporary root dir
DIR=$(mktemp -d)
trap "rm -r $DIR" EXIT
cd $DIR

# busybox and libc6
apt-get download busybox-static libc6
dpkg-deb -x busybox-static*.deb .
dpkg-deb -x libc6*.deb .
rm -r usr/share *.deb
(cd bin; for i in $(./busybox --list) ; do ln -s busybox $i ; done)

# users/groups/nss
cp /etc/passwd etc/passwd
cp /etc/group etc/group
cp /etc/nsswitch.conf etc/nsswitch.conf

# somewhere to put services
mkdir srv

tar c . | docker import - base:busybox-libc
