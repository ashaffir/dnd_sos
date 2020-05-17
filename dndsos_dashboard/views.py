import logging
import os
from django.shortcuts import render, redirect, get_object_or_404
from django.http import HttpResponseRedirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth import logout, get_user_model
from django.http import HttpResponse
# from django.contrib.auth.models import User

from django.contrib import  messages
from django.template.loader import render_to_string
from django.template import RequestContext
from django.conf import settings

from rest_framework import generics
from rest_framework.response import Response

from core.models import Employee, Employer, User
from core.forms import EmployeeProfileForm, EmployerProfileForm
from core.decorators import employer_required, employee_required

from .forms import BusinessUpdateForm, FreelancerUpdateForm, OrderForm
from .models import Email, FreelancerProfile, BusinessProfile
from orders.models import Order
from .utilities import send_mail

from notifier.signals import alert_freelancer_accepted

from .serializers import UserSerializer


LOG_FORMAT = '%(levelname)s %(asctime)s - %(message)s'
logging.basicConfig(filename=os.path.join(settings.BASE_DIR,'logs/dashboard.log'),level=logging.INFO,format=LOG_FORMAT, filemode='w')
logger = logging.getLogger()

class SignUpView(generics.CreateAPIView):
    queryset = get_user_model().objects.all()
    serializer_class = UserSerializer

def order_input(request):
    return render(request, 'dndsos_dashboard/order-input.html')

def order(request, order_id):
    return render(request, 'dndsos_dashboard/order.html', {
        'order_id': order_id
    })

@login_required
def b_dashboard(request, b_id):
    context = {}
    return render(request, 'dndsos_dashboard/b-dashboard.html')

@login_required
def f_dashboard(request, f_id):
    context = {}
    return render(request, 'dndsos_dashboard/f-dashboard.html')


@login_required
def b_profile(request, b_id):
    context = {}
    user_profile = Employer.objects.get(user=request.user.id)

    if request.method == 'POST':
        # form = BusinessUpdateForm(request.POST, instance=request.user.profile)

        new_name = request.POST.get("name")
        new_business_name = request.POST.get("business_name")
        new_business_category = request.POST.get("business_category")
        new_phone = request.POST.get("phone")
        new_bio = request.POST.get("bio")
        new_street = request.POST.get("street")
        new_building = request.POST.get("building_number")
        new_city = request.POST.get("city")
        profile_pic = request.FILES.get("profile_pic")

        if new_name:
            user_profile.name = new_name

        if new_business_name:
            user_profile.company = new_business_name

        if new_business_category:
            user_profile.business_category = new_business_category

        # if new_vehicle:
        #     user_profile.vehicle = new_vehicle

        if new_phone:
            user_profile.phone = new_phone

        if new_bio:
            user_profile.bio = new_bio

        if new_street:
            user_profile.street = new_street

        if new_building:
            user_profile.building_number = new_building

        if new_city:
            user_profile.city = new_city
    
        if not profile_pic:
            profile_pic = request.FILES.get("old_profile_pic")
        else:
            user_profile.profile_pic = profile_pic

        # if form.is_valid():
        #     form.save()
        #     messages.success(request,'You have successfully updated your profile.')
        # else:
        #     messages.error(request,'There was an error updating the profile.')

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
        'city': False
        }    
    # for f in user_profile._meta.get_fields():
        # field = str(f).split('.')[2]
    field_count = 0
    for field in required_fields.keys():
        if getattr(user_profile, field):
            required_fields[field] = True
            field_count += 1

    # context['required_fields'] = ['Business Name', 'Business Type', 'Phone', 'City']
    # context['business_type'] = request.user.profile.business_type
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

    if request.method == 'POST':
        # form = FreelancerUpdateForm(request.POST, instance=request.user.profile)
        # form = EmployeeProfileForm(request.POST or None, instance=request.user)

        new_name = request.POST.get("name")
        new_vehicle = request.POST.get("vehicle")
        new_phone = request.POST.get("phone")
        new_bio = request.POST.get("bio")
        new_city = request.POST.get("city")
        new_hours = request.POST.get("active_hours")
        profile_pic = request.FILES.get("profile_pic")

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

        if not profile_pic:
            profile_pic = request.FILES.get("old_profile_pic")
        else:
            user_profile.profile_pic = profile_pic

        user_profile.email = request.user.email
        
        try:
            user_profile.save()
            messages.success(request,'You have successfully updated your profile.')
        except Exception as e:
            messages.success(request,f'There was an error updating your profile. ERRRO: {e}')

    # Check profile completion
    required_fields = {
        'vehicle': False,
        'phone': False,
        'city': False
        }    
    # for f in user_profile._meta.get_fields():
        # field = str(f).split('.')[2]
    field_count = 0
    for field in required_fields.keys():
        if getattr(user_profile, field):
            required_fields[field] = True
            field_count += 1

    # context['required_fields'] = ['Business Name', 'Business Type', 'Phone', 'City']
    # context['business_type'] = request.user.profile.business_type
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
    business_name = business_profile.business_name
    business_city = business_profile.city
    business_street = business_profile.street
    business_building = business_profile.building_number

    if business_street != '' and business_street is not None:
        if business_city != '' and business_city is not None:
            if business_building != '' and business_building is not None:
                pick_up_address = business_name + ', ' + business_building + ' ' + business_street + ' street, ' + business_city
    else:
        messages.error(request, 'Please fill our your business address details before adding orders')
        return redirect('dndsos_dashboard:b-profile', b_id=request.user.pk)

    business_orders = Order.objects.filter(business=request.user.pk).order_by('-created')
    context['orders'] = business_orders

    if request.method == 'POST':
        if 'addOrder' in request.POST:

            try:
                new_order = Order.objects.create(
                    business=business_id,
                    pick_up_address=pick_up_address,
                    drop_off_address=request.POST.get('drop_off_address'),
                    notes=request.POST.get('notes')
                )
                messages.success(request,'Your order was saved.')
            except Exception as e:
                messages.error(request,f'Failed to save your order. ERROR>> {e}')
                return HttpResponseRedirect(request.path_info)

            # # TODO: Add the pusher/concurrent run (threads) to email alerts sending

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

            return redirect('dndsos_dashboard:orders', b_id=request.user.pk)
       
        elif 'dispached' in request.POST:
            dispached_order_id = request.POST.get('dispached')
            order = Order.objects.get(id=dispached_order_id)
            order.order_dispatched = True
            order.save()

            # TODO: When the order is dispached need to update the FLs in that city that the order is closed

            return redirect('dndsos_dashboard:orders', b_id=request.user.pk)

        elif 'delivered' in request.POST:
            delivered_order_id = request.POST.get('delivered')
            order = Order.objects.get(id=delivered_order_id)
            order.order_delivered = True
            order.save()
            return redirect('dndsos_dashboard:orders', b_id=request.user.pk)
        elif 'orderDelete' in request.POST:
            delete_order_id = request.POST.get(f'orderDelete')
            order = Order.objects.get(order_id=delete_order_id)
            order.delete()
            return redirect('dndsos_dashboard:orders', b_id=request.user.pk)
        else:
            print('No Order form detected.')

    return render(request, 'dndsos_dashboard/orders.html', context)

@employer_required
@login_required
def add_order(request):
    context = {}
    return render(request, 'dndsos_dashboard/add-order.html')

@employer_required
@login_required
def edit_order(request):
    context = {}
    return render(request, 'dndsos_dashboard/edit-order.html')

@employee_required
@login_required
def f_deliveries(request, f_id):
    context = {}
    return render(request, 'dndsos_dashboard/deliveries.html', context)

@login_required
def f_statistics(request, f_id):
    context = {}
    return render(request, 'dndsos_dashboard/statistics.html', context)

@employer_required
@login_required
def b_deliveries(request, b_id):
    context = {}
    return render(request, 'dndsos_dashboard/deliveries.html', context)

@login_required
def b_statistics(request, b_id):
    context = {}
    return render(request, 'dndsos_dashboard/statistics.html', context)


@login_required
def freelancers(request, b_id):
    context = {}
    freelancers = Employee.objects.all()
    context['total_freelancers'] = len(freelancers)
    
    if request.method == 'POST':
        city = request.POST.get('city')
        vehicle = request.POST.get('vehicle')
        if vehicle and city:
            freelancers = Employee.objects.filter(vehicle=vehicle, city=city)
            context['total_freelancers'] = len(freelancers)
        elif vehicle and not city:
            freelancers = Employee.objects.filter(vehicle=vehicle)
            context['total_freelancers'] = len(freelancers)
        elif not vehicle and city:
            freelancers = Employee.objects.filter(city=city)
            context['total_freelancers'] = len(freelancers)
        else:
            freelancers = Employee.objects.all()
            context['total_freelancers'] = len(freelancers)

    context['freelancers'] = freelancers
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
    alert_freelancer_accepted.send(sender=FreelancerProfile, f_id=freelancer.user, order_id=order.pk)

    return render(request, 'dndsos_dashboard/freelancer-accept.html', context)

def email_test(request):
    return render(request, 'dndsos_dashboard/emails/delivery_order_email.html')


def broadcast_order(request, order, f_list, order_status):
    pass