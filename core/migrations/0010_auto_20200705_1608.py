# Generated by Django 3.0.7 on 2020-07-05 16:08

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0009_auto_20200701_1049'),
    ]

    operations = [
        migrations.AlterField(
            model_name='employer',
            name='business_category',
            field=models.CharField(blank=True, choices=[('Restaurant', 'Restaurant'), ('Cothing', 'Clothing'), ('Convenience', 'Convenience'), ('Grocery', 'Grocery'), ('Office', 'Office'), ('Other', 'Other')], max_length=50, null=True),
        ),
    ]
