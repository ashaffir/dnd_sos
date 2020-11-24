from django.shortcuts import render
from core.models import User
def newsletter(request):
    pass

def newsletter_test(request):
    context = {}
    return render(request, 'newsletters_app/newsletter.html')


def unsubscribe(request, user_id):
    context = {}
    context['user'] = User.objects.get(pk=user_id)
    return render(request, 'newletters_app/unsubscribe.html', context)