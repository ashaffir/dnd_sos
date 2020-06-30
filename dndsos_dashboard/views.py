import logging
import os
from datetime import datetime,date

from django.shortcuts import render, redirect, get_object_or_404
from django.http import HttpResponseRedirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth import logout, get_user_model
from django.http import HttpResponse
from django.db.models.signals import post_save
from django.dispatch import receiver
# from django.contrib.auth.models import User

from django.contrib import  messages
from django.template.loader import render_to_string
from django.template import RequestContext
from django.conf import settings
from django.db.models import Q

from django.contrib.gis.db.models.functions import Distance

from rest_framework import generics
from rest_framework.response import Response

from core.models import Employee, Employer, User
from core.forms import EmployeeProfileForm, EmployerProfileForm
from core.decorators import employer_required, employee_required

from .forms import BusinessUpdateForm, FreelancerUpdateForm
from .models import Email, FreelancerProfile, BusinessProfile
from orders.models import Order
from .utilities import send_mail
from geo.models import Street, CityModel
from geo.geo_utils import location_calculator

# from notifier.signals import alert_freelancer_accepted

from .serializers import UserSerializer


LOG_FORMAT = '%(levelname)s %(asctime)s - %(message)s'
logging.basicConfig(filename=os.path.join(settings.BASE_DIR,'logs/dashboard.log'),level=logging.INFO,format=LOG_FORMAT, filemode='w')
logger = logging.getLogger()

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

    if request.user.relationships:
        context['num_active_freelancers'] = len(request.user.relationships['freelancers'])

    return render(request, 'dndsos_dashboard/b-dashboard.html', context)

@employee_required
@login_required
def f_dashboard(request, f_id):
    context = {}

    freelancer = Employee.objects.get(user=request.user.pk)

    if request.method == 'POST':
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

    if request.method == 'POST':

        new_name = request.POST.get("name")
        new_business_name = request.POST.get("business_name")
        new_business_category = request.POST.get("business_category")
        new_phone = request.POST.get("phone")
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

        user_profile.location, user_profile.lon, user_profile.lat = location_calculator(new_city,new_street, new_building, 'israel')
        

        profile_pic = request.FILES.get("profile_pic")

        if new_name:
            user_profile.name = new_name

        if new_business_name:
            user_profile.business_name = new_business_name

        if new_business_category:
            user_profile.business_category = new_business_category

        if new_phone:
            user_profile.phone = new_phone

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
            

    # Check profile completion
    required_fields = {
        'business_name': False,
        'phone': False,
        'street': False,
        'building_number':False,
        'city': False
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

    context['required_fields'] = required_fields
    context['complete'] = round(field_count/len(required_fields)*100)
    context['email'] = request.user.email
    context['profile'] = user_profile
    context['form'] = BusinessUpdateForm()
    return render(request, 'dndsos_dashboard/b-profile.html', context)

@login_required
def f_profile(request, f_id):
    context = {}
    context['freelancer'] = True
    user_profile = Employee.objects.get(user=request.user.id)
    context['cities'] = CityModel.objects.all()

    if request.method == 'POST':

        new_name = request.POST.get("name")
        new_vehicle = request.POST.get("vehicle")
        new_phone = request.POST.get("phone")
        new_bio = request.POST.get("bio")
        new_city = request.POST.get("city")
        new_hours = request.POST.get("active_hours")
        profile_pic = request.FILES.get("profile_pic")
        id_doc = request.FILES.get("id_doc")

        if new_name:
            user_profile.name = new_name

        if new_vehicle:
            user_profile.vehicle = new_vehicle

        if new_phone:
            user_profile.phone = new_phone

        if new_bio:
            user_profile.bio = new_bio

        if new_city:
            user_profile.city = new_city

        if new_hours:
            user_profile.active_hours = new_hours

        if id_doc:
            user_profile.id_doc = request.FILES.get("id_doc")

        if not profile_pic:
            profile_pic = request.FILES.get("old_profile_pic")
        else:
            user_profile.profile_pic = profile_pic

        user_profile.email = request.user.email
        
        try:
            user_profile.save()
            
            # if id_doc:
            #     path = user_profile.id_doc
            #     print(f'PATH: {path}')
            #     filename = request.FILES.get("id_doc").name
            #     os.rename('documents/' + filename, f"documents/{f_id}.{filename}")

            messages.success(request,'You have successfully updated your profile.')
        except Exception as e:
            messages.success(request,f'There was an error updating your profile. ERRRO: {e}')

    # Check profile completion
    required_fields = {
        'name': False,
        'vehicle': False,
        'phone': False,
        'city': False,
        'id_doc':False,
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

    context['required_fields'] = required_fields
    context['complete'] = round(field_count/len(required_fields)*100)
    context['email'] = request.user.email
    context['profile'] = user_profile
    context['form'] = FreelancerUpdateForm()

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

    # business_name = business_profile.business_name
    # business_city = business_profile.city
    # business_street = business_profile.street
    # business_building = business_profile.building_number

    # if business_street != '' and business_street is not None:
    #     if business_city != '' and business_city is not None:
    #         if business_building != '' and business_building is not None:
    #             pick_up_address = business_name + ', ' + business_building + ' ' + business_street + ' street, ' + business_city
    # else:
    #     messages.error(request, 'Please fill our your business address details before adding orders')
    #     return redirect('dndsos_dashboard:b-profile', b_id=request.user.pk)

    # business_orders = Order.objects.filter(business=request.user.pk).order_by('-created')
    # context['orders'] = business_orders


    # if request.method == 'POST':
    #     #TODO: Clean up code. There are limited POST from this page...the add-order is from JS/WS

    #     if 'addOrder' in request.POST:
    #         print(f'POST: {request.POST}')

    #         try:
    #             new_order = Order.objects.create(
    #                 business=business_id,
    #                 pick_up_address=pick_up_address,
    #                 drop_off_address=request.POST.get('drop_off_address'),
    #                 notes=request.POST.get('notes')
    #             )
    #             messages.success(request,'Your order was saved.')
    #         except Exception as e:
    #             messages.error(request,f'Failed to save your order. ERROR>> {e}')
    #             return HttpResponseRedirect(request.path_info)


            # Sending emails to the relevant Freelancers
            #################
            # relevant_freelancers = Employee.objects.filter(city=order_city)

            # for fl in relevant_freelancers:
            #     try:    
            #         mail_context = {
            #             'domain': request._current_scheme_host,
            #             'fl_name': fl.name,
            #             'fl_id': fl.pk,
            #             'email_title': mail_title,
            #             'ordering_business': business_name,
            #             'ordering_business_city': business_city,
            #             'ordering_business_street': business_street,
            #             'ordering_business_building': business_building,
            #             'order_id': order_id,
            #             'oid': new_order.pk,
            #             'order_city': order_city,
            #             'order_type': order_product_type,
            #             'order_notes': order_notes
            #             # 'email_body': mail_body,
            #             # 'lang': language,
            #             }

            #         send_mail(subject=mail_subject, email_template_name=None,
            #                 context=mail_context, to_email=[fl.email], 
            #                 html_email_template_name='dndsos_dashboard/emails/delivery_order_email.html')

            #     except Exception as ex:
            #         messages.error(request, f"mail not sent -- Email configurations required. ERROR: {ex}")
            #         return redirect('dndsos_dashboard:orders', b_id=request.user.pk)

            # return redirect('dndsos_dashboard:orders', b_id=request.user.pk)
 
        # elif 'cancel_b_order' in request.POST:
        #     order = Order.objects.get(order_id=request.POST.get('cancel_b_order'))
        #     if order.status == 'IN_PROGRESS' or order.status == 'COMPLETED':
        #         print(f'CANCEL B ORDER: {order.notes}')
        #         messages.error(request, 'Please pay for the delivery before archiving the order.')
        #     else:
        #         order.status = 'ARCHIVED'
        #         order.save()            

        # elif 'orderDelete' in request.POST:
        #     delete_order_id = request.POST.get(f'orderDelete')
        #     order = Order.objects.get(order_id=delete_order_id)

        #     if order.status == 'IN_PROGRESS' or order.status == 'COMPLETED':
        #         messages.error(request, 'Please pay for the delivery before archiving the order.')
        #     else:
        #         order.status = 'ARCHIVED'
        #         order.save()            
        # else:
        #     print('No Order form detected.')

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

        context['businesses'] = True
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
            filtered_freelancers = Employee.objects.all(is_approved=True)

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

def email_test(request):
    return render(request, 'dndsos_dashboard/emails/delivery_order_email.html')


def broadcast_order(request, order, f_list, order_status):
    pass