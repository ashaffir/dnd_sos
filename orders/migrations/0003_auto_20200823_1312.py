# Generated by Django 3.0.7 on 2020-08-23 13:12

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0002_order_fare'),
    ]

    operations = [
        migrations.AlterField(
            model_name='order',
            name='fare',
            field=models.CharField(blank=True, max_length=100, null=True),
        ),
    ]
