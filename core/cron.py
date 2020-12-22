# - https://www.youtube.com/watch?v=PUT29lvDFco
# - https://pypi.org/project/django-crontab/
import datetime
import logging
from .models import User, Employee, Employer

logger = logging.getLogger(__file__)


def check_user_profile_complete():
    print('CHECKIG>..........')

    try:
        current_freelancers_w_incomplete_profile = list(Employee.objects.filter(
            profile_pending=False, is_approved=False))
        current_businesses_w_incomplete_profile = list(Employer.objects.filter(
            is_approved=False))

        uncomplete_profiles = current_businesses_w_incomplete_profile + \
            current_freelancers_w_incomplete_profile

        print(f'LIST FREELANCER: {current_freelancers_w_incomplete_profile}')
        print(f'LIST BUSINESS: {current_businesses_w_incomplete_profile}')
        print(f'LIST : {uncomplete_profiles}')
    except Exception as e:
        print(f"FAILED: {e}")

    for p in uncomplete_profiles:
        print(f"Profile: {p} is incomplete")


def id_expired_check():
    today = datetime.today().strftime('%Y-%m-%d')
    qs_freelancers = Employee.objects.all()
    for freelancer in qs_freelancers:
        exp = freelancer.id_doc_expiry.strftime('%Y-%m-%d')
        if exp < today:
            freelancer.id_expired = True
            freelancer.save()
