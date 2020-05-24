import asyncio
from asgiref.sync import async_to_sync
from channels.db import database_sync_to_async
from channels.generic.websocket import AsyncJsonWebsocketConsumer

from orders.models import Order
from orders.serializers import ReadOnlyOrderSerializer, OrderSerializer

class OrderConsumer(AsyncJsonWebsocketConsumer):

    # new
    def __init__(self, scope):
        super().__init__(scope)

        # Keep track of the user's orders.
        self.orders = set()

    async def connect(self):
        user = self.scope['user']
        if user.is_anonymous:
            await self.close()
        else:
            channel_groups = []

           # Add a freelancer to the 'freelancers' group.
            user_group = await self._get_user_group(self.scope['user'])

            if user_group == 'freelancer':
                channel_groups.append(self.channel_layer.group_add(
                    group='freelancers',
                    channel=self.channel_name
                ))
            
            # Get orders and add business to each one's group.
            self.orders = set([
                str(order_id) for order_id in await self._get_orders(self.scope['user']) 
            ])
            
            for order in self.orders:
                channel_groups.append(self.channel_layer.group_add(order, self.channel_name))
            
            asyncio.gather(*channel_groups)

            await self.accept()

    async def receive_json(self, content, **kwargs):
        message_type = content.get('type')
        if message_type == 'create.order':
            await self.create_order(content)
        elif message_type == 'update.order':  
            await self.update_order(content)


    async def echo_message(self, event):
        
        # TODO: add filtering so that only the relecant freelancers are getting the notification
        
        await self.send_json(event)

    # The name of this function is edrived from the automated process of generating the name from the signals type order.created
    # This method will generate and broadcast the alert
    # async def order_created(self, event):
    #     await self.send_json(event)
    #     print(f'Got message: {event} at group: {self.channel_name}')


    async def create_order(self, event):
        
        print('>>> CREATING ORDER: ',event)
        order = await self._create_order(event.get('data'))
        order_id = f'{order.order_id}'
        order_data = ReadOnlyOrderSerializer(order).data
        
        # print(f'ORDER DATA: {order_data}')
        
        # Send business requests to all freelancers.
        await self.channel_layer.group_send(group='freelancers', message={
            'type': 'echo.message',
            'data': order_data
        })

        if order_id not in self.orders:
            self.orders.add(order_id)
            await self.channel_layer.group_add(
                group=order_id,
                channel=self.channel_name
            )
        
        await self.send_json({
            'type': 'create.order',
            'data': order_data
        })

    
    async def update_order(self, event):
        
        order, order_updated = await self._update_order(event.get('data'))

        order_id = f'{order.order_id}'
        order_data = ReadOnlyOrderSerializer(order).data

        # Send updates to the business that created this order.
        if order_updated:
            print('>>> ORDER UPDATED')
            await self.channel_layer.group_send(group=order_id, message={
                'type': 'echo.message',
                'data': order_data
            })

            if order_id not in self.orders:
                self.orders.add(order_id)
                await self.channel_layer.group_add(
                    group=order_id,
                    channel=self.channel_name
                )

            await self.send_json({
                'type': 'update.order',
                'data': order_data
            })

        else:
            data = {
                'order_id': order_id,
                'freelancer': order.freelancer.id,
                'status': 'STARTED'
            }
            await self.send_json({
                    'type': 'echo.message',
                    'data': data
                }
            )


    async def disconnect(self, code):
        channel_groups = [
            self.channel_layer.group_discard(
                group=order,
                channel=self.channel_name
            )
            for order in self.orders
        ]

        # Discard freelancer from 'freelancers' group.
        user_group = await self._get_user_group(self.scope['user'])
        if user_group == 'freelancer':
            channel_groups.append(self.channel_layer.group_discard(
                group='freelancers',
                channel=self.channel_name
            ))

        asyncio.gather(*channel_groups)
        self.orders.clear()

        await super().disconnect(code)
    @database_sync_to_async
    def _create_order(self, content):
        serializer = OrderSerializer(data=content)
        serializer.is_valid(raise_exception=True)
        order = serializer.create(serializer.validated_data)
        return order

    @database_sync_to_async
    def _get_orders(self, user):
        if not user.is_authenticated:
            raise Exception('User is not authenticated.')
        user_groups = user.groups.values_list('name', flat=True)
        
        if 'freelancer' in user_groups:
            # TODO: Fix this!!!
            orders = user.freelancer_orders.exclude(status=Order.ARCHIVED).only('order_id').values_list('order_id', flat=True)
            return orders
            # return []
        else:
            # TODO: Fix this!!!
            orders = user.business_orders.exclude(status=Order.ARCHIVED).only('order_id').values_list('order_id', flat=True)
            return orders
            # return []

    @database_sync_to_async
    def _get_user_group(self, user):
        if not user.is_authenticated:
            raise Exception('User is not authenticated.')
        return user.groups.first().name

    @database_sync_to_async
    def _update_order(self, content):
        instance = Order.objects.get(order_id=content.get('order_id'))
        replying_fl = content.get('freelancer')
        
        if instance.freelancer:
            accepted_fl = instance.freelancer.pk
        else:
            accepted_fl = replying_fl
        
        if str(accepted_fl) != str(replying_fl):
            # print(f'SKIPPING. Already allocated: accepted={accepted_fl} replying={replying_fl}')
            order = instance
            order_updated = False
        else:
            serializer = OrderSerializer(data=content)
            serializer.is_valid(raise_exception=True)
            order = serializer.update(instance, serializer.validated_data)
            order_updated = True

        return order, order_updated