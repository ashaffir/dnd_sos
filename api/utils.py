import phonenumbers
from django.contrib.auth.forms import UserCreationForm
from core.models import User, Employee, Employer

def clean_phone_number(phone_number, country_code):
    print(f'Checking: {phone_number} Country: {country_code}')
    z = phonenumbers.parse(phone_number, country_code)
    if not phonenumbers.is_valid_number(z):
        print(f'Phone not valid.')
        return False
    return True

def check_profile_approved(user_id, is_employee):
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