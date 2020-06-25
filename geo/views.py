from django.shortcuts import render
from django.views.generic import DetailView
from django.views import generic
from django.contrib.gis.geos import fromstr, Point
from django.contrib.gis.db.models.functions import Distance
from django.contrib.auth.decorators import login_required

from .models import City, BusinessLocation, Street

@login_required
def city_streets(request):
    context = {}
    data_type = request.GET.get('type')
    if data_type == 'profile':
        city_name = request.GET.get('city')
        context['data_type'] = 'profile'
        context['streets'] = Street.objects.filter(city_name=city_name)
    else:
        city_symbol = request.GET.get('city')
        context['streets'] = Street.objects.filter(city_symbol=city_symbol)

    return render(request, 'geo/partials/_city_streets.html', context)


class CitiesDetailView(DetailView):
    """
        City detail view.
    """
    template_name = 'geo/city-detail.html'
    model = City


# Reference: https://tinyurl.com/y9rdrqce

longitude = -80.191788
latitude = 25.761681
user_location = Point(longitude, latitude, srid=4326)

class Businesses(generic.ListView):
    model = BusinessLocation
    context_object_name = 'businesses'
    queryset = BusinessLocation.objects.annotate(
            distance=Distance('location',user_location)
        ).order_by('distance')[0:6]
    template_name = 'geo/businesses.html' 
