from django.db import models
from django.contrib.postgres.fields import ArrayField, JSONField


class Newsletter(models.Model):
    name = models.CharField(max_length=100, null=True, blank=True)
    created = models.TimeField(auto_created=True)
    sent = models.BooleanField(default=False)
    sent_date = models.DateTimeField(null=True, blank=True)
    subject = models.CharField(max_length=100, null=True, blank=True)
    title_1 = models.CharField(max_length=100, null=True, blank=True)
    content_1 = models.TextField(max_length=2000, null=True, blank=True)
    title_2 = models.CharField(max_length=100, null=True, blank=True)
    content_2 = models.TextField(max_length=2000, null=True, blank=True)
    title_3 = models.CharField(max_length=100, null=True, blank=True)
    content_3 = models.TextField(max_length=2000, null=True, blank=True)

    recipients = JSONField(blank=True, null=True, default=list)



