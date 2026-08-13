[![CircleCI](https://circleci.com/gh/giantswarm/grafana-app.svg?style=shield)](https://circleci.com/gh/giantswarm/grafana-app)

# grafana-app chart

Giant Swarm offers a Grafana Managed App which can be installed in tenant clusters.
This chart is almost an exact copy of the upstream [Grafana Chart](https://github.com/grafana/helm-charts).

Changes compared to upstream:

- images URLs are set to use Giant Swarm's HA registries
- AppArmor for PSPs is disabled
- requests/limits are enabled
- the Grafana logo and favicon are replaced with Giant Swarm's (see [Branding](#branding))

## Configuration

Please refer [this file](helm/grafana/Chart.yaml) for available config options and more info.
Please note, that by default only the main grafana pod has requests and limits set for resources.

## Branding

Grafana OSS has no white-labeling settings - those are an Enterprise feature - so we brand it by
mounting our own files over the ones the image ships. The assets live in
[helm/grafana/branding](helm/grafana/branding), go into a ConfigMap via
[branding-configmap.yaml](helm/grafana/templates/branding-configmap.yaml) and are mounted by the
`giantswarm-branding-*` entries of `grafana.extraConfigmapMounts` in
[values.yaml](helm/grafana/values.yaml).

| Asset | Replaces | Shows up in |
| --- | --- | --- |
| `grafana_icon.svg` | `public/build/static/img/grafana_icon.<hash>.svg` | nav bar logo, login page logo |
| `fav32.png` | `public/build/img/fav32.png` | browser tab icon |
| `apple-touch-icon.png` | `public/build/img/apple-touch-icon.png` | iOS home screen icon |

The logo and favicon are the Giant Swarm logo mark from
[giantswarm/brand](https://github.com/giantswarm/brand), cropped to a square viewBox because
Grafana's logo slots are square.

Notes:

- **The logo path contains a webpack content hash and has to be checked after a Grafana upgrade.**
  It hashes Grafana's own logo file, so it only changes when upstream changes that logo. Get the
  current name with
  `docker run --rm --entrypoint ls grafana/grafana:<appVersion> /usr/share/grafana/public/build/static/img/grafana_icon.*.svg`.
  If it drifts, the mount lands on an unused file and Grafana shows its own logo again.
- `subPath` mounts are not updated in place by kubelet, so the Grafana pod has to be restarted after
  changing an asset.
- To go back to Grafana's own branding, set `grafana.extraConfigmapMounts` to `[]`.
- Only assets can be changed this way, and the app keeps calling itself `Grafana` - the product name
  in the nav bar, the browser tab title and the `Welcome to Grafana` heading are JavaScript
  constants compiled into hashed bundles, and renaming them would mean rewriting the DOM in the
  browser. The login page background is bundled the same way. Changing any of it is Enterprise
  white-labeling territory.

## Statefulness

Our grafana app can be stateful by using a postgresql cluster managed by the cloudnative-pg operator. For more information on how this works, see the following [page](https://intranet.giantswarm.io/docs/support-and-ops/processes/manage-postgresql-databases/).

## Credit

- <https://github.com/grafana/helm-charts>
