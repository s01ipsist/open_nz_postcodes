import koordinates
from datetime import datetime, timedelta
import pytz
import sys
import logging
from config import DATA_SOURCES

UTC = pytz.UTC

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

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
