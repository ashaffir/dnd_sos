# Generated by Django 3.0.6 on 2020-10-17 10:46

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('dndsos', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='AdminParameters',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('usd_ils_default', models.FloatField(default=3.5)),
                ('usd_eur_default', models.FloatField(default=0.8)),
                ('rookie_level_max', models.IntegerField(default=1)),
                ('advanced_level_max', models.IntegerField(default=10)),
                ('expert_level_max', models.IntegerField(default=50)),
            ],
        ),
    ]
