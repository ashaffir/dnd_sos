# Generated by Django 3.0.6 on 2020-11-23 06:38

from django.db import migrations, models
import django.utils.timezone


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0022_user_newsletter_optin'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='joined',
            field=models.DateTimeField(auto_now_add=True, default=django.utils.timezone.now),
            preserve_default=False,
        ),
    ]