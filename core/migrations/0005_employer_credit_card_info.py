# Generated by Django 3.0.7 on 2020-07-20 07:59

import django.contrib.postgres.fields.jsonb
from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0004_remove_employee_freelancer_rating_report'),
    ]

    operations = [
        migrations.AddField(
            model_name='employer',
            name='credit_card_info',
            field=django.contrib.postgres.fields.jsonb.JSONField(blank=True, null=True),
        ),
    ]