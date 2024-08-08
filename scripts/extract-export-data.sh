#!/bin/bash
set -eof

mv scripts/koordinates/data/linz-koord.zip data/linz-koord.zip
mv scripts/koordinates/data/statsnz-koord.zip data/statsnz-koord.zip

cd data
unzip -o linz-koord.zip
unzip -o statsnz-koord.zip
