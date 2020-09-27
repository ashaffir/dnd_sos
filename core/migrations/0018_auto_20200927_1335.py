# Generated by Django 3.0.6 on 2020-09-27 13:35

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0017_employee_account_level'),
    ]

    operations = [
        migrations.AlterField(
            model_name='employee',
            name='payment_method',
            field=models.CharField(blank=True, choices=[('None', 'None'), ('Bank', 'Bank'), ('Phone', 'Phone'), ('PayPal', 'PayPal'), ('Other', 'Other')], default='None', max_length=50, null=True),
        ),
        migrations.AlterField(
            model_name='employee',
            name='preferred_payment_method',
            field=models.CharField(choices=[('None', 'None'), ('Bank', 'Bank'), ('Phone', 'Phone'), ('PayPal', 'PayPal'), ('Other', 'Other')], default='Bank', max_length=100),
        ),
    ]
