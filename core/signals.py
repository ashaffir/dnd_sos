import os
import platform
import logging

from datetime import datetime

from django.db.models.signals import post_save
from django.dispatch import receiver, Signal
from django.core.signals import request_finished
from django.conf import settings
from django.utils.translation import gettext

logger = logging.getLogger(__file__)

from dndsos_dashboard.utilities import send_mail

from .models import Employee, Employer, User

@receiver(post_save, sender=Employee)   
def employee_signal(sender, instance, update_fields, **kwargs): 
    """
    
    This signal is to generate an email to a freelancer that was approved through the admin.
    ** Check core/admin.py to see how to implement.

    """     
    print(f'=========== EMPLOYEE SIGNAL:  ===============: {instance}')
    logger.info(f'===========  EMPLOYEE SIGNAL ===============: {instance}')
    try:
        if 'is_approved' in update_fields:
            if instance.is_approved:
                print(f'User profile approved: {update_fields}')
                try:
                    user_email = instance.email
                    subject = gettext('Your PickNdell Account is Approved')
                    content = gettext('''
                    Thank you for applying to PickNdell network. 
                    We reviewed the information you have submitted and approved your account. 
                    You can now start delivering.
                    Good Luck!!
                    ''')
                    message = {
                        'user': instance,
                        'message': content
                    }

                    send_mail(subject, email_template_name=None,
                            context=message, to_email=[user_email],
                            html_email_template_name='core/emails/profile_approved_email.html')
                except Exception as e:
                    logger.error(f'Failed sending account approval to the user {instance}. ERROR: {e}')
        else:
            print('Signal was NOT for is_approved')
    except Exception as e:
        print(f'Core Signal exception. INFO: {e}')
        logger.info(f'Core Signal exception. INFO: {e}')


        


