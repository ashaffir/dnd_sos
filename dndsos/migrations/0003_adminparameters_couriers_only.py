# Generated by Django 3.0.6 on 2020-11-16 12:53

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('dndsos', '0002_adminparameters'),
    ]

    operations = [
        migrations.AddField(
            model_name='adminparameters',
            name='couriers_only',
            field=models.BooleanField(default=False),
        ),
    ]
