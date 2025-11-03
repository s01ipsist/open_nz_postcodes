SELECT 'Generate QGIS snapshot CLI command for each postcode', NOW();

-- wrap command with timeout to cater for qgis fragility
-- https://docs.qgis.org/3.34/en/docs/user_manual/introduction/qgis_configuration.html#command-line-and-environment-variables

\COPY (SELECT 'timeout 15 /Applications/QGIS.app/Contents/MacOS/QGIS --snapshot ./' || postcode || '.png --extent ' || ROUND(ST_XMin(geom)::numeric, 4) || ',' || ROUND(ST_YMin(geom)::numeric, 4) || ',' || ROUND(ST_XMax(geom)::numeric, 4) || ',' || ROUND(ST_YMax(geom)::numeric, 4) || ' --project ./open_nz_post.qgz --nologo --noversioncheck --hide-browser' FROM postcode_boundaries ORDER BY postcode) TO 'snapshots/qgis_screenshots.sh';
