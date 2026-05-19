#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/config.sh"

# psql client-side \copy so the CSVs are written wherever psql runs
# (repo workspace), not on the postgres server's filesystem — works
# locally via docker compose AND in CI against a service container.
cd "$(dirname "$0")/.."

log "-- Exporting nz_street_postcodes"
for x in {a..z}
do
  psql -d open_nz_postcodes -c "\copy (SELECT road_id, postcode, name, locality, city FROM nz_street_postcodes WHERE name ~* '^${x}' ORDER BY name, locality, city, road_id) TO 'street_postcodes/${x}.csv' WITH DELIMITER ',' HEADER csv"
done
# use 0.csv for any roads starting with a digit
psql -d open_nz_postcodes -c "\copy (SELECT road_id, postcode, name, locality, city FROM nz_street_postcodes WHERE name ~* '^\d' ORDER BY name, locality, city, road_id) TO 'street_postcodes/0.csv' WITH DELIMITER ',' HEADER csv"
