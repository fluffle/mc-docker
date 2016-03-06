exec docker run -d -it \
      -p 25565:25565 -p 25565:25565/udp \
      -v /data/minecraft/rr3_world:/srv/minecraft/world:rw \
      -v /data/minecraft/rr3_config:/srv/minecraft/config:rw \
      -v /data/minecraft/rr3_backups:/srv/minecraft/backups:rw \
      --restart=always --name resonantrise --cpuset-cpus='1-3' \
      minecraft:resonantrise-3270rc
