#!/usr/bin/env bash
set -eof

# USAGE: docker compose run --rm app scripts/run_local.sh

echo "-- BEGIN $(date)"

cd /app
bash scripts/setup-koordinates-data.sh
bash scripts/extract-export-data.sh
bash scripts/run.sh

echo "-- END $(date)"
