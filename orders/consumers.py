import asyncio
from asgiref.sync import async_to_sync
from channels.db import database_sync_to_async
from channels.generic.websocket import AsyncJsonWebsocketConsumer
from channels.layers import get_channel_layer

from orders.models import Order
from orders.serializers import ReadOnlyOrderSerializer, OrderSerializer
from core.models import User

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

            # Add a channel name to to DB for direct communications
            user = User.objects.get(pk=user.pk)
            user.channel_name = self.channel_name
            user.save()

            await self.accept()

    async def receive_json(self, content, **kwargs):
        message_type = content.get('type')
        if message_type == 'create.order':
            await self.create_order(content)
        elif message_type == 'update.order':  
            await self.update_order(content)
        elif message_type == 'direct.message':  
            await self.direct_message(content)


    # Sending JSON messages 
    async def echo_message(self, event):
        print(f'>>> ECHO 1: {event}')
        await self.send_json(event)

    # Sending direct text messages 
    async def text_message(self, event):
        print(f'>>> ECHO 2: {event}')
        await self.send(event)

    async def direct_message(self, message):
        message_data = message.get('data')
        print(f'DIRECT MESSAGE: {message_data}')
        channel_layer = get_channel_layer()

        if message_data.get('requested_freelancer'):
            freelancer_id = message_data.get('requested_freelancer')
            freelancer = User.objects.get(pk=freelancer_id)
            freelancer_channel = freelancer.channel_name

            order_id = message_data.get('order_id')
            business = message_data.get('business')
            order_id = message_data.get('order_id')

            data = {
                    'order_id': order_id,
                    'business': business,
                    'title': 'Direct Invitation'
                }

            await channel_layer.send(freelancer_channel, message={
                "type": "echo.message",
                "data": data
                })


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

        if order_updated:
    
            # Order Re-Requested. Brodcast again to ALL freelancers
            if event.get('data')['event'] == 'Request Freelancer':
                print(f'RE-REQUESTED: {order_data}')
                data = {
                    'order_id': order_id,
                    'business': order.business.id,
                    'pick_up_address': order.pick_up_address,
                    'drop_off_address': order.drop_off_address,
                    'notes': order.notes,
                    'status': 'RE_REQUESTED'
                }
    
                await self.channel_layer.group_send(group='freelancers', message={
                    'type': 'echo.message',
                    'data': data
                })

            elif event.get('data')['event'] == 'Direct Invitation':
                print('DIRECT INVITE UPDATED')
                pass
            else:            
            # Send updates to the business that created this order.
                print(f'UPDATED: {order_data}')
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
            # Order Re-Requested
            # if event.get('data')['event'] == 'Request Freelancer':
            #     data = {
            #         'order_id': order_id,
            #         'business': order.business.id,
            #         'pick_up_address': order.pick_up_address,
            #         'drop_off_address': order.drop_off_address,
            #         'notes': order.notes,
            #         'status': 'REQUESTED'
            #     }
    
            #     await self.channel_layer.group_send(group='freelancers', message={
            #         'type': 'echo.message',
            #         'data': data
            #     })
            
            # else:
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



    # async def order_accepted(self, event):
    #     print('>>> ORDER ACCEPTED: ',event)
    #     order, order_updated = await self._update_order(event.get('data'))
    #     order_id = f'{order.order_id}'
    #     order_data = ReadOnlyOrderSerializer(order).data
        
    #     await self.send_json({
    #         'type': 'echo.message',
    #         'data': order_data
    #     })

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
        event = content.get('event')
        order_instance = Order.objects.get(order_id=content.get('order_id'))
        current_status = order_instance.status
        replying_fl = content.get('freelancer')
        updating_business = content.get('business')
        next_status = content.get('status')
        
        print(f"UPDATE CONTENT: ***************{content}****************")

        if replying_fl:
            if event == 'Order Accepted':
                if order_instance.freelancer:  # Freelancer already allocated
                    accepted_fl = order_instance.freelancer.pk
                else:
                    accepted_fl = replying_fl
                
                # Prevent other freelancers to accept after first accept
                if str(accepted_fl) != str(replying_fl):
                    order = order_instance
                    order_updated = False
                else: 
                    serializer = OrderSerializer(data=content)
                    serializer.is_valid(raise_exception=True)
                    order = serializer.update(order_instance, serializer.validated_data)
                    order_updated = True
            elif event == 'Order Canceled':
                print('CANCELED!!!!')
                content['freelancer'] = None
                serializer = OrderSerializer(data=content)
                serializer.is_valid(raise_exception=True)
                order = serializer.update(order_instance, serializer.validated_data)
                order_updated = True
            elif event == 'Order Delivered':
                print('DELIVERED!!!!')
                content['status'] = 'COMPLETED'

                if not order_instance.selected_freelancers:
                    order_instance.selected_freelancers = [replying_fl]
                else:
                    order_instance.selected_freelancers.append(replying_fl)

                order_updated = True
            elif event == 'Direct Invitation':
                print(f'======> DIRECT INVITATION: {replying_fl}')
                if not order_instance.selected_freelancers:
                    order_instance.selected_freelancers = [replying_fl]
                else:
                    order_instance.selected_freelancers.append(replying_fl)
                
                order_instance.save()
                order = order_instance
                order_updated = True

        # Business updates
        if updating_business:
            print('======> PO 2 ')
            if event == 'Request Freelancer':
                print('======> FREELANCER REQUESTED ')  
                serializer = OrderSerializer(data=content)
                serializer.is_valid(raise_exception=True)
                order = serializer.update(order_instance, serializer.validated_data)
                order_updated = True
            elif event == 'Order Canceled':
                print('======> ORDER CANCELED ')  
                serializer = OrderSerializer(data=content)
                serializer.is_valid(raise_exception=True)
                order = serializer.update(order_instance, serializer.validated_data)
                order_updated = True
            else:
                print('======> PO 3 ')
                serializer = OrderSerializer(data=content)
                serializer.is_valid(raise_exception=True)
                order = serializer.update(order_instance, serializer.validated_data)
                order_updated = True


        return order, order_updated
    