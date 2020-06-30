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
        freelancer = Employee.objects.get(user=request.user.pk)
        context['is_available'] = freelancer.is_available
    except:
        context['is_available'] = False
        
    return context

# def requested_freelancer(request):
#     context = {}
#     try:
#         context['freelacner_requested'] = request.session['freelacner_requested']
#     except Exception as e:
#         print(f'Context ERROR: {e}')

#     return context


def debugMode(request):
    context = {}
    context['debug'] = settings.DEBUG
    return context