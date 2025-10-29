SELECT 'Overall precision as percentage of address points that are in a generated boundary of the same postcode' AS description;
SELECT
CAST(
  SUM(count_matching_address_points)
  AS real)
/
CAST(
  SUM(count_matching_address_points) + SUM(count_non_matching_address_points)
  AS real)
AS precision
FROM postcode_boundaries;

SELECT 'check for boundaries with worst precision by comparing count of matching and non-matching address points' AS description;

SELECT postcode, count_matching_address_points, count_non_matching_address_points,
count_matching_address_points + count_non_matching_address_points,
ROUND((
CAST(count_matching_address_points AS real) /
(
  CAST((count_matching_address_points + count_non_matching_address_points) AS real)
)
)::numeric, 4) AS precision
FROM postcode_boundaries
ORDER BY precision ASC
LIMIT 20;


SELECT 'Find postcodes with disparate area vs bounding box. A low ratio (below 0.15) may identify roads with misconfigured postcodes that are a long way away' AS description;

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
