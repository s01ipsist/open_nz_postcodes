import koordinates
import os
from datetime import datetime, timedelta
import pytz
import sys
import logging

UTC = pytz.UTC
LINZ_API_TOKEN = os.environ['LINZ_DATA_API_TOKEN']
STATSNZ_API_TOKEN = os.environ['STATSNZ_DATA_API_TOKEN']

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Define configurations for different data sources
# https://data.linz.govt.nz/layer/123113-nz-addresses-pilot/
# https://data.linz.govt.nz/layer/123110-nz-addresses-roads-pilot/
# https://data.linz.govt.nz/layer/113764-nz-suburbs-and-localities/
# https://datafinder.stats.govt.nz/layer/123521-meshblock-2026/

DATA_SOURCES = {
    'linz': {
        'name': 'linz-koord-2026',
        'host': 'data.linz.govt.nz',
        'token': LINZ_API_TOKEN,
        'crs': 'EPSG:4167',
        'format': 'application/x-zipped-shp',
        'layers': [123113, 123110, 113764]
    },
    'statsnz': {
        'name': 'statsnz-koord-2026a',
        'host': 'datafinder.stats.govt.nz',
        'token': STATSNZ_API_TOKEN,
        'crs': 'EPSG:2193',
        'format': 'application/x-zipped-shp',
        'layers': [123521]
    }
}

def get_client(host, token):
    return koordinates.Client(host=host, token=token)

def get_recent_active_exports(client, export_name):
    exports = client.exports.list()
    now = datetime.now().replace(tzinfo=UTC)
    one_week_ago = now - timedelta(days=7)

    return [
        export for export in exports
        if export.state in ['processing', 'complete'] and
        export.created_at > one_week_ago and
        export.name == export_name
    ]

def create_new_export(client, config):
    export = koordinates.Export()
    export.name = config['name']
    export.crs = config['crs']
    export.formats = {"vector": config['format']}

    for layer_id in config['layers']:
        try:
            layer = client.layers.get(layer_id)
            export.add_item(layer)
            logging.info(f"Added layer {layer_id} to export")
        except koordinates.exceptions.ClientError as e:
            logging.error(f"Failed to add layer {layer_id}: {e}")

    try:
        client.exports.create(export)
        logging.info(f"New export '{config['name']}' created successfully")
    except koordinates.exceptions.ClientError as e:
        logging.error(f"Failed to create export: {e}")

def process_data_source(config):
    client = get_client(config['host'], config['token'])

    recent_active_exports = get_recent_active_exports(client, config['name'])

    if recent_active_exports:
        logging.info(f"Found usable exports for '{config['name']}':")
        for export in recent_active_exports:
            logging.info(f"ID: {export.id}, Name: {export.name}, State: {export.state}, Created: {export.created_at}")
    else:
        logging.info(f"No exports found meeting the criteria for '{config['name']}'. Creating new export.")
        create_new_export(client, config)

def main():
    for source, config in DATA_SOURCES.items():
        logging.info(f"Processing {source}")
        process_data_source(config)

if __name__ == "__main__":
    main()
