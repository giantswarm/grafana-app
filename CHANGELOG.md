# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Upgrade Grafana to 8.3.2 to fix some CVEs including CVE-2021-43813 and CVE-2021-43798

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

[Unreleased]: https://github.com/giantswarm/grafana-app/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/giantswarm/grafana-app/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/giantswarm/grafana-app/compare/v0.1.0-alpha1...v0.2.0
[0.1.0-alpha1]: https://github.com/giantswarm/grafana-app/releases/tag/v0.1.0-alpha1
