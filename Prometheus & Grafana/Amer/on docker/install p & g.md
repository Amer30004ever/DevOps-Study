# Pull and run Prometheus
    docker pull bitnami/prometheus
	docker run -d --name prometheus --restart always -p 9090:9090 bitnami/prometheus

    # Pull and run Grafana
    docker pull grafana/grafana
	docker run -d --name grafana --restart always -p 3000:3000 grafana/grafana 