from django.urls import path, include

from rest_framework import routers
from rest_framework.authtoken.views import obtain_auth_token

from .views import (UserRecordView, registration_view, 
                    LoginView, LogoutView,
                    OrdersView, ContactView, order_update_view, order_view,
                    all_user_orders, all_businesses, all_users, user_profile, phone_verification,
                    NewLoginViewSet,OpenOrdersViewSet,ActiveOrdersViewSet,
                    UserLocationViewSet,BusinessOrdersViewSet,BusinessRejectedOrdersViewSet, UserAvailable,
                    email_verification, new_order, price_parameteres, user_credit_card, user_photo_id, order_delivery,
                    user_profile_image, bank_details)

# Firebase Cloud Messageing (FCM)
from fcm_django.api.rest_framework import FCMDeviceAuthorizedViewSet
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r'devices', FCMDeviceAuthorizedViewSet)

router = routers.DefaultRouter()
router.register('user-orders', OrdersView)
router.register('contacts', ContactView)
router.register('open-orders', OpenOrdersViewSet, basename='api')
router.register('active-orders', ActiveOrdersViewSet, basename='api')
router.register('business-orders', BusinessOrdersViewSet, basename='api')
router.register('rejected-orders', BusinessRejectedOrdersViewSet, basename='api')

app_name = 'api'
urlpatterns = [
    path('', include(router.urls)),
    path('users/', UserRecordView.as_view(), name='users'),
    path('register/', registration_view, name='register'),
    path('email-verification/', email_verification, name='email-verification'),
    path('phone-verification/', phone_verification , name='phone-verification'),
    # path('login/', obtain_auth_token, name='login'),
    path('login/', NewLoginViewSet.as_view(), name='login'),
    path('order-update/', order_update_view , name='order-update'),
    path('price-parameteres/', price_parameteres , name='price-parameters'),
    path('new-order/', new_order , name='new-order'),
    path('order-delivery/', order_delivery , name='order-delivery'),
    path('order-view/', order_view , name='order-view'),
    path('all-user-orders/', all_user_orders , name='all-user-orders'),
    path('all-businesses/', all_businesses , name='all-businesses'),
    path('all-users/', all_users , name='all-users'),
    path('user-profile/', user_profile , name='user-profile'),
    path('user-credit-card/', user_credit_card , name='user-credit-card'),
    path('user-photo-id/', user_photo_id , name='user-photo-id'),
    path('user-profile-image/', user_profile_image , name='user-profile-image'),
    path('user-location/', UserLocationViewSet.as_view() , name='user-location'),
    path('user-availability/', UserAvailable.as_view() , name='user-availability'),
    path('bank-details/', bank_details , name='bank-details'),

    # FCM
    path('devices/', FCMDeviceAuthorizedViewSet.as_view({'post': 'create'}), name='create_fcm_device'),


]
