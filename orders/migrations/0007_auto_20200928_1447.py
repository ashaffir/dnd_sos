# Generated by Django 3.0.6 on 2020-09-28 14:47

import django.contrib.postgres.fields.jsonb
from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0006_auto_20200915_1618'),
    ]

    operations = [
        migrations.AlterField(
            model_name='order',
            name='new_message',
            field=django.contrib.postgres.fields.jsonb.JSONField(blank=True, default={}, null=True),
        ),
    ]