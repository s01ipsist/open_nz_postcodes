-- calculate overall precision as percentage of address points that are in
-- a boundary of the same postcode
SELECT
CAST(
  SUM(count_matching_address_points)
  AS double precision)
/
CAST(
  SUM(count_matching_address_points) + SUM(count_non_matching_address_points)
  AS double precision)
AS precision
FROM postcode_boundaries;

-- check for boundaries with worst precision
-- by comparing count of matching and non-matching address points

SELECT postcode, count_matching_address_points, count_non_matching_address_points,
ROUND((
cast(count_non_matching_address_points AS double precision) / cast(count_matching_address_points AS double precision)
)::numeric, 4) AS precision
FROM postcode_boundaries
ORDER BY precision DESC
LIMIT 20;

-- Find postcodes with disparate area vs bounding box
-- a low ratio (below 0.15) may point to a misconfigured postcode that is a long way away
SELECT postcode, ROUND((St_area(geom) / St_area(Box2D(geom)))::numeric, 3) AS ratio
FROM postcode_boundaries
WHERE postcode NOT IN ('3506', '1010', '7886', '3121', '5373', '4984', '4102')
AND St_area(geom) / St_area(Box2D(geom)) < 0.15
ORDER by ratio
LIMIT 10;
-- excludes some known postcodes with low ratios
-- 3506 : Coromandel + Great Barrier
-- 1010 : Hauraki Gulf
-- 7886 : West Coast, South Island
-- 3121 : Ohope stretch of beach
-- 5373 : large unpopulated area in Remutakas
-- 4984 : weird disconnected
-- 4102 : coastal stretch at Haumoana
