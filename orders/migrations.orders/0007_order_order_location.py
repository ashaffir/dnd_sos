# Generated by Django 3.0.7 on 2020-06-24 09:51

import django.contrib.gis.db.models.fields
from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0006_auto_20200624_0836'),
    ]

    operations = [
        migrations.AddField(
            model_name='order',
            name='order_location',
            field=django.contrib.gis.db.models.fields.PointField(blank=True, null=True, srid=4326),
        ),
    ]