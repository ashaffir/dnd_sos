from django.urls import path, re_path
from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
import chat.routing
import dndsos_dashboard.routing
from chat import consumers as chat_consumers
from dndsos_dashboard import consumers as dndsos_dashboard_consumers
# from notifier import consumers as notifier_consumers
from orders import consumers as orders_consumers

application = ProtocolTypeRouter({
    # (http->django views is added by default)
    'websocket': AuthMiddlewareStack(
        URLRouter([
            # chat.routing.websocket_urlpatterns,
            re_path(r'ws/chat/(?P<room_name>\w+)/$', chat_consumers.ChatConsumer),
            # re_path(r'ws/dashboard/order/(?P<order_id>\w+)/$', dndsos_dashboard_consumers.OrderConsumer),
            # re_path(r"ws/business_notifications/order/", notifier_consumers.BusinessConsumer),
            # re_path(r'ws/freelancer_notifications/order/(?P<order_id>\w+)/$', notifier_consumers.FreelancersConsumer),
            re_path(r'ws/orders/', orders_consumers.OrderConsumer),
        ])
    ),
})