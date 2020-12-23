# Generated by Django 3.0.6 on 2020-12-15 08:55

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0031_employee_profile_incomplete_message_sent'),
    ]

    operations = [
        migrations.AddField(
            model_name='employee',
            name='phone_blacklisted',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='employer',
            name='phone_blacklisted',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='user',
            name='phone_blacklisted',
            field=models.BooleanField(default=False),
        ),
    ]