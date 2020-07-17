from django.urls import path
from django.conf.urls import url
from django.views.generic import ListView

from . import views as payments_views

app_name = 'payments'

urlpatterns = [
    path('credit-card-form/', payments_views.credit_card_form, name='credit-card-form'),
    path('success-card-collection/<int:b_id>', payments_views.success_card_collection, name='success-card-collection'),
    path('failed-card-collection/', payments_views.failed_card_collection, name='failed-card-collection'),
    path('ipn-listener-card-info/', payments_views.ipn_listener_card_info, name='ipn-listener-card-info'),
    path('ipn-listener-lock-price/', payments_views.ipn_listener_lock_price, name='ipn-listener-lock-price'),

    path('lock-delivery-price/', payments_views.lock_delivery_price, name='lock-delivery-price'),


    path('add-card/', payments_views.add_card, name='add-card'),
    path('remove-card/', payments_views.remove_card, name='remove-card'),
    path('charge/', payments_views.charge, name='charge'),

]