import json
import django.contrib.gis.db.models.fields
from django.db import migrations, models
from django.core.management import call_command
from django.contrib.gis.geos import fromstr
from pathlib import Path


# DATA_FILENAME = '../maps/miami_shops.json'
# def load_data(apps, schema_editor):
#     print('loading data...')
#     BusinessLocation = apps.get_model('geo', 'BusinessLocation')
#     jsonfile = Path(__file__).parents[2] / DATA_FILENAME

#     with open(str(jsonfile)) as datafile:
#         objects = json.load(datafile)
#         for obj in objects['elements']:
#             try:
#                 objType = obj['type']
#                 if objType == 'node':
#                     tags = obj['tags']
#                     name = tags.get('name','no-name')
#                     longitude = obj.get('lon', 0)
#                     latitude = obj.get('lat', 0)
#                     location = fromstr(f'POINT({longitude} {latitude})', srid=4326)
#                     BusinessLocation(name=name, location = location).save()
#             except KeyError:
#                 pass     

class Migration(migrations.Migration):
    dependencies = [
        ('geo', '0001_initial'),
    ]

    # operations = [
    #     migrations.RunPython(load_data)
    # ]