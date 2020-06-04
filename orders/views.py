from django.shortcuts import render, redirect
from django.contrib.auth import get_user_model, login, logout
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth.decorators import login_required
from django.db.models import Q

from rest_framework import generics, permissions, status, views, viewsets 
from rest_framework.response import Response

from core.models import User
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
    # print(f'>>>> RELATIONS: {request.user.relations[-1]}')

    f = User.objects.get(pk=request.user.pk)
    # f.relations = ['stam','batata', 'CCC', 'trerteerrttttttttttttt','gggffsdfgsdf']
    # f.relations.append('hhh')
    # f.save()

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


@login_required
def open_orders(request):
    context = {}

    if request.method == 'POST':
        if 'acceptOrder' in request.POST:
            order = Order.objects.get(order_id=request.POST.get('acceptOrder'))
            if order.status == 'REQUESTED':
                order.freelancer = request.user
                order.status = 'STARTED'
                order.save()
            else:
                print('>>>>>>>> NOT AVAILABLE')
                context['offer_removed'] = True

    open_orders = Order.objects.filter(freelancer=None).exclude(status='ARCHIVED')
        
    number_open_orders = len(open_orders)
    context['open_orders'] = open_orders
    context['num_open_orders'] = number_open_orders


    return render(request, 'dndsos_dashboard/open-orders.html', context)

@login_required
def business_alerts_list(request):
    context = {}
    business_id = request.user.pk
    orders = Order.objects.filter(Q(business=business_id) & Q(status='REQUESTED') | Q(status='REJECTED') | Q(status='RE_REQUESTED'))
    # number_open_orders = len(open_orders)
    context['orders'] = orders
    context['num_alerts'] = len(orders)
    return render(request, 'dndsos_dashboard/partials/_business-orders-alerts-list.html', context)