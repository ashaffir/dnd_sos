import json
import requests

from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.utils.safestring import mark_safe
from django.contrib import messages
from django.conf import settings
from django.utils.translation import gettext as _

from dndsos_dashboard.utilities import send_mail
from .models import ContactUs, ContentPage
from .forms import ContactForm

def home(request):
    context = {}
    form = ContactForm(request.POST or None)
    
    if request.POST:

        # if settings.DEBUG:
        #     captcha_ok = True
        # else:
        captcha_ok = check_captcha(request)

        if captcha_ok:
            if form.is_valid():
                form.save()
                update_admin(request)
                messages.success(request, _('Thank you for your interest in PickNdell. We will get back to you shortly.'))
            else:
                messages.error(request, _('Please fill out the required fields before submitting the form.'))
                return redirect(request.META['HTTP_REFERER'])
        else:
            messages.error(request, _('Please confirm you are not a robot.'))
            return redirect(request.META['HTTP_REFERER'])



    try:
        if request.LANGUAGE_CODE == 'he':
            context['why_section'] = ContentPage.objects.filter(section='why-section', language='Hebrew')
            context['pricing_business'] = ContentPage.objects.get(section='pricing_business', language='Hebrew')
            context['pricing_freelancers'] = ContentPage.objects.get(section='pricing_freelancers', language='Hebrew')
            context['what_is_section'] = ContentPage.objects.get(section='what_is', language='Hebrew')
            context['how_1_section'] = ContentPage.objects.get(section='how', language='Hebrew', name='how-1')
            context['how_2_section'] = ContentPage.objects.get(section='how', language='Hebrew', name='how-2')
            context['how_3_section'] = ContentPage.objects.get(section='how', language='Hebrew', name='how-3')
            context['how_4_section'] = ContentPage.objects.get(section='how', language='Hebrew', name='how-4')
            context['faq_freelancer'] = ContentPage.objects.filter(section='faq_freelancer', language='Hebrew')
            context['faq_business'] = ContentPage.objects.filter(section='faq_business', language='Hebrew')
        else:
            context['why_section'] = ContentPage.objects.filter(section='why-section', language='English')
            context['pricing_business'] = ContentPage.objects.get(section='pricing_business', language='English')
            context['pricing_freelancers'] = ContentPage.objects.get(section='pricing_freelancers', language='English')
            context['what_is_section'] = ContentPage.objects.get(section='what_is', language='English')
            context['how_1_section'] = ContentPage.objects.get(section='how', language='English', name='how-1')
            context['how_2_section'] = ContentPage.objects.get(section='how', language='English', name='how-2')
            context['how_3_section'] = ContentPage.objects.get(section='how', language='English', name='how-3')
            context['how_4_section'] = ContentPage.objects.get(section='how', language='English', name='how-4')
            context['faq_freelancer'] = ContentPage.objects.filter(section='faq_freelancer', language='English')
            context['faq_business'] = ContentPage.objects.filter(section='faq_business', language='English')
    except Exception as e:
        messages.error(request, f'Missing content in DB! ERROR: {e}')
    
    context['form'] = form
    context['site_recaptcha'] = settings.RECAPTCHA_PUBLIC_KEY
    
    return render(request, 'dndsos/index.html', context)


def update_admin(request):
    mail_subject = 'Contact request from DND SOS'
    try:    
        mail_context = {
            'fname': request.POST.get('fname'),
            'lname': request.POST.get('lname'),
            'email': request.POST.get('email'),
            'subject': request.POST.get('subject'),
            'message': request.POST.get('message')
            }

        send_mail(subject=mail_subject, email_template_name=None,
                context=mail_context, to_email=[settings.ADMIN_EMAIL], 
                html_email_template_name='dndsos//admin_email.html')

    except Exception as ex:
        # messages.error(request, f"mail not sent -- Email configurations required. ERROR: {ex}")
        # return redirect('dndsos_dashboard:orders', b_id=request.user.pk)
        print(f'>>>>> ERROR SENDING MESSAGE TO ADMIN. EX: {ex}')


# reference: https://github.com/shahriarshm/websocket-with-django-and-channels/tree/master/08-Create-Simple-Chat-Application
def index_test(request):
    context = {}
    return render(request, 'dndsos/index_test.html')

@login_required
def room(request, username):
    context = {}
    return render(request, 'dndsos/room.html', {'username_json': mark_safe(json.dumps(username))})

def terms(request):
    context = {}
    context['terms'] = ContentPage.objects.get(name='terms').content

    try:
        context['terms_he'] = ContentPage.objects.get(name='terms_he').content
    except Exception as e:
        messages.warning(request, 'Terms HE is not ready.')

    return render(request, 'dndsos/terms.html', context)

def privacy(request):
    context = {}
    context['privacy'] = ContentPage.objects.get(name='privacy').content
    try:
        context['privacy_he'] = ContentPage.objects.get(name='privacy_he').content
    except Exception as e:
        messages.warning(request, 'Privacy HE is not ready.')

    return render(request, 'dndsos/privacy.html', context)    

def check_captcha(request):
    client_key = request.POST['g-recaptcha-response']
    secret_key = settings.RECAPTCHA_PRIVATE_KEY

    captcha_data = {
        'secret':secret_key,
        'response':client_key
    }

    r = requests.post('https://www.google.com/recaptcha/api/siteverify',data=captcha_data)
    response = json.loads(r.text)
    verify = response['success']
    return verify