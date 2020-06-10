
from django.contrib import admin
from django.urls import path, include
from dndsos_dashboard import views as dndsos_dashboard_views

app_name = 'dndsos_dashboard'

urlpatterns = [

    path('business/<int:b_id>/', dndsos_dashboard_views.b_dashboard, name='b-dashboard'),
    path('business/<int:b_id>/b-profile/', dndsos_dashboard_views.b_profile, name='b-profile'),
    path('business/<int:b_id>/orders', dndsos_dashboard_views.orders, name='orders'),
    path('business/<int:b_id>/deliveries', dndsos_dashboard_views.b_deliveries, name='b-deliveries'),
    path('business/<int:b_id>/statistics', dndsos_dashboard_views.b_statistics, name='b-statistics'),
    path('business/<int:b_id>/freelancers', dndsos_dashboard_views.freelancers, name='freelancers'),
    path('business/<int:b_id>/b-alerts', dndsos_dashboard_views.b_alerts, name='b-alerts'),
    path('business/<int:b_id>/b-alerts-items', dndsos_dashboard_views.b_alerts_items, name='b-alerts-items'),
    path('business/<int:b_id>/b-messages', dndsos_dashboard_views.b_messages, name='b-messages'),
    path('business/<int:b_id>/b-chat-room', dndsos_dashboard_views.b_chat_room, name='b-chat-room'),
    path('business/<int:b_id>/b-messages-list', dndsos_dashboard_views.b_messages_list, name='b-messages-list'),

    # path('add-order', dndsos_dashboard_views.add_order, name='add-order'),
    path('add-freelancer', dndsos_dashboard_views.add_freelancer, name='add-freelancer'),

    path('freelancer/<int:f_id>/', dndsos_dashboard_views.f_dashboard, name='f-dashboard'),
    path('freelancer/<int:f_id>/deliveries', dndsos_dashboard_views.f_deliveries, name='f-deliveries'),
    path('freelancer/<int:f_id>/f-businesses', dndsos_dashboard_views.f_businesses, name='f-businesses'),
    path('freelancer/<int:f_id>/statistics', dndsos_dashboard_views.f_statistics, name='f-statistics'),
    path('freelancer/<int:f_id>/f-profile', dndsos_dashboard_views.f_profile, name='f-profile'),
    path('freelancer-accept/<slug:fid>/<slug:oid>/', dndsos_dashboard_views.freelancer_accept, name='freelancer-accept'),
    path('freelancer/<int:f_id>/f-messages', dndsos_dashboard_views.f_messages, name='f-messages'),
    path('freelancer/<int:f_id>/f-chat-room', dndsos_dashboard_views.f_chat_room, name='f-chat-room'),
    path('freelancer/<int:f_id>/f-messages-list', dndsos_dashboard_views.f_messages_list, name='f-messages-list'),
        
    path('order/', dndsos_dashboard_views.order_input, name='order-input'),
    path('order/<str:order_id>/', dndsos_dashboard_views.order, name='order'),

    path('email-test', dndsos_dashboard_views.email_test, name='email-test'),
    
]
