#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/config.sh"

# USAGE: docker compose run --rm app scripts/run_local.sh

log "-- BEGIN"

cd /app
bash scripts/setup-koordinates-data.sh
bash scripts/extract-export-data.sh
bash scripts/run.sh

log "-- END"
