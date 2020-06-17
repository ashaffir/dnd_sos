from django.shortcuts import render, redirect
from django.contrib.auth import get_user_model, login, logout
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth.decorators import login_required
from django.db.models import Q

from rest_framework import generics, permissions, status, views, viewsets 
from rest_framework.response import Response

from core.models import User, Employee, Employer
from core.decorators import employer_required, employee_required

from .models import Order 
from .serializers import OrderSerializer, UserSerializer

class TripView(viewsets.ReadOnlyModelViewSet):
    lookup_field = 'id' 
    lookup_url_kwarg = 'trip_id' 
    permission_classes = (permissions.IsAuthenticated,)
    queryset = Order.objects.all()
    serializer_class = OrderSerializer

@login_required
def orders_table(request):
    context = {}
    business_id = request.user.pk
    orders = Order.objects.filter(business=request.user.pk).exclude(status='ARCHIVED')
    context['orders'] = orders
    return render(request, 'dndsos_dashboard/partials/_orders-table.html', context)

@login_required
def deliveries_table(request):
    context = {}

    freelancer_id = request.user.pk
    orders = Order.objects.filter(Q(freelancer=freelancer_id) & ~Q(status='REQUESTED') & ~Q(status='ARCHIVED'))
    context['orders'] = orders

    return render(request, 'dndsos_dashboard/partials/_deliveries-table.html', context)

@login_required
def open_orders_alerts(request):
    context = {}
    open_orders = Order.objects.filter(freelancer=None).exclude(status='ARCHIVED')
    number_open_orders = len(open_orders)
    context['open_orders'] = open_orders
    context['num_open_orders'] = number_open_orders
    return render(request, 'dndsos_dashboard/partials/_open-orders-alerts.html', context)

@login_required
def open_orders_list(request):
    context = {}
    open_orders = Order.objects.filter(freelancer=None).exclude(status='ARCHIVED')
    number_open_orders = len(open_orders)
    context['open_orders'] = open_orders
    context['num_open_orders'] = number_open_orders
    return render(request, 'dndsos_dashboard/partials/_open-orders-list.html', context)

@employee_required
@login_required
def active_deliveries_list(request):
    context = {}
    f_id = request.user.pk
    active_deliveries = Order.objects.filter(
        (Q(freelancer=f_id) & Q(status='STARTED')) | 
         Q(freelancer=f_id) & Q(status='IN_PROGRESS')
         )
    num_active_deliveries = len(active_deliveries)
    context['active_deliveries'] = active_deliveries
    context['num_active_deliveries'] = num_active_deliveries
    return render(request, 'dndsos_dashboard/partials/_active-deliveries-list.html', context)


@login_required
def freelancer_messages_list(request):
    '''
    Messages can be sent between the users only when the order status is:
    1) Started
    2) IN_PROGRESS
    3) COMPLETED

    In other statuses the message button is in active.
    '''

    context = {}
    freelancer_id = request.user.pk

    current_orders = Order.objects.filter(
        (Q(freelancer=freelancer_id) & Q(status='STARTED')) |
         Q(freelancer=freelancer_id) & Q(status='IN_PROGRESS') |
         Q(freelancer=freelancer_id) & Q(status='COMPLETED')
         )

    freelancer = Employee.objects.get(pk=freelancer_id)

    current_new_messages = 0
    orders_with_chats = []
    for order in current_orders:
        print(f'ORDER ID: {order.order_id}')
        if order.new_message['freelancer']:
            current_new_messages += 1

        if order.chat:
            orders_with_chats.append(order)
    
    freelancer.new_messages = current_new_messages
    freelancer.save()

    context['orders_with_chats'] = orders_with_chats
    
    return render(request, 'dndsos_dashboard/partials/_freelancer-messages-alerts-list.html', context)


@login_required
def open_orders(request):
    context = {}
    
    open_orders = Order.objects.filter(freelancer=None).exclude(status='ARCHIVED')

    cities = []
    for order in open_orders:
        cities.append(order.city)

    if request.method == 'POST':
        if 'sort_by_city' in request.POST:

            city = request.POST.get('city')
            print(f'{city}')
            sorted_orders = Order.objects.filter(Q(city=city) & Q(freelancer=None) & Q(status='ARCHIVED'))
            context['open_orders'] = sorted_orders
            context['num_open_orders'] = len(sorted_orders)
        else:
            context['open_orders'] = open_orders
            context['num_open_orders'] = len(open_orders)

    context['cities'] = set(cities)
    return render(request, 'dndsos_dashboard/open-orders.html', context)

# Alerts to business about orders that were rejected or that are late
@login_required
def business_alerts_list(request):
    context = {}
    business_id = request.user.pk
    orders = Order.objects.filter(
        (Q(business=business_id) & Q(status='REJECTED'))
        )
    # number_open_orders = len(open_orders)
    context['orders'] = orders
    context['num_alerts'] = len(orders)
    return render(request, 'dndsos_dashboard/partials/_business-orders-alerts-list.html', context)

@login_required
def business_messages_list(request):
    '''
    Messages can be sent between the users only when the order status is:
    1) Started
    2) IN_PROGRESS
    3) COMPLETED

    In other statuses the message button is in active.
    '''

    context = {}
    business_id = request.user.pk

    current_orders = Order.objects.filter(
        (Q(business=business_id) & Q(status='STARTED')) |
         Q(business=business_id) & Q(status='IN_PROGRESS') |
         Q(business=business_id) & Q(status='COMPLETED')
         )

    business = Employer.objects.get(pk=business_id)

    current_new_messages = 0
    orders_with_chats = []
    for order in current_orders:
        print(f'ORDER ID: {order.order_id}')
        if order.new_message['business']:
            current_new_messages += 1

        if order.chat:
            orders_with_chats.append(order)
    
    business.new_messages = current_new_messages
    business.save()
    
    context['orders_with_chats'] = orders_with_chats
    
    return render(request, 'dndsos_dashboard/partials/_business-messages-alerts-list.html', context)
