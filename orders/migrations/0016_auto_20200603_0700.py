# Generated by Django 3.0.6 on 2020-06-03 07:00

import django.contrib.postgres.fields
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0015_order_selected_freelancers'),
    ]

    operations = [
        migrations.AlterField(
            model_name='order',
            name='selected_freelancers',
            field=django.contrib.postgres.fields.ArrayField(base_field=django.contrib.postgres.fields.ArrayField(base_field=models.CharField(blank=True, max_length=10000, null=True), size=400), null=True, size=1),
        ),
    ]
