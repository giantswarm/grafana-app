# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/giantswarm/grafana-app/compare/v0.3.4...HEAD
[0.3.4]: https://github.com/giantswarm/grafana-app/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/giantswarm/grafana-app/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/giantswarm/grafana-app/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/giantswarm/grafana-app/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/giantswarm/grafana-app/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/giantswarm/grafana-app/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/giantswarm/grafana-app/compare/v0.1.0-alpha1...v0.2.0
[0.1.0-alpha1]: https://github.com/giantswarm/grafana-app/releases/tag/v0.1.0-alpha1
