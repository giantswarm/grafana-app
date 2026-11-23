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

Two things about this cannot be expressed in the chart itself, so
[hack/branding.sh](hack/branding.sh) keeps them honest. The `verify-branding` CircleCI job runs it
on every push and gates the catalog pushes:

- **The logo path contains a webpack content hash**, so a Grafana upgrade can move the file we mount
  over. The hash is of Grafana's own logo file, so it only changes when upstream changes that logo,
  but when it does the mount silently lands on a file nobody reads and Grafana shows its own logo
  again. The script compares the path against the image the chart deploys.
- **`subPath` mounts are not updated in place by kubelet**, so the Grafana pod has to restart to pick
  up a changed asset. The `checksum/giantswarm-branding` pod annotation in `values.yaml` makes that
  automatic. Helm cannot compute it - the pod template comes from the upstream subchart, which does
  not template `podAnnotations` and could not read this chart's files anyway - so the script
  generates it.

After changing anything in `branding/`, or when the check fails after a Grafana bump:

```
make branding-update
```

To go back to Grafana's own branding, set `grafana.extraConfigmapMounts` to `[]`.

Note that only assets can be changed this way, and the app keeps calling itself `Grafana` - the product name
  in the nav bar, the browser tab title and the `Welcome to Grafana` heading are JavaScript
  constants compiled into hashed bundles, and renaming them would mean rewriting the DOM in the
  browser. The login page background is bundled the same way. Changing any of it is Enterprise
  white-labeling territory.

## Statefulness

Our grafana app can be stateful by using a postgresql cluster managed by the cloudnative-pg operator. For more information on how this works, see the following [page](https://intranet.giantswarm.io/docs/support-and-ops/processes/manage-postgresql-databases/).

The cluster comes with a `PodMonitor`, which needs the Prometheus Operator CRDs. On a cluster without them, set `postgresqlCluster.podMonitor.enabled: false`.

### Backups

With `postgresqlCluster.backup.enabled: true`, the cluster is backed up through the barman-cloud plugin. The S3 credentials come from the first of these that is set:

1. Inline keys: `postgresqlCluster.objectStorage.s3.accessKeyId` and `secretAccessKey`. The chart renders them into a Secret.
2. An existing Secret: `postgresqlCluster.objectStorage.s3.existingSecret` (`name`, `accessKeyIdKey`, `secretAccessKeyKey`). Use it to give backups their own, bucket-scoped keys.
3. The parent chart's `global.objectStorage.existingSecret`, on the Standalone Observability Platform (see below).
4. The pod's IAM role (`inheritFromIAMRole`).

On the Standalone Observability Platform, which sets `global.objectStorage` with backend `s3`, the chart falls back to the platform's store while it sets no `endpointURL` and no keys of its own:

- **Endpoint:** `https://` or, with `insecure`, `http://`, followed by `global.objectStorage.s3.endpoint`.
- **Region:** `global.objectStorage.s3.region`. barman reads it from a Secret, so the chart renders `<cluster>-s3-region`.
- **Destination:** `s3://<global.objectStorage.buckets.grafanaPostgresql>/`, unless `backup.destinationPath` is set.
- **Credentials:** the platform's credentials Secret, keys `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. The render fails if neither it nor `s3.existingSecret` names a Secret, rather than falling back to the IAM role.

Two more settings apply on every S3 path:

- `postgresqlCluster.objectStorage.s3.endpointCA` (`name`, `key`): a Secret in the release namespace holding the CA bundle of a store behind a private CA.
- `postgresqlCluster.backup.encryption.data` and `.wal`: server-side encryption, `AES256` or `aws:kms`. Empty uses the bucket's policy. The render fails if they're set with `objectStorage.type: azure`.

## Credit

- <https://github.com/grafana/helm-charts>
