#!/usr/bin/env bash
set -eof

echo "-- BEGIN $(date)"

cd /app/scripts/koordinates
mkdir -p /app/scripts/koordinates/data

apt update && apt install -y python3 python3-pip python3-venv

python3 -m venv onzp
source onzp/bin/activate

pip install -r requirements.txt

python3 ./setup_downloads.py

echo "Exports must complete before progressing (~10 mins)"
echo "https://data.linz.govt.nz/my/export-history/"
echo "https://datafinder.stats.govt.nz/my/export-history/"

read -n 1 -p "After exports complete... press any key to continue..."

python3 ./export_downloads.py

echo "-- END $(date)"
