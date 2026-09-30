# Image rendering

The chart can deploy the [Grafana image renderer](https://github.com/grafana/grafana-image-renderer). It is disabled by default.
It powers:

* Panel PNG export, via the panel menu → Share → Share link → Generate image.
* Dashboard PNG export, via Export → Export as image.

To enable the renderer:

```yaml
grafana:
  imageRenderer:
    enabled: true
```

## Chart defaults

The chart overrides these upstream `grafana.imageRenderer` values:

* `image`: `gsoci.azurecr.io/giantswarm/grafana-image-renderer:v5.12.4` with `pullPolicy: IfNotPresent`.
* `securityContext`: `runAsNonRoot`, UID/GID/fsGroup `65532` and seccomp `RuntimeDefault`. It meets the Pod Security Standards restricted profile.
* `resources`: requests `100m` CPU, `256Mi` memory and `64Mi` ephemeral-storage. Limits `1Gi` memory and `512Mi` ephemeral-storage.

## CiliumNetworkPolicy

The `grafana-image-renderer` CiliumNetworkPolicy lets the renderer fetch external resources, such as images or feeds.
Otherwise the image rendering would fail for dashboards referencing external content.

With `ciliumNetworkPolicy.enabled` (the default), the chart creates the `grafana-image-renderer` CiliumNetworkPolicy:

* Ingress: from Grafana pods on 8081/TCP.
* Egress: to Grafana pods on 3000/TCP, for the callback URL.
* Egress: to `world` on 443/TCP, for external content that dashboards embed.
* Egress: to `coredns` and `k8s-dns-node-cache` in `kube-system` on 53 and 1053, UDP and TCP.
