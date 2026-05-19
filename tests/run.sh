#!/usr/bin/env bash
set -euo pipefail

# Smoke test: run set-postcodes.sql + setup-postcode-boundaries.sql against a
# small committed fixture (Great Barrier Island, postcodes 0991 + 0975) and
# assert that the pipeline produces both expected boundaries with reasonable
# precision. Requires the docker-compose postgres service to be running.

cd "$(dirname "$0")/.."

DC="docker compose exec -T postgres"
DB=open_nz_postcodes_test
FIXTURES=tests/fixtures

echo "-- recreating test db"
$DC dropdb -U postgres --if-exists "$DB" > /dev/null
$DC createdb -U postgres "$DB"
$DC psql -U postgres -d "$DB" -c "CREATE EXTENSION postgis;" > /dev/null

echo "-- loading schema"
$DC psql -U postgres -d "$DB" -v ON_ERROR_STOP=1 -q < "$FIXTURES/schema.sql"

load() {
  local table=$1 file=$2
  $DC psql -U postgres -d "$DB" -v ON_ERROR_STOP=1 -c "\copy $table FROM STDIN" < "$FIXTURES/$file" > /dev/null
}
echo "-- loading fixture data"
load nz_addresses addresses.copy
load nz_roads roads.copy
load nz_meshblocks meshblocks.copy
load nz_street_postcodes street_postcodes.copy

echo "-- resetting derived columns to simulate fresh LINZ import"
$DC psql -U postgres -d "$DB" -v ON_ERROR_STOP=1 -q <<SQL
UPDATE nz_addresses SET road_id = NULL, postcode = NULL;
UPDATE nz_roads SET postcode = NULL;
UPDATE nz_meshblocks SET postcode = NULL;
DELETE FROM nz_roads WHERE full_road_ IN ('Roadway', 'Accessway', 'Service Lane');
SQL

echo "-- running pipeline SQL"
$DC psql -U postgres -d "$DB" -v ON_ERROR_STOP=1 -q -f /app/scripts/set-postcodes.sql > /dev/null
$DC psql -U postgres -d "$DB" -v ON_ERROR_STOP=1 -q -f /app/scripts/setup-postcode-boundaries.sql > /dev/null

echo "-- checking results"
PRECISION=$($DC psql -U postgres -d "$DB" -At -c "SELECT ROUND((SUM(count_matching_address_points)::numeric / NULLIF(SUM(count_matching_address_points) + SUM(count_non_matching_address_points), 0)) * 100, 2) FROM postcode_boundaries;")
COUNT=$($DC psql -U postgres -d "$DB" -At -c "SELECT COUNT(*) FROM postcode_boundaries;")
POSTCODES=$($DC psql -U postgres -d "$DB" -At -c "SELECT string_agg(postcode, ',' ORDER BY postcode) FROM postcode_boundaries;")

echo "boundary_count=$COUNT postcodes=$POSTCODES precision=${PRECISION}%"

fail=0
if [ "$COUNT" != "2" ]; then
  echo "FAIL: expected 2 boundaries, got $COUNT"
  fail=1
fi
if [ "$POSTCODES" != "0975,0991" ]; then
  echo "FAIL: expected boundaries for 0975 and 0991, got $POSTCODES"
  fail=1
fi
if ! awk "BEGIN { exit !($PRECISION >= 90) }"; then
  echo "FAIL: precision ${PRECISION}% below 90% threshold"
  fail=1
fi

if [ $fail -eq 0 ]; then
  echo "PASS"
fi
exit $fail
