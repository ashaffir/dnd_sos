# Generated by Django 3.0.6 on 2020-09-30 12:42

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0008_auto_20200928_1447'),
    ]

    operations = [
        migrations.AlterField(
            model_name='order',
            name='fare',
            field=models.FloatField(blank=True, default=0.0, null=True),
        ),
    ]