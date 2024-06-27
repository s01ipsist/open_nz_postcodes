-- new roads are regularly added to LINZ data
-- use this script to add those into our street-postcodes dataset

-- show roads missing from street-postcodes dataset
SELECT nz_roads.road_id, full_road_
FROM "nz_roads" LEFT OUTER JOIN "nz_street_postcodes"
ON ("nz_street_postcodes"."road_id" = "nz_roads"."road_id")
WHERE ("nz_street_postcodes"."road_id" IS NULL)
AND full_road_ IS NOT NULL
ORDER BY full_road_;

SELECT 'SET CITY/LOCALITY for nz_roads', NOW();

ALTER TABLE nz_roads ADD COLUMN IF NOT EXISTS locality text;
ALTER TABLE nz_roads ADD COLUMN IF NOT EXISTS city text;

-- set locality, city values for new roads
UPDATE nz_roads
SET
locality = temp_table.name,
city = temp_table.city
FROM (
  SELECT nz_roads.gid,
    STRING_AGG(DISTINCT(nz_localities.name_ascii), ',') AS name,
    STRING_AGG(DISTINCT(nz_localities.major_na_2), ',') AS city
  FROM nz_roads, nz_localities
  WHERE
  ST_Intersects(nz_localities.geom, nz_roads.geom)
  GROUP BY nz_roads.gid
) temp_table
WHERE temp_table.gid = nz_roads.gid
AND nz_roads.road_id IN
(
  SELECT nz_roads.road_id
  FROM "nz_roads" LEFT OUTER JOIN "nz_street_postcodes"
  ON ("nz_street_postcodes"."road_id" = "nz_roads"."road_id")
  WHERE ("nz_street_postcodes"."road_id" IS NULL)
  AND full_road_ IS NOT NULL
);

-- set postcode on new roads to nearest point postcode
UPDATE nz_roads
SET postcode = (
  SELECT postcode
  FROM nz_addresses
  WHERE postcode IS NOT NULL
  ORDER BY
    nz_roads.geom <-> nz_addresses.geom
  LIMIT 1
  )
WHERE nz_roads.road_id IN
(
  SELECT nz_roads.road_id
  FROM "nz_roads" LEFT OUTER JOIN "nz_street_postcodes"
  ON ("nz_street_postcodes"."road_id" = "nz_roads"."road_id")
  WHERE ("nz_street_postcodes"."road_id" IS NULL)
  AND full_road_ IS NOT NULL
);


INSERT INTO nz_street_postcodes (road_id, postcode, name, locality, city)
  SELECT road_id, postcode, full_road_, locality, city
  FROM nz_roads
  WHERE road_id IN
  (
    SELECT nz_roads.road_id
    FROM "nz_roads" LEFT OUTER JOIN "nz_street_postcodes"
    ON ("nz_street_postcodes"."road_id" = "nz_roads"."road_id")
    WHERE ("nz_street_postcodes"."road_id" IS NULL)
    AND full_road_ IS NOT NULL
  );
