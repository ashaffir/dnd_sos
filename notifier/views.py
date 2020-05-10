from django.shortcuts import render

def notifier(request):
    print('=========== 3 ===============')

    return render(request, 'notifier/notifier.html')
