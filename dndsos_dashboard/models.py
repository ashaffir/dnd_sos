
from django.db import models
from django.db.models.signals import post_save
# from django.contrib.auth.models import User
from django.utils.translation import ugettext_lazy as _
from django.dispatch import receiver

from .utils.models import TimeStampedUUIDModel
from ckeditor.fields import RichTextField
from core.models import User, Employee, Employer

class BusinessProfile(TimeStampedUUIDModel):

    BUSINESS_CATEGORY = (
        ('Restaurant', 'Restaurant'),
        ('Cothing', 'Clothing'),
        ('Convenience', 'Convenience'),
        ('Grocery', 'Grocery'),
        ('Other', 'Other'),
    )

    user = models.OneToOneField(User, on_delete=models.CASCADE)
    business_category = models.CharField(max_length=50, choices=BUSINESS_CATEGORY, blank=True, null=True)
    business_name = models.CharField(max_length=50, blank=True, null=True)
    street = models.CharField(max_length=100, blank=True, null=True)
    building_number = models.CharField(max_length=50, blank=True, null=True)
    city = models.CharField(max_length=100, blank=True, null=True)
    email = models.CharField(max_length=100, null=True, blank=True)
    phone = models.CharField(max_length=100, null=True, blank=True)

    profile_pic = models.ImageField(null=True, blank=True, upload_to="profile_pics", default = 'profile_pics/no-img.jpg')

    newsletter_optin = models.BooleanField(default=True)

    is_approved = models.BooleanField(default=False)

    class Meta:
        verbose_name = _('Business Profile')
        verbose_name_plural = _('Business Profiles')

    def __str__(self):
        return self.user.username

class FreelancerProfile(TimeStampedUUIDModel):

    VEHICLE = (
        ('Car', 'Car'),
        ('Scooter', 'Scooter'),
        ('Bicycle', 'Bicycle'),
        ('Motorcycle', 'Motorcycle'),
        ('Other', 'Other'),
    )

    ACTIVE_HOURS = (
        ('08:00-12:00', '08:00-12:00'),
        ('12:00-16:00', '12:00-16:00'),
        ('16:00-20:00', '16:00-20:00'),
        ('20:00-00:00', '20:00-00:00'),
    )

    user = models.OneToOneField(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=50, blank=True, null=True)
    city = models.CharField(max_length=100, blank=True, null=True)
    bio = models.TextField(max_length=500, blank=True, null=True)
    email = models.CharField(max_length=100, null=True, blank=True)
    phone = models.CharField(max_length=100, null=True, blank=True)
    vehicle = models.CharField(max_length=100, choices=VEHICLE, blank=True, null=True)
    active_hours = models.CharField(max_length=100, blank=True, null=True)

    profile_pic = models.ImageField(null=True, blank=True, upload_to="profile_pics", default = 'profile_pics/no-img.jpg')

    newsletter_optin = models.BooleanField(default=True)

    is_approved = models.BooleanField(default=False)

    class Meta:
        verbose_name = _('Freelancer Profile')
        verbose_name_plural = _('Freelancer Profiles')

    def __str__(self):
        return self.user.username

# @receiver(post_save, sender=User)
# def create_user_profile(sender, instance, created, **kwargs):
#     if created:
#         BusinessProfile.objects.create(user=instance)

# @receiver(post_save, sender=User)
# def save_user_profile(sender, instance, **kwargs):
#     instance.profile.save()

# class Order(TimeStampedUUIDModel):
#     order_id = models.CharField(max_length=100, null=True, default=-1)
#     created = models.DateTimeField(auto_now_add=True)
#     status = models.BooleanField(default=False, help_text='Active or not active')    
#     order_delivery_type = models.CharField(max_length=100, null=True, default='food')
#     order_time = models.DateTimeField(auto_now=True)
#     order_dispatched = models.BooleanField(default=False)
#     order_delivered = models.BooleanField(default=False)
#     order_city = models.CharField(max_length=100)
#     order_notes = models.TextField(max_length=500, blank=True, null=True)

#     order_business = models.ForeignKey(Employer, on_delete=models.CASCADE)
#     freelancer_allocated = models.ForeignKey(Employee, on_delete=models.CASCADE, null=True)    

#     freelancer_paid = models.BooleanField(default=False)

#     class Meta:
#         verbose_name = _('Order')
#         verbose_name_plural = _('Orders')
    
#     def __str__(self):
#         return f'{self.order_business}: {self.id}'


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

class Alert(models.Model):
    sender = models.ForeignKey(User, on_delete=models.CASCADE, null=True, related_name='sender')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, null=True, related_name='receiver')