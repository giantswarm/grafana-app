# Image rendering

The chart can deploy the [Grafana image renderer](https://github.com/grafana/grafana-image-renderer). It is disabled by default.
It powers:

* Panel and dashboard PNG export, via Share → Link → Generate image.
* Images in alert notifications.

When enabled, the chart configures Grafana to use the renderer.
It generates the shared renderer token into a Secret. Set `grafana.imageRenderer.token` or `grafana.imageRenderer.existingSecret` to provide your own.

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

## Callback URL

The renderer calls back into Grafana to load the page it renders.
Set `grafanaProtocol` to `https` when Grafana serves TLS itself.
Set `grafanaSubPath` when Grafana runs under a sub-path (`serve_from_sub_path`).

```yaml
grafana:
  imageRenderer:
    grafanaProtocol: https
    grafanaSubPath: /grafana
```

## Scaling

The renderer runs one replica. Set `grafana.imageRenderer.replicas` for a fixed count, or enable autoscaling:

```yaml
grafana:
  imageRenderer:
    autoscaling:
      enabled: true
      minReplicas: 1
      maxReplicas: 5
      targetCPU: "60"
```

## Network policies

A NetworkPolicy lets only Grafana pods reach the renderer on port 8081.
With `ciliumNetworkPolicy.enabled` (the default), the chart also creates the `grafana-image-renderer` CiliumNetworkPolicy:

* Ingress: from Grafana pods on 8081/TCP.
* Egress: to Grafana pods on 3000/TCP, for the callback URL.
* Egress: to `world` on 443/TCP, for external content that dashboards embed.
* Egress: to `coredns` and `k8s-dns-node-cache` in `kube-system` on 53 and 1053, UDP and TCP.

`grafana.imageRenderer.serviceMonitor` is disabled. To enable it, allow the scraper through `grafana.imageRenderer.networkPolicy.extraIngressSelectors`:

```yaml
grafana:
  imageRenderer:
    serviceMonitor:
      enabled: true
    networkPolicy:
      extraIngressSelectors:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring
          podSelector:
            matchLabels:
              app.kubernetes.io/name: prometheus
```

Cilium policies are additive. Add a separate CiliumNetworkPolicy that allows the scraper on port 8081, for example via `grafana.extraObjects`:

```yaml
grafana:
  extraObjects:
    - apiVersion: cilium.io/v2
      kind: CiliumNetworkPolicy
      metadata:
        name: grafana-image-renderer-metrics
      spec:
        endpointSelector:
          matchLabels:
            app.kubernetes.io/name: grafana-image-renderer
        ingress:
          - fromEndpoints:
              - matchLabels:
                  k8s:io.kubernetes.pod.namespace: monitoring
                  app.kubernetes.io/name: prometheus
            toPorts:
              - ports:
                  - port: "8081"
                    protocol: TCP
```
