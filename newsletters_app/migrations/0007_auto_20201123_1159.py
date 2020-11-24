# Generated by Django 3.0.6 on 2020-11-23 11:59

import ckeditor.fields
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('newsletters_app', '0006_auto_20201123_0800'),
    ]

    operations = [
        migrations.AddField(
            model_name='newsletter',
            name='language',
            field=models.CharField(choices=[('Hebrew', 'he'), ('English', 'en')], default='English', max_length=20),
        ),
        migrations.AlterField(
            model_name='newsletter',
            name='content_1',
            field=ckeditor.fields.RichTextField(blank=True, max_length=2000, null=True),
        ),
        migrations.AlterField(
            model_name='newsletter',
            name='content_2',
            field=ckeditor.fields.RichTextField(blank=True, max_length=2000, null=True),
        ),
        migrations.AlterField(
            model_name='newsletter',
            name='content_3',
            field=ckeditor.fields.RichTextField(blank=True, max_length=2000, null=True),
        ),
    ]
