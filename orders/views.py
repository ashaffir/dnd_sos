from django.shortcuts import render
from django.contrib.auth import get_user_model, login, logout
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth.decorators import login_required
from rest_framework import generics, permissions, status, views, viewsets 
from rest_framework.response import Response

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
    return render(request, 'dndsos_dashboard/partials/_orders_table.html', context)

@login_required
def deliveries_table(request):
    context = {}
    freelancer_id = request.user.pk
    orders = Order.objects.filter(freelancer=freelancer_id).exclude(status='ARCHIVED')
    context['orders'] = orders
    return render(request, 'dndsos_dashboard/partials/_deliveries-table.html', context)