
from django.contrib import admin
from django.urls import path, include
from dndsos_dashboard import views as dndsos_dashboard_views

app_name = 'dndsos_dashboard'

urlpatterns = [

    path('business', dndsos_dashboard_views.b_dashboard, name='b-dashboard'),
    path('freelancer', dndsos_dashboard_views.f_dashboard, name='f-dashboard'),
    path('b-profile', dndsos_dashboard_views.b_profile, name='b-profile'),
    path('add-freelancer', dndsos_dashboard_views.add_freelancer, name='add-freelancer'),
    path('orders', dndsos_dashboard_views.orders, name='orders'),
    path('deliveries', dndsos_dashboard_views.deliveries, name='deliveries'),
    path('statistics', dndsos_dashboard_views.statistics, name='statistics'),
    path('freelancers', dndsos_dashboard_views.freelancers, name='freelancers'),
    path('f-profile', dndsos_dashboard_views.f_profile, name='f-profile'),
    path('add-order', dndsos_dashboard_views.add_order, name='add-order'),
    path('freelancer-accept/<slug:fid>/<slug:oid>/', dndsos_dashboard_views.freelancer_accept, name='freelancer-accept'),
        
    path('order/', dndsos_dashboard_views.order_input, name='order-input'),
    path('order/<str:order_id>/', dndsos_dashboard_views.order, name='order'),

    path('email-test', dndsos_dashboard_views.email_test, name='email-test'),
    
]
