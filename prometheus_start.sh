exec docker run -d -p 9090:9090 \
      -v /data/prometheus/timeseries:/srv/prometheus/timeseries:rw \
      -v /data/prometheus/prometheus.yml:/srv/prometheus/prometheus.yml:ro \
      --link node_exporter:node-exporter --link infinity:infinity \
      --restart always --name prometheus prometheus:prometheus-0_15_0rc1
