import platform
import asyncio
import os
import logging
from geopy.geocoders import Nominatim
from geopy.distance import geodesic, distance
from datetime import datetime

from asgiref.sync import async_to_sync
from channels.db import database_sync_to_async
from channels.generic.websocket import AsyncJsonWebsocketConsumer
from channels.layers import get_channel_layer

from django.contrib.gis.geos import Point, fromstr
from django.conf import settings

from orders.models import Order
from orders.serializers import ReadOnlyOrderSerializer, OrderSerializer
from core.models import User, Employer, Employee

from geo.models import UserLocation

LOG_FORMAT = '%(levelname)s %(asctime)s - %(message)s'
logging.basicConfig(filename=os.path.join(settings.BASE_DIR,'logs/consumers.log'),level=logging.INFO,format=LOG_FORMAT, filemode='w')
logger = logging.getLogger()

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
        elif message_type == 'cancel.alert':
            await self.cancel_alert(content)
        elif message_type == 'user.location':
            await self.user_location(content)

    # Sending JSON messages 
    async def echo_message(self, event):
        print(f'>>> ECHO 1: {event}')
        await self.send_json(event)

    # Sending direct text messages 
    async def text_message(self, event):
        print(f'>>> ECHO 2: {event}')
        await self.send(event)


    async def cancel_alert(self, event):
        print(f'Cancel Alert!! {event}')
        data = event.get('data')
        order_id = data.get('order_id')
        order = Order.objects.get(order_id=order_id)
        order.new_message = ''
        order.save()


    async def direct_message(self, message):
        message_data = message.get('data')
        print(f'DIRECT MESSAGE: {message_data}')
        channel_layer = get_channel_layer()

        # Freelancer direct request 
        if message_data.get('requested_freelancer'):
            freelancer_id = message_data.get('requested_freelancer')
            freelancer = User.objects.get(pk=freelancer_id)
            
            # TODO: Add solution to situation where the user is not conneted or does not have a channel_name yet (did)
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
       
        # Chat message directly to the freelancer
        elif message_data.get('chat_message'):
            chat_message = message_data.get("chat_message")
            order_id = message_data.get('order_id')
            order = Order.objects.get(order_id=order_id)

            if not order.new_message:
                order.new_message = {
                    'business': '',
                    'freelancer':''
                }

            if message_data.get('new_message') == 'to_business':
                order.new_message['business'] = True
            elif message_data.get('new_message') == 'to_freelancer':
                order.new_message['freelancer'] = True
            elif message_data.get('new_message') == 'clear_business':
                order.new_message['business'] = False
            elif message_data.get('new_message') == 'clear_freelancer':
                order.new_message['freelancer'] = False
            else:
                print('WRONG MESSAGE ALERT SEETUP!!! (consumers.py/b-messages/f-messages)')

            if not order.chat:
                order.chat = {
                    'messages': []
                }

            now = datetime.now()

            order.chat['freelancer'] = order.freelancer.pk

            chat_message = {
                'time': now.ctime(),
                'message': chat_message,
                'order_id':order_id
            }

            if message_data.get('new_message') == 'clear_freelancer' or message_data.get('new_message') == 'clear_business':
                pass
            else:
                order.chat['messages'].append(chat_message) 
            
            order.save()

            print(f'CHAT MESSAGE: {chat_message}')
            await self.channel_layer.group_send(group=order_id, message={
                'type': 'echo.message',
                'data': chat_message
                })



    async def create_order(self, event):
        
        print('>>> CREATING ORDER: ',event)
        order = await self._create_order(event.get('data'))
        order_id = f'{order.order_id}'
        order_data = ReadOnlyOrderSerializer(order).data
        
        # Setting up inital data for messages
        order = Order.objects.get(order_id = order_id)
        order.chat = {
            'messages': []
        }
        order.new_message = {
            'freelancer':'',
            'business':''
        }
        order.save()
        # print(f'ORDER DATA: {order_data}')
        
        # Send business requests to all freelancers if broadcast was requested.
        if event.get('data')['select_freelancers'] == 'all':
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

            elif event.get('data')['event'] == 'Order Settled':
                print('Order Settled')
                pass
            elif event.get('data')['event'] == 'Order Canceled':
                print('Order Canceled')
                if order.freelancer:
                    active_freelancer = order.freelancer.pk
                else:
                    active_freelancer = None
                
                data = {
                    'order_id': order_id,
                    'business': order.business.pk,
                    'freelancer': active_freelancer,
                    'drop_off_address': order.drop_off_address,
                    'business_name': order.business.employer.business_name,
                    'created': str(order.created),
                    'status': 'ARCHIVED'
                }
                await self.channel_layer.group_send(group='freelancers', message={
                    'type': 'echo.message',
                    'data': data
                })

                await self.channel_layer.group_send(group=order_id, message={
                    'type': 'echo.message',
                    'data': data
                })

            elif event.get('data')['event'] == 'Freelancer Canceled':
                print(f'Freelancer Canceled. Order: {order.order_id}')
                data = {
                    'order_id': order_id,
                    'status': 'REJECTED'
                }
                await self.channel_layer.group_send(group=order_id, message={
                    'type': 'echo.message',
                    'data': data
                })
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
        # Adding GEO location info before creating the order
        geolocator = Nominatim(user_agent="dndsos", timeout=3)
        drop_off_address = content.get('drop_off_address')
        location = geolocator.geocode(drop_off_address)
        try:
            order_location = Point(location.latitude,location.longitude)
            order_coords = (location.latitude,location.longitude)  # The cords for geopy are reversed to GeoDjango Point.
        except:
            try:
                drop_off_address = content.get('drop_off_address').split(',')[1]

                                # Checking OS
                if platform.system() == 'Darwin':
                    order_location = Point(location.latitude,location.longitude)
                else:
                    order_location = Point(location.longitude, location.latitude)
                
                order_coords = (location.latitude,location.longitude)
            except Exception as e:
                print(f'Failed getting the location for {drop_off_address}')
                order_location = None
                order_coords = None

        content['order_location'] = order_location

        # Calculate distance between drop off address the business
        business = Employer.objects.get(pk=content.get('business'))
        business_address = business.building_number + ' ' + business.street + ',' + business.city
        
        try:
            business_location = geolocator.geocode(business_address)
            business_coords = (business_location.latitude, business_location.longitude)
            order_to_business_distance = distance(business_coords, order_coords).km
        except Exception as e:
            logger.error(f'''Fail getting business location. ERROR: {e}
                            business address: {business_address}
                            business location: {business_location}
                        ''')
            order_to_business_distance = 1000

        content['distance_to_business'] = round(order_to_business_distance,2)

        if not business.location:
            business.location = Point(business_location.longitude,business_location.latitude, srid=4326)
            business.save()
        else:
            pass


        # Creating the new order
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
            elif event == 'Freelancer Canceled':
                print('CANCELED!!!!')
                content['freelancer'] = None
                serializer = OrderSerializer(data=content)
                serializer.is_valid(raise_exception=True)
                order = serializer.update(order_instance, serializer.validated_data)
                order_updated = True
            elif event == 'Order Delivered':
                print('DELIVERED!!!!')
                content['status'] = 'COMPLETED'
                serializer = OrderSerializer(data=content)
                serializer.is_valid(raise_exception=True)
                order = serializer.update(order_instance, serializer.validated_data)
                order_updated = True

                # Updating the involved parties relationships
                freelancer = User.objects.get(pk=order_instance.freelancer.pk)
                business = User.objects.get(pk=order_instance.business.pk)

                if not freelancer.relationships:
                    freelancer.relationships = {'businesses':[business.pk]}
                else:
                    businesses_list = freelancer.relationships['businesses']
                    businesses_list.append(business.pk)
                    freelancer.relationships['businesses'] = list(set(businesses_list))

                if not business.relationships:
                    business.relationships = {'freelancers':[freelancer.pk]}
                else:
                    freelancers_list = business.relationships['freelancers']
                    freelancers_list.append(freelancer.pk)
                    business.relationships['freelancers'] = list(set(freelancers_list))

                
                freelancer.save()
                business.save()


            elif event == 'Direct Invitation':
                print(f'======> DIRECT INVITATION: {replying_fl}')
                if not order_instance.selected_freelancers:
                    order_instance.selected_freelancers = [replying_fl]
                else:
                    if replying_fl not in order_instance.selected_freelancers:
                        order_instance.selected_freelancers.append(replying_fl)
                
                order_instance.save()
                order = order_instance
                order_updated = True

            elif event == 'Order Settled':
                print(f'======> Order Settled: {replying_fl}')
                order_instance.status = 'SETTLED'

                order_instance.save()
                order = order_instance
                order_updated = True


        # Business updates
        if updating_business:
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
                serializer = OrderSerializer(data=content)
                serializer.is_valid(raise_exception=True)
                order = serializer.update(order_instance, serializer.validated_data)
                order_updated = True


        return order, order_updated


    # Dynamically obtain the location of users
    # @database_sync_to_async
    # def user_location(self, content):
    #     data = content.get('data')
    #     event = data['event']
    #     user_id = data['user_id']
    #     lat = data['lat']
    #     lon = data['lon']

    #     freelancer = Employee.objects.get(pk=user_id)
    #     freelancer.location = Point(lon,lat, srid=4326)
    #     freelancer.lon = lon
    #     freelancer.lat = lat
    #     freelancer.save()
    #     print(f'>>>>  F: {user_id} locaiton saved ')