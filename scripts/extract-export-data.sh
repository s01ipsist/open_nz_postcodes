#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/config.sh"

mkdir -p data

# source file names from DATA_SOURCES in scripts/koordinates/config.py
mv scripts/koordinates/data/linz-koord-${YEAR}.zip data/linz-koord.zip
mv scripts/koordinates/data/statsnz-koord-${YEAR}a.zip data/statsnz-koord.zip

cd data
unzip -o linz-koord.zip
unzip -o statsnz-koord.zip
