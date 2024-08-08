#!/usr/bin/env bash
set -eof

echo "-- Importing nz_street_postcodes"
psql -d open_nz_postcodes -c "CREATE TABLE IF NOT EXISTS nz_street_postcodes (road_id integer, postcode text, name text, locality text, city text);"
psql -d open_nz_postcodes -c "TRUNCATE TABLE nz_street_postcodes;"
for x in {0,{a..z}}
do
  cat street_postcodes/${x}.csv | psql -d open_nz_postcodes -c "COPY nz_street_postcodes (road_id, postcode, name, locality, city) FROM STDIN DELIMITER ',' HEADER csv;"
done
psql -d open_nz_postcodes -c "CREATE INDEX IF NOT EXISTS nz_street_postcodes_road_idx ON nz_street_postcodes USING btree (road_id);"
psql -d open_nz_postcodes -c "SELECT COUNT(*) FROM nz_street_postcodes;"
