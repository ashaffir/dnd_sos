import json
import sys
import urllib.parse
import requests
import logging

from django.shortcuts import render, redirect, HttpResponse
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.conf import settings
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST


from .models import Card
from core.models import Employee, Employer
from orders.models import Order

logger = logging.getLogger(__file__)

if settings.DEBUG_SERVER:
    CURRENT_DOMAIN = 'https://pickndell.com'
else: 
    CURRENT_DOMAIN = 'https://6b524698e0e9.ngrok.io'


HEADERS = {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36'
        }

'''
iCredit API:

https://testicredit.rivhit.co.il/API/PaymentPageRequest.svc/help

'''

def create_card_token(owner_id, due_date_yymm,card_number):
    '''
    Creating credit card token from an API request
    '''
    CREATE_TOKEN_TEST =  "https://testpci.rivhit.co.il/api/iCreditRestApiService.svc/CreateToken"    
    CREATE_TOKEN_PROD = " https://icredit.rivhit.co.il/api/iCreditRestApiService.svc/CreateToken"
    
    CREATE_TOKEN_URL = CREATE_TOKEN_TEST if settings.DEBUG else CREATE_TOKEN_PROD

    verify_headers = {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36'
        }

    credit_box_token = 'd27a5712-53a5-4543-bf3e-7a3c16164ff8' if settings.DEBUG else settings.CREDIT_BOX_TOKEN
    
    payload = '{ \
        "Id":"' + f"{owner_id}" + '", \
        "Creditbox": "' + f'{credit_box_token}' +  '", \
        "DueDateYYMM": "' + f'{due_date_yymm}' + '", \
        "CardNumber": "' + f'{card_number}' + '"\
        }'
    
    try:
        token_response = requests.post(CREATE_TOKEN_URL, data=payload, headers=verify_headers)
        print(f'PAYLOAD: {payload}')
        if not token_response.json()["ErrorMessage"]:
            return token_response.json()["Token"]
        else:
            return 'error'
    except Exception as e:
        print(f'ERROR CREDIT CART TOKEN: {e}')
 


def credit_card_form(request):
    '''
    Collection of a credit card information in the business profile
    '''
    context = {}
    b_id = request.user.pk
    GET_URL_TEST = 'https://testicredit.rivhit.co.il/API/PaymentPageRequest.svc/GetUrl'
    GET_URL_PROD = 'https://icredit.rivhit.co.il/API/PaymentPageRequest.svc/GetUrl'

    GET_URL = GET_URL_TEST if settings.DEBUG else GET_URL_PROD

    REDIRECT_URL = 'https://6b524698e0e9.ngrok.io/payments/success-card-collection/' if settings.DEBUG else settings.DOMAIN_PROD + '/payments/success-card-collection/'

    payload_prod = '{ \
        "GroupPrivateToken":"' + f'{settings.GROUP_PRIVATE_TOKEN}' + '", \
        "RedirectURL": "' + f'{str(REDIRECT_URL)}' + f'{str(b_id)}' + '", \
        "IPNURL": "https://6b524698e0e9.ngrok.io/payments/ipn-listener-card-info/", \
        "CustomerLastName":"test", \
        "EmailAddress":"alfred.shaffir@gmail.com", \
        "SaleType": 3, \
        "HideItemList":true, \
        "DocumentLanguage":"English", \
        "Items": [ \
            {\
            "UnitPrice": "10",\
            "Quantity": "1",\
            "Description": "collect only"\
            }\
            ],\
        "Custom1":' + f"{request.user.pk}" +'}'

    payload_test = '{ \
        "GroupPrivateToken":"7a81fc4b-1b18-4add-b730-d434a9f5120a", \
        "RedirectURL": "https://6b524698e0e9.ngrok.io/payments/success-card-collection/' + f'{str(b_id)}' + '", \
        "IPNURL": "https://6b524698e0e9.ngrok.io/payments/ipn-listener-card-info/", \
        "CustomerLastName":"test", \
        "EmailAddress":"alfred.shaffir@gmail.com", \
        "SaleType": 3, \
        "HideItemList":true, \
        "DocumentLanguage":"English", \
        "Items": [ \
            {\
            "UnitPrice": "10",\
            "Quantity": "1",\
            "Description": "collect only"\
            }\
            ],\
        "Custom1":' + f"{request.user.pk}" +'}'

    payload = payload_test if settings.DEBUG else payload_prod

    try:
        get_card_form = requests.post(GET_URL, data=payload, headers=HEADERS)
    except Exception as e:
        print(f'ERROR getting card information: {e}')
        context['error'] = e

    print(f">>> Credit card form: OUTBOUND: ***************{get_card_form.json()}****************")
    icredit_form_url = get_card_form.json()['URL']
    private_token = get_card_form.json()['PrivateSaleToken']
    public_token = get_card_form.json()['PublicSaleToken']

    return icredit_form_url,private_token, public_token

@csrf_exempt
@require_POST
def ipn_listener_card_info(request):
    print(f">>> IPN TOKEN : ***************{request.POST}****************")
    sale_id = request.POST.get('SaleId')
    group_private_token = request.POST.get('GroupPrivateToken')
    transaction_token = request.POST.get('TransactionToken')
    business_pk = request.POST.get('Custom1')
    request.session['business_pk'] = business_pk
    return HttpResponse(status=200)


def get_credit_card_information(token=None):
    '''
    Retreiving details about the credit card and store in DB
    '''
    context = {}
    GET_CARD_DETAILS_TEST = 'https://testpci.rivhit.co.il/api/RivhitRestAPIService.svc/GetTokenDetails'
    GET_CARD_DETAILS_PROD = 'https://pci.rivhit.co.il/api/RivhitRestAPIService.svc/GetTokenDetails'

    # credit_box_token = settings.CREDIT_BOX_TOKEN

    credit_box_token = 'd27a5712-53a5-4543-bf3e-7a3c16164ff8' if settings.DEBUG else settings.CREDIT_BOX_TOKEN
    token = '890387f6-1a66-44be-9181-4f72d78ce30a' if settings.DEBUG else token
    
    payload = '{ \
        "CreditboxToken":"' + f'{credit_box_token}' + '", \
        "Token": " ' + f'{token}' + '  " \
        }'
    
    try:
        card_info = requests.post(GET_CARD_DETAILS_TEST, data=payload, headers=HEADERS)
        print(f"CARD INFO: ***************{card_info.json()}****************")
        logger.info(f"CARD INFO: ***************{card_info.json()}****************")
        return card_info.json()
    except Exception as e:
        print(f'ERROR retreiving credit card information: {e}')
        context['error'] = e
        return e


def lock_delivery_price(order):
    '''
    When freelanceer accepts a delivery order, the price for that delivery is locked on the 
    businesse's credit card (not charged until delivery)
    '''
    context = {}
    # order = Order.objects.get(pk=order_id)
    order_price = order.price

    b_id = order.business.business.pk
    b_credit_card_token = order.business.business.credit_card_token


    SALE_CHARGE_TEST = 'https://testicredit.rivhit.co.il/API/PaymentPageRequest.svc/SaleChargeToken'
    SALE_CHARGE_PROD = 'https://icredit.rivhit.co.il/API/PaymentPageRequest.svc/SaleChargeToken'

    # payload = '{ \
    #         "GroupPrivateToken": "a1408bfc-18da-49dc-aa77-d65870f7943e", \
    #         "CreditcardToken": "' + f'{b_credit_card_token}' + '", \
    #         "IPNURL": "https://6b524698e0e9.ngrok.io/payments/ipn-listener-lock-price/", \
    #         "CustomerLastName": "none", \
    #         "CustomerFirstName": "none", \
    #         "Address": "none", \
    #         "City": "none", \
    #         "EmailAddress": "alfred.shaffir@gmail.com", \
    #         "NumberOfPayments": 1, \
    #         "SaleType": 2, \
    #         "Items": [ \
    #             { \
    #             "UnitPrice": "' + f'{order_price}' + '", \
    #             "Quantity": "1", \
    #             "Description": "delivery" \
    #             } \
    #         ] \
    #     }'

    payload = '{ \
            "GroupPrivateToken": "a1408bfc-18da-49dc-aa77-d65870f7943e", \
            "CreditcardToken": "ba56dcb2-1f19-4627-b203-4a77a1939f4f", \
            "IPNURL": "https://6b524698e0e9.ngrok.io/payments/ipn-listener-lock-price/", \
            "CustomerLastName": "none", \
            "CustomerFirstName": "none", \
            "Address": "none", \
            "City": "none", \
            "EmailAddress": "alfred.shaffir@gmail.com", \
            "NumberOfPayments": 1, \
            "SaleType": 2, \
            "Items": [ \
                { \
                "UnitPrice": "' + f'{order_price}' + '", \
                "Quantity": "1", \
                "Description": "delivery" \
                } \
            ] \
        }'

    # print(f'SALE CHARGE PAYLOAD: \n {payload} ')

    try:
        sales_charge = requests.post(SALE_CHARGE_TEST, data=payload, headers=HEADERS)
        print(f'SALES CHARGE RESPONSE: \n {sales_charge.json()}')
        logger.info(f'PAYMENTS: SALES CHARGE RESPONSE: \n {sales_charge.json()}')
        
    except Exception as e:
        print(f'ERROR locking order price: {e}')
        context['error'] = e

    private_sale_token = sales_charge.json()['PrivateSaleToken']

    print(f">>> OUTBOUND LOCK. TOKEN:{sales_charge.json()['PrivateSaleToken']}  PRICE: {order_price} ****************")    

    return private_sale_token

@csrf_exempt
@require_POST
def ipn_listener_lock_price(request):
    print(f">>> IPN LOCK PRICE TX ID: ***************{request.POST.get('CustomerTransactionId')}****************")
    transaction_auth_num = request.POST.get('TransactionAuthNum')
    customer_transaction_id = request.POST.get('CustomerTransactionId')

    return HttpResponse(status=200)


def complete_charge(private_sale_token):
    '''
    Completing the waiting transaction once the order is delivered/confirmed-delivered
    '''
    CHARGE_PENDING_SALE_TEST = 'https://testicredit.rivhit.co.il/API/PaymentPageRequest.svc/ChargePendingSale'
    CHARGE_PENDING_SALE_PROD = 'https://icredit.rivhit.co.il/API/PaymentPageRequest.svc/ChargePendingSale'

    payload = '{"SalePrivateToken":"' + f'{private_sale_token}' + '"}'
    
    try:
        complete_charge = requests.post(CHARGE_PENDING_SALE_TEST, data=payload, headers=HEADERS)
        print(f'>>>>>>>>>>>>> COMPLETE: {complete_charge.json()}')
        return complete_charge.json()
    except Exception as e:
        print(f'ERROR completing the charge: {e}')
        context['error'] = e
        return e



def success_card_collection(request, b_id):
    context = {}
    business = Employer.objects.get(pk=b_id)
    business.credit_card_token = request.GET.get("Token")
    business.save()
    return render(request, 'payments/success-card-collection.html', context)

def failed_card_collection(request):
    context = {}
    return render(request, 'payments/failed-card-collection.html', context)


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
        pass

    return render(request, 'payments/charge.html')

def ipn_listener_test(request):
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