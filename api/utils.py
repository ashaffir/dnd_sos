import logging
import phonenumbers
from django.contrib.auth.forms import UserCreationForm
from django.conf import settings
from core.models import User, Employee, Employer
from dndsos_dashboard.utilities import send_mail

logger = logging.getLogger(__file__)

def clean_phone_number(phone_number, country_code):
    print(f'Checking: {phone_number} Country: {country_code}')
    z = phonenumbers.parse(phone_number, country_code)
    if not phonenumbers.is_valid_number(z):
        print(f'Phone not valid.')
        return False
    return True

def check_profile_approved(user_id, is_employee):
    print('Profile Check...')
    if is_employee == 1:
        user =  Employee.objects.get(user=user_id)
        name = user.name
        phone = user.phone
        vehicle = user.vehicle
        id_doc = user.id_doc

        if not name or not phone or not vehicle or not id_doc:
            user.profile_pending = False
            user.save()
            return False
        else:
            user.profile_pending = True
            user.save()
            alert_admin(user_id)
            return True
    else:
        user = Employer.objects.get(user=user_id)
        name = user.business_name
        phone = user.phone
        credit_card = user.credit_card_token

        if not name or not phone or not credit_card:
            user.is_approved = False
            user.save()
            return False
        else:
            user.is_approved = True
            user.save()
            return True

def alert_admin(user_id):
    print('Alerting Admin on new pending user account...')
    user_email = settings.ADMIN_EMAIL
    subject = 'PickNdell Pending Profile'
    content = f'''
        User ID: {user_id}
    '''
    message = {
        # 'user': instance,
        'message': content
    }

    try:
        send_mail(subject, email_template_name=None,
            context=message, to_email=[user_email],
            html_email_template_name='core/emails/update_admin_email.html')
        return True
    except Exception as e:
        print(f'Faled sending the Admin alert email on pending account. ERROR: {e}')
        logger(f'Faled sending the Admin alert email on pending account. ERROR: {e}')
        return False
