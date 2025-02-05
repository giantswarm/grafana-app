#!/bin/bash

set -eu

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
  echo "Usage: $0 --database-file <database-file> --orgs-file <orgs-file>"
}

update_orgs() {
  local database_file="$1"
  local orgs_file="$2"


  # Prepare sqlite transaction
  local sqlite_transaction="BEGIN TRANSACTION;\n"

  # Transform yaml array into lines
  orgs="$(yq -c '.[]' "$orgs_file")"
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
  local orgs_file=""

  # Handle arguments
  ARGS=$(getopt -o 'd:ho:' --long 'database-file:,help,orgs-file:' -- "$@")
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
      -o|--orgs-file)
        orgs_file="$2"
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
  test -n "$orgs_file" || { echo "Missing required argument: --orgs-file"; exit 1; }
  test -f "$orgs_file" || { echo "File not found: $orgs_file"; exit 1; }
  test -n "$database_file" || { echo "Missing required argument: --database-file"; exit 1; }
  test -f "$database_file" || { echo "File not found: $database_file"; exit 1; }

  local watch_dir="$(dirname "$orgs_file")"

  echo "Initializing organizations"
  update_orgs "$database_file" "$orgs_file"
  echo

  echo "Watching for changes in $watch_dir"
  while inotifywait -e modify "$watch_dir"; do
    update_orgs "$database_file" "$orgs_file"
  done
}

main "$@"
