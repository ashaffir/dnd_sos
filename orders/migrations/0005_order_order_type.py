# Generated by Django 3.0.7 on 2020-07-05 13:43

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0004_auto_20200701_1326'),
    ]

    operations = [
        migrations.AddField(
            model_name='order',
            name='order_type',
            field=models.CharField(choices=[('Food', 'Food'), ('Documents', 'Documents'), ('Tools', 'Tools'), ('Other', 'Other')], default='Food', max_length=50),
        ),
    ]
