import asyncio
from channels.generic.websocket import AsyncJsonWebsocketConsumer

class OrdersConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        await self.accept()
        await self.channel_layer.group_add('created', self.channel_name)
        print('=========== 2 ===============')
        print(f'New channel: {self.channel_name} was added to created group.')

    async def disconnect(self):
        await self.channel_layer.group_discard('created', self.channel_name)
        print(f'Removed channel {self.channel_name} from created group.')

    
    # The name of this function is edrived from the automated process of generating the name from the signals type order.created
    # This method will generate and broadcast the alert
    async def order_created(self, event):
        await self.send_json(event) 
        print(f'Got message: {event} at group: {self.channel_name}')

class NoseyConsumer(AsyncJsonWebsocketConsumer):

    async def connect(self):
        await self.accept()
        await self.channel_layer.group_add("gossip", self.channel_name)
        print(f"Added {self.channel_name} channel to gossip")

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard("gossip", self.channel_name)
        print(f"Removed {self.channel_name} channel to gossip")

    async def user_gossip(self, event):
        await self.send_json(event)
        print(f"Got message {event} at {self.channel_name}")