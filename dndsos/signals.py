import os
import platform
import logging

from datetime import datetime

from django.db.models.signals import post_save
from django.dispatch import receiver, Signal
from django.core.signals import request_finished
from django.conf import settings

logger = logging.getLogger(__file__)

from dndsos_dashboard.utilities import send_mail

from .models import ContactUs

'''

NOT ACTIVE (THERE IS A SUPPORT FOR THIS IN VIEWS)

'''



@receiver(post_save, sender=ContactUs)   
def employee_signal(sender, instance, created, **kwargs): 
    """
    
    This signal is to generate an email to a admin when there is a contact us form submitted on the website.

    """     
    print(f'=========== CONTACT US SIGNAL:  ===============: {instance}')
    logger.info(f'===========  CONTACT US SIGNAL ===============: {instance}')
    if created:
        try:
            subject = 'PickNdell - Contact Us form'

            message = {
                'fname': instance.fname,
                'lname': instance.lname,
                'subject': instance.subject,
                'email': instance.email,
                'message': instance.message
            }

            send_mail(subject, email_template_name=None,
                    context=message, to_email=settings.ADMIN_EMAIL,
                    html_email_template_name='admin_email.html')
        except Exception as e:
            print(f'Core Signal exception. INFO: {e}')
            logger.info(f'Core Signal exception. INFO: {e}')


        


