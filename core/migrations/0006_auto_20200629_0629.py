# Generated by Django 3.0.7 on 2020-06-29 06:29

import django.contrib.postgres.fields.jsonb
from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0005_auto_20200629_0552'),
    ]

    operations = [
        migrations.AlterField(
            model_name='employee',
            name='trips',
            field=django.contrib.postgres.fields.jsonb.JSONField(blank=True, null=True),
        ),
    ]
