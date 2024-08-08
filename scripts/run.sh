#!/usr/bin/env bash
set -eof

echo "-- BEGIN $(date)"

bash scripts/import-geodata.sh
bash scripts/import-street-postcodes.sh
psql -d open_nz_postcodes -f scripts/set-postcodes.sql
psql -d open_nz_postcodes -f scripts/setup-postcode-boundaries.sql
psql -d open_nz_postcodes -f scripts/setup-snapshots.sql

# optional: simplify topographies to reduce generated shapefile size from 90mb to 2mb
# psql -d open_nz_postcodes -c "UPDATE postcode_boundaries SET geom = ST_Simplify(geom, 0.001);"

# generate zipped shapefile bundle
mkdir -p release tmp
pgsql2shp -f "tmp/open_nz_postcode_boundaries" open_nz_postcodes postcode_boundaries
zip -jr release/open_nz_postcode_boundaries_shp.zip tmp/

echo "-- END $(date)"
