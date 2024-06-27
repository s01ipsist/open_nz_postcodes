#!/usr/bin/env bash
set -eof

echo "-- BEGIN $(date)"

bash scripts/import-street-postcodes.sh

psql -d open_nz_postcodes -c "UPDATE nz_roads SET postcode = NULL;"
psql -d open_nz_postcodes -c "UPDATE nz_addresses SET postcode = NULL;"
psql -d open_nz_postcodes -c "UPDATE nz_meshblocks SET postcode = NULL;"

psql -d open_nz_postcodes -f scripts/set-postcodes.sql
psql -d open_nz_postcodes -f scripts/setup-postcode-boundaries.sql
psql -d open_nz_postcodes -f scripts/setup-snapshots.sql

echo "-- END $(date)"
