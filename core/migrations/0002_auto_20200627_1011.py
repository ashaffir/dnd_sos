# Generated by Django 3.0.7 on 2020-06-27 10:11

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='employer',
            name='lat',
            field=models.FloatField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='employer',
            name='lon',
            field=models.FloatField(blank=True, null=True),
        ),
    ]
