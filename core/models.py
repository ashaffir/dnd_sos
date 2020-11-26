from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils.translation import ugettext_lazy as _
from django.contrib.postgres.fields import ArrayField, JSONField

from django.contrib.gis.db import models as geomodels
from django.contrib.gis.db.models import PointField
from django.core.validators import FileExtensionValidator

from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver
from rest_framework.authtoken.models import Token
from imagekit.models import ImageSpecField
from imagekit.processors import ResizeToFill
# from orders.models import Order

# use a custom auth user model to add extra fields
# for both Employer and Employee
class User(AbstractUser):
    # override username and email(unique)
    username = models.CharField(max_length=200, blank=False)
    email = models.EmailField(max_length=200, unique=True, blank=False)
    joined = models.DateTimeField(auto_now_add=True)
    
    # denotes whether the user is Employer
    is_employer = models.BooleanField(default=False)

    first_name = models.CharField(_('first name'), max_length=30, blank=True, null=True)
    
    # denotes wether the user is Employee
    is_employee = models.BooleanField(default=False)
    
    # role of the user
    position = models.CharField(max_length=200, default=None, blank=True, null=True)

    address = models.CharField(max_length=200, blank=True, null=True)
    lat = models.FloatField(null=True, blank=True)
    lon = models.FloatField(null=True, blank=True)

    # phone number
    phone_number = models.CharField(max_length=15, blank=True, null=True, default=None)
    
    # date of birth
    date_of_birth = models.DateField(default=None, blank=True, null=True)
    
    # national ID
    national_id = models.CharField(max_length=15, default=None, blank=True, null=True)
    
    # KRA PIN
    kra_pin = models.CharField(max_length=50, default=None, blank=True, null=True)

    # Term agreement
    terms_accepted = models.BooleanField(default=False)

    # mandatory fields
    REQUIRED_FIELDS = ['username',]
    
    # require the email to be the unique identifier
    USERNAME_FIELD = 'email'

    vehicle = models.CharField(max_length=50, null=True, blank=True)

    relationships = JSONField(null=True, blank=True)

    channel_name = models.CharField(max_length=100, null=True, blank=True)

    newsletter_optin = models.BooleanField(default=True)

    def __str__(self):
        return self.email
        
        
# profile model for fields specific to Employer
class Employer(models.Model):
    BUSINESS_CATEGORY = (
        ('Restaurant', 'Restaurant'),
        ('Clothes', 'Clothes'),
        ('Convenience', 'Convenience'),
        ('Grocery', 'Grocery'),
        ('Office', 'Office'),
        ('Other', 'Other'),
    )

    user = models.OneToOneField(User,on_delete=models.CASCADE,primary_key=True, related_name='business')
    
    # business name
    business_name = models.CharField(max_length=200, blank=True, null=True)
    
    # number of employees associated with the employer
    number_of_employees  = models.IntegerField(default=0, blank=True, null=True)

    business_category = models.CharField(max_length=50, choices=BUSINESS_CATEGORY, blank=True, null=True)
    
    # GEO
    street = models.CharField(max_length=100, blank=True, null=True)
    building_number = models.CharField(max_length=50, blank=True, null=True)
    city = models.CharField(max_length=100, blank=True, null=True)
    country = models.CharField(max_length=100, blank=True, null=True)
    address = models.CharField(max_length=200, blank=True, null=True)
    lat = models.FloatField(null=True, blank=True)
    lon = models.FloatField(null=True, blank=True)
    location = PointField(blank=True, null=True)

    email = models.CharField(max_length=100, null=True, blank=True)
    phone = models.CharField(max_length=100, null=True, blank=True)

    credit_card_token = models.CharField(max_length=100, blank=True, null=True)
    # credit_card_info = JSONField(null=True, blank=True) # Will be retreived directly from Rivhit

    business_total_rating = models.FloatField(null=True, blank=True)

    b_freelancers = models.CharField(max_length=500, null=True, blank=True)
 
    profile_pic = models.ImageField(null=True, blank=True, upload_to="profile_pics", default = 'profile_pics/no-img.jpg')
    # profile_pic_thumbnail = ImageSpecField(source='avatar',
    #                                   processors=[ResizeToFill(100, 50)],
    #                                   format='JPEG',
    #                                   options={'quality': 60})
    newsletter_optin = models.BooleanField(default=True)

    new_messages = models.IntegerField(default=0)

    is_approved = models.BooleanField(default=False)
    
    verification_code = models.CharField(max_length=10, null=True, blank=True)

    @property
    def lat_lng(self):
        return list(getattr(self.location, 'coords', [])[::-1])


    class Meta:
        verbose_name = _('Business Profile')
        verbose_name_plural = _('Business Profiles')

    def __str__(self):
        return self.user.username

def id_path(instance, filename):
    return f'documents/{instance.pk}.id_doc.{filename}'

# profile model for fields specific to Freelancer
class Employee(models.Model):    
    # employee 'belongs' to employer
    # employer = models.ForeignKey(Employer, on_delete=models.SET_DEFAULT, default=1)
    VEHICLE = (
        ('Car', 'Car'),
        ('Scooter', 'Scooter'),
        ('Bicycle', 'Bicycle'),
        ('Motorcycle', 'Motorcycle'),
        ('Truck', 'Truck'),
    )

    ACCOUNT_LEVEL = (
        ('Rookie', 'Rookie'),
        ('Advanced','Advanced'),
        ('Expert','Expert'),
    )

    ACTIVE_HOURS = (
        ('08:00-12:00', '08:00-12:00'),
        ('12:00-16:00', '12:00-16:00'),
        ('16:00-20:00', '16:00-20:00'),
        ('20:00-00:00', '20:00-00:00'),
    )

    # COUNTRIES = (
    #     ('IL', 'Israel'),
    #     ('USA', 'USA'),
    # )

    user = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True, related_name='freelancer')
    name = models.CharField(max_length=50, blank=True, null=True)
    city = models.CharField(max_length=100, blank=True, null=True)
    country = models.CharField(max_length=100, blank=True, null=True)
    address = models.CharField(max_length=200, blank=True, null=True)
    bio = models.TextField(max_length=500, blank=True, null=True)
    email = models.CharField(max_length=100, null=True, blank=True)
    phone = models.CharField(max_length=100, null=True, blank=True)
    vehicle = models.CharField(max_length=100, choices=VEHICLE, blank=True, null=True)
    active_hours = models.CharField(max_length=100, blank=True, null=True)
    
    is_available = models.BooleanField(default=False) # Available for delivering ("open for business")
    is_delivering = models.BooleanField(default=False) # Is currently delivering or accepted delivery and going to pick up
    
    # current_order = models.OneToOneField(Order, on_delete=models.SET_DEFAULT, default=-1)

    lat = models.FloatField(null=True, blank=True)
    lon = models.FloatField(null=True, blank=True)
    location = PointField(blank=True, null=True)

    '''
    Trips: saving all Freelancer's locaitons for mornitorung and statistics
    trips = {
        time: datetime
        lat: float
        lon: float
    } 
    '''
    trips = JSONField(null=True, blank=True)

    profile_pic = models.ImageField(null=True, blank=True, upload_to="profile_pics", default = 'profile_pics/no-img.jpg')
    id_doc = models.ImageField(null=True, blank=True, upload_to=id_path, validators=[FileExtensionValidator(allowed_extensions=['pdf', 'jpg', 'jpeg', 'png'])])
    id_doc_expiry = models.DateField(null=True, blank=True)
    
    freelancer_total_rating = models.FloatField(null=True, blank=True)
    account_level = models.CharField(max_length=30,choices=ACCOUNT_LEVEL, default='Rookie')

    newsletter_optin = models.BooleanField(default=True)

    new_messages = models.IntegerField(default=0)

    profile_pending = models.BooleanField(default=False) # He filled up the profile information necessary
    is_approved = models.BooleanField(default=False) # He filled up the profile information necessary

    verification_code = models.CharField(max_length=20, null=True, blank=True) # Used for email verificaiton

    PAYMENT_METHODS = (
        ('None', 'None'),
        ('Bank', 'Bank'),
        ('Phone', 'Phone'),
        ('PayPal', 'PayPal'),
        ('Other', 'Other'),
    )
    paypal_account = models.CharField(max_length=100, null=True, blank=True)
    payment_via_phone = models.BooleanField(default=False) # E.g. Bit
    bank_details = JSONField(null=True, blank=True, default=dict)
    preferred_payment_method = models.CharField(max_length=100, choices=PAYMENT_METHODS, default='None')

    balance = models.FloatField(null=True, blank=True, default=0.0)

    payment_amount = models.FloatField(null=True, blank=True, default=0.0)
    last_payment_date = models.DateTimeField(null=True, blank=True)
    next_payment_date = models.DateTimeField(null=True, blank=True)
    payment_method = models.CharField(max_length=50, choices=PAYMENT_METHODS, null=True, blank=True, default="None")

    class Meta:
        verbose_name = _('Freelancer Profile')
        verbose_name_plural = _('Freelancer Profiles')

    def __str__(self):
        return self.user.username

    
    # def __str__(self):
    #     return self.user.email

# company assets, owned by the employer
class Asset(models.Model):
    asset = models.CharField(max_length=50, blank=False, primary_key=True)
    employer = models.ForeignKey(Employer, on_delete=models.CASCADE)
    description = models.CharField(max_length=200, blank=False)

# track which asset is owned by which employee
class AssignedAsset(models.Model):
    asset = models.OneToOneField(Asset, on_delete=models.CASCADE)
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE)

class BankDetails(models.Model):
    freelancer = models.OneToOneField(Employee, on_delete=models.CASCADE)
    first_name = models.CharField(max_length=100, null=True, blank=True)
    last_name = models.CharField(max_length=100, null=True, blank=True)
    full_name_in_native_language = models.CharField(max_length=100)
    name_on_the_account = models.CharField(max_length=100)
    address = models.CharField(max_length=100)
    city = models.CharField(max_length=100)
    country = models.CharField(max_length=100)
    phone_number = models.CharField(max_length=100, null=True, blank=True)
    account_ownership = models.BooleanField()
    national_id_number = models.CharField(max_length=100, null=True, blank=True)

    # Bank Details
    iban = models.CharField(max_length=100, null=True, blank=True)
    swift = models.CharField(max_length=100)
    account_number = models.CharField(max_length=100)

    def __str__(self):
        return self.freelancer

@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_auth_token(sender, instance=None, created=False, **kwargs):
    if created:
        Token.objects.create(user=instance)
