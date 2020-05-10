from django.contrib import admin
from django.urls import path, include

from notifier import views as notifier_views

app_name = 'notifier'

urlpatterns = [
    path('', notifier_views.notifier, name='notifier'),
    
]
