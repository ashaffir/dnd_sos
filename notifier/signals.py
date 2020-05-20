from django.db.models.signals import post_save
from django.dispatch import receiver, Signal
from django.core.signals import request_finished
# from django.contrib.auth.models import User

from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

from core.models import User, Employee, Employer
from dndsos_dashboard.models import FreelancerProfile
from orders.models import Order

@receiver(post_save, sender=User)
def announce_new_user(sender, instance, created, **kwargs):
    if created:
        print(f'=========== SIGNAL: New User ===============: {instance.username}')
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            "gossip", {"type": "user.gossip",
                       "event": "New User",
                       "username": instance.username})

# @receiver(post_save, sender=Order)
# def alert_new_order(sender, instance, created, **kwargs):
#     if created:
#         print(f'=========== SIGNAL: New Order ID ===============: {instance.order_id}')
#         relevant_freelancers = Employee.objects.filter(city=instance.city)
#         order_id = instance.order_id
#         # Turing the result list to string for serialization
#         relevant_freelancers_arr = []
#         for fl in relevant_freelancers:
#             relevant_freelancers_arr.append(str(fl.pk))
#         relevant_freelancers_str = '-'.join(relevant_freelancers_arr)
        
#         business_id = instance.business_id

#         business = User.objects.get(pk=business_id)

#         channel_layer = get_channel_layer()
#         async_to_sync(channel_layer.group_send)(
#             str(order_id), {
#                 'type':"create.order",
#                 'event': 'New Order',
#                 'orderId': instance.order_id, 
#                 'business_id': business_id,
#                 'city': instance.city,
#                 'relevant_fls': relevant_freelancers_str
#             }
#         )

# alert_new_order = Signal(providing_args=['b_id', 'order_id', 'f_list'])

alert_freelancer_accepted = Signal(providing_args=['f_id', 'order_id'])

@receiver(alert_freelancer_accepted)
def alert_freelancer_accepted_receiver(sender, **kwargs):
    print(f'>>>> Freelancer accepted offer. ARGS: {kwargs}')