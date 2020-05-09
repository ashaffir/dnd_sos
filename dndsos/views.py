import json
from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.utils.safestring import mark_safe

def home(request):
    context = {}
    return render(request, 'dndsos/index.html')


# reference: https://github.com/shahriarshm/websocket-with-django-and-channels/tree/master/08-Create-Simple-Chat-Application
def index_test(request):
    context = {}
    return render(request, 'dndsos/index_test.html')

@login_required
def room(request, username):
    context = {}
    return render(request, 'dndsos/room.html', {'username_json': mark_safe(json.dumps(username))})