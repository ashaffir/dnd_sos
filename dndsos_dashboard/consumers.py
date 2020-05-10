import json
from channels.db import database_sync_to_async
from channels.generic.websocket import AsyncJsonWebsocketConsumer, AsyncWebsocketConsumer

class OrderConsumer(AsyncJsonWebsocketConsumer):

    async def connect(self):
        user = self.scope['user']
        
        self.order_id = self.scope['url_route']['kwargs']['order_id']
        self.order_group_name = 'order_%s' % self.order_id

        print('Order ID:', self.order_id)
        print('User:', user)

        if user.is_anonymous:
            await self.close()
        else:
        # Join room group
            await self.channel_layer.group_add(
                self.order_group_name,
                self.channel_name
            )
            await self.accept()


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

    # new
    # async def create_trip(self, event):
    #     print('EVENT:', event)
    #     # order = await self._create_order(event.get('order'))
    #     # print('ORDER', order)
    #     order_data = event.data
    #     print('ORDER DATA', order_data)
    #     await self.send_json({
    #         'type': 'create.order',
    #         'data': order_data
    #     })

    # new
    # @database_sync_to_async
    # def _create_trip(self, content):
    #     print('CONTENT DATA:', content)
    #     order = content.get('order')
    #     print('ORDER DATA:', order)
    #     # serializer = TripSerializer(data=content)
    #     # serializer.is_valid(raise_exception=True)
    #     # trip = serializer.create(serializer.validated_data)
    #     return order





    #     self.order_id = self.scope['url_route']['kwargs']['order_id']
    #     self.order_group_name = 'order_%s' % self.order_id

    #     # Join order group
    #     await self.channel_layer.group_add(
    #         self.order_group_name,
    #         self.channel_name
    #     )

    #     await self.accept()
    # async def disconnect(self, close_code):
    #     # Leave order group
    #     await self.channel_layer.group_discard(
    #         self.order_group_name,
    #         self.channel_name
    #     )

    # # Receive message from WebSocket
    # async def receive(self, text_data):
    #     text_data_json = json.loads(text_data)
    #     message = text_data_json['message']

    #     # Send message to room group
    #     await self.channel_layer.group_send(
    #         self.room_group_name,
    #         {
    #             'type': 'chat_message',
    #             'message': message
    #         }
    #     )

    # # Receive message from room group
    # async def chat_message(self, event):
    #     message = event['message']

    #     # Send message to WebSocket
    #     await self.send(text_data=json.dumps({
    #         'message': message
    #     }))