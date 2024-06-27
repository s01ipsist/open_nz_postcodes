SELECT 'CREATE postcode_boundaries', NOW();

CREATE TABLE IF NOT EXISTS postcode_boundaries (
  postcode text,
  geom geometry,
  count_matching_address_points integer,
  count_non_matching_address_points integer
);

TRUNCATE postcode_boundaries;

INSERT INTO postcode_boundaries (postcode, geom)
  SELECT postcode,
  ST_Union(geom)
  FROM nz_meshblocks
  WHERE postcode IS NOT NULL
  AND land_area_ > 0
  GROUP by postcode;

CREATE INDEX IF NOT EXISTS postcode_boundaries_geom_idx ON postcode_boundaries USING gist (geom);

-- set accuracy statistics
UPDATE postcode_boundaries
SET count_matching_address_points = temp.count_matching_address_points
FROM (
  SELECT postcode_boundaries.postcode AS postcode, COUNT(*) AS count_matching_address_points
  FROM nz_addresses, postcode_boundaries
  WHERE
    ST_Contains(postcode_boundaries.geom, nz_addresses.geom)
  AND postcode_boundaries.postcode = nz_addresses.postcode
  GROUP BY postcode_boundaries.postcode
) AS temp
WHERE postcode_boundaries.postcode = temp.postcode;

UPDATE postcode_boundaries
SET count_non_matching_address_points = temp.count_non_matching_address_points
FROM (
  SELECT postcode_boundaries.postcode AS postcode, COUNT(*) AS count_non_matching_address_points
  FROM nz_addresses, postcode_boundaries
  WHERE
    ST_Contains(postcode_boundaries.geom, nz_addresses.geom)
  AND postcode_boundaries.postcode != nz_addresses.postcode
  GROUP BY postcode_boundaries.postcode
) AS temp
WHERE postcode_boundaries.postcode = temp.postcode;

UPDATE postcode_boundaries
SET count_non_matching_address_points = 0
WHERE count_non_matching_address_points IS NULL;
