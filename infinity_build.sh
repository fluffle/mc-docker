#! /bin/sh

set -x

[ -z "$1" ] && echo "Usage: $0 VERSION" && exit 1
VERSION="$1"
ZIP="/data/minecraft/servers/FTBInfinityServer-${VERSION}-1.7.10.zip"
[ ! -f "$ZIP" ] && echo "Could not find $ZIP" && exit 1

# Temp dir
DIR="$(mktemp -d)"
trap "rm -r $DIR" EXIT
chmod 755 $DIR
cd $DIR

# Unzip the server
unzip "$ZIP"

# Run the "installer" to get Minecraft .jar
sh -x FTBInstall.sh

# Copy out updated configs, commit them, and rebase our changes onto them.
sudo -u minecraft sh -c "
  cd /data/minecraft/inf_config;
  git reset --hard HEAD;
  git checkout master;
  cp -a $DIR/config/* .;
  git add .;
  git commit -m '$VERSION configs';
  git rebase master prod;"
rm -r config

# Copy in configs and additional server-side mods
cp /data/minecraft/configs/server.properties .
cp /data/minecraft/configs/*.json .
cp /data/minecraft/configs/*.zs modpack/expert/scripts
cp /data/minecraft/mods/* mods

# Agree to the EULA, lols.
sed -i 's/eula=false/eula=true/' eula.txt

# Figure out the FTB server .jar version
FTB="$(ls FTBServer-1.7.10*.jar)"

# Write out the dockerfile. Hooray for having to do a separate chmod.
cat >Dockerfile <<__DOCKERFILE__
FROM base:java-jre8
COPY . /srv/minecraft
RUN ["/bin/busybox", "chown", "-R", "minecraft:minecraft", "/srv/minecraft"]

USER minecraft
WORKDIR /srv/minecraft
EXPOSE 25565 25565/udp 9101
ENTRYPOINT [\
  "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java", \
  "-Xms4g", "-Xmx4g", \
  "-XX:MetaspaceSize=256M", "-XX:MaxMetaspaceSize=256M", \
  "-XX:NewSize=2g", "-XX:MaxNewSize=2g", \
  "-XX:+UseConcMarkSweepGC", "-XX:+UseParNewGC", \
  "-XX:CMSInitiatingOccupancyFraction=95", "-Xloggc:gc.log", \
  "-verbose:gc", "-XX:+PrintGCDetails", "-XX:+PrintGCDateStamps", \
  "-XX:+UseGCLogFileRotation", "-XX:NumberOfGCLogFiles=10", \
  "-XX:GCLogFileSize=1M", "-XX:+PrintTenuringDistribution", \
  "-XX:+HeapDumpOnOutOfMemoryError", "-XX:GCTimeLimit=80", \
  "-XX:GCHeapFreeLimit=20", "-XX:HeapDumpPath=/srv/minecraft/backups", \
  "-XX:+UseGCOverheadLimit", "-jar", "$FTB", "nogui" \
]
__DOCKERFILE__

sudo docker build -t minecraft:infinity-$(echo -n $VERSION | tr A-Z a-z) .
