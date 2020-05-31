# Generated by Django 3.0.6 on 2020-05-29 07:02

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0011_auto_20200527_1145'),
    ]

    operations = [
        migrations.AlterField(
            model_name='order',
            name='city',
            field=models.CharField(max_length=100, null=True),
        ),
        migrations.AlterField(
            model_name='order',
            name='drop_off_address',
            field=models.CharField(max_length=255, null=True),
        ),
        migrations.AlterField(
            model_name='order',
            name='pick_up_address',
            field=models.CharField(max_length=255, null=True),
        ),
    ]
