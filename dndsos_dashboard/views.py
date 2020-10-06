import logging
import os
from datetime import datetime,date
import phonenumbers
from email_validator import validate_email, EmailNotValidError

from django_twilio.decorators import twilio_view
from twilio.rest import Client

from django.shortcuts import render, redirect, get_object_or_404
from django.http import HttpResponseRedirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth import logout, get_user_model
from django.http import HttpResponse
from django.dispatch import receiver
from django.views.decorators.csrf import csrf_exempt
# from django.contrib.auth.models import User

from django.contrib import  messages
from django.template.loader import render_to_string
from django.template import RequestContext
from django.conf import settings
from django.db.models import Q

from django.contrib.gis.db.models.functions import Distance

# Language translation
from django.utils.translation import gettext

from rest_framework import generics
from rest_framework.response import Response

from core.models import Employee, Employer, User
from core.forms import EmployeeProfileForm, EmployerProfileForm
from core.decorators import employer_required, employee_required

from .forms import BusinessUpdateForm, FreelancerUpdateForm, BankDetailsForm
from .models import Email
from orders.models import Order
from .utilities import send_mail, calculate_freelancer_total_rating
from geo.models import Street, CityModel
from geo.geo_utils import location_calculator
from payments.views import add_card, remove_card, credit_card_form, get_credit_card_information
from payments.models import Card

from .serializers import UserSerializer

logger = logging.getLogger(__file__)
    

DEFAULT_FREELANCER_RANGE = 1.0 # Default distance beween business and available freelancers

class SignUpView(generics.CreateAPIView):
    queryset = get_user_model().objects.all()
    serializer_class = UserSerializer

def order_input(request):
    return render(request, 'dndsos_dashboard/order-input.html')

def order(request, order_id):
    return render(request, 'dndsos_dashboard/order.html', {
        'order_id': order_id
    })

@employer_required
@login_required
def b_dashboard(request, b_id):
    context = {}

    try:
        is_active = Employer.objects.get(pk=b_id)
    except Exception as e:
        messages.error(request, 'Please activate your account.')
        return redirect('dndsos:home')


    # Active orders stats
    active_orders = Order.objects.filter(
        (Q(business=request.user.pk) & Q(status='IN_PROGRESS')) |
        (Q(business=request.user.pk) & Q(status='REQUESTED')) |
        (Q(business=request.user.pk) & Q(status='RE_REQUESTED')) |
        (Q(business=request.user.pk) & Q(status='REJECTED')) |
        (Q(business=request.user.pk) & Q(status='STARTED'))
    )
    context['active_orders'] = active_orders

    orders = []
    for order in active_orders:
        created_ts = datetime.timestamp(order.created)
        now_ts = datetime.timestamp(datetime.now())
        delta_time_ts = now_ts - created_ts
        delta_time = datetime.fromtimestamp(delta_time_ts)

        order_timing = {
            'order':order,
            'order_hours': delta_time.hour,
            'order_minutes': delta_time.minute,
            'delayed': True if delta_time.hour == 1 else False 
        }

        orders.append(order_timing)

    # Daily orders:
    context['orders'] = orders
    context['num_orders'] = len(orders)

    today = date.today()
    daily_orders = Order.objects.filter(business=request.user.pk, created__contains=today)
    
    context['num_daily_orders'] = len(daily_orders)

    # Daily cost
    daily_cost = 0
    for order in daily_orders:
        daily_cost += order.price

    context['daily_cost'] = round(daily_cost,2)

    if request.user.relationships:
        context['num_active_freelancers'] = len(request.user.relationships['freelancers'])

    return render(request, 'dndsos_dashboard/b-dashboard.html', context)

@employee_required
@login_required
def f_dashboard(request, f_id):
    context = {}
    try:
        is_active = Employee.objects.get(pk=f_id)
    except Exception as e:
        messages.error(request, 'Please activate your account.')
        return redirect('dndsos:home')


    freelancer = Employee.objects.get(user=request.user.pk)

    if request.method == 'POST':
        if freelancer.is_delivering:
            messages.error(request, "Status can't be changed while in the process of delivery")
            return render(request, 'dndsos_dashboard/f-dashboard.html', context)

        if request.POST.get('is_available'):
            freelancer.is_available = False
            freelancer.save()
            context['is_available'] = False
        elif request.POST.get('not_available'):
            freelancer.is_available = True
            freelancer.save()
            context['is_available'] = True
    else:
        context['is_available'] = freelancer.is_available

    # Active orders stats
    active_orders = Order.objects.filter(
        (Q(freelancer=request.user.pk) & Q(status='IN_PROGRESS'))                            
        | (Q(freelancer=request.user.pk) & Q(status='STARTED')))
    context['active_orders'] = active_orders


    orders_summary = []
    for order in active_orders:
        created_ts = datetime.timestamp(order.created)
        now_ts = datetime.timestamp(datetime.now())
        delta_time_ts = now_ts - created_ts
        delta_time = datetime.fromtimestamp(delta_time_ts)

        order_timing = {
            'order':order,
            'order_hours': delta_time.hour,
            'order_minutes': delta_time.minute,
            'delayed': True if delta_time.hour == 1 else False 
        }

        orders_summary.append(order_timing)

    # Daily orders:
    context['orders_summary'] = orders_summary
    context['num_orders'] = len(orders_summary)

    today = date.today()
    daily_orders = Order.objects.filter(Q(freelancer=request.user.pk) & Q(updated__contains=today) & Q(status='COMPLETED'))
    
    context['num_daily_orders'] = len(daily_orders)

    # Daily profit
    daily_profit = 0
    for order in daily_orders:
        daily_profit += order.price

    context['daily_profit'] = round(daily_profit,2)

    f_businesses = []
    f_relationships = User.objects.get(pk=f_id).relationships
    if f_relationships:
        for fl in f_relationships['businesses']:
            f_businesses.append(User.objects.get(pk=fl))
    
        context['f_businesses'] = f_businesses

    context['num_active_businesses'] = len(f_businesses)


    return render(request, 'dndsos_dashboard/f-dashboard.html', context)


@login_required
def b_profile(request, b_id):
    context = {}
    user_profile = Employer.objects.get(user=request.user.id)

    context['cities'] = CityModel.objects.all()

    form = BusinessUpdateForm(instance=user_profile)

    icredit_form_url,private_token, public_token = credit_card_form(request)
    context['icredit_form_url'] = icredit_form_url

    # To display the last digits of the current credit card
    card_info = get_credit_card_information(token=public_token)
    context['card_number'] = card_info['CardNumber'][-4:]
    context['card_due_date'] = card_info['CardDueDate']

    if request.method == 'POST':

        # form = BusinessUpdateForm(request.POST,request.FILES, instance=user_profile)

        if 'update_profile' in request.POST:
            new_name = request.POST.get("name")
            new_business_name = request.POST.get("business_name")
            new_business_category = request.POST.get("business_category")
            # new_phone = request.POST.get("phone")
            new_bio = request.POST.get("bio")
            new_building = request.POST.get("building_number")

            if request.POST.get("city") != 'none':
                new_city = request.POST.get("city").replace('\'', '').replace('\"', '')
                user_profile.city = new_city
            else:
                pass

            if request.POST.get("city_streets"):
                new_street = request.POST.get("city_streets").replace('\'', '').replace('\"', '')
                user_profile.street = new_street
            else:
                pass

            # Setting the business location coordinates
            try:
                user_profile.location, user_profile.lon, user_profile.lat = location_calculator(new_city,new_street, new_building, 'israel')
                if not user_profile.location or not user_profile.lon or not user_profile.lat:
                    print('Failed to update business address')
                    messages.error(request, 'This address is not valid please try again or a nearby location.')
                    return redirect(request.META['HTTP_REFERER'])
            except:
                pass

            profile_pic = request.FILES.get("profile_pic")

            if new_name:
                user_profile.name = new_name

            if new_business_name:
                user_profile.business_name = new_business_name

                # Patch: updating the business name for the API
                business_user = User.objects.get(pk=b_id)
                business_user.first_name = new_business_name
                business_user.save()
                ###

            if new_business_category:
                user_profile.business_category = new_business_category

            # if new_phone:
            #     user_profile.phone = new_phone

            if new_bio:
                user_profile.bio = new_bio

            if new_building:
                user_profile.building_number = new_building

            if not profile_pic:
                profile_pic = request.FILES.get("old_profile_pic")
            else:
                user_profile.profile_pic = profile_pic

            user_profile.email = request.user.email

            try:        
                user_profile.save()
                messages.success(request,'You have successfully updated your profile.')
            except Exception as e:
                messages.success(request,f'There was ann error processing your request. ERROR: {e}')
        
        elif 'addPhone' in request.POST:
                    phone = request.POST.get('phoneNumber')
                    request.session['phone'] = phone
                    sent_sms_status = phone_verify(request, action='send_verification_code', phone=phone, code=None)
                    if sent_sms_status:
                        print('>>>>>>> SENT SMS <<<<<<<<')
                        return redirect('dndsos_dashboard:b-phone-verify', b_id=request.user.pk)
                    else:
                        print(f'>>>>>>> FAILE TO SEND SMS <<<<<<<< Error: {sent_sms_status}')
                        return render(request, 'dndsos_dashboard/failed-phone-verification.html')
                                    
        elif 'add_credit_card' in request.POST:
            pass        

    # Check profile completion
    required_fields = {
        'business_name': False,
        'phone': False,
        'street': False,
        'building_number':False,
        'city': False,
        'credit_card_token': False
        }    

    field_count = 0
    for field in required_fields.keys():
        if getattr(user_profile, field):
            required_fields[field] = True
            field_count += 1
    
    if field_count == len(required_fields):
        user_profile.is_approved = True
    else:
        user_profile.is_approved = False

    user_profile.save()

    cards = Card.objects.filter(card_holder=request.user, status=True)
    context['cards'] = cards
    
    context['required_fields'] = required_fields
    context['complete'] = round(field_count/len(required_fields)*100)
    context['email'] = request.user.email
    context['profile'] = user_profile
    context['form'] = form
    return render(request, 'dndsos_dashboard/b-profile.html', context)

@login_required
def f_profile(request, f_id):
    context = {}
    context['freelancer'] = True
    user_profile = Employee.objects.get(user=request.user.id)
    context['cities'] = CityModel.objects.all()
    context['countries'] = ['IL', 'USA']

    form = FreelancerUpdateForm(instance=user_profile)

    if request.method == 'POST':
        
        if 'updateProfile' in request.POST:
            form = FreelancerUpdateForm(request.POST,request.FILES, instance=user_profile)            

            if form.is_valid():
                try:
                    form.save()

                    # Patch: updating the name for the API access
                    user_freelancer = User.objects.get(pk=f_id)                  
                    user_freelancer.first_name = form.cleaned_data.get("name")
                    user_freelancer.save()
                    #####

                    messages.success(request,gettext('You have successfully updated your profile.'))
                except Exception as e:
                    messages.success(request,f'gettext(There was an error updating your profile. ERRRO): {e}')
            else:
                for error in form.errors:
                    messages.error(request, f'Error: {error}')

                    # TODO: Fix this workaround. Files are uploaded even when fail extension validation, so 
                    # the workaround is to rewrite this field.
                    if error == 'id_doc':
                        user_profile.id_doc = None
                        user_profile.save()

                print('ERROR PROFILE FORM')
        
        elif 'addPhone' in request.POST:
            phone = request.POST.get('phoneNumber')
            request.session['phone'] = phone
            sent_sms_status = phone_verify(request, action='send_verification_code', phone=phone, code=None)
            if sent_sms_status:
                print('>>>>>>> SENT SMS <<<<<<<<')
                return redirect('dndsos_dashboard:f-phone-verify', f_id=request.user.pk)
            else:
                print(f'>>>>>>> FAILE TO SEND SMS <<<<<<<< Error: {sent_sms_status}')
                return render(request, 'dndsos_dashboard/failed-phone-verification.html')
            
        elif request.POST.get('paypal_account'): 
            paypal_account = request.POST.get('paypal_account')
            try:
                valid = validate_email(paypal_account)
                user_profile.paypal_account = paypal_account
                user_profile.save()
                messages.success(request,'You have successfully updated a payment method to PayPal.')
                return redirect(request.META['HTTP_REFERER'])
            except EmailNotValidError as e:
                messages.error(request,f'You have entered a non-valid email. Error: {e}')
                return redirect(request.META['HTTP_REFERER'])

        elif 'phonePayment' in request.POST: 
            user_profile.payment_via_phone = True
            user_profile.save()
            messages.success(request,'You have successfully updated a payment method to Phone Payments.')
            return redirect(request.META['HTTP_REFERER'])

        elif 'makePreferred_paypal' in request.POST: 
            user_profile.preferred_payment_method = 'PayPal'
            user_profile.save()
            messages.success(request,'You have successfully set Paypal as a default payment method.')
            return redirect(request.META['HTTP_REFERER'])
        elif 'makePreferred_bank' in request.POST: 
            user_profile.preferred_payment_method = 'Bank'
            user_profile.save()
            messages.success(request,'You have successfully set bank transfer as a default payment method.')
            return redirect(request.META['HTTP_REFERER'])
        elif 'makePreferred_phone' in request.POST: 
            user_profile.preferred_payment_method = 'Phone'
            user_profile.save()
            messages.success(request,'You have successfully set phone-transfer as a default payment method.')
            return redirect(request.META['HTTP_REFERER'])

    # Check profile completion
    required_fields = {
        'name': False,
        'vehicle': False,
        'phone': False,
        'id_doc':False,
        }    

    field_count = 0
    for field in required_fields.keys():
        if getattr(user_profile, field):
            required_fields[field] = True
            field_count += 1

    if field_count == len(required_fields):
        user_profile.is_approved = True
        user_profile.save()
    else:
        user_profile.is_approved = False
        user_profile.save()
    
    # Check earnings due
    daily_orders = Order.objects.filter(Q(freelancer=request.user.pk) & Q(status='COMPLETED'))

    earnings_due = 0
    for order in daily_orders:
        earnings_due += order.price

    context['earnings_due'] = round(earnings_due,2) 

    context['required_fields'] = required_fields
    context['complete'] = round(field_count/len(required_fields)*100)
    context['email'] = request.user.email
    context['profile'] = user_profile
    context['form'] = form

    return render(request, 'dndsos_dashboard/f-profile.html', context)


@login_required
def add_freelancer(request):
    context = {}
    return render(request, 'dndsos_dashboard/add-freelancer.html', context)

@employer_required
@login_required
def orders(request, b_id):
    context = {}

    business_id = Employer.objects.get(user=request.user.pk)
    business_profile = Employer.objects.get(user=request.user)
    context['business_profile'] = business_profile
    context['freelancers'] = Employee.objects.all()

    context['cities'] = CityModel.objects.all()

    if request.method == 'POST':
        if 'rateFreelancer' in request.POST:
            freelancer_rating = request.POST.get('f_rating')
            freelancer_rating_report = request.POST.get('f_rating_report')
            order_id = request.POST.get('rateFreelancer')
            order = Order.objects.get(pk=order_id)

            if freelancer_rating:
                order.freelancer_rating = freelancer_rating
                order.freelancer_rating_report = freelancer_rating_report
                order.save()

                # Calculating overall freelancer rating
                calculate_freelancer_total_rating(order.freelancer.freelancer.pk)

                return HttpResponseRedirect(request.META.get('HTTP_REFERER'))
            

        else:
            pass

    return render(request, 'dndsos_dashboard/orders.html', context)

@employer_required
@login_required
def edit_order(request):
    context = {}
    return render(request, 'dndsos_dashboard/edit-order.html')

@employee_required
@login_required
def f_deliveries(request, f_id):
    context = {}
    freelancer_id = request.user.pk

    return render(request, 'dndsos_dashboard/deliveries.html', context)

@employee_required
@login_required
def f_active_deliveries(request,f_id):
    context = {}
    freelancer_id = request.user.pk

    return render(request, 'dndsos_dashboard/active-deliveries.html', context)


@employee_required
@login_required
def f_businesses(request, f_id):
    context = {}
    context['businesses'] = False

    if request.user.relationships:
        f_businesses = request.user.relationships['businesses']
    
        cities = []
        businesses = []
        for b_id in f_businesses:
            businesses.append(Employer.objects.get(pk=b_id))

        for b in businesses:
            cities.append(b.city)

        if request.method == 'POST':
            if 'sort_by_city' in request.POST:
                sorted_businesses = []
                city = request.POST.get('city')
                for biz in businesses:
                    if biz.city == city:
                        sorted_businesses.append(biz)
                context['businesses'] = sorted_businesses
                context['num_businesses'] = len(sorted_businesses)
            else:
                context['businesses'] = businesses
                context['num_businesses'] = len(businesses)
        else:
            context['businesses'] = businesses
            context['num_businesses'] = len(businesses)

        context['businesses'] = businesses
        context['cities'] = set(cities)

    return render(request, 'dndsos_dashboard/f-businesses.html', context)


@login_required
def f_statistics(request, f_id):
    context = {}
    return render(request, 'dndsos_dashboard/statistics.html', context)

@employer_required
@login_required
def b_deliveries(request, b_id):
    context = {}
    return render(request, 'dndsos_dashboard/deliveries.html', context)

@employer_required
@login_required
def b_alerts(request, b_id):
    context = {}

    if request.method == 'POST':
        if 'requestFreelancer' in request.POST:
            pass

    orders = Order.objects.filter(
            (Q(business=b_id) & Q(status='REQUESTED')) | 
            (Q(business=b_id) & Q(status='REJECTED'))  | 
            (Q(business=b_id) & Q(status='RE_REQUESTED'))
        )

    context['orders'] = orders
    context['num_orders'] = len(orders)
    return render(request, 'dndsos_dashboard/b-alerts.html', context)

@employer_required
@login_required
def b_messages(request, b_id):
    context = {}
    return render(request, 'dndsos_dashboard/b-messages.html', context)

@employer_required
@login_required
def b_chat_room(request, b_id):
    context = {}
    order_id = request.GET.get("oid")
    order = Order.objects.get(order_id=order_id)
    context['order'] = order
    return render(request, 'dndsos_dashboard/partials/_b-chat-room.html', context)

@employee_required
@login_required
def f_messages(request, f_id):
    context = {}
    orders_chat = []
    orders = Order.objects.filter(Q(freelancer=f_id))
    print(f'ORDERS:{orders}')
    for order in orders:
        if order.chat:
            orders_chat.append(order)
    context['orders'] = orders_chat
    return render(request, 'dndsos_dashboard/f-messages.html', context)

@employee_required
@login_required
def f_chat_room(request, f_id):
    context = {}
    order_id = request.GET.get("oid")
    order = Order.objects.get(order_id=order_id)
    context['order'] = order
    return render(request, 'dndsos_dashboard/partials/_f-chat-room.html', context)



@employer_required
@login_required
def b_alerts_items(request, b_id):
    context = {}
    orders = Order.objects.filter(Q(business=b_id) & Q(status='REQUESTED') | Q(status='REJECTED') | Q(status='RE_REQUESTED'))
    context['orders'] = orders
    return render(request, 'dndsos_dashboard/partials/_b-alerts-items.html', context)

@employer_required
@login_required
def b_messages_list(request, b_id):
    context = {}
    orders_chat = []
    orders = Order.objects.filter(Q(business=b_id) & ~Q(status='ARCHIVED'))
    for order in orders:
        if order.chat:
            orders_chat.append(order)
    
    context['orders'] = orders_chat
    return render(request, 'dndsos_dashboard/partials/_b-messages-list.html', context)



@login_required
def b_statistics(request, b_id):
    context = {}
    return render(request, 'dndsos_dashboard/statistics.html', context)

@employer_required
@login_required
def freelancers(request, b_id):
    context = {}

    # Extracting the freelancers that worked with the business in the past
    b_freelancers = []
    b_relationships = User.objects.get(pk=b_id).relationships
    if b_relationships:
        for fl in b_relationships['freelancers']:
            b_freelancers.append(User.objects.get(pk=fl))
    
        context['b_freelancers'] = b_freelancers

    # Extracting the business orders
    orders = Order.objects.filter(
        (Q(business=request.user.pk) & Q(status='REQUESTED')) |
        (Q(business=request.user.pk) & Q(status='RE_REQUESTED')) |
        (Q(business=request.user.pk) & Q(status='REJECTED'))
        )
    context['orders'] = orders

    completed_orders = Order.objects.filter(Q(business=request.user.pk) & Q(status='COMPLETED') & ~Q(status='SETTLED'))
    context['completed_orders'] = completed_orders

    # Quering the freelancers that are due payment
    freelancers_due_payment = []
    for order in completed_orders:
        freelancers_due_payment.append(order.freelancer.pk)

    context['freelancers_due_payment'] = freelancers_due_payment
    context['num_freelancers_due_payment'] = len(freelancers_due_payment)
    context['num_b_freelancers'] = len(b_freelancers)
    max_range = DEFAULT_FREELANCER_RANGE

    # Filter freelancers
    if request.method == 'POST':

        # Freelancers filtering options
        city = request.POST.get('city')
        vehicle = request.POST.get('vehicle')
        
        max_range = request.POST.get('range')

        if 'filter' in request.POST:
            if vehicle and city:
                filtered_freelancers = Employee.objects.filter(is_approved=True, vehicle=vehicle, city=city)
            elif vehicle and not city:
                filtered_freelancers = Employee.objects.filter(is_approved=True, vehicle=vehicle)
            elif not vehicle and city:
                filtered_freelancers = Employee.objects.filter(is_approved=True, city=city)
            else:
                filtered_freelancers = Employee.objects.all()
        else:
            filtered_freelancers = Employee.objects.filter(is_approved=True)

    else:
        max_range = DEFAULT_FREELANCER_RANGE
        filtered_freelancers = None

    all_freelancers = Employee.objects.filter(is_approved=True, is_available=True)

    cities = []
    vehicles = []
    for fl in all_freelancers:
        cities.append(fl.city)
        vehicles.append(fl.vehicle)

    # Freelancer locations
    freelancers_in_range = []
    for freelancer in all_freelancers:
        try:
            freelancer_location = freelancer.location
            business_location = Employer.objects.get(pk=b_id).location
            range_to_freelancer = round(business_location.distance(freelancer_location) * 100, 3)
            print(f'DISTANCE from {freelancer}: {range_to_freelancer} km')
            print(f'MAX RANGE: {max_range} km')
            if range_to_freelancer < float(max_range):
                freelancers_in_range.append(freelancer)
        except Exception as e:
            print(f'Freelancer {freelancer} does not have location. EX: {e}')
    # End Freelancers locations

    # Filter freelancers
    freelancers = []
    if filtered_freelancers:
        for fl in filtered_freelancers:
            if fl in freelancers_in_range:
                freelancers.append((fl))
    else:
        freelancers = freelancers_in_range

    context['total_freelancers'] = len(freelancers)

    context['freelancers'] = freelancers
    context['cities'] = set(cities)
    context['vehicles'] = set(vehicles)
    context['max_range'] = max_range

    return render(request, 'dndsos_dashboard/freelancers.html', context)

def freelancer_accept(request, fid, oid):
    '''
    On Freelancer Accept:
    0) Freelancer get's a "Accept" landing page
    1) Order is updated with the allocated freelancer 
    2) Freelancer's ID is added to the Business's pool of freelancers
    3) Buiness is notified on freelacer acceptance
    4) System notifys all OTHER freelancers that the order was filled/canceled (not necessary...)
    '''
    context = {}
    freelancer = Employee.objects.get(pk=fid)
    order = get_object_or_404(Order, pk=oid)

    # 1) Update order with allocated FL
    if order.freelancer_allocated:
        return render(request, 'dndsos_dashboard/freelancer-accept.html' , context)
    else:
        context['order_not_allocated'] = True
        order.freelancer_allocated = Employee.objects.get(pk=fid)
        order.save()

    # 2) Adding freelancer ID to business's FLs pool
    ordering_business = Employer.objects.get(pk=order.order_business)
    b_freelancers = ordering_business.b_freelancers

    if b_freelancers is None:
        ordering_business.b_freelancers = str(fid)
        ordering_business.save()
    else:
        b_freelancers_tmp = b_freelancers + ',' + str(fid)
        b_freelancers_list = b_freelancers_tmp.split(',')
        b_freelancers_set = set()
        for fl in b_freelancers_list:
            b_freelancers_set.add(fl)
        
        ordering_business.b_freelancers = ','.join(b_freelancers_set)
        ordering_business.save()

    # 3) Notifying the business about the acceptance using

    # 3.1) With email

    email_template = Email.objects.get(name='freelancer-confirmation')
    mail_subject = email_template.mail_subject
    mail_title = email_template.mail_title
    mail_body = email_template.mail_body

    try:    
        mail_context = {
            'domain': request._current_scheme_host,
            'ordering_business': ordering_business.business_name,
            'fl_name': freelancer.name,
            'fl_phone': freelancer.phone,
            'email_title': mail_title,
            'order_id': order.order_id
            # 'email_body': mail_body,
            # 'lang': language,
            }

        send_mail(subject=mail_subject, email_template_name=None,
                context=mail_context, to_email=[ordering_business.email], 
                html_email_template_name='dndsos_dashboard/emails/freelancer_response.html')

    except Exception as ex:
        logger.error(f"mail not sent -- Email configurations required. ERROR: {ex}")
        messages.error(request, f"mail not sent -- Email configurations required. ERROR: {ex}")
        return redirect('home')

    # 3.2 With alerts/signals
    # alert_freelancer_accepted.send(sender=FreelancerProfile, f_id=freelancer.user, order_id=order.pk)

    return render(request, 'dndsos_dashboard/freelancer-accept.html', context)

@employee_required
@login_required
def f_messages_list(request, f_id):
    context = {}
    orders_chat = []
    orders = Order.objects.filter(Q(freelancer=f_id) & ~Q(status='ARCHIVED'))
    for order in orders:
        if order.chat:
            orders_chat.append(order)
    
    context['orders'] = orders_chat
    return render(request, 'dndsos_dashboard/partials/_f-messages-list.html', context)

@login_required
def f_bank_details(request, f_id):
    context = {}
    
    form = BankDetailsForm(request.POST or None)
    
    freelancer = Employee.objects.get(pk=f_id)

    if not freelancer.bank_details:
        freelancer.bank_details = {
            'f_name':'',
            'l_name':'',
            'full_name_in_native_language':'',
            'name_on_the_account':'',
            'address':'',
            'city':'',
            'country':'',
            'phone_number':'',
            'account_ownership':'',
            'national_id_number':'',
            'iban':'',
            'swift':'',
            'account_number':''
        }

    if request.method == 'POST':
        if 'bankDetailsSubmit' in request.POST:
            try:
                if form.is_valid():

                    freelancer.bank_details = {
                    'f_name':form.cleaned_data["first_name"],
                    'l_name':form.cleaned_data["last_name"],
                    'full_name_in_native_language':form.cleaned_data["full_name_in_native_language"],
                    'name_on_the_account':form.cleaned_data["name_on_the_account"],
                    'address':form.cleaned_data["address"],
                    'city':form.cleaned_data["city"],
                    'country':form.cleaned_data["country"],
                    'phone_number':form.cleaned_data["phone_number"],
                    'account_ownership':form.cleaned_data["account_ownership"],
                    'national_id_number':form.cleaned_data["national_id_number"],
                    'iban':form.cleaned_data["iban"],
                    'swift':form.cleaned_data["swift"],
                    'account_number':form.cleaned_data["account_number"]
                    }
                    
                    freelancer.save()
                    messages.success(request, "Bank details were updated successfully")
                    return redirect('dndsos_dashboard:f-profile', f_id=f_id)
                else:
                    for error in form.errors:
                        messages.error(request, f"Error updating bank details. {error}")
                    print('ERROR Bank details')
            except Exception as e:
                messages.error(request, f'Exception: {e}')

    context['form'] = form

    return render(request, 'dndsos_dashboard/f-bank-details.html', context)

# @twilio_view
@csrf_exempt
def f_phone_verify(request, f_id):
    context = {}
    phone = request.session['phone']
    context['phone'] = request.session['phone']

    if request.method == 'POST':
        code = request.POST.get('phone_code')
        try:
            verification_status = phone_verify(request,action='verify_code', phone=phone, code=code)
            if verification_status == 'approved':
                freelancer =  Employee.objects.get(pk=f_id)
                freelancer.phone = phone
                freelancer.save()

                # Patch: updating the freelancer phone for the API calls.
                freelancer_user = User.objects.get(pk=f_id)
                freelancer_user.phone_number = phone
                freelancer_user.save()
                ###

                return render(request,'dndsos_dashboard/phone-verified-success.html')
            else:
                print(f'>>> Failed verify the phone. Error: {verification_status}')
                return render(request,'dndsos_dashboard/failed-phone-verification.html')
        except Exception as e:
            print(f'Failed verify the phone. Error: {e}')
            return render(request,'dndsos_dashboard/failed-phone-verification.html')
    else:
        return render(request, 'dndsos_dashboard/phone-verify.html')

@csrf_exempt
def b_phone_verify(request, b_id):
    context = {}
    phone = request.session['phone']
    context['phone'] = request.session['phone']

    if request.method == 'POST':
        code = request.POST.get('phone_code')
        try:
            verification_status = phone_verify(request,action='verify_code', phone=phone, code=code)
            if verification_status == 'approved':
                business =  Employer.objects.get(pk=b_id)
                business.phone = phone
                business.save()
                
                # Patch: updating the business phone for the API calls.
                business_user = User.objects.get(pk=b_id)
                business_user.phone_number = phone
                business_user.save()
                ###

                return render(request,'dndsos_dashboard/phone-verified-success.html')
            else:
                print(f'>>> Failed verify the phone. Error: {verification_status}')
                return render(request,'dndsos_dashboard/failed-phone-verification.html')
        except Exception as e:
            print(f'Failed verify the phone. Error: {e}')
            return render(request,'dndsos_dashboard/failed-phone-verification.html')
    else:
        return render(request, 'dndsos_dashboard/phone-verify.html')

# @twilio_view
@csrf_exempt
def phone_verify(request,action,phone, code):
    context = {}
    account_sid = settings.TWILIO_ACCOUNT_SID
    auth_token = settings.TWILIO_AUTH_TOKEN
    client = Client(account_sid, auth_token)

    # Create a service if there is none. Only once.
    # service = client.verify.services.create(
    #                     friendly_name='Actappon Verify Service'
    #                     )

    # context['service'] = service
    verify_service_sid = 'VA65cfa1690f666e975f9df686792ee279'

    if action == 'send_verification_code':
        # Verification code to sent to the registrar => $$$$
        try:
            verification = client.verify \
                            .services(verify_service_sid) \
                            .verifications \
                            .create(to=phone, channel='sms')

            context['verification'] = verification
        except Exception as e:
            print(f'Fail sending the confirmation code. ERROR: {e}')
            return False 
        
        return True

    elif action == 'verify_code':
        # Checking the code entered by the user
        try:
            verification_check = client.verify \
                                    .services(verify_service_sid) \
                                    .verification_checks \
                                    .create(to=phone, code=code)
            context['verification_status'] = verification_check.status
            return verification_check.status
        except Exception as e:
            return e

def email_test(request):
    return render(request, 'dndsos_dashboard/emails/delivery_order_email.html')


def broadcast_order(request, order, f_list, order_status):
    pass