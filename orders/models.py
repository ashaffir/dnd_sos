import uuid

from django.urls import reverse
from django.db import models
from django.conf import settings
from django.contrib.postgres.fields import ArrayField, JSONField

from django.contrib.gis.db import models as geomodels
from django.contrib.gis.db.models import PointField


from core.models import Employee, Employer, User


class Order(models.Model):
    
    REQUESTED = 'REQUESTED'
    RE_REQUESTED = 'RE_REQUESTED'
    REJECTED = 'REJECTED'
    STARTED = 'STARTED'
    IN_PROGRESS = 'IN_PROGRESS'
    COMPLETED = 'COMPLETED'
    SETTLED = 'SETTLED'
    ARCHIVED = 'ARCHIVED'
    
    STATUSES = (
        (REQUESTED, REQUESTED),
        (RE_REQUESTED, RE_REQUESTED),
        (REJECTED, REJECTED),
        (STARTED, STARTED),
        (IN_PROGRESS, IN_PROGRESS),
        (COMPLETED, COMPLETED),
        (SETTLED, SETTLED),
        (ARCHIVED, ARCHIVED),
    )

    FOOD = 'Food'
    DOCUMENTS = 'Documents'
    TOOLS = 'Tools'
    CLOTHES = 'Clothes'
    OTHER = 'Other'

    ORDER_TYPES = (
        (FOOD, FOOD),
        (DOCUMENTS, DOCUMENTS),
        (CLOTHES, CLOTHES),
        (TOOLS, TOOLS),
        (OTHER, OTHER),
    )
    order_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True)
    pick_up_address = models.CharField(max_length=255, null=True)
    drop_off_address = models.CharField(max_length=255, null=True)
    order_type = models.CharField(max_length=50, choices=ORDER_TYPES, default=FOOD)
    
    # GEO
    order_country = models.CharField(max_length=100, null=True, blank=True)
    order_city_name = models.CharField(max_length=100, null=True, blank=True)
    order_city_symbol = models.IntegerField(null=True, blank=True)
    order_street_name = models.CharField(max_length=100, null=True, blank=True)
    order_street_symbol = models.IntegerField(null=True, blank=True)
    order_location = geomodels.PointField(null=True, blank=True)

    distance_to_business = models.FloatField(null=True, blank=True)
    trip = JSONField(null=True, blank=True)
    trip_completed = models.FloatField(null=True, blank=True)

    notes = models.TextField(max_length=500, blank=True, null=True)

    # List of freelancers that were directly chosen by the business (in case there are more than one)
    # selected_freelancers = ArrayField(
    #     ArrayField(
    #         models.CharField(max_length=10000, null=True, blank=True),
    #         size=400
    #     ),
    #     size=1,
    #     null=True,
    #     blank=True
    # )

    selected_freelancers = JSONField(blank=True, null=True)


    status = models.CharField(max_length=20, choices=STATUSES, default=REQUESTED)

    freelancer = models.ForeignKey( # new
        # settings.AUTH_USER_MODEL,
        User,
        null=True,
        blank=True,
        on_delete=models.CASCADE,
        related_name='freelancer_orders'
    )
    business = models.ForeignKey( # new
        # settings.AUTH_USER_MODEL,
        User,
        null=True,
        blank=True,
        on_delete=models.CASCADE,
        related_name='business_orders'
    )

    chat = JSONField(blank=True, null=True)
    new_message = JSONField(blank=True, null=True)

    def __str__(self):
        return f'{self.order_id}'

    def get_absolute_url(self):
        return reverse('trip:trip_detail', kwargs={'trip_id': self.order_id})


class ChatMessage(models.Model):
    freelancer = models.ForeignKey(User, null=True, blank=True, on_delete=models.CASCADE, related_name='freelancer_messages')
    business = models.ForeignKey(User, null=True, blank=True, on_delete=models.CASCADE, related_name='business_messages')
    updated = models.DateTimeField(auto_now=True)
    order = models.ForeignKey(Order, on_delete=models.CASCADE)

    def __str__(self):
        return self.updated
