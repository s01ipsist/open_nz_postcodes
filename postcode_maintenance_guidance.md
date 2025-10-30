# Maintenance

Guidance and code snippets useful during review.

- Postcode interpolation (assigning postcode to one road based on the postcode of a nearby road) can lead to small anomalies getting bigger
- Use QGIS with the included `snapshots/open_nz_post.qgz` project to visually review GIS data.

## Review by meshblock

Code snippets below from an exercise in 2025 where it was identified that most of an area around Lake Hayes was miscorrectly assigned postcodes.

QGIS was used to select the meshblocks which contained the identified roads.
The Attribute table was used to copy the meshblock values and added to SQL queries.

Check values in specific meshblocks

```
SELECT road_id, nz_roads.postcode, full_road_, locality, city
  FROM nz_roads, nz_meshblocks
  WHERE
  ST_Intersects(nz_meshblocks.geom, nz_roads.geom)
AND
mb2025_v1_ IN ('3039715', '3039722', '3039716', '3039726', '4017710', '3039724', '4017238', '4017950', '4017811', '3039727', '4001203', '4014615', '4017861', '3039713', '3039714', '3039718', '3039720', '3039719', '3039725', '4001031', '4014629', '4001207', '4018230', '4018231', '4017593', '4017915', '4018137', '4017810', '4018014', '4018096', '4017316', '4018083', '4014621', '4014628', '4017808', '4017039', '4014625', '4014611', '4016932', '3039721', '4014610', '4014613', '4014612', '4017058', '4001204', '4001213', '4017919', '4017896')
AND
nz_roads.postcode IS NOT NULL
ORDER BY nz_roads.postcode, full_road_;
```

Update postcode for meshblocks
```
UPDATE nz_roads SET postcode = 9304
FROM nz_meshblocks
  WHERE
  ST_Intersects(nz_meshblocks.geom, nz_roads.geom)
AND
mb2025_v1_ IN ('3039715', '3039722', '3039716', '3039726', '4017710', '3039724', '4017238', '4017950', '4017811', '3039727', '4001203', '4014615', '4017861', '3039713', '3039714', '3039718', '3039720', '3039719', '3039725', '4001031', '4014629', '4001207', '4018230', '4018231', '4017593', '4017915', '4018137', '4017810', '4018014', '4018096', '4017316', '4018083', '4014621', '4014628', '4017808', '4017039', '4014625', '4014611', '4016932', '3039721', '4014610', '4014613', '4014612', '4017058', '4001204', '4001213', '4017919', '4017896')
AND
nz_roads.postcode IS NOT NULL;
```

Confirm roads where master csv files don't match updated data

```
SELECT nz_street_postcodes.*, nz_roads.postcode FROM nz_street_postcodes, nz_roads
WHERE nz_street_postcodes.road_id = nz_roads.road_id
AND
nz_street_postcodes.postcode != nz_roads.postcode;
```

Update `nz_street_postcodes` data
```
UPDATE nz_street_postcodes SET postcode = nz_roads.postcode
FROM nz_roads
WHERE nz_street_postcodes.road_id = nz_roads.road_id
AND
nz_street_postcodes.postcode != nz_roads.postcode;
```

Now use `./scripts/export-street-postcodes.sh` to export back to master csv files.
