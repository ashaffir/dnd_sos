
from ckeditor.fields import RichTextField

from django.db import models

class ContactUs(models.Model):
    fname = models.CharField(max_length=100, blank=True, null=True)
    lname = models.CharField(max_length=100, blank=True, null=True)
    subject = models.CharField(max_length=100, blank=True, null=True)
    email = models.CharField(max_length=100)
    message = models.TextField(max_length=500)
    created = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.email


class ContentPage(models.Model):
	name = models.CharField(max_length=100, null=True)
	content = RichTextField(max_length=100000, null=True)
	active = models.BooleanField(default=True)

	def __str__(self):
	 return self.name