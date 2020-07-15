import json
import sys
import urllib.parse
import requests

from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.conf import settings
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST


from .models import Card
from core.models import Employee



def enter_credit_card(request):
    context = {}
    return render(request, 'payments/enter_credit_card.html', context)


@login_required
def add_card(request):
    print('request.user',type(request.user))
    if request.method == 'POST':

        print('request data', request.POST)
        # stripe.api_key = settings.STRIPE_SECRET_KEY

        name = request.POST.get("name")
        card_number = request.POST.get("card-number")
        expiry_date = request.POST.get("expiry-date")
        # cvv = request.POST.get("cvv")
        exp_year = int(expiry_date[:4])
        exp_month = int(expiry_date[5:7])
        print(exp_month,exp_year)

        cvv = hash(request.POST.get("cvv"))
        if name and card_number and expiry_date and cvv:

            cards = Card.objects.filter(card_holder=request.user, status=True)
            for i in cards:
                if i.card_number == card_number:
                    messages.error(request,'card already exist, please try any other card ')
                    return redirect('/orders/add-card')
            else:

                try:
                    print("request.user",request.user)
                    card = Card.objects.create(
                        name=name,
                        card_number=card_number,
                        expiry_date=expiry_date,
                        cvv=cvv,
                        card_holder=request.user
                    )
                    card.save()
                    messages.success(request, "Card added")
                except Exception as ex:
                    print(ex)
                    messages.error(request, ex)
        else:
            messages.error('please do fill all the fields')

    return redirect(request.META['HTTP_REFERER'])
    # return render(request, "order/add-card.html", {'cards': cards})


@login_required
def remove_card(request):
    card_id = request.GET.get("card-id")
    try:
        card = Card.objects.get(id=card_id, card_holder=request.user)
        # card.status = False
        # card.save()
        card.delete()
        messages.success(request, "Card Removed")

    except Exception as e:
        messages.error(request, "Invalid user request")
    
    try:
        cards = Card.objects.filter(card_holder=request.user, status=True)
    except:
        cards = []
    # return render(request, "payments/add-card.html", {'cards': cards})
    return redirect(request.META['HTTP_REFERER'])

def charge(request):
    context = {}
    if request.method == 'POST':

        # customer = stripe.Customer.create(
        #         name = 'STAM',
        #         email = request.POST['stripeEmail']
        #         )

        # payment_method = stripe.PaymentMethod.create(
        #     type="card",
        #     card={
        #         "number": "4242424242424242",
        #         "exp_month": 3,
        #         "exp_year": 2021,
        #         "cvc": "314",
        #         },
        #     )

        # attach_pm = stripe.PaymentMethod.attach(
        #         payment_method.id,
        #         customer=customer.id,
        #         )

        # subscription = stripe.Subscription.create(
        #         customer=customer.id,
        #         items=[
        #         {
        #             # "plan": (SubscriptionPlan.objects.get(id = subscription_id)).plan_id
        #             # "plan": 'plan_Gs3SvCQ72PTfdx'  # WORKS
        #             "plan": 'plan_Gs4KkgRfrZ77ht' # NOT WORKING
        #         }
        #         ],
        #         default_payment_method=payment_method.id
        #     )
        
        pass

    return render(request, 'payments/charge.html')

'''
iCredit API:

https://testicredit.rivhit.co.il/API/PaymentPageRequest.svc/help

'''
# @csrf_exempt
# @require_POST
def ipn_listener(request):
    context = {}
    
    VERIFY_TEST = 'https://testicredit.rivhit.co.il/API/PaymentPageRequest.svc/Verify'
    VERIFY_PROD = 'https://icredit.rivhit.co.il/API/PaymentPageRequest.svc/Verify'

    SALEDETAIL_TEST = 'https://testicredit.rivhit.co.il/API/PaymentPageRequest.svc/SaleDetails'
    SALEDETAIL_PROD = 'https://icredit.rivhit.co.il/API/PaymentPageRequest.svc/SaleDetails'
    
    # Post back to iCredit for validation

    sale_params = {
	    "SaleId":"1627aea5-8e0a-4371-9022-9b504344e724",
	    "SalePrivateToken":"1627aea5-8e0a-4371-9022-9b504344e724"
    }

    sale_headers = {
            'content-type': 'application/x-www-form-urlencoded',
            'user-agent': 'Python-IPN-Verification-Script'
            }

    r = requests.post(SALEDETAIL_TEST, params=sale_params, headers=sale_headers, verify=True)
    if r.status_code == 200:
        context['sale_details'] = r.text


    # Verify request
    verify_headers = {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36'
        }


    payload = '{ \
        "GroupPrivateToken":"80283c37-1e16-4fe3-8977-203d5180d1fa", \
        "SaleId": "ec52aaf8-743f-4e89-a74b-6646e11610f6", \
        "TotalAmount": 150.90\
        }'
    
    try:
        vr = requests.post(VERIFY_PROD, data=payload, headers=verify_headers)
        print(f'VR: {vr.text}')
        context['verified'] = vr.text
    except Exception as e:
        print(f'ERROR: {e}')
        context['verified'] = e
    
    return render(request, 'payments/iCredit.html', context)
    # return HttpResponse(status=200)