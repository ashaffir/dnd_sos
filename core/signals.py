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

from .models import Employee, Employer, User

@receiver(post_save, sender=Employee)   
def employee_signal(sender, instance, update_fields, **kwargs):      
    print(f'=========== EMPLOYEE SIGNAL:  ===============: {instance}')
    logger.info(f'===========  EMPLOYEE SIGNAL ===============: {instance}')
    if 'is_approved' in update_fields:
        if instance.is_approved:
            print(f'User profile approved: {update_fields}')
            user_email = instance.email
            subject = 'Your PickNdell Account is Approved'
            content = '''
            Thank you for applying to PickNdell network. 
            We reviewed the information you have submitted and approved your account. 
            You can now start delivering.
            Good Luck!!
            '''
            message = {
                'user': instance,
                'message': content
            }

            send_mail(subject, email_template_name=None,
                    context=message, to_email=[user_email],
                    html_email_template_name='core/emails/profile_approved_email.html')


        


