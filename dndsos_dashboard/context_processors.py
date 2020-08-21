import platform
from django.contrib.auth.decorators import login_required
from django.conf import settings
from core.models import Employee

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