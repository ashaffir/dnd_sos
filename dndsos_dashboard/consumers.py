import json
from channels.generic.websocket import AsyncJsonWebsocketConsumer, AsyncWebsocketConsumer

class OrderConsumer(AsyncWebsocketConsumer):

    async def websocket_connect(self, event):
        user = self.scope['user']
        
        self.order_id = self.scope['url_route']['kwargs']['order_id']
        self.order_group_name = 'order_%s' % self.order_id
        
        print('Order ID:', self.order_id)
        print('User:', user)
        print('Event:', event)

        if user.is_anonymous:
            await self.close()
        else:
            await self.accept()

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