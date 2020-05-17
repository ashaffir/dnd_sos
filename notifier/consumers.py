import asyncio
import json

from channels.generic.websocket import AsyncJsonWebsocketConsumer
from channels.exceptions import DenyConnection
from channels.db import database_sync_to_async

from django.contrib.auth.models import AnonymousUser

from dndsos_dashboard.models import FreelancerProfile
from orders.models import Order
from core.models import Employee, Employer

class FreelancersConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.order_id = self.scope['url_route']['kwargs']['order_id']
        self.order_group_name = f'Order_{self.id}'

        if self.scope['user'] == AnonymousUser():
           raise DenyConnection("Invalid User")

        channel_groups = []       

        # Add all freelancers in the order city to the Order group.
        order_group = await self._get_freelancers_group()
        # print(f'FLS: {order_group}')
        
        channel_groups.append(self.channel_layer.group_add(
            group=self.order_group_name,
            channel=self.channel_name
        ))

        #     self.trips = set([
        #         str(trip_id) for trip_id in await self._get_trips(self.scope['user'])
        #     ])
        #     for trip in self.trips:
        #         channel_groups.append(self.channel_layer.group_add(trip, self.channel_name))
        #     asyncio.gather(*channel_groups)
        
    #     await self.channel_layer.group_add(
    #         # 'created',
    #        self.order_group_name,
    #        self.channel_name
    #    )

        # await self.channel_layer.group_add('created', self.channel_name)
        print(f'=========== 2 - Freelancers Consumer ===============')
        print(f'New channel: {self.channel_name} was added to {self.order_group_name} group.')

        await self.accept()
        

    async def disconnect(self):
        await self.channel_layer.group_discard(
            self.order_group_name,
            self.channel_name
            )
        print(f'Removed channel {self.channel_name} from created group.')

    # The name of this function is edrived from the automated process of generating the name from the signals type order.created
    # This method will generate and broadcast the alert
    async def order_created(self, event):
        await self.send_json(event)
        print(f'Got message: {event} at group: {self.channel_name}')

    @database_sync_to_async
    def _get_freelancers_group(self):
        # if not user.is_authenticated:
        #     raise Exception('User is not authenticated.')
        # else:
        city = Order.objects.get(order_id='t5').order_city
        relevant_freelancers = Employee.objects.filter(city=city)
        
        return relevant_freelancers

class BusinessConsumer(AsyncJsonWebsocketConsumer):

    async def connect(self):
        await self.accept()
        await self.channel_layer.group_add("gossip", self.channel_name)
        print('=========== 2 - Business Consumer ===============')
        print(f"Added {self.channel_name} channel to gossip")

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard("gossip", self.channel_name)
        print(f"Removed {self.channel_name} channel to gossip")

    async def user_gossip(self, event):
        await self.send_json(event)
        print(f"Got message {event} at {self.channel_name}")