from django.db import models
from dndsos_dashboard.models import TimeStampedUUIDModel
from django.utils.translation import ugettext_lazy as _

from core.models import User

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

