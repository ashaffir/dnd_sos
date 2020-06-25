# Generated by Django 3.0.7 on 2020-06-23 13:59

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0007_auto_20200623_1352'),
    ]

    operations = [
        migrations.CreateModel(
            name='Street',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('street_id', models.IntegerField()),
                ('city_name', models.CharField(max_length=100)),
                ('city_symbol', models.IntegerField()),
                ('street_name', models.CharField(max_length=100)),
                ('street_symbol', models.IntegerField()),
            ],
            options={
                'verbose_name_plural': 'Streets',
            },
        ),
        migrations.AlterField(
            model_name='citymodel',
            name='city_symbol',
            field=models.IntegerField(),
        ),
    ]
