import json
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.utils.safestring import mark_safe
from django.contrib import messages
from django.conf import settings

from dndsos_dashboard.utilities import send_mail
from .models import ContactUs
from .forms import ContactForm

def home(request):
    context = {}

    if request.method == 'POST':
        form = ContactForm(request.POST or None)
        if form.is_valid():
            form.save()
            update_admin(request)
            messages.success(request, 'Thank you for your interest in DND-SOS. \nWe will get back to you shortly.')
        else:
            messages.error(request, 'Please fill out the required fields before submitting the form.')

    return render(request, 'dndsos/index.html')


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