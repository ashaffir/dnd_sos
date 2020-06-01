# Generated by Django 3.0.6 on 2020-06-01 15:39

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0013_auto_20200531_1511'),
    ]

    operations = [
        migrations.AlterField(
            model_name='order',
            name='status',
            field=models.CharField(choices=[('REQUESTED', 'REQUESTED'), ('RE_REQUESTED', 'RE_REQUESTED'), ('REJECTED', 'REJECTED'), ('STARTED', 'STARTED'), ('IN_PROGRESS', 'IN_PROGRESS'), ('COMPLETED', 'COMPLETED'), ('SETTLED', 'SETTLED'), ('ARCHIVED', 'ARCHIVED')], default='REQUESTED', max_length=20),
        ),
    ]
