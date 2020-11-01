from django.urls import path

from dndsos import views

app_name = 'dndsos'

urlpatterns = [
    path('', views.home, name='home'),
    path('index_test/', views.index_test, name='index_test'),
    path('room/<str:username>/', views.room, name='room'),
    path('terms/', views.terms, name='terms'),
    path('terms_courier/', views.terms_courier, name='terms_courier'),
    path('terms_sender/', views.terms_sender, name='terms_sender'),
    path('privacy/', views.privacy, name='privacy'),
    path('courier-addendum/', views.c_addendum, name='courier-addendum'),
]