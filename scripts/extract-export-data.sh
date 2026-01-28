#!/bin/bash
set -eof

mkdir -p data

# source file names from DATA_SOURCES in scripts/koordinates/export_downloads.py
mv scripts/koordinates/data/linz-koord-2026.zip data/linz-koord.zip
mv scripts/koordinates/data/statsnz-koord-2026a.zip data/statsnz-koord.zip

cd data
unzip -o linz-koord.zip
unzip -o statsnz-koord.zip
