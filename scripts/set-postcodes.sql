SELECT 'START SETTING POSTCODES', NOW();

-- disable pagination
\pset pager off

-- set postcode on roads
SELECT 'SET POSTCODES ON nz_roads FROM nz_street_postcodes', NOW();
UPDATE nz_roads
SET postcode = nz_street_postcodes.postcode
FROM nz_street_postcodes
WHERE nz_street_postcodes.road_id = nz_roads.road_id
AND
nz_street_postcodes.postcode IS NOT NULL;


-- set road_id on address points from nearby roads with matching name
SELECT 'SET road_id ON nz_addresses MATCHING nearby road names', NOW();
-- 0.1 degree in WGS84 =~ 11km
UPDATE nz_addresses
SET road_id = (
  SELECT road_id
  FROM nz_roads
  WHERE
  nz_roads.full_road_ = nz_addresses.full_road_
  AND ST_Distance(nz_roads.geom, nz_addresses.geom) < 0.1
  ORDER BY
    nz_roads.geom <-> nz_addresses.geom
  LIMIT 1
  )
WHERE road_id IS NULL;

-- add index to speed up following steps now that bulk of data is imported
CREATE INDEX IF NOT EXISTS nz_addresses_road_id_idx
ON nz_addresses USING btree (road_id);

-- one more time with case insensitive matching
-- this catches some data inconsistencies in LINZ data
SELECT 'SET road_id ON nz_addresses MATCHING nearby road names (case insensitive)', NOW();
UPDATE nz_addresses
SET road_id = (
  SELECT road_id
  FROM nz_roads
  WHERE
  LOWER(nz_roads.full_road_) = LOWER(nz_addresses.full_road_)
  AND ST_Distance(nz_roads.geom, nz_addresses.geom) < 0.1
  ORDER BY
    nz_roads.geom <-> nz_addresses.geom
  LIMIT 1
  )
WHERE road_id IS NULL;

SELECT 'COUNT nz_addresses WITHOUT road_id', NOW();
SELECT COUNT(*) FROM nz_addresses
WHERE
nz_addresses.road_id IS NULL;

-- assign postcode to all address points on road
SELECT 'SET POSTCODES ON nz_addresses BY road_id', NOW();
UPDATE nz_addresses
SET
postcode = (
  SELECT postcode FROM nz_street_postcodes
  WHERE nz_street_postcodes.road_id = nz_addresses.road_id
  AND postcode IS NOT NULL
)
WHERE
nz_addresses.postcode IS NULL;

VACUUM ANALYZE;

-- for everything left, assign postcode from nearest address point that has a postcode
SELECT 'SET POSTCODES ON nz_addresses BY nearest postcode', NOW();
UPDATE nz_addresses nz_addresses_a
SET postcode = (
  SELECT postcode
  FROM nz_addresses nz_addresses_b
  WHERE postcode IS NOT NULL
  ORDER BY
    nz_addresses_a.geom <-> nz_addresses_b.geom
  LIMIT 1
  )
WHERE postcode IS NULL;

SELECT COUNT(*) FROM nz_addresses WHERE postcode IS NULL;

-- set postcode on meshblocks based on highest represented postcode in contained address points
SELECT 'SET 1 POSTCODE PER MESHBLOCK on highest count of postcode', NOW();
UPDATE nz_meshblocks
SET
postcode = temp_table.postcode
FROM (
  SELECT
    nz_meshblocks.gid,
    nz_addresses.postcode,
    COUNT(*)
  FROM nz_meshblocks, nz_addresses
  WHERE
  ST_Contains(nz_meshblocks.geom, nz_addresses.geom)
  GROUP BY nz_meshblocks.gid, nz_addresses.postcode
  ORDER BY nz_meshblocks.gid, COUNT(*) DESC
) temp_table
WHERE temp_table.gid = nz_meshblocks.gid;


SELECT 'FINISHED SETTING POSTCODES', NOW();
