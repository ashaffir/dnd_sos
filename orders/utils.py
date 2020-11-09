import random
from .models import Order


def random_string():
    return str(random.randint(10001, 99999))

def unique_order_id(user):
    for _ in range(5):
        order_public_id = random_string()
        if not Order.objects.filter(order_public_id=order_public_id, business=user).exists():
            print(f'>> ORDERS UTILS: {order_public_id}')
            return order_public_id
    
    order_public_id_a = order_public_id + "a"
    print(f'>> ORDERS UTILS: {order_public_id}')
    return order_public_id_a