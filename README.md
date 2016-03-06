# mc-docker

Some hacky shell scripts to build relatively slimline docker
containers for modded minecraft servers. No warranty is provided,
these scripts may destroy your data, mess with your head or fuck
your mother. You have been warned.

# Assumptions inherent in these scripts

0.  You are running debian wheezy :-)
1.  Everything outside the container is stored in `/data/minecraft`.
2.  Each server instance has three volumes mounted into it.
    These directories must all exist, probably under `/data/minecraft`.
	1.  The world, e.g. `rr3_world` or `inf_world`.
	2.  The configs, e.g. `rr3_config` or `inf_config`.
	3.  The backups, e.g. `rr3_backups` or `inf_backups`.
3.  The config directory (b) above has an already-initialized git
    repository in it with two branches, `master` and `prod`. Only
	make manual changes to config files in the `prod` branch, and
	when you update new versions, your changes will be rebased on
	top of the new version configs. Theoretically. This step is
	a little flaky ;-)
4.  Various `.zs`, `.json` config files and `server.properties`
    exist in `/data/minecraft/configs` to configure the server.
5.  You want all the additional mods in `/data/minecraft/mods`
    to be added to the modpack.

# Quick build HOWTO for Infinity Evolved

1.  Run `java-jre8.sh`.
2.  Run `infinity_build.sh 2.4.0`.
3.  Run `infinity_start.sh`.
4.  Run `docker attach infinity` to get a console.

If you care about monitoring, you can set up a Prometheus container
and a node-exporter container with the other scripts provided. You
can get the prometheus integration mod for minecraft here:

http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2413629-prometheus-server-monitoring-integration
https://github.com/Baughn/PrometheusIntegration

