from django.urls import path

from orders import views as orders_views


app_name = 'orders'

urlpatterns = [
    path('', orders_views.TripView.as_view({'get': 'list'}), name='order_list'),

    # Freelancers
    path('open-orders-list',orders_views.open_orders_list , name='open-orders-list'),
    path('active-deliveries-list',orders_views.active_deliveries_list , name='active-deliveries-list'),
    path('open-orders',orders_views.open_orders, name='open-orders'),
    path('open-orders-alerts',orders_views.open_orders_alerts, name='open-orders-alerts'),
    path('deliveries-table',orders_views.deliveries_table , name='deliveries-table'),
    path('freelancer-messages-list',orders_views.freelancer_messages_list, name='freelancer-messages-list'),

    # Bussiness    
    path('orders-table',orders_views.orders_table , name='orders-table'),
    path('business-alerts-list',orders_views.business_alerts_list, name='business-alerts-list'),
    path('business-messages-list',orders_views.business_messages_list, name='business-messages-list'),

    path('<uuid:trip_id>/', orders_views.TripView.as_view({'get': 'retrieve'}), name='trip_detail'), 
]