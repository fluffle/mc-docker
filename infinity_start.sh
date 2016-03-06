exec docker run -d -it \
      -p 25565:25565 -p 25565:25565/udp \
      -v /data/minecraft/inf_world:/srv/minecraft/world:rw \
      -v /data/minecraft/inf_config:/srv/minecraft/config:rw \
      -v /data/minecraft/inf_backups:/srv/minecraft/backups:rw \
      --restart=always --name infinity --cpuset-cpus='1-3' \
      minecraft:infinity-2.3.5
