from django.urls import path

from orders import views as orders_views


app_name = 'orders'

urlpatterns = [
    path('', orders_views.TripView.as_view({'get': 'list'}), name='order_list'),
    path('orders-table',orders_views.orders_table , name='orders-table'),
    path('open-orders-list',orders_views.open_orders_list , name='open-orders-list'),
    path('open-orders',orders_views.open_orders, name='open-orders'),
    path('open-orders-alerts',orders_views.open_orders_alerts, name='open-orders-alerts'),

    # Bussiness    
    path('business-alerts-list',orders_views.business_alerts_list, name='business-alerts-list'),


    path('deliveries-table',orders_views.deliveries_table , name='deliveries-table'),
    path('<uuid:trip_id>/', orders_views.TripView.as_view({'get': 'retrieve'}), name='trip_detail'), 
]