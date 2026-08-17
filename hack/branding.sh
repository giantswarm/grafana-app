#!/usr/bin/env bash
#
# Keeps the Giant Swarm branding in helm/grafana consistent with the Grafana
# image, and checks two things that would otherwise break silently:
#
#   1. The logo mount path. Grafana serves its logo from a webpack asset whose
#      file name carries a content hash. If upstream changes their logo, the
#      hash changes, our mount lands on a file nobody reads, and Grafana shows
#      its own logo again.
#
#   2. The `checksum/giantswarm-branding` pod annotation. `subPath` mounts are
#      not updated in place by kubelet, so the Grafana pod has to restart to
#      pick up a changed asset. The annotation makes a changed asset roll the
#      deployment. Helm cannot compute it: the pod template comes from the
#      upstream subchart, which does not template `podAnnotations` and cannot
#      read this chart's files anyway.
#
# Usage:
#   hack/branding.sh            # verify, exit non-zero on drift (used by CI)
#   hack/branding.sh --update   # write the current values into values.yaml
#
# Set BRANDING_IMAGE to check against an image other than the one the chart
# deploys.

set -euo pipefail

readonly chart_dir="helm/grafana"
readonly values_file="${chart_dir}/values.yaml"
readonly chart_file="${chart_dir}/Chart.yaml"
readonly assets_dir="${chart_dir}/branding"
readonly logo_dir="/usr/share/grafana/public/build/static/img"

update=false
if [[ "${1:-}" == "--update" ]]; then
  update=true
elif [[ -n "${1:-}" ]]; then
  echo "usage: $0 [--update]" >&2
  exit 2
fi

if [[ ! -f "${values_file}" ]]; then
  echo "error: run this from the repository root" >&2
  exit 2
fi

# Both spellings print "<hash>  <file>", so the checksum below is the same on
# Linux and macOS. Note this deliberately avoids BSD `sha256`, which is not on
# Linux and prints a different format.
if command -v sha256sum >/dev/null 2>&1; then
  sha256=(sha256sum)
else
  sha256=(shasum -a 256)
fi

container_runtime() {
  for runtime in docker podman; do
    if command -v "${runtime}" >/dev/null 2>&1 && "${runtime}" info >/dev/null 2>&1; then
      echo "${runtime}"
      return 0
    fi
  done
  echo "error: no working docker or podman, cannot inspect the Grafana image" >&2
  return 1
}

# A key of `grafana.image` in values.yaml.
image_field() {
  awk -v key="$1:" '
    /^grafana:/ { in_grafana = 1; next }
    /^[^[:space:]]/ { in_grafana = 0 }
    in_grafana && /^  image:/ { in_image = 1; next }
    in_grafana && in_image && /^  [^[:space:]]/ { in_image = 0 }
    in_grafana && in_image && $1 == key { print $2; exit }
  ' "${values_file}"
}

# The image the chart deploys, so we check what we actually ship.
grafana_image() {
  if [[ -n "${BRANDING_IMAGE:-}" ]]; then
    echo "${BRANDING_IMAGE}"
    return
  fi
  local tag
  # An empty `tag` in values.yaml means the chart falls back to the appVersion.
  tag=$(image_field tag | tr -d '"')
  if [[ -z "${tag}" ]]; then
    tag=$(awk '/^appVersion:/{print $2; exit}' "${chart_file}")
  fi
  echo "$(image_field registry)/$(image_field repository):${tag}"
}

# Hash of every branding asset, by name and content.
assets_checksum() {
  (
    cd "${assets_dir}" || exit 1
    find . -type f | LC_ALL=C sort | xargs "${sha256[@]}"
  ) | "${sha256[@]}" | cut -d' ' -f1
}

# The file name the logo is mounted over, taken from the mount itself rather
# than from anywhere it is mentioned in a comment.
configured_logo() {
  awk '/mountPath:.*grafana_icon/ { n = split($2, path, "/"); print path[n]; exit }' "${values_file}"
}

configured_checksum() {
  awk -F'"' '/checksum\/giantswarm-branding:/{print $2; exit}' "${values_file}"
}

drift=false

# 1. The hashed logo file name in the image.
image=$(grafana_image)
echo "Reading ${logo_dir} from ${image}"
runtime=$(container_runtime)
image_logo=$("${runtime}" run --rm --entrypoint ls "${image}" -1 "${logo_dir}" | grep '^grafana_icon\.' | head -1)
values_logo=$(configured_logo)

if [[ -z "${image_logo}" ]]; then
  echo "error: no grafana_icon.*.svg in ${logo_dir} of ${image}" >&2
  echo "       upstream moved the logo, the mount in ${values_file} needs a new path" >&2
  exit 1
fi

if [[ "${image_logo}" == "${values_logo}" ]]; then
  echo "ok: logo mount path matches the image (${image_logo})"
elif [[ "${update}" == true ]]; then
  sed -i.bak "s#${values_logo}#${image_logo}#g" "${values_file}" && rm -f "${values_file}.bak"
  echo "updated: logo mount path ${values_logo} -> ${image_logo}"
else
  echo "drift: the image serves its logo as ${image_logo}, ${values_file} mounts over ${values_logo}" >&2
  drift=true
fi

# 2. The checksum annotation over the assets we ship.
assets_sum=$(assets_checksum)
values_sum=$(configured_checksum)

if [[ "${assets_sum}" == "${values_sum}" ]]; then
  echo "ok: checksum annotation matches the assets (${assets_sum})"
elif [[ "${update}" == true ]]; then
  sed -i.bak "s#\(checksum/giantswarm-branding: \)\".*\"#\1\"${assets_sum}\"#" "${values_file}" && rm -f "${values_file}.bak"
  echo "updated: checksum annotation ${values_sum:-none} -> ${assets_sum}"
else
  echo "drift: the branding assets hash to ${assets_sum}, ${values_file} annotates ${values_sum:-none}" >&2
  drift=true
fi

if [[ "${drift}" == true ]]; then
  echo >&2
  echo "Run 'make branding-update' and commit the result." >&2
  exit 1
fi
