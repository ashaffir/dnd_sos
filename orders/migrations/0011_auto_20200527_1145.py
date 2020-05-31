# Generated by Django 3.0.6 on 2020-05-27 11:45

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0010_auto_20200527_0955'),
    ]

    operations = [
        migrations.AlterField(
            model_name='order',
            name='status',
            field=models.CharField(choices=[('REQUESTED', 'REQUESTED'), ('STARTED', 'STARTED'), ('IN_PROGRESS', 'IN_PROGRESS'), ('COMPLETED', 'COMPLETED'), ('SETTLED', 'SETTLED'), ('ARCHIVED', 'ARCHIVED')], default='REQUESTED', max_length=20),
        ),
    ]
