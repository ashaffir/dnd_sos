# Generated by Django 3.0.6 on 2020-10-21 14:06

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0011_auto_20201005_1148'),
    ]

    operations = [
        migrations.AddField(
            model_name='order',
            name='sale_id',
            field=models.CharField(blank=True, max_length=100, null=True),
        ),
    ]