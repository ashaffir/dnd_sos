# Generated by Django 3.0.7 on 2020-06-11 16:07

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0018_auto_20200610_0635'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='channel_name',
            field=models.CharField(blank=True, max_length=100, null=True),
        ),
    ]