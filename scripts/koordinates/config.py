import os


def _parse_config_sh(path):
    settings = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line.startswith('export '):
                key, _, value = line[len('export '):].partition('=')
                settings[key] = value
    return settings


_cfg = _parse_config_sh(os.path.join(os.path.dirname(__file__), '..', 'config.sh'))
YEAR = int(_cfg['YEAR'])
MESHBLOCK_LAYER_ID = int(_cfg['MESHBLOCK_LAYER_ID'])

LINZ_API_TOKEN = os.environ['LINZ_DATA_API_TOKEN']
STATSNZ_API_TOKEN = os.environ['STATSNZ_DATA_API_TOKEN']

# Define configurations for different data sources
# https://data.linz.govt.nz/layer/123113-nz-addresses/
# https://data.linz.govt.nz/layer/123110-nz-addresses-roads/
# https://data.linz.govt.nz/layer/113764-nz-suburbs-and-localities/

DATA_SOURCES = {
    'linz': {
        'name': f'linz-koord-{YEAR}',
        'host': 'data.linz.govt.nz',
        'token': LINZ_API_TOKEN,
        'crs': 'EPSG:4167',
        'format': 'application/x-zipped-shp',
        'layers': [123113, 123110, 113764]
    },
    'statsnz': {
        'name': f'statsnz-koord-{YEAR}a',
        'host': 'datafinder.stats.govt.nz',
        'token': STATSNZ_API_TOKEN,
        'crs': 'EPSG:2193',
        'format': 'application/x-zipped-shp',
        'layers': [MESHBLOCK_LAYER_ID]
    }
}

DATA_FOLDER = './data/'
