# Generated by Django 3.0.7 on 2020-09-05 08:41

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0006_user_address'),
    ]

    operations = [
        migrations.AlterField(
            model_name='employer',
            name='business_category',
            field=models.CharField(blank=True, choices=[('Restaurant', 'Restaurant'), ('Clothing', 'Clothing'), ('Convenience', 'Convenience'), ('Grocery', 'Grocery'), ('Office', 'Office'), ('Other', 'Other')], max_length=50, null=True),
        ),
    ]