import koordinates
import os
import logging

LINZ_API_TOKEN = os.environ['LINZ_DATA_API_TOKEN']
STATSNZ_API_TOKEN = os.environ['STATSNZ_DATA_API_TOKEN']

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

DATA_SOURCES = {
    'linz': {
        'name': 'linz-koord-2026',
        'host': 'data.linz.govt.nz',
        'token': LINZ_API_TOKEN
    },
    'statsnz': {
        'name': 'statsnz-koord-2026a',
        'host': 'datafinder.stats.govt.nz',
        'token': STATSNZ_API_TOKEN
    }
}
DATA_FOLDER='./data/'

def get_client(host, token):
    return koordinates.Client(host=host, token=token)

def get_recent_active_exports(client, export_name):
    exports = client.exports.list()

    return [
        export for export in exports
        if export.state in ['complete'] and
        export.name == export_name
    ]

def download_export(client, export):
    filename = f"{export.name}.zip"
    full_path = os.path.join(DATA_FOLDER, filename)

    if os.path.exists(full_path):
        logging.info(f"File {filename} already exists in {DATA_FOLDER}. Skipping download.")
    else:
        logging.info(f"Downloading {filename} to {DATA_FOLDER}")
        os.makedirs(DATA_FOLDER, exist_ok=True)  # Ensure the data folder exists
        client.exports.get(export.id).download(DATA_FOLDER)
        logging.info(f"Download complete: {filename}")

def process_data_source_if_not_cached(config):
    filename = f"{config['name']}.zip"
    full_path = os.path.join(DATA_FOLDER, filename)

    if os.path.exists(full_path):
        logging.info(f"File {filename} already exists in {DATA_FOLDER}. Skipping download.")
    else:
        process_data_source(config)

def process_data_source(config):
    client = get_client(config['host'], config['token'])

    recent_active_exports = get_recent_active_exports(client, config['name'])

    if recent_active_exports:
        logging.info(f"Found usable exports for '{config['name']}':")
        for export in recent_active_exports:
            logging.info(f"ID: {export.id}, Name: {export.name}, State: {export.state}, Created: {export.created_at}")
            download_export(client, export)

    else:
        logging.info(f"No usable exports found for '{config['name']}'.")

def main():
    for source, config in DATA_SOURCES.items():
        logging.info(f"Processing {source}")
        process_data_source_if_not_cached(config)

if __name__ == "__main__":
    main()
