from django.urls import path
from django.conf.urls import url
from django.views.generic import ListView
from . import views as geo_views
from .models import Entry

app_name = 'geo'

class EntryList(ListView):
    queryset = Entry.objects.filter(point__isnull=False)

urlpatterns = [
    path('city/<pk>', geo_views.CitiesDetailView.as_view(), name='city-detail'),
    path('map/', EntryList.as_view()),
    path('businesses', geo_views.Businesses.as_view()),
    path('city-streets/', geo_views.city_streets, name='city-streets'),
    path('freelancer-location/', geo_views.freelancer_location, name='freelancer-location'),

    path('autocomplete/', geo_views.autocomplete, name='autocomplete'),
    path('place/place_create', geo_views.PlaceCreate.as_view(), name='place_create'),
    path('place/<int:pk>/', geo_views.PlaceUpdate.as_view(), name='place_update')


]