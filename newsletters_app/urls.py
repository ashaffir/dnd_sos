from django.urls import path
from django.urls.conf import include

from . import views

app_name = 'newsletters_app'

urlpatterns = [
    path('', views.newsletter, name='newsletter'),
    path('unsubscribe/<str:user_id>', views.unsubscribe, name='unsubscribe'),
    path('newsletter_test', views.newsletter_test, name='newsletter_test'),
]