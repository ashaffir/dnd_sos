# Generated by Django 3.0.6 on 2020-10-25 07:21

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0012_order_sale_id'),
    ]

    operations = [
        migrations.AddField(
            model_name='order',
            name='order_cc',
            field=models.CharField(blank=True, max_length=20, null=True),
        ),
    ]
