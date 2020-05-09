from django.contrib.auth import get_user_model
from django.contrib.auth.models import Group
from django.test import Client
from channels.db import database_sync_to_async
from channels.layers import get_channel_layer
from channels.testing import WebsocketCommunicator
import pytest

from dnd_sos_project.routing import application
from dndsos_dashboard.models import Order


TEST_CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels.layers.InMemoryChannelLayer',
    },
}


@database_sync_to_async
def create_user(
    *,
    username='rider@example.com',
    password='pAssw0rd!',
    group='rider'
):
    # Create user.
    user = get_user_model().objects.create_user(
        username=username,
        password=password
    )

    # Create user group.
    user_group, _ = Group.objects.get_or_create(name=group)
    user.groups.add(user_group)
    user.save()
    return user


@pytest.mark.asyncio
@pytest.mark.django_db(transaction=True)
class TestWebsockets:

    async def test_authorized_user_can_connect(self, settings):
        # Use in-memory channel layers for testing.
        settings.CHANNEL_LAYERS = TEST_CHANNEL_LAYERS

        # Force authentication to get session ID.
        client = Order()
        user = await create_user()
        client.force_login(user=user)

        # Pass session ID in headers to authenticate.
        communicator = WebsocketCommunicator(
            application=application,
            path='/taxi/',
            headers=[(
                b'cookie',
                f'sessionid={client.cookies["sessionid"].value}'.encode('ascii')
            )]
        )
        connected, _ = await communicator.connect()
        assert connected is True
        await communicator.disconnect()