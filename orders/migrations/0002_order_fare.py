# Generated by Django 3.0.7 on 2020-08-23 13:07

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='order',
            name='fare',
            field=models.FloatField(blank=True, null=True),
        ),
    ]