import platform
from forex_python.converter import CurrencyRates # https://github.com/MicroPyramid/forex-python
from django.contrib.auth.decorators import login_required
from django.conf import settings
from django.db.models import Q
from core.models import Employee, User
from orders.models import Order
from dndsos.models import AdminParameters

# @login_required
def business_type(request):
    context = {}
    try:
        if request.user.is_employer:
            context['business_type'] = 'business'
        else:
            context['business_type'] = 'freelancer'
    except:
        context['business_type'] = ''
        
    return context

def freelancer_available(request):
    context = {}
    try:
        freelancer = Employee.objects.get(pk=request.user.pk)
        context['is_available'] = freelancer.is_available
        context['is_active'] = freelancer.is_delivering
    except:
        context['is_available'] = False
        context['is_active'] = False
        
    return context

def checkOS(request):
    context = {}
    try:
        if platform.system() == 'Darwin':
            context['platform'] = 'mac'
        else:
            context['platform'] = 'linux'
    
        return context
   
    except Exception as e:
        context['platform'] = 'mac'
        return context

def pageLanguage(request):
    context = {}
    if 'he' in request.path_info:
        context['language'] = 'he'
    else:
        context['language'] = 'en'

    return context


def debugMode(request):
    context = {}
    context['debug'] = settings.DEBUG
    return context

def getCurrencyRates(request):
    context = {}
    c = CurrencyRates()
    usd_ils = c.get_rate('USD', 'ILS')
    usd_eur = c.get_rate('USD', 'EUR')
    context['usd_ils'] = usd_ils
    context['usd_eur'] = usd_eur
    return context

def getFreelancerActiveOrders(request):
    context = {}
    try:
        admin_params = AdminParameters.objects.all().first()
        user = User.objects.get(pk=request.user.pk)
        freelancer_profile = Employee.objects.get(user=user)
        freelancer_active_orders = Order.objects.filter(
                                    (Q(freelancer=freelancer_profile.user) & Q(status='IN_PROGRESS'))                            
                                    | (Q(freelancer=freelancer_profile.user) & Q(status='STARTED')))
        context['current_active_orders'] = len(freelancer_active_orders)
        context['freelancer_account_level'] = freelancer_profile.account_level
        context['freelancer_is_approved'] = 1 if freelancer_profile.is_approved else 0
        context['rookie_max'] = admin_params.rookie_level_max
        context['advanced_max'] = admin_params.advanced_level_max
        context['expert_max'] = admin_params.expert_level_max
    except Exception as e:
        print('User is not an Employee')
        context['current_active_orders'] = 1
        context['freelancer_is_approved'] = False
        context['freelancer_account_level'] = 'Rookie'
        context['rookie_max'] = settings.ROOKIE_LEVEL
        context['advanced_max'] = settings.ADVANCED_LEVEL
        context['expert_max'] = settings.EXPERT_LEVEL

    return context
