import os

LINZ_API_TOKEN = os.environ['LINZ_DATA_API_TOKEN']
STATSNZ_API_TOKEN = os.environ['STATSNZ_DATA_API_TOKEN']

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

DATA_FOLDER = './data/'
