#!/usr/bin/env bash
set -euo pipefail

echo "-- BEGIN $(date)"

bash scripts/import-geodata.sh
bash scripts/import-street-postcodes.sh
psql -d open_nz_postcodes -f scripts/set-postcodes.sql
psql -d open_nz_postcodes -f scripts/setup-postcode-boundaries.sql
psql -A -d open_nz_postcodes -f scripts/checks.sql

NEW_ROADS_COUNT=$(psql -At -d open_nz_postcodes -c "SELECT COUNT(*) FROM nz_roads LEFT OUTER JOIN nz_street_postcodes ON (nz_street_postcodes.road_id = nz_roads.road_id) WHERE (nz_street_postcodes.road_id IS NULL) AND full_road_ IS NOT NULL;")
echo "::notice::New roads to add (see add-new-roads.sql): ${NEW_ROADS_COUNT}"

# optional: simplify topographies to reduce generated shapefile size from 90mb to 2mb
# psql -d open_nz_postcodes -c "UPDATE postcode_boundaries SET geom = ST_Simplify(geom, 0.001);"

# generate zipped shapefile bundle
mkdir -p release tmp
pgsql2shp -f "tmp/open_nz_postcode_boundaries" open_nz_postcodes postcode_boundaries
zip -jr release/open_nz_postcode_boundaries_shp.zip tmp/

echo "-- END $(date)"
