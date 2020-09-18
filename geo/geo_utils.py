import platform
from geopy.geocoders import Nominatim
from django.contrib.gis.geos import fromstr, Point

from core.models import User, Employee, Employer
from orders.models import Order

def distance_calculator(order):
    '''
    Dynamically calculate the distancce between the order drop off address
    and the freelancer that is delivering in reference to the distance between drop off address
    and the business.

    This method is called from the "orders_table" page which is what updates the orders page for business.
    '''
    order_business_distance = order.distance_to_business * 1000 # In meters
    
    active_freelancer_id = order.freelancer.pk
    print(f'GEO UTILS >> ACTIVE: {active_freelancer_id}')

    order_location = order.order_location
    
    freelancer_location = Employee.objects.get(pk=active_freelancer_id).location

    try:
        order_range_to_freelancer = round(order_location.distance(freelancer_location) * 100, 3) * 1000 # In meters
        print(f'DISTANCE between courier and order drop off address: {order_range_to_freelancer} meters')

        if order_business_distance > order_range_to_freelancer:
            trip_completed = 100 * (order_business_distance - order_range_to_freelancer) / order_business_distance
            print(f'Courier has completed {trip_completed}% of the trip.')
        else:
            print(f'Courier did not start moving.')
            trip_completed = 0
    except:
        print(f'ERROR calculating distance between courier and order drop off address!')
        trip_completed = 0

    return trip_completed


def location_calculator(city, street, building=1, country='israel'):
    geolocator = Nominatim(user_agent="dndsos", timeout=3)
    address = building + ' ' + street + ', ' + city
    location = geolocator.geocode(address)

    try:
        if platform.system() == 'Darwin':
            point = Point(location.latitude,location.longitude)
        else:
            point = Point(location.longitude, location.latitude)
    
        return point, location.longitude, location.latitude

    except Exception as e:
        print(f'No location found for: city - {city} | street - {street}')
        return None, None, None

    