from django.urls import path

from orders import views as orders_views


app_name = 'orders'

urlpatterns = [
    path('', orders_views.TripView.as_view({'get': 'list'}), name='order_list'),
    path('orders-table',orders_views.orders_table , name='orders-table'),
    path('deliveries-table',orders_views.deliveries_table , name='deliveries-table'),
    path('<uuid:trip_id>/', orders_views.TripView.as_view({'get': 'retrieve'}), name='trip_detail'), 
]