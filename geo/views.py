import platform
from datetime import datetime
import calendar
import time
from django.shortcuts import render
from django.views.generic import DetailView
from django.views import generic
from django.contrib.gis.geos import fromstr, Point
from django.contrib.gis.db.models.functions import Distance
from django.contrib.auth.decorators import login_required
from django.db.models import Q
from django.views.decorators.csrf import csrf_exempt

from .models import City, BusinessLocation, Street, FreelancerLocation, CityModel
from core.models import Employee
from orders.models import Order

# @csrf_exempt
def freelancer_location(request):
    context = {}

    freelancer = Employee.objects.get(user=request.user.pk)
    freelancer_in_progress_orders = Order.objects.filter(Q(freelancer=request.user.pk) & Q(status='IN_PROGRESS'))

    try:
        location = {
            'time': calendar.timegm(time.gmtime()),
            'lat': float(request.POST.get("lat")),
            'lon': float(request.POST.get("lon"))
        }
    except Exception as e:
        location = {
            'time': calendar.timegm(time.gmtime()),
            'lat': None,
            'lon': None
        }
        print(f'Freelancer location is missing. Reason: {e}')

    # Saving the trip point of a carrier throughout the delivery 
    # process for every order he is involved at that moment
    for order in freelancer_in_progress_orders:
        if not order.trip:
            order.trip = {'locations':[]}
        else:
            if freelancer.is_available:
                if location['lat'] is not None and location['lon'] is not None:
                    order.trip['locations'].append(location)
        order.save()

    # Chacking if the freelancer is active
    active_orders = Order.objects.filter(
        (Q(freelancer=request.user.pk) & Q(status='IN_PROGRESS'))                            
        | (Q(freelancer=request.user.pk) & Q(status='STARTED')))

    print(f"active_orders ***************{len(active_orders)}****************")
    if len(active_orders) == 0:
        freelancer.is_delivering = False
        freelancer.save()
        
    # Tracking location of an available freelancer
    if not freelancer.trips:
        freelancer.trips = {'locations':[]}
        freelancer.save()
    else:
        if freelancer.is_available:
            if location['lat'] is not None and location['lon'] is not None:
                # freelancer.trips['locations'].append(location)

                # Checking OS (for some reason the order of lat/lon in "Point" is different)
                if platform.system() == 'Darwin':
                    freelancer.location = Point(float(request.POST.get("lat")), float(request.POST.get("lon")))
                else:
                    freelancer.location = Point(float(request.POST.get("lon")), float(request.POST.get("lat")))

                freelancer.save()

            print(f'LOC: {location}')
    

    return render(request, 'geo/f-location.html', context)


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
    model = CityModel


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
