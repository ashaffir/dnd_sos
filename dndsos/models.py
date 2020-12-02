
from ckeditor.fields import RichTextField
from django.core.validators import MinValueValidator, MaxValueValidator

from django.db import models
from core.models import Employee, Employer


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
    LANGUAGES = (
        ('Hebrew', 'he'),
        ('English', 'en'),
    )
    name = models.CharField(max_length=100, null=True, blank=True)
    content = RichTextField(max_length=100000, null=True, blank=True)
    language = models.CharField(
        max_length=20, choices=LANGUAGES, default='English')
    section = models.CharField(max_length=100, null=True, blank=True)
    active = models.BooleanField(default=True)
    image = models.CharField(max_length=200, null=True, blank=True)

    def __str__(self):
        return self.name


class Faq(models.Model):
    name = models.CharField(max_length=100, null=True)
    content = RichTextField(max_length=1000, null=True)
    active = models.BooleanField(default=True)

    def __str__(self):
        return self.name

# NOT USED


class FreelancerFeedback(models.Model):
    freelancer = models.OneToOneField(Employee, on_delete=models.CASCADE)
    overall = models.IntegerField(null=True, blank=True, validators=[
                                  MaxValueValidator(5), MinValueValidator(0)])
    communication = models.IntegerField(null=True, blank=True)
    response_time = models.IntegerField(null=True, blank=True)
    recommend = models.IntegerField(null=True, blank=True)

    def __str__(self):
        return f'{self.freelancer.name} | {self.freelancer.pk}'


class AdminParameters(models.Model):
    name = models.CharField(max_length=100, blank=True, null=True)
    usd_ils_default = models.FloatField(default=3.5)
    usd_eur_default = models.FloatField(default=0.8)
    rookie_level_max = models.IntegerField(default=1)
    advanced_level_max = models.IntegerField(default=10)
    expert_level_max = models.IntegerField(default=50)
    couriers_only = models.BooleanField(default=False)


class AlertMessage(models.Model):
    alert_message_page = models.CharField(
        max_length=100, null=True, blank=True)
    alert_message_title = models.CharField(
        max_length=100, null=True, blank=True)
    alert_message_content = RichTextField(
        max_length=1000, null=True, blank=True)
    alert_message_language = models.CharField(
        max_length=100, null=True, blank=True, default='en')
    alert_message_active = models.BooleanField(default=False)
