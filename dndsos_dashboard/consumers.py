import asyncio
import json
from channels.db import database_sync_to_async
from channels.generic.websocket import AsyncJsonWebsocketConsumer, AsyncWebsocketConsumer

class OrderConsumer(AsyncJsonWebsocketConsumer):

    async def connect(self):
        user = self.scope['user']

        if user.is_anonymous:
            await self.close()
        else:
        # Join room group
            # await self.channel_layer.group_add(
            #     self.order_group_name,
            #     self.channel_name
            # )
            await self.accept()

        await self.channel_layer.group_add('created', self.channel_name)
        print('=========== 222 - Order Consumer ===============')
        print(f'New channel: {self.channel_name} was added to created group.')

        
        # self.order_id = self.scope['url_route']['kwargs']['order_id']
        # self.order_group_name = 'order_%s' % self.order_id

        print('Order ID:', self.order_id)
        print('User:', user)




    async def disconnect(self, close_code):
        # Leave room group
        await self.channel_layer.group_discard(
            self.order_group_name,
            self.channel_name
        )

    # Receive message from WebSocket
    async def receive_json(self, content, **kwargs):
        message_type = content.get('type')
        print('MESSAGE TYPE:', message_type)
        # Send message to room group
        await self.channel_layer.group_send(
            self.order_group_name,
            {
                'type': 'order_message',
                'message': content
            }
        )

    async def order_message(self, event):
        message = event['message']['message']
        print(f'MESSAGE: {message}')
        # Send message to WebSocket
        await self.send(text_data=json.dumps({
            'message': message
        }))
        # if message_type == 'create.order':
        #     await self.create_trip(content)

