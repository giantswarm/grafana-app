[![CircleCI](https://circleci.com/gh/giantswarm/grafana-app.svg?style=shield)](https://circleci.com/gh/giantswarm/grafana-app)

# grafana-app chart

Giant Swarm offers a Grafana Managed App which can be installed in tenant clusters.
This chart is almost an exact copy of the upstream [Grafana Chart](https://github.com/grafana/helm-charts).

Changes compared to upstream:

- images URLs are set to use Giant Swarm's HA registries
- AppArmor for PSPs is disabled
- requests/limits are enabled

## Configuration

Please refer [this file](helm/grafana/Chart.yaml) for available config options and more info.
Please note, that by default only the main grafana pod has requests and limits set for resources.

## Credit

- <https://github.com/grafana/helm-charts>
