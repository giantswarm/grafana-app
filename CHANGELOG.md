# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/giantswarm/grafana-app/compare/v2.3.3...HEAD
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
