# Generated by Django 3.0.7 on 2020-06-25 06:03

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0008_order_distance_to_business'),
    ]

    operations = [
        migrations.AddField(
            model_name='order',
            name='trip_completed',
            field=models.FloatField(blank=True, null=True),
        ),
    ]
