#!/usr/bin/env bash
set -euo pipefail

# Regenerate fixture data for the smoke test from a live open_nz_postcodes DB.
# Captures a geographically-isolated subset (Great Barrier Island, postcodes
# 0991 and 0975) — small enough to commit and run end-to-end in seconds,
# but real enough to exercise the multi-postcode joins in set-postcodes.sql.

POSTCODES="('0991', '0975')"
OUT="$(cd "$(dirname "$0")" && pwd)"

echo "-- writing schema to $OUT/schema.sql"
DOCKER_HOST=${DOCKER_HOST:-unix:///var/run/docker.sock} \
docker compose exec -T postgres pg_dump -U postgres -d open_nz_postcodes \
  --schema-only --no-owner --no-acl \
  -t nz_addresses -t nz_roads -t nz_meshblocks \
  -t nz_localities -t nz_street_postcodes \
  > "$OUT/schema.sql"

dump_table() {
  local table=$1 where=$2 file=$3
  echo "-- writing $file"
  DOCKER_HOST=${DOCKER_HOST:-unix:///var/run/docker.sock} \
  docker compose exec -T postgres psql -U postgres -d open_nz_postcodes \
    -c "\\copy (SELECT * FROM $table WHERE $where) TO STDOUT" \
    > "$OUT/$file"
}

dump_table nz_addresses "postcode IN $POSTCODES" addresses.copy
dump_table nz_roads "postcode IN $POSTCODES" roads.copy
dump_table nz_meshblocks "postcode IN $POSTCODES" meshblocks.copy
dump_table nz_street_postcodes "postcode IN $POSTCODES" street_postcodes.copy

# nz_localities is only used by maintenance script add-new-roads.sql, not by
# set-postcodes.sql or setup-postcode-boundaries.sql, so we don't bother
# capturing its rows — schema.sql still creates the empty table.

wc -l "$OUT"/*.copy
