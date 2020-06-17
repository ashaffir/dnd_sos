from django.urls import path
from django.conf.urls import url
from django.views.generic import ListView
from . import views
from .models import Entry

app_name = 'geo'

class EntryList(ListView):
    queryset = Entry.objects.filter(point__isnull=False)

urlpatterns = [
    path('city/<pk>', views.CitiesDetailView.as_view(), name='city-detail'),
    path('map/', EntryList.as_view()),

]