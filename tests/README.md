# Tests

A smoke test that runs the postcode-assignment SQL against a small committed fixture (Great Barrier Island, postcodes 0991 + 0975) and asserts the pipeline produces the expected boundaries with reasonable precision.

Requires the docker-compose postgres service to be running.

```
docker compose up -d postgres
bash tests/run.sh
```

The test creates a `open_nz_postcodes_test` database alongside the main one, loads the fixture, NULLs out the derived columns to simulate a fresh LINZ import, runs `set-postcodes.sql` and `setup-postcode-boundaries.sql`, and checks:

- exactly 2 postcode_boundaries are produced
- they are for `0991` and `0975`
- overall precision is at least 90%

## Regenerating fixtures

Fixtures are dumped from a fully-loaded `open_nz_postcodes` database (run `scripts/run_local.sh` first):

```
bash tests/fixtures/extract.sh
```

Captures all rows where postcode is `0991` or `0975` plus the localities that geographically intersect those meshblocks. ~3.5MB committed.
