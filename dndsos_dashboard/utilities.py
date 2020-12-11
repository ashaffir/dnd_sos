import sys
import requests
import json
import logging

from django.core.mail import EmailMultiAlternatives
from django.template import RequestContext, TemplateDoesNotExist
from django.template.loader import render_to_string
from django.conf import settings

from .models import Employee, Employer
from orders.models import Order

logger = logging.getLogger(__file__)


def send_mail(subject, email_template_name,
              context, to_email, html_email_template_name=None, request=None, from_email=None):
    """
    Sends a django.core.mail.EmailMultiAlternatives to `to_email`.
    """

    print(f'''
    subject: {subject}
    html email template name: {html_email_template_name}
    context: {context}
    to email: {to_email}
    request: {request}
    from email: {from_email}
    ''')

    logger.info(f'''
    subject: {subject}
    html email template name: {html_email_template_name}
    context: {context}
    to email: {to_email}
    request: {request}
    from email: {from_email}
    ''')

    ctx_dict = {}
    if request is not None:
        ctx_dict = RequestContext(request, ctx_dict)
    # update ctx_dict after RequestContext is created
    # because template context processors
    # can overwrite some of the values like user
    # if django.contrib.auth.context_processors.auth is used
    if context:
        ctx_dict.update(context)

    # Email subject *must not* contain newlines
    from_email = from_email or getattr(settings, 'DEFAULT_FROM_EMAIL')
    if email_template_name:
        message_txt = render_to_string(email_template_name,
                                       ctx_dict)

        email_message = EmailMultiAlternatives(subject, message_txt,
                                               from_email, to_email)
    else:
        try:
            message_html = render_to_string(
                html_email_template_name, ctx_dict)
            email_message = EmailMultiAlternatives(subject, message_html,
                                                   from_email, to_email)
            email_message.content_subtype = 'html'
        except TemplateDoesNotExist:
            pass

    try:
        email_message.send()
        print(f">>> DNDSOS_DASHBOARD UTILITIES: Email sent to {to_email}")
        logger.info(
            f">>> DNDSOS_DASHBOARD UTILITIES: Email sent to {to_email}")
    except Exception as e:
        logging.error(
            f">>> DNDSOS_DASHBOARD UTILITIES: failed sending email to {to_email}. ERROR: {e}")
        if settings.DEBUG:
            print(f'ERROR: email not sent (utilities.py). Reason: {e}')
            print(sys.exc_info())


def check_captcha(request):
    client_key = request.POST['g-recaptcha-response']
    secret_key = settings.RECAPTCHA_PRIVATE_KEY

    captcha_data = {
        'secret': secret_key,
        'response': client_key
    }

    r = requests.post(
        'https://www.google.com/recaptcha/api/siteverify', data=captcha_data)
    response = json.loads(r.text)
    verify = response['success']
    return verify


def calculate_freelancer_total_rating(f_id):
    # Calculating overall freelancer rating
    freelancer = Employee.objects.get(pk=f_id)
    freelancer_orders = Order.objects.filter(
        freelancer=f_id, status='COMPLETED')

    if len(freelancer_orders) > 1:
        total_rating = 0
        ratings = 0
        for order in freelancer_orders:
            if order.freelancer_rating:
                total_rating += order.freelancer_rating
                ratings += 1

        total_rating = round(total_rating/ratings, 2)

    else:
        total_rating = freelancer_orders[0].freelancer_rating

    freelancer.freelancer_total_rating = total_rating
    freelancer.save()
