from django.urls import path
from django.conf.urls import url
from django.views.generic import ListView

from . import views as payments_views

app_name = 'payments'

urlpatterns = [
    path('enter-credit-card/', payments_views.enter_credit_card, name='enter-credit-card'),
    path('add-card/', payments_views.add_card, name='add-card'),
    path('remove-card/', payments_views.remove_card, name='remove-card'),
    path('charge/', payments_views.charge, name='charge'),
    path('ipn-listener/', payments_views.ipn_listener, name='ipn-listener'),

]