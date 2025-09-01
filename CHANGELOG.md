# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- upgrade grafana chart: 9.3.6 => 9.4.3
- upgrade grafana : 12.1.0 => 12.1.1

## [2.25.2] - 2025-08-27

### Changed

- upgrade pg-cluster-recovery-test subchart: v0.2.2 => v0.2.3

## [2.25.1] - 2025-08-27

### Changed

- upgrade pg-cluster-recovery-test subchart: v0.2.0 => v0.2.2
- upgrade grafana chart: 9.3.1 => 9.3.6

## [2.25.0] - 2025-08-07

### Changed

- upgrade grafana chart: 9.2.10 => 9.3.1
- upgrade grafana : 12.0.2 => 12.1.0

## [2.24.3] - 2025-07-29

### Changed

- Updated pg-cluster-recovery-test subchart: v0.1.6 => v0.2.0

## [2.24.2] - 2025-07-10

### Changed

- upgrade grafana chart: 9.2.1 => 9.2.10
- upgrade grafana : 12.0.0-security-01 => 12.0.2

## [2.24.1] - 2025-07-03

### Changed

- Updated pg-cluster-recovery-test subchart: v0.1.5 => v0.1.6

## [2.24.0] - 2025-06-30

### Changed

- Updated dependencies (pg-cluster-recovery-test subchart, architect and docker tags).

## [2.23.0] - 2025-06-05

### Added

- Add `pg-cluster-recovery-test` as chart dependency.

## [2.22.1] - 2025-05-28

### Changed

- upgrade grafana chart: 9.0.0 => 9.2.1
- upgrade grafana : 12.0.0 => 12.0.0-security-01

## [2.22.0] - 2025-05-09

### Changed

- upgrade grafana chart: 8.15.0 => 9.0.0
- upgrade grafana : 11.6.1 => 12.0.0

## [2.21.1] - 2025-05-09

### Changed

- upgrade grafana chart: 8.14.0 => 8.15.0

## [2.21.0] - 2025-04-30

### Changed

- upgrade grafana chart: 8.11.3 => 8.14.0
- upgrade grafana : 11.5.1 => 11.6.1

### Fixed

- Fix CNP apiversion and fix changelog and app version.

## [2.20.0] - 2025-04-07

### Changed

- upgrade grafana chart: 8.9.0 => 8.11.3

## [2.19.0] - 2025-02-06

### Changed

- upgrade grafana chart: 8.6.4 => 8.9.0
- upgrade grafana : 11.3.1 => 11.5.1

## [2.18.0] - 2024-12-03

### Changed

- Add Ingress dummy paths to block access to the `/swagger`, `/metrics`, and `/api/health` endpoints by default.
- upgrade grafana chart: 8.5.12 => 8.6.0

## [2.17.0] - 2024-11-07

### Changed

- upgrade grafana chart: 8.5.2 => 8.5.12
- upgrade grafana : 11.2.1 => 11.3.0

## [2.16.3] - 2024-10-08

### Fixed

- Attempt to fix CI builds on tags, take 2.

## [2.16.2] - 2024-10-07

### Fixed

- Attempt to fix CI builds on tags.

## [2.16.1] - 2024-10-07

### Fixed

- Fix CI jobs generating new releases

## [2.16.0] - 2024-10-07

### Changed

- upgrade grafana chart: 8.3.4 => 8.5.2
- upgrade grafana : 11.1.3 => 11.2.1

## [2.15.0] - 2024-08-19

### Changed

- Update tests for ats usage.

## [2.14.0] - 2024-08-13

### Changed

- upgrade grafana chart: 8.3.4 => 8.4.4
- upgrade grafana : 11.1.0 => 11.1.3

## [2.13.0] - 2024-07-15

### Changed

- upgrade grafana chart: 8.2.0 => 8.3.4
- upgrade grafana : 11.0.0 => 11.1.0

## [2.12.0] - 2024-06-13

### Changed

- upgrade grafana chart: 7.3.12 => 8.0.2
- upgrade grafana : 10.4.3 => 11.0.0

## [2.11.1] - 2024-06-12

### Changed

- upgrade grafana chart: 7.3.7 => 7.3.12
- upgrade grafana : 10.4.0 => 10.4.3

## [2.11.0] - 2024-03-19

### Changed

- upgrade grafana chart: 7.3.0 => 7.3.7
- upgrade grafana : 10.3.1 => 10.4.0

## [2.10.1] - 2024-02-19

### Fixed

- Fix `CiliumNetworkPolicy` to allow cluster ingress (for e.g. Prometheus).
- 
## [2.10.0] - 2024-02-09

### Changed

- upgrade grafana chart: 7.2.4 => 7.3.0
- upgrade grafana : 10.2.3 => 10.3.1

## [2.9.0] - 2024-01-23

### Changed

- upgrade grafana chart: 7.0.19 => 7.2.4
- upgrade grafana : 10.2.2 => 10.2.3

## [2.8.1] - 2024-01-23

### Fixed

- Fix `CiliumNetworkPolicy` to allow access to the internet (required to download plugins).

## [2.8.0] - 2024-01-23

### Added

- Add `CiliumNetworkPolicy`.

### Changed

- upgrade grafana chart: 7.0.11 => 7.0.19

## [2.7.1] - 2023-12-20

### Changed

- Configure `gsoci.azurecr.io` as the default container image registry.

## [2.7.0] - 2023-12-04

### Changed

- upgrade grafana chart: 7.0.1 => 7.0.11
- upgrade grafana : 10.1.5 => 10.2.2

## [2.6.0] - 2023-10-30

### Changed

- upgrade grafana chart: 6.58.7 => 7.0.1
- upgrade grafana : 10.0.3 => 10.1.5

## [2.5.0] - 2023-08-08

### Changed

- push grafana-app to cloud-director and vsphere collections.
- upgrade grafana chart: 6.56.4 => 6.58.7
- upgrade grafana: 9.5.2 => 10.0.3

## [2.4.1] - 2023-05-15

### Changed

- upgrade grafana chart: 6.56.1 => 6.56.4
- upgrade grafana: 9.5.1 => 9.5.2

## [2.4.0] - 2023-05-08

### Changed

- upgrade grafana chart: 6.55.1 => 6.56.1
- upgrade grafana: 9.4.7 => 9.5.1

### Removed

- Stop pushing to `openstack-app-collection`.

## [2.3.3] - 2023-04-27

### Changed

- upgrade grafana chart: 6.53.0 => 6.55.1

## [2.3.2] - 2023-04-17

### Changed

- upgrade grafana chart: 6.52.8 => 6.53.0

## [2.3.1] - 2023-04-06

### Changed

- upgrade grafana chart: 6.52.4 => 6.52.8
- upgrade grafana: 9.4.3 => 9.4.7

## [2.3.0] - 2023-03-27

### Changed

- upgrade grafana chart: 6.51.3 => 6.52.4
- upgrade grafana: 9.3.8 => 9.4.3

## [2.2.1] - 2023-03-07

### Changed

- upgrade grafana chart: 6.50.5 => 6.51.3
- upgrade grafana: 9.3.6 => 9.3.8

## [2.2.0] - 2023-01-30

### Changed

- upgrade grafana chart: 6.44.7 => 6.50.5
- upgrade grafana: 9.2.5 => 9.3.6

## [2.1.0] - 2022-11-28

### Changed

- Upgrade grafana upstream version.

## [2.0.2] - 2022-11-22

- pspUseAppArmor disabled

## [2.0.1] - 2022-11-21

- Push app to gcp-collection

## [2.0.0] - 2022-11-21

### Breaking change ⚠️

- You have to update your values.yaml by moving the whole content under a `grafana:` section. See default `values.yaml` for reference.

## [1.1.0] - 2022-09-22

- Upgrade upstream chart from version 6.31.0 to 6.37.0, and grafana from 9.0.1. to 9.1.9. This release includes a small set of breaking changes that you can check [here](https://grafana.com/docs/grafana/latest/release-notes/release-notes-9-1-0/#breaking-changes).

## [1.0.3] - 2022-08-09

### Changed

- New version to trigger deployment everywhere to fix grafana serviceMonitor.

## [1.0.2] - 2022-08-05

## [1.0.1] - 2022-06-24

### Fixed

- Fix incorrect podsecuritypolicy api version.

## [1.0.0] - 2022-06-24

### Changed

- Upgrade upstream chart from version 6.24.1 to 6.31.0, and grafana from 8.4.2 to 9.0.1. This release includes a small set of breaking changes that you can check [here](https://grafana.com/docs/grafana/latest/release-notes/release-notes-9-0-0/#breaking-changes).

This release also allows some existing values to be templetized (tpl function) and adds a bit more configurability options (e.g. network policies)

## [0.4.0] - 2022-04-04

### Changed

- Upgrade to version 6.24.1 of the upstream chart.

## [0.3.4] - 2022-03-31

### Fixed

- Add missing config annotation to the chart.

## [0.3.3] - 2022-03-31

### Fixed

- Rename app to grafana instead of grafana-app

## [0.3.2] - 2022-03-31

### Fixed

- Fix app name in circle ci.

## [0.3.1] - 2022-03-31

### Added

- Push to control plane catalogs.

## [0.3.0] - 2021-12-16

### Changed

- Upgrade Grafana to 8.3.2 to fix some CVEs including CVE-2021-43813 and CVE-2021-43798
- Disable app armor by default

## [0.2.1] - 2021-11-03

- Update app metadata

## [0.2.0] - 2021-03-15

Changed:

- Upgraded charts from [upstream](https://github.com/grafana/helm-charts/tree/main/charts/grafana)
- Upgraded Grafana image version to `7.4.3`

## [0.1.0-alpha1] - 2020-11-10

Added:

- initial import of upstream repo
- disabled AppArmor in PSP
- added test run with `kube-app-testing`
- images retagged for Giant Swarm registries
- simple functionality test to get login web page

[Unreleased]: https://github.com/giantswarm/grafana-app/compare/v2.25.2...HEAD
[2.25.2]: https://github.com/giantswarm/grafana-app/compare/v2.25.1...v2.25.2
[2.25.1]: https://github.com/giantswarm/grafana-app/compare/v2.25.0...v2.25.1
[2.25.0]: https://github.com/giantswarm/grafana-app/compare/v2.24.3...v2.25.0
[2.24.3]: https://github.com/giantswarm/grafana-app/compare/v2.24.2...v2.24.3
[2.24.2]: https://github.com/giantswarm/grafana-app/compare/v2.24.1...v2.24.2
[2.24.1]: https://github.com/giantswarm/grafana-app/compare/v2.24.0...v2.24.1
[2.24.0]: https://github.com/giantswarm/grafana-app/compare/v2.23.0...v2.24.0
[2.23.0]: https://github.com/giantswarm/grafana-app/compare/v2.22.1...v2.23.0
[2.22.1]: https://github.com/giantswarm/grafana-app/compare/v2.22.0...v2.22.1
[2.22.0]: https://github.com/giantswarm/grafana-app/compare/v2.21.1...v2.22.0
[2.21.1]: https://github.com/giantswarm/grafana-app/compare/v2.21.0...v2.21.1
[2.21.0]: https://github.com/giantswarm/grafana-app/compare/v2.20.0...v2.21.0
[2.20.0]: https://github.com/giantswarm/grafana-app/compare/v2.19.0...v2.20.0
[2.19.0]: https://github.com/giantswarm/grafana-app/compare/v2.18.0...v2.19.0
[2.18.0]: https://github.com/giantswarm/grafana-app/compare/v2.17.0...v2.18.0
[2.17.0]: https://github.com/giantswarm/grafana-app/compare/v2.16.3...v2.17.0
[2.16.3]: https://github.com/giantswarm/grafana-app/compare/v2.16.2...v2.16.3
[2.16.2]: https://github.com/giantswarm/grafana-app/compare/v2.16.1...v2.16.2
[2.16.1]: https://github.com/giantswarm/grafana-app/compare/v2.16.0...v2.16.1
[2.16.0]: https://github.com/giantswarm/grafana-app/compare/v2.15.0...v2.16.0
[2.15.0]: https://github.com/giantswarm/grafana-app/compare/v2.14.0...v2.15.0
[2.14.0]: https://github.com/giantswarm/grafana-app/compare/v2.13.0...v2.14.0
[2.13.0]: https://github.com/giantswarm/grafana-app/compare/v2.12.0...v2.13.0
[2.12.0]: https://github.com/giantswarm/grafana-app/compare/v2.11.1...v2.12.0
[2.11.1]: https://github.com/giantswarm/grafana-app/compare/v2.11.0...v2.11.1
[2.11.0]: https://github.com/giantswarm/grafana-app/compare/v2.10.1...v2.11.0
[2.10.1]: https://github.com/giantswarm/grafana-app/compare/v2.10.0...v2.10.1
[2.10.0]: https://github.com/giantswarm/grafana-app/compare/v2.9.0...v2.10.0
[2.9.0]: https://github.com/giantswarm/grafana-app/compare/v2.8.1...v2.9.0
[2.8.1]: https://github.com/giantswarm/grafana-app/compare/v2.8.0...v2.8.1
[2.8.0]: https://github.com/giantswarm/grafana-app/compare/v2.7.1...v2.8.0
[2.7.1]: https://github.com/giantswarm/grafana-app/compare/v2.7.0...v2.7.1
[2.7.0]: https://github.com/giantswarm/grafana-app/compare/v2.6.0...v2.7.0
[2.6.0]: https://github.com/giantswarm/grafana-app/compare/v2.5.0...v2.6.0
[2.5.0]: https://github.com/giantswarm/grafana-app/compare/v2.4.1...v2.5.0
[2.4.1]: https://github.com/giantswarm/grafana-app/compare/v2.4.0...v2.4.1
[2.4.0]: https://github.com/giantswarm/grafana-app/compare/v2.3.3...v2.4.0
[2.3.3]: https://github.com/giantswarm/grafana-app/compare/v2.3.2...v2.3.3
[2.3.2]: https://github.com/giantswarm/grafana-app/compare/v2.3.1...v2.3.2
[2.3.1]: https://github.com/giantswarm/grafana-app/compare/v2.3.0...v2.3.1
[2.3.0]: https://github.com/giantswarm/grafana-app/compare/v2.2.1...v2.3.0
[2.2.1]: https://github.com/giantswarm/grafana-app/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/giantswarm/grafana-app/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/giantswarm/grafana-app/compare/v2.0.2...v2.1.0
[2.0.2]: https://github.com/giantswarm/grafana-app/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/giantswarm/grafana-app/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/giantswarm/grafana-app/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/giantswarm/grafana-app/compare/v1.0.3...v1.1.0
[1.0.3]: https://github.com/giantswarm/grafana-app/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/giantswarm/grafana-app/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/giantswarm/grafana-app/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/giantswarm/grafana-app/compare/v0.4.0...v1.0.0
[0.4.0]: https://github.com/giantswarm/grafana-app/compare/v0.3.4...v0.4.0
[0.3.4]: https://github.com/giantswarm/grafana-app/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/giantswarm/grafana-app/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/giantswarm/grafana-app/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/giantswarm/grafana-app/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/giantswarm/grafana-app/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/giantswarm/grafana-app/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/giantswarm/grafana-app/compare/v0.1.0-alpha1...v0.2.0
[0.1.0-alpha1]: https://github.com/giantswarm/grafana-app/releases/tag/v0.1.0-alpha1
