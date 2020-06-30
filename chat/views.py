from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt

def index(request):
    return render(request, 'chat/index.html')


# @csrf_exempt
def room(request, room_name):
    context = {}

    user_id = request.POST.get("user_id")
    lat = request.POST.get("lat")
    lon = request.POST.get("lon")
    print(f'USER ID: {user_id}')
    print(f'USER LAT: {lat}')
    print(f'USER LON: {lon}')
    
    context['oid'] = user_id
    context['room_name'] = room_name

    return render(request, 'chat/room.html', context)

def notifier(request):
    return render(request, 'chat/notifier.html')