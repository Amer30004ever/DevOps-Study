# Local Monitoring Stack with Node Exporter, Prometheus, and Grafana

```plaintext
Prometheus Server  
│  
▼  
Node_Exporter  
│  
▼  
Grafana  
│  
▼  
localhost:3000
```

## Prerequisites
- Docker installed
- Docker Compose installed
- Portainer (optional, but recommended for management)

## Setup Instructions

### 1. Run Portainer (Optional)
Use the following steps to run Portainer locally using Docker:
[Insert your Portainer setup link here]

### 2. Deploy Monitoring Stack

#### Using Portainer:
1. Create a Stack named "monitoring"
2. Copy the contents of `node-exporter/docker-compose.yml` into the stack web editor
3. Deploy the stack

#### Using Docker CLI:
```bash
# Create necessary network
docker network create monitoring_default

# Node Exporter
docker run -d --name node-exporter -p 9100:9100 --network monitoring_default prom/node-exporter
```

### 3. Deploy Prometheus

```bash
# Create volume and run Prometheus
docker volume create prometheus_data
cd prometheus_config/

docker run -d \
  --name prometheus-docker \
  -p 9090:9090 \
  --mount type=bind,source=$PWD/prometheus.yml,target=/etc/prometheus/prometheus.yml \
  --network monitoring_default \
  prom/prometheus
```

**Verification:**
- Access Prometheus at: http://localhost:9090
- Navigate to Status → Targets to verify node-exporter is running

### 4. Deploy Grafana

```bash
# Create volume and run Grafana
docker volume create grafana_data

docker run -d \
  --name grafana-docker \
  -p 3000:3000 \
  -v grafana_data:/var/lib/grafana \
  --network monitoring_default \
  grafana/grafana
```

### 5. Configure Grafana

1. Access Grafana at: http://localhost:3000
   - Default credentials: admin/admin (you'll be prompted to change password)
   
2. Add Prometheus as Data Source:
   - Navigate to Configuration → Data Sources → Prometheus
   - Set URL: `http://<YOUR_MACHINE_IP>:9090`
   - Click "Save & Test"

3. Import Dashboard:
   - Navigate to Dashboards → Import
   - Use dashboard ID: 1860
   - Select Prometheus as data source
   - Click "Import"

## Accessing the Monitoring Stack

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000
- **Node Exporter Metrics**: http://localhost:9100/metrics

## Troubleshooting

1. If services can't communicate:
   - Verify all containers are on the same network (`monitoring_default`)
   - Check container logs: `docker logs <container_name>`

2. If dashboard isn't showing data:
   - Verify Prometheus is scraping Node Exporter (check Targets)
   - Verify Grafana's data source URL is correct
```
