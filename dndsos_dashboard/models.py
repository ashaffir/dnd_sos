import os
from django.db import models
# from django.contrib.auth.models import User
from django.utils.translation import ugettext_lazy as _
from django.dispatch import receiver

from .utils.models import TimeStampedUUIDModel
from ckeditor.fields import RichTextField
from core.models import User, Employee, Employer

class Email(models.Model):
    name = models.CharField(max_length=100)
    mail_subject = models.CharField(max_length=100)
    mail_title = models.CharField(max_length=100)
    mail_body = RichTextField(max_length=5000)

    class Meta:
        verbose_name = _('Email Template')
        verbose_name_plural = 'Email Templates'

   
    def __str__(self):
        return self.name
