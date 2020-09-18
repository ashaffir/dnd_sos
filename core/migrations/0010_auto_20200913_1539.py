# Generated by Django 3.0.6 on 2020-09-13 15:39

import core.models
import django.core.validators
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0009_auto_20200909_1806'),
    ]

    operations = [
        migrations.AlterField(
            model_name='employee',
            name='id_doc',
            field=models.ImageField(blank=True, null=True, upload_to=core.models.id_path, validators=[django.core.validators.FileExtensionValidator(allowed_extensions=['pdf', 'jpg', 'jpeg', 'png'])]),
        ),
    ]