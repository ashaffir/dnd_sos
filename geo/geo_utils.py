from core.models import User, Employee, Employer
from orders.models import Order

def distance_calculator(order):
    '''
    Dynamically calculate the distancce between the order drop off address
    and the freelancer that is delivering in reference to the distance between drop off address
    and the business.
    '''
    order_business_distance = order.distance_to_business * 1000 # In meters
    
    active_freelancer_id = order.freelancer.pk

    order_location = order.order_location
    freelancer_location = Employee.objects.get(pk=active_freelancer_id).location

    order_range_to_freelancer = round(order_location.distance(freelancer_location) * 100, 3) * 1000 # In meters


    print(f'DISTANCE between carrier and order drop off address: {order_range_to_freelancer} meters')

    if order_business_distance > order_range_to_freelancer:
        trip_completed = round((order_business_distance - order_range_to_freelancer) / order_business_distance, 2) * 100
        print(f'Carrier has completed {trip_completed}% of the trip.')
    else:
        print(f'Carrier did not start moving.')
        trip_completed = 0
    
    return trip_completed

