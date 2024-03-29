# Generated by Django 3.0.6 on 2020-10-09 07:10

from django.db import migrations, models
import django.db.models.deletion
import places.fields


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0015_citymodel_geometry'),
    ]

    operations = [
        migrations.CreateModel(
            name='Place',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('location', places.fields.PlacesField(blank=True, max_length=255)),
            ],
        ),
        migrations.CreateModel(
            name='Route',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50)),
            ],
        ),
        migrations.CreateModel(
            name='RoutePoint',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50)),
                ('location', places.fields.PlacesField(max_length=255)),
                ('route', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='geo.Route')),
            ],
        ),
    ]
