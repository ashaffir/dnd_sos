# Generated by Django 3.0.7 on 2020-06-25 06:49

import django.contrib.gis.db.models.fields
from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0022_auto_20200624_1157'),
    ]

    operations = [
        migrations.AddField(
            model_name='employee',
            name='location',
            field=django.contrib.gis.db.models.fields.PointField(blank=True, null=True, srid=4326),
        ),
    ]