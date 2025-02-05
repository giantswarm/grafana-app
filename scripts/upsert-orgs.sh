#!/bin/bash

set -euo pipefail

# database schema
#
#CREATE TABLE `org` (
#`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
#, `version` INTEGER NOT NULL
#, `name` TEXT NOT NULL
#, `address1` TEXT NULL
#, `address2` TEXT NULL
#, `city` TEXT NULL
#, `state` TEXT NULL
#, `zip_code` TEXT NULL
#, `country` TEXT NULL
#, `billing_email` TEXT NULL
#, `created` DATETIME NOT NULL
#, `updated` DATETIME NOT NULL
#);

usage() {
  echo "Usage: $0 --database-file <database-file> --configmap-name <configmap-name> --configmap-data-key <configmap-data-key>"
}

update_orgs() {
  local database_file="$1"
  local data="$2"


  # Prepare sqlite transaction
  local sqlite_transaction="BEGIN TRANSACTION;\n"

  # Transform yaml array into lines
  orgs="$(echo "$data" | yq -c '.[]')"
  orgs_count="$(echo "$orgs" | wc -l)"
  echo "Updating $orgs_count organizations"

  # Loop over each orgs lines
  exec 6< <(echo "$orgs")
  while read -r <&6 org; do
    # Get organization id and name
    name="$(echo "$org" | jq -r '.name')"
    id="$(echo "$org" | jq -r '.id')"
    echo "Processing organization: id=$id name=$name"
    sqlite_transaction+="REPLACE INTO org (id, name, version, address1, address2, city, state, zip_code, country, billing_email, created, updated) VALUES ($id, '${name}', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, datetime('now'), datetime('now'));\n"
  done
  exec 6<&-

  sqlite_transaction+="COMMIT;"

  # Execute sqlite transaction
  #cat <(echo -e "$sqlite_transaction")
  sqlite3 "$database_file" < <(echo -e "$sqlite_transaction")

  echo "Updated $orgs_count organizations"
}

main() {
  local database_file=""
  local configmap_name=""
  local configmap_data_key=""

  # Handle arguments
  ARGS=$(getopt -o 'c:d:hk:' --long 'configmap-name:,configmap-data-key:,database-file:,help' -- "$@")
  eval set -- "$ARGS"
  while true; do
    case "$1" in
      -c|--configmap-name)
        configmap_name="$2"
        shift 2
        continue
        ;;
      -d|--database-file)
        database_file="$2"
        shift 2
        continue
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      -k|--configmap-data-key)
        configmap_data_key="$2"
        shift 2
        continue
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
  test -n "$configmap_name" || { echo "Missing required argument: --configmap-name"; exit 1; }
  test -n "$configmap_data_key" || { echo "Missing required argument: --configmap-data-key"; exit 1; }

  echo "Initializing organizations"
  data="$(kubectl get configmap "$configmap_name" -o json | jq -r '.data["'"$configmap_data_key"'"]')"
  update_orgs "$database_file" "$data"
  echo

  echo "Watching for changes"
  exec 5< <(kubectl get configmap "$configmap_name" -o json --watch --watch-only | jq --unbuffered -c '.data["'"$configmap_data_key"'"]')
  while read -r <&5 raw_data; do
    data="$(echo "$raw_data"|yq -r .)"
    update_orgs "$database_file" "$data"
    #kubectl patch grafanaorganization giantswarm --type=merge --subresource status --patch 'status: {orgID: 2}'
  done
  exec 5<&-
}

main "$@"
