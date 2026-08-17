##@ Branding

.PHONY: branding-verify
branding-verify: ## Check the branding wiring against the Grafana image.
	@hack/branding.sh

.PHONY: branding-update
branding-update: ## Write the current logo mount path and asset checksum into values.yaml.
	@hack/branding.sh --update
