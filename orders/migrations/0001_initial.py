# Generated by Django 3.0.7 on 2020-08-23 12:55

from django.conf import settings
import django.contrib.gis.db.models.fields
import django.contrib.postgres.fields.jsonb
import django.core.validators
from django.db import migrations, models
import django.db.models.deletion
import uuid


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Order',
            fields=[
                ('order_id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('pick_up_address', models.CharField(max_length=255, null=True)),
                ('drop_off_address', models.CharField(max_length=255, null=True)),
                ('order_type', models.CharField(choices=[('Food', 'Food'), ('Documents', 'Documents'), ('Clothes', 'Clothes'), ('Tools', 'Tools'), ('Other', 'Other')], default='Food', max_length=50)),
                ('order_country', models.CharField(blank=True, max_length=100, null=True)),
                ('order_city_name', models.CharField(blank=True, max_length=100, null=True)),
                ('order_city_symbol', models.IntegerField(blank=True, null=True)),
                ('order_street_name', models.CharField(blank=True, max_length=100, null=True)),
                ('order_street_symbol', models.IntegerField(blank=True, null=True)),
                ('order_location', django.contrib.gis.db.models.fields.PointField(blank=True, null=True, srid=4326)),
                ('distance_to_business', models.FloatField(blank=True, null=True)),
                ('trip', django.contrib.postgres.fields.jsonb.JSONField(blank=True, null=True)),
                ('trip_completed', models.FloatField(blank=True, null=True)),
                ('notes', models.TextField(blank=True, max_length=500, null=True)),
                ('price', models.FloatField(blank=True, null=True)),
                ('selected_freelancers', django.contrib.postgres.fields.jsonb.JSONField(blank=True, null=True)),
                ('status', models.CharField(choices=[('REQUESTED', 'REQUESTED'), ('RE_REQUESTED', 'RE_REQUESTED'), ('REJECTED', 'REJECTED'), ('STARTED', 'STARTED'), ('IN_PROGRESS', 'IN_PROGRESS'), ('COMPLETED', 'COMPLETED'), ('SETTLED', 'SETTLED'), ('ARCHIVED', 'ARCHIVED')], default='REQUESTED', max_length=20)),
                ('transaction_auth_num', models.CharField(blank=True, max_length=100, null=True)),
                ('customer_transaction_id', models.CharField(blank=True, max_length=100, null=True)),
                ('private_sale_token', models.CharField(blank=True, max_length=100, null=True)),
                ('invoice_url', models.URLField(blank=True, null=True)),
                ('freelancer_rating', models.IntegerField(blank=True, null=True, validators=[django.core.validators.MaxValueValidator(5), django.core.validators.MinValueValidator(0)])),
                ('freelancer_rating_report', models.TextField(blank=True, max_length=500, null=True)),
                ('business_rating', models.IntegerField(blank=True, null=True, validators=[django.core.validators.MaxValueValidator(5), django.core.validators.MinValueValidator(0)])),
                ('chat', django.contrib.postgres.fields.jsonb.JSONField(blank=True, null=True)),
                ('new_message', django.contrib.postgres.fields.jsonb.JSONField(blank=True, null=True)),
                ('business', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='business_orders', to=settings.AUTH_USER_MODEL)),
                ('freelancer', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='freelancer_orders', to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='ChatMessage',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('updated', models.DateTimeField(auto_now=True)),
                ('business', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='business_messages', to=settings.AUTH_USER_MODEL)),
                ('freelancer', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='freelancer_messages', to=settings.AUTH_USER_MODEL)),
                ('order', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='orders.Order')),
            ],
        ),
    ]