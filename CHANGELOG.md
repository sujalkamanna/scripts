## CHANGELOG.md

### v1.0.0 (Previous)
- Prometheus v3.2.1 and Grafana not installed / not configured for AWS VPC monitoring setup.

### v1.1.0 (Current)
- Prometheus upgraded/standardized to v3.2.1 with production systemd configuration and Grafana OSS installed and configured (latest stable release) for dashboard integration with Prometheus data source.

## CHANGELOG.md

### v1.0.0 (Previous)
- Grafana not installed or configured; Prometheus metrics were accessed directly without visualization dashboards.

### v1.1.0 (Current)
- Grafana OSS installed (latest stable version) on monitoring server and integrated with Prometheus 3.2.1 as a data source, enabling prebuilt dashboards for Node Exporter (1860) and Blackbox Exporter (7587).