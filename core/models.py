from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils.translation import ugettext_lazy as _
from jsonfield import JSONField
# from django.contrib.postgres.fields import ArrayField

# use a custom auth user model to add extra fields
# for both Employer and Employee
class User(AbstractUser):
    # override username and email(unique)
    username = models.CharField(max_length=200, blank=False)
    email = models.EmailField(max_length=200, unique=True, blank=False)
    
    # denotes whether the user is Employer
    is_employer = models.BooleanField(default=False)
    
    # denotes wether the user is Employee
    is_employee = models.BooleanField(default=False)
    
    # role of the user
    position = models.CharField(max_length=200, default=None, blank=True, null=True)
    
    # phone number
    phone_number = models.CharField(max_length=15, blank=False)
    
    # date of birth
    date_of_birth = models.DateField(default=None, blank=True, null=True)
    
    # national ID
    national_id = models.CharField(max_length=15, default=None, blank=True, null=True)
    
    # KRA PIN
    kra_pin = models.CharField(max_length=50, default=None, blank=True, null=True)
    
    # mandatory fields
    REQUIRED_FIELDS = ['username',]
    
    # require the email to be the unique identifier
    USERNAME_FIELD = 'email'

    def __str__(self):
        return self.email
        
        
# profile model for fields specific to Employer
class Employer(models.Model):
    BUSINESS_CATEGORY = (
        ('Restaurant', 'Restaurant'),
        ('Cothing', 'Clothing'),
        ('Convenience', 'Convenience'),
        ('Grocery', 'Grocery'),
        ('Other', 'Other'),
    )

    user = models.OneToOneField(User,on_delete=models.CASCADE,primary_key=True)
    
    # business name
    business_name = models.CharField(max_length=200, default=None, blank=True, null=True)
    
    # number of employees associated with the employer
    number_of_employees  = models.IntegerField(default=0, blank=True, null=True)


    business_category = models.CharField(max_length=50, choices=BUSINESS_CATEGORY, blank=True, null=True)
    street = models.CharField(max_length=100, blank=True, null=True)
    building_number = models.CharField(max_length=50, blank=True, null=True)
    city = models.CharField(max_length=100, blank=True, null=True)
    email = models.CharField(max_length=100, null=True, blank=True)
    phone = models.CharField(max_length=100, null=True, blank=True)

    b_freelancers = models.CharField(max_length=500, null=True)
 

    profile_pic = models.ImageField(null=True, blank=True, upload_to="profile_pics", default = 'profile_pics/no-img.jpg')

    newsletter_optin = models.BooleanField(default=True, null=True)

    class Meta:
        verbose_name = _('Business Profile')
        verbose_name_plural = _('Business Profiles')

    def __str__(self):
        return self.business_name

# profile model for fields specific to Freelancer
class Employee(models.Model):    
    # employee 'belongs' to employer
    # employer = models.ForeignKey(Employer, on_delete=models.SET_DEFAULT, default=1)
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

    user = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True)
    name = models.CharField(max_length=50, blank=True, null=True)
    city = models.CharField(max_length=100, blank=True, null=True)
    bio = models.TextField(max_length=500, blank=True, null=True)
    email = models.CharField(max_length=100, null=True, blank=True)
    phone = models.CharField(max_length=100, null=True, blank=True)
    vehicle = models.CharField(max_length=100, choices=VEHICLE, blank=True, null=True)
    active_hours = models.CharField(max_length=100, blank=True, null=True)

    profile_pic = models.ImageField(null=True, blank=True, upload_to="profile_pics", default = 'profile_pics/no-img.jpg')

    newsletter_optin = models.BooleanField(default=True, null=True)

    class Meta:
        verbose_name = _('Freelancer Profile')
        verbose_name_plural = _('Freelancer Profiles')

    def __str__(self):
        return self.user.username

    
    def __str__(self):
        return self.user.email

# company assets, owned by the employer
class Asset(models.Model):
    asset = models.CharField(max_length=50, blank=False, primary_key=True)
    employer = models.ForeignKey(Employer, on_delete=models.CASCADE)
    description = models.CharField(max_length=200, blank=False)

# track which asset is owned by which employee
class AssignedAsset(models.Model):
    asset = models.OneToOneField(Asset, on_delete=models.CASCADE)
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE)






