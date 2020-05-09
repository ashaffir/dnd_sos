from django.contrib.auth.decorators import login_required
from django.conf import settings

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

def debugMode(request):
    context = {}
    context['debug'] = settings.DEBUG
    return context