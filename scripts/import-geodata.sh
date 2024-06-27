#!/usr/bin/env bash
set -eof

# Datasets come in various coordinate systems
# transform everything into WGS84 - World Geodetic System 1984
# Coordinate systems used:
# WGS84 https://epsg.io/4326
# NZGD2000 https://epsg.io/4167
# NZGD2000/NZTM https://epsg.io/2193

# Data sources:
# https://data.linz.govt.nz/layer/105689-nz-addresses/
# https://data.linz.govt.nz/layer/53382-nz-roads-addressing/
# https://data.linz.govt.nz/layer/113764-nz-suburbs-and-localities/
# https://datafinder.stats.govt.nz/layer/115225-meshblock-2024/
# These must be downloaded and extracted into the data folder

# ensure clean data folder structure
mkdir -p data/tmp
rm -f data/tmp/*.sql

path_addresses_1=data/nz-addresses/nz-addresses.shp
path_addresses_2=data/nz-addresses/nz-addresses.2.shp
path_roads=data/nz-roads/nz-roads-addressing.shp
path_suburbs=data/nz-suburbs-localities/nz-suburbs-and-localities.shp
path_meshblocks=data/meshblock-2024/meshblock-2024.shp

# check that data assets are in place
for x in ${!path_@}; do
  if [ ! -f ${!x} ]; then
    echo "File not found! ${!x}"
  fi
done

dropdb --if-exists open_nz_postcodes
createdb open_nz_postcodes
psql -d open_nz_postcodes -c "CREATE EXTENSION postgis;"

echo "-- Transforming shapefile: nz-addresses part 1/2"
shp2pgsql -d -s 4167:4326 "${path_addresses_1}" nz_addresses > data/tmp/nz_addresses.1.sql
echo "-- Importing nz-addresses part 1/2"
psql -d open_nz_postcodes -q -f data/tmp/nz_addresses.1.sql

echo "-- Transforming shapefile: nz_address_points part 2/2"
shp2pgsql -a -s 4167:4326 "${path_addresses_2}" nz_addresses > data/tmp/nz_addresses.2.sql
echo "-- Importing nz-addresses part 2/2"
psql -d open_nz_postcodes -q -f data/tmp/nz_addresses.2.sql
echo "--  wrangle Chatham Islands"
psql -d open_nz_postcodes -c "UPDATE nz_addresses SET geom = ST_WrapX(geom, 180, -360) WHERE ST_x(ST_Centroid(geom)) >180;"
psql -d open_nz_postcodes -c "CREATE INDEX nz_addresses_geom_idx ON nz_addresses USING gist (geom);"


echo "-- Transforming shapefile: nz_roads"
shp2pgsql -d -s 4167:4326 "${path_roads}" nz_roads > data/tmp/nz_roads.sql
echo "-- Importing nz_roads"
psql -d open_nz_postcodes -q -f data/tmp/nz_roads.sql
psql -d open_nz_postcodes -c "UPDATE nz_roads SET geom = ST_WrapX(geom, 180, -360) WHERE ST_x(ST_Centroid(geom)) >180;"
psql -d open_nz_postcodes -c "CREATE INDEX nz_roads_geom_idx ON nz_roads USING gist (geom);"
psql -d open_nz_postcodes -c "CREATE INDEX nz_roads_full_road_idx ON nz_roads USING btree (full_road_);"


echo "-- Transforming shapefile: nz_localities"
shp2pgsql -d -s 4167:4326 "${path_suburbs}" nz_localities > data/tmp/nz_localities.sql
echo "-- Importing nz_localities"
psql -d open_nz_postcodes -q -f data/tmp/nz_localities.sql
psql -d open_nz_postcodes -c "CREATE INDEX nz_localities_geom_idx ON nz_localities USING gist (geom);"


echo "-- Transforming shapefile: nz_meshblocks"
shp2pgsql -d -s 2193:4326 "${path_meshblocks}" nz_meshblocks > data/tmp/nz_meshblocks.sql
echo "-- Importing nz_meshblocks"
psql -d open_nz_postcodes -q -f data/tmp/nz_meshblocks.sql
psql -d open_nz_postcodes -c "CREATE INDEX nz_meshblocks_geom_idx ON nz_meshblocks USING gist (geom);"

# Alter tables for processing to add fields for completion
psql -d open_nz_postcodes -c "ALTER TABLE nz_addresses ADD COLUMN road_id integer;"
psql -d open_nz_postcodes -c "ALTER TABLE nz_roads ADD COLUMN postcode text;"
psql -d open_nz_postcodes -c "ALTER TABLE nz_addresses ADD COLUMN postcode text;"
psql -d open_nz_postcodes -c "ALTER TABLE nz_meshblocks ADD COLUMN postcode text;"
