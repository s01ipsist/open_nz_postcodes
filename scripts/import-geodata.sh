#!/usr/bin/env bash
set -eof

# Datasets come in various coordinate systems
# transform everything into WGS84 - World Geodetic System 1984
# Coordinate systems used:
# WGS84 https://epsg.io/4326
# NZGD2000 https://epsg.io/4167
# NZGD2000/NZTM https://epsg.io/2193

# Data sources: refer scripts/koordinates/setup_downloads.py
# These must be downloaded and extracted into the data folder

# ensure clean data folder structure
mkdir -p data/tmp
rm -f data/tmp/*.sql

path_addresses_1=data/nz-addresses-pilot/nz-addresses-pilot.shp
path_roads=data/nz-addresses-roads-pilot/nz-addresses-roads-pilot.shp
path_suburbs=data/nz-suburbs-and-localities/nz-suburbs-and-localities.shp
path_meshblocks=data/meshblock-2025.shp

# check that data assets are in place
for x in ${!path_@}; do
  if [ ! -f ${!x} ]; then
    echo "File not found! ${!x}"
  fi
done

dropdb --if-exists open_nz_postcodes
createdb open_nz_postcodes
psql -d open_nz_postcodes -c "CREATE EXTENSION postgis;"

echo "-- Transforming shapefile: nz-addresses-pilot"
shp2pgsql -d -s 4167:4326 "${path_addresses_1}" nz_addresses > data/tmp/nz_addresses.sql
echo "-- Importing nz-addresses"
psql -d open_nz_postcodes -q -f data/tmp/nz_addresses.sql

echo "--  wrangle Chatham Islands"
psql -d open_nz_postcodes -c "UPDATE nz_addresses SET geom = ST_WrapX(geom, 180, -360) WHERE ST_x(ST_Centroid(geom)) >180;"
psql -d open_nz_postcodes -c "CREATE INDEX IF NOT EXISTS nz_addresses_geom_idx ON nz_addresses USING gist (geom);"


echo "-- Transforming shapefile: nz_roads"
shp2pgsql -d -s 4167:4326 "${path_roads}" nz_roads > data/tmp/nz_roads.sql
echo "-- Importing nz_roads"
psql -d open_nz_postcodes -q -f data/tmp/nz_roads.sql
psql -d open_nz_postcodes -c "UPDATE nz_roads SET geom = ST_WrapX(geom, 180, -360) WHERE ST_x(ST_Centroid(geom)) >180;"
psql -d open_nz_postcodes -c "CREATE INDEX IF NOT EXISTS nz_roads_geom_idx ON nz_roads USING gist (geom);"
psql -d open_nz_postcodes -c "CREATE INDEX IF NOT EXISTS nz_roads_full_road_idx ON nz_roads USING btree (full_road_);"


echo "-- Transforming shapefile: nz_localities"
shp2pgsql -d -s 4167:4326 "${path_suburbs}" nz_localities > data/tmp/nz_localities.sql
echo "-- Importing nz_localities"
psql -d open_nz_postcodes -q -f data/tmp/nz_localities.sql
psql -d open_nz_postcodes -c "CREATE INDEX IF NOT EXISTS nz_localities_geom_idx ON nz_localities USING gist (geom);"


echo "-- Transforming shapefile: nz_meshblocks"
shp2pgsql -d -s 2193:4326 "${path_meshblocks}" nz_meshblocks > data/tmp/nz_meshblocks.sql
echo "-- Importing nz_meshblocks"
psql -d open_nz_postcodes -q -f data/tmp/nz_meshblocks.sql
psql -d open_nz_postcodes -c "CREATE INDEX IF NOT EXISTS nz_meshblocks_geom_idx ON nz_meshblocks USING gist (geom);"

# Alter tables for processing to add fields for completion
# road_id is now included in the upstream nz-addresses-pilot data, so only add if missing
psql -d open_nz_postcodes -c "ALTER TABLE nz_addresses ADD COLUMN IF NOT EXISTS road_id integer;"
psql -d open_nz_postcodes -c "ALTER TABLE nz_roads ADD COLUMN postcode text;"
psql -d open_nz_postcodes -c "ALTER TABLE nz_addresses ADD COLUMN postcode text;"
psql -d open_nz_postcodes -c "ALTER TABLE nz_meshblocks ADD COLUMN postcode text;"

# Remove unnamed access lanes
psql -d open_nz_postcodes -c "DELETE FROM nz_roads WHERE full_road_ IN ('Roadway', 'Accessway', 'Service Lane');"
