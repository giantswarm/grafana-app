#!/bin/bash

set -eu

usage() {
  echo "Usage: $0 --database-file <database-file> --configmap-name <configmap-name> --configmap-data-key <configmap-data-key>"
}

update_org() {(
  set -eu
  local database_file="$1"
  local name="$2"
  local org="$3"

  # Read organization details
  local org_name="$(echo "$org"|jq -r '.spec.displayName|strings')"
  local org_id="$(echo "$org"|jq -r '.metadata.labels.orgID|strings')"
  test -n "$org_id" || { echo "Skipped organization: name='"$name"', missing orgID label"; return 1; }
  test -n "$org_name" || { echo "Skipped organization: name='"$name"', missing displayName"; return 1; }

  # Prepare sqlite command
  local sqlite_command="REPLACE INTO org (id, name, version, address1, address2, city, state, zip_code, country, billing_email, created, updated) VALUES ($org_id, '${org_name}', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, datetime('now'), datetime('now'));\n"

  # Execute sqlite command
  #cat <(echo -e "$sqlite_transaction")
  sqlite3 "$database_file" < <(echo -e "$sqlite_command")

  # Update organization orgID status
  kubectl patch grafanaorganization "$name" --type=merge --subresource status --patch 'status: {orgID: '"$org_id"'}' || return 1
)}

main() {
  local database_file=""

  # Handle arguments
  ARGS=$(getopt -o 'd:h' --long 'database-file:,help' -- "$@")
  eval set -- "$ARGS"
  while true; do
    case "$1" in
      -d|--database-file)
        database_file="$2"
        shift 2
        continue
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      '--')
        shift
        break
        ;;
      *)
        echo 'Internal error'
        exit 1
        ;;
    esac
  done

  # Validate arguments
  test -n "$database_file" || { echo "Missing required argument: --database-file"; exit 1; }
  test -f "$database_file" || { echo "File not found: $database_file"; exit 1; }

  echo "Initializing organizations"
  exec 5< <(kubectl get grafanaorganizations -o json | jq -c '.items[]')
  while read -r <&5 org; do
    local name="$(echo "$org"|jq -r '.metadata.name|strings')"
    test -n "$name" || { echo "Error organization name missing"; exit 1; }
    echo "Updating organization $name"
    update_org "$database_file" "$name" "$org" || continue
    echo "Updated organization $name"
  done
  echo

  echo "Watching for changes"
  exec 5< <(kubectl get grafanaorganizations -o json --watch --watch-only --output-watch-events=true | jq --unbuffered -c .)
  while read -r <&5 raw_event; do
    # Skip DELETED events
    local event_type="$(echo "$raw_event"|jq -r '.type|strings')"
    test "$event_type" == "DELETED" && continue

    local org="$(echo "$raw_event"|jq -c '.object')"
    local deletionTimestamp="$(echo "$org"|jq -r '.metadata.deletionTimestamp|strings')"
    test -n "$deletionTimestamp" && continue

    local name="$(echo "$org"|jq -r '.metadata.name|strings')"
    test -n "$name" || { echo "Error organization name missing"; exit 1; }
    echo "Updating organization $name"
    update_org "$database_file" "$name" "$org" || continue
    echo "Updated organization $name"
  done
  exec 5<&-
}

main "$@"
