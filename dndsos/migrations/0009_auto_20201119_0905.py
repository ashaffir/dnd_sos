# Generated by Django 3.0.6 on 2020-11-19 09:05

import ckeditor.fields
from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('dndsos', '0008_auto_20201119_0856'),
    ]

    operations = [
        migrations.AlterField(
            model_name='alertmessage',
            name='alert_message_content',
            field=ckeditor.fields.RichTextField(blank=True, max_length=1000, null=True),
        ),
    ]