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
from newsletters_app.models import EmailTemplate

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
                print(f'>>> CORE SIGNALS: User profile approved: {update_fields}')
                logger.info(f'>>> CORE SIGNALS: User profile approved: {update_fields}')
                
                if platform.system() == 'Darwin': # MAC
                    current_site = 'http://127.0.0.1:8000' if settings.DEBUG else settings.DOMAIN_PROD
                else:
                    current_site = settings.DOMAIN_PROD

                try:
                    user_email = instance.email
                    email_language = instance.language
                    # print(f'>>> CORE SIGNALS: User profile language: {email_language}')
                    email_template = EmailTemplate.objects.get(name='account_approval', language=email_language)
                    # print(f'>>> CORE SIGNALS: email template: {email_template}')
                    subject = email_template.subject
                    content = email_template.content
                    title = email_template.title
                    
                    # subject = gettext('Your PickNdell Account is Approved')
                    # content = gettext('''
                    # Thank you for applying to PickNdell network. 
                    # We reviewed the information you have submitted and approved your account. 
                    # You can now start delivering.
                    # Good Luck!!
                    # ''')
                    message = {
                        'user': instance,
                        'title': title,
                        'content': content,
                        'lang': email_language,
                        'domain': current_site
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


        


