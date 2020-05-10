from django.db.models.signals import post_save
from django.dispatch import receiver
# from django.contrib.auth.models import User

from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

from core.models import User
from dndsos_dashboard.models import Order

@receiver(post_save, sender=User)
def announce_new_user(sender, instance, created, **kwargs):
    if created:
        print(f'=========== 1 ===============: {instance.username}')
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            "gossip", {"type": "user.gossip",
                       "event": "New User",
                       "username": instance.username})

@receiver(post_save, sender=Order)
def alert_new_order(sender, instance, created, **kwargs):
    if created:
        print(f'=========== 1 ===============: {instance.order_id}')
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            'created', {
                'type':"order.created",
                'event': 'New Order',
                'orderId': instance.order_id
            }
        )