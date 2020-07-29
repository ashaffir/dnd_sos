from django.urls import path, include

from rest_framework import routers
from rest_framework.authtoken.views import obtain_auth_token

from .views import (UserRecordView, registration_view, 
                    LoginView, LogoutView,
                    OrdersView, ContactView, order_update_view, order_view,
                    all_user_orders, all_businesses, all_users)

router = routers.DefaultRouter()
router.register('user-orders', OrdersView)
router.register('contacts', ContactView)

app_name = 'api'
urlpatterns = [
    path('', include(router.urls)),
    path('users/', UserRecordView.as_view(), name='users'),
    path('register/', registration_view, name='register'),
    path('login/', obtain_auth_token, name='login'),
    path('order-update/', order_update_view , name='order-update'),
    path('order-view/', order_view , name='order-view'),
    path('all-user-orders/', all_user_orders , name='all-user-orders'),
    path('all-businesses/', all_businesses , name='all-businesses'),
    path('all-users/', all_users , name='all-users'),
]
