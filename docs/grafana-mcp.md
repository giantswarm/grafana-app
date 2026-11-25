# grafana-mcp

`grafana-mcp` is a second Grafana instance for the [mcp-observability-platform](https://github.com/giantswarm/mcp-observability-platform) MCP server.
The MCP server sends each caller's Dex `id_token` in the `X-JWT-Assertion` header.
`grafana-mcp` verifies the token against Dex (`[auth.jwt]`) and applies the caller's org roles.
It shares the main Grafana's database, so users, orgs, dashboards and datasources are the same on both instances.

`grafanaMcp.enabled: true` turns it on. It is off by default.

## How the chart renders it

The chart declares the upstream Grafana chart a second time, under the alias `grafanaMcp`.
The alias receives `global.*` and none of the `grafana.*` values, so `values.yaml` repeats under `grafanaMcp` every default the instance needs.

- **Names and labels.** `fullnameOverride: grafana-mcp` names its objects `grafana-mcp`.
  Its pods carry `app.kubernetes.io/name: grafanaMcp` and `app.kubernetes.io/instance: <release name>`.
  The Service, ServiceMonitor and policies of the main Grafana select `app.kubernetes.io/name: grafana` and do not select them.
- **Image.** `grafanaMcp.image` must equal `grafana.image` (registry, repository, tag and sha).
  The render fails when they differ, because both instances migrate the same database.
  One Helm upgrade changes both Deployments.
- **Rollout.** One replica, no PodDisruptionBudget.
  The rolling update sets `maxSurge: 1` and `maxUnavailable: 0`, so the new pod is Ready before the old pod stops.
- **Kubernetes API.** No RBAC, no service account token.
- **Exposure.** No ingress. The Service listens on port 3000 inside the cluster. A ServiceMonitor scrapes it.
- **Auth.** The login form and basic auth are off.
  `[auth.jwt]` reads the token from `X-JWT-Assertion`, caches the Dex keys for 5 minutes and signs up users on their first call.
  The login is the Dex connector id and the email, with `@` replaced by `_at_`, for example `giantswarm-github:theo_at_giantswarm.io`.
  No email claim is mapped, so a token never links to an existing user by email.
  Org roles come only from the JWT org mapping, read from the `groups` claim, with strict role mapping.
- **JWT org mapping.** `GF_AUTH_JWT_ORG_MAPPING` reads key `orgMapping` of Secret `grafana-mcp-org-mapping`, which observability-operator writes.
  The reference is optional: without the Secret, `grafana-mcp` starts and every caller gets role None.
- **Alerting.** `[unified_alerting] execute_alerts = false`: only the main Grafana evaluates alerts. The alerting API stays available.
  `grafana-mcp` sets no `ha_peers` and does not join the main Grafana's alert cluster.
- **secret_key.** Neither instance sets one, so both use Grafana's default key and decrypt the same stored secrets.

## Network policies

With `ciliumNetworkPolicy.enabled` (the default), the chart renders the CiliumNetworkPolicy `grafana-mcp`:

- Ingress on port 3000 from the MCP server pods (`grafanaMcp.ciliumNetworkPolicy.mcpClients`), the image renderer and the metrics scrapers (`grafanaMcp.ciliumNetworkPolicy.metricsScrapers`).
- Egress to the database, the image renderer, DNS, and the `cluster` and `world` entities for Dex and the datasources, the same as the main Grafana.

With the image renderer on, the CiliumNetworkPolicy `grafana-image-renderer` and the NetworkPolicy `grafana-mcp-image-renderer-ingress` admit render requests from `grafana-mcp`, and the renderer may call `grafana-mcp` back.
The CiliumNetworkPolicy `grafana-postgresql` admits `app.kubernetes.io/instance: grafana`, which the `grafana-mcp` pods carry.

## Installation values

The installation supplies the settings that depend on it: the Dex URLs, the database, the image renderer and the plugins. For example:

```yaml
grafanaMcp:
  enabled: true
  env:
    GF_PLUGINS_PREINSTALL: "marcusolsson-treemap-panel, marcusolsson-json-datasource"
    GF_RENDERING_SERVER_URL: http://grafana-image-renderer.monitoring:8081/render
    GF_RENDERING_CALLBACK_URL: http://grafana-mcp.monitoring:3000/
  envValueFrom:
    GF_DATABASE_PASSWORD:
      secretKeyRef:
        name: grafana-postgresql-app
        key: password
    GF_RENDERING_RENDERER_TOKEN:
      secretKeyRef:
        name: grafana-image-renderer
        key: token
  grafana.ini:
    auth.jwt:
      jwk_set_url: https://dex.example.com/keys
      expect_claims: '{"iss": "https://dex.example.com", "aud": "mcp-observability-platform"}'
    database:
      type: postgres
      host: grafana-postgresql-rw:5432
      name: app
      user: app
```
