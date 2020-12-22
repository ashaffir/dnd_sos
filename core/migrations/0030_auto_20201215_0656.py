# Generated by Django 3.0.6 on 2020-12-15 06:56

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0029_auto_20201215_0641'),
    ]

    operations = [
        migrations.AddField(
            model_name='employee',
            name='is_rejected',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='employee',
            name='rejection_reason',
            field=models.CharField(blank=True, max_length=100, null=True),
        ),
        migrations.AddField(
            model_name='employee',
            name='review_date',
            field=models.DateTimeField(blank=True, null=True),
        ),
    ]
