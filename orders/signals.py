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
# def signal_order_update(sender, instance, update_fields, **kwargs):        
#     business_id = instance.business_id
#     print(f'>>>>>>> SIGNAL >>> Order Status Change: {instance.status}. ID: {instance.order_id}')  
    
#     if instance.status == 'STARTED':
#         # print(f''''
#         # >>>>>>> SIGNAL: Order STARTED: {instance.order_id}  
#         # update: {instance.status} type: {type(instance.status)}
#         # update: {instance.order_id} type: {type(instance.order_id)}
#         # update: {instance.business_id} type: {type(instance.business_id)}
#         # ''')
#         channel_layer = get_channel_layer()
#         async_to_sync(channel_layer.group_send)(
#             str(instance.order_id), {
#                 # 'type':"order.accepted",
#                 'type':"update.order",
#                 'data': {
#                     'event': 'Order Accepted',
#                     'order_id': str(instance.order_id), 
#                     'business_id': business_id,
#                     'status': str(instance.status)
#                 }
#             }
#         )
#     elif instance.status == 'REQUESTED':
#         channel_layer = get_channel_layer()
#         async_to_sync(channel_layer.group_send)(
#             str(instance.order_id), {
#                 'type':"update.order",
#                 # 'type':"order.canceled",
#                 'data': {
#                     'event': 'Order Canceled',
#                     'order_id': str(instance.order_id), 
#                     'business_id': business_id,
#                     'status': str(instance.status)
#                 }
#             }
#         )
    
#     elif instance.status == 'RE_REQUESTED': # Avoiding second update through the sigmnl
#         print('RE-REQUEST. No action on this signal.')
#         pass

#     elif instance.status == 'ARCHIVED':
#         channel_layer = get_channel_layer()
#         async_to_sync(channel_layer.group_send)(
#             str(instance.order_id), {
#                 'type':"echo.message",
#                 # 'type':"order.canceled",
#                 'data': {
#                     'event': 'Order Canceled',
#                     'order_id': str(instance.order_id),
#                     'freelancer': str(instance.freelancer.pk),
#                     'business_id': business_id,
#                     'status': str(instance.status)
#                 }
#             }
#         )

    # elif instance.status == 'IN_PROGRESS':
    #     print(f''''
    #     >>>>>>> SIGNAL: Order In Progress: {instance.order_id}  
    #     update: {instance.status} type: {type(instance.status)}
    #     update: {instance.order_id} type: {type(instance.order_id)}
    #     update: {instance.business_id} type: {type(instance.business_id)}
    #     update: {instance.freelancer.pk} type: {type(instance.freelancer.pk)}
    #     ''')
    #     channel_layer = get_channel_layer()
    #     async_to_sync(channel_layer.group_send)(
    #         str(instance.order_id), {
    #             'type':"order.dispached",
    #             'event': 'Order Dispached',
    #             'order_id': str(instance.order_id), 
    #             'business': business_id,
    #             'freelancer': instance.freelancer.pk,
    #             'status': str(instance.status)
    #         }
    #     )




# alert_new_order = Signal(providing_args=['b_id', 'order_id', 'f_list'])

# alert_freelancer_accepted = Signal(providing_args=['f_id', 'order_id'])

# @receiver(alert_freelancer_accepted)
# def alert_freelancer_accepted_receiver(sender, **kwargs):
#     print(f'>>>> Freelancer accepted offer. ARGS: {kwargs}')