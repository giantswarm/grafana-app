# Image rendering

The chart can deploy the [Grafana image renderer](https://github.com/grafana/grafana-image-renderer). It is disabled by default.
It powers:

* Panel and dashboard PNG export, via Share → Link → Generate image.
* Images in alert notifications.

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

The `grafana` CiliumNetworkPolicy selects only Grafana pods, so the renderer pod needs its own policy to pass traffic under the cluster default-deny policies.

With `ciliumNetworkPolicy.enabled` (the default), the chart creates the `grafana-image-renderer` CiliumNetworkPolicy:

* Ingress: from Grafana pods on 8081/TCP.
* Egress: to Grafana pods on 3000/TCP, for the callback URL.
* Egress: to `world` on 443/TCP, for external content that dashboards embed.
* Egress: to `coredns` and `k8s-dns-node-cache` in `kube-system` on 53 and 1053, UDP and TCP.
