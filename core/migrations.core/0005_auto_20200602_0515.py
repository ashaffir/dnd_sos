# Generated by Django 3.0.6 on 2020-06-02 05:15

import django.contrib.postgres.fields
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0004_auto_20200602_0512'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='relations',
            field=django.contrib.postgres.fields.ArrayField(base_field=django.contrib.postgres.fields.ArrayField(base_field=models.CharField(blank=True, max_length=10000, null=True), size=400), size=1),
        ),
    ]