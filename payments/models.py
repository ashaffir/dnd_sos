from django.db import models
from dndsos_dashboard.models import TimeStampedUUIDModel
from django.utils.translation import ugettext_lazy as _

from core.models import User, Employee, Employer
from orders.models import Order

class Card(TimeStampedUUIDModel):
    card_holder = models.OneToOneField(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=30)
    card_number = models.CharField(max_length=16)
    expiry_date = models.DateField()
    cvv = models.BigIntegerField(null = True)
    card_provider = models.CharField(max_length=30, blank=True, null=True)
    card_logo = models.ImageField(null=True, blank=True, upload_to="cards")
    status = models.BooleanField(_('Card status'), default=True,
                                 help_text='Card is active or not active')

    class Meta:
        verbose_name = _('Card')

    def __str__(self):
        return "{} ({})".format(self.name, self.card_number)

class Payment(models.Model):
    created = models.DateTimeField(auto_now=True)
    order = models.ForeignKey(Order,related_name='payment_order', on_delete=models.CASCADE)
    freelancer = models.ForeignKey(Employee, on_delete=models.CASCADE, related_name='freelancer')
    business = models.ForeignKey(Employer, on_delete=models.CASCADE, related_name='business')
    amount = models.FloatField(null=True, blank=True)
    payment_received = models.BooleanField(default=False)
    payment_date = models.DateTimeField(null=True, blank=True)
    paid_freelancer = models.BooleanField(default=False)
    payment_freelancer_date = models.DateField(null=True, blank=True)
    
    class Meta:
        verbose_name = _('Payment')
    
    # def __str__(self):
    #     return str(self.order.pk)
