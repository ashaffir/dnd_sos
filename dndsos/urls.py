from django.urls import path

from dndsos import views

app_name = 'dndsos'

urlpatterns = [
    path('', views.home, name='home'),
    path('index_test/', views.index_test, name='index_test'),
    path('room/<str:username>/', views.room, name='room'),
]