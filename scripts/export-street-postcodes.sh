#!/usr/bin/env bash
set -eof

# Export current street postcodes
# https://www.postgresql.org/docs/current/sql-copy.html
echo "-- Exporting nz_street_postcodes"
for x in {a..z}
do
  psql -d open_nz_postcodes -c "COPY (SELECT road_id, postcode, name, locality, city FROM nz_street_postcodes WHERE name ~* '^${x}' ORDER BY name, locality, city, road_id) TO '/app/street_postcodes/${x}.csv' WITH DELIMITER ',' csv;"
done
# use 0.csv for any roads starting with a digit
psql -d open_nz_postcodes -c "COPY (SELECT road_id, postcode, name, locality, city FROM nz_street_postcodes WHERE name ~* '^\d' ORDER BY name, locality, city, road_id) TO '/app/street_postcodes/0.csv' WITH DELIMITER ',' csv;"
