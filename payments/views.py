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
from django.utils.translation import gettext

from .models import Card
from core.models import Employee, Employer
from orders.models import Order

logger = logging.getLogger(__file__)

if settings.DEBUG:
    CURRENT_DOMAIN = 'https://90b5f03e3570.ngrok.io'
else: 
    CURRENT_DOMAIN = 'https://pickndell.com'


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
    CREATE_TOKEN_TEST = "https://testpci.rivhit.co.il/api/iCreditRestApiService.svc/CreateToken"
    CREATE_TOKEN_PROD = " https://pci.rivhit.co.il/Api/iCreditRestApiService.svc/CreateToken"
    
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
        print(f'CC TOKEN REQUEST URL: {CREATE_TOKEN_URL}')
        print(f'CC TOKEN REQUEST PAYLOAD: {payload}')
        if not token_response.json()["ErrorMessage"]:
            return token_response.json()["Token"]
        else:
            print(f'ERROR GENERATING CC TOKEN: {token_response}')
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

    REDIRECT_URL = f'{CURRENT_DOMAIN}/payments/success-card-collection/'

    payload_prod = '{ \
        "GroupPrivateToken":"' + f'{settings.GROUP_PRIVATE_TOKEN}' + '", \
        "RedirectURL": "' + f'{str(REDIRECT_URL)}' + f'{str(b_id)}' + '", \
        "IPNURL": "' + CURRENT_DOMAIN + '/payments/ipn-listener-card-info/", \
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
        "RedirectURL": "' + CURRENT_DOMAIN + '/payments/success-card-collection/' + f'{str(b_id)}' + '", \
        "IPNURL": "' + CURRENT_DOMAIN + '/payments/ipn-listener-card-info/", \
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

    print(f'CC FORM PAYLOAD: \n {payload}')

    try:
        get_card_form = requests.post(GET_URL, data=payload, headers=HEADERS)
    except Exception as e:
        print(f'ERROR getting card information: {e}')
        context['error'] = e

    print(f">>> Credit card form: OUTBOUND: ***************{get_card_form.json()}****************")
    icredit_form_url = get_card_form.json()['URL']
    print(f'URL: {icredit_form_url}')
    private_token = get_card_form.json()['PrivateSaleToken']
    print(f'PRIVATE TOKEN: {private_token}')
    public_token = get_card_form.json()['PublicSaleToken']
    print(f'PUBLIC TOKEN: {public_token}')

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

    GET_CARD_DETAILS_URL =  GET_CARD_DETAILS_TEST if settings.DEBUG else GET_CARD_DETAILS_PROD   

    # credit_box_token = settings.CREDIT_BOX_TOKEN

    credit_box_token = 'd27a5712-53a5-4543-bf3e-7a3c16164ff8' if settings.DEBUG else settings.CREDIT_BOX_TOKEN
    token = '890387f6-1a66-44be-9181-4f72d78ce30a' if settings.DEBUG else token
    
    payload = '{ \
        "CreditboxToken":"' + f'{credit_box_token}' + '", \
        "Token": "' + f'{token}' + '" \
        }'
    
    try:
        print(f'GET_CARD_DETAILS_URL: {GET_CARD_DETAILS_URL}')
        print(f'payload: {payload}')
        logger.info(f'CARD DETAILS PAYLOAD: {payload}  URL: {GET_CARD_DETAILS_URL}')
        card_info = requests.post(GET_CARD_DETAILS_URL, data=payload, headers=HEADERS)
        print(f"CARD INFO: ***************{card_info.json()}****************")
        logger.info(f"CARD INFO: ***************{card_info.json()}****************")
        return card_info.json()
    except Exception as e:
        print(f'ERROR retreiving credit card information: {e}')
        context['error'] = e
        return e

def lock_price_cc_check(cc_token):
    
    SALE_CHARGE_TEST = 'https://testicredit.rivhit.co.il/API/PaymentPageRequest.svc/SaleChargeToken'
    SALE_CHARGE_PROD = 'https://icredit.rivhit.co.il/API/PaymentPageRequest.svc/SaleChargeToken'
    SALE_CHARGE_URL = SALE_CHARGE_TEST if settings.DEBUG else SALE_CHARGE_PROD

    CC_TEST_TOKEN = "ba56dcb2-1f19-4627-b203-4a77a1939f4f"

    CC_TOKEN = CC_TEST_TOKEN if settings.DEBUG else cc_token
    print(f'CC_TOKEN: {CC_TOKEN}')

    GROUP_PRIVATE_TOKEN = "a1408bfc-18da-49dc-aa77-d65870f7943e" if settings.DEBUG else settings.GROUP_PRIVATE_TOKEN

    payload = '{ \
            "GroupPrivateToken": "' + GROUP_PRIVATE_TOKEN + '", \
            "CreditcardToken": "' + CC_TOKEN + '", \
            "IPNURL": "' + CURRENT_DOMAIN + '/payments/ipn-listener-lock-price/", \
            "CustomerLastName": "none", \
            "CustomerFirstName": "none", \
            "Address": "none", \
            "City": "none", \
            "EmailAddress": "alfred.shaffir@gmail.com", \
            "NumberOfPayments": 1, \
            "SaleType": 2, \
            "Items": [ \
                { \
                "UnitPrice": "1", \
                "Quantity": "1", \
                "Description": "cc validation" \
                } \
            ] \
        }'

    # print(f'SALE CHARGE PAYLOAD: \n {payload} ')

    try:
        sales_charge = requests.post(SALE_CHARGE_URL, data=payload, headers=HEADERS)
        print(f'CC VALIDATION SALES CHARGE RESPONSE: \n {sales_charge.json()}')
        logger.info(f'PAYMENTS: CC VALIDATION SALES CHARGE RESPONSE: \n {sales_charge.json()}')
        
    except Exception as e:
        print(f'ERROR cc validation: {e}')
        context['error'] = e

    cc_valprivate_sale_token = sales_charge.json()['PrivateSaleToken']

    print(f">>> CC VALIDATION LOCK. TOKEN:{sales_charge.json()['PrivateSaleToken']}****************")    

    cc_val = (cc_valprivate_sale_token != "00000000-0000-0000-0000-000000000000")

    return cc_val


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
    SALE_CHARGE_URL = SALE_CHARGE_TEST if settings.DEBUG else SALE_CHARGE_PROD

    CC_TEST_TOKEN = "ba56dcb2-1f19-4627-b203-4a77a1939f4f"

    CC_TOKEN = CC_TEST_TOKEN if settings.DEBUG else b_credit_card_token
    
    # print(f'CC_TOKEN: {CC_TOKEN}')
    # logger.info(f'CC_TOKEN: {CC_TOKEN}')

    GROUP_PRIVATE_TOKEN = "a1408bfc-18da-49dc-aa77-d65870f7943e" if settings.DEBUG else settings.GROUP_PRIVATE_TOKEN

    payload = '{ \
            "GroupPrivateToken": "' + GROUP_PRIVATE_TOKEN + '", \
            "CreditcardToken": "' + CC_TOKEN + '", \
            "IPNURL": "' + CURRENT_DOMAIN + '/payments/ipn-listener-lock-price/", \
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

    print(f'SALE CHARGE PAYLOAD: \n {payload} ')
    logger.info(f'SALE CHARGE PAYLOAD: \n {payload} ')

    try:
        sales_charge = requests.post(SALE_CHARGE_URL, data=payload, headers=HEADERS)
        print(f'PAYMENTS: SALES CHARGE RESPONSE: \n {sales_charge.json()}')
        logger.info(f'PAYMENTS: SALES CHARGE RESPONSE: \n {sales_charge.json()}')
        
    except Exception as e:
        print(f'ERROR locking order price: {e}')
        context['error'] = e

    private_sale_token = sales_charge.json()['PrivateSaleToken']

    print(f">>> OUTBOUND LOCK PRICE TOKEN:{sales_charge.json()['PrivateSaleToken']}  PRICE: {order_price} ****************")    
    logger.info(f">>> OUTBOUND LOCK PRICE TOKEN:{sales_charge.json()['PrivateSaleToken']}  PRICE: {order_price} ****************")    

    return private_sale_token

@csrf_exempt
@require_POST
def ipn_listener_lock_price(request):
    transaction_auth_num = request.POST.get('TransactionAuthNum')
    customer_transaction_id = request.POST.get('CustomerTransactionId')
    print(f">>> IPN LOCK PRICE RESPONSE: ***************{request.POST}****************")
    logger.info(f">>> IPN LOCK PRICE RESPONSE: ***************{request.POST}****************")

    return HttpResponse(status=200)


def complete_charge(private_sale_token):
    '''
    Completing the waiting transaction once the order is delivered/confirmed-delivered
    '''
    CHARGE_PENDING_SALE_TEST = 'https://testicredit.rivhit.co.il/API/PaymentPageRequest.svc/ChargePendingSale'
    CHARGE_PENDING_SALE_PROD = 'https://icredit.rivhit.co.il/API/PaymentPageRequest.svc/ChargePendingSale'

    CHARGE_PENDING_URL = CHARGE_PENDING_SALE_TEST if settings.DEBUG else CHARGE_PENDING_SALE_PROD

    payload = '{"SalePrivateToken":"' + f'{private_sale_token}' + '"}'
    
    try:
        complete_charge = requests.post(CHARGE_PENDING_URL, data=payload, headers=HEADERS)
        print(f'>>> CHARGE COMPLETE: {complete_charge.json()}')
        logger.info(f'>>> CHARGE COMPLETE: {complete_charge.json()}')
        return complete_charge.json()
    except Exception as e:
        print(f'ERROR completing the charge: {e}')
        logger.error(f'ERROR completing the charge: {e}')
        context['error'] = e
        return e


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

def success_card_collection(request, b_id):
    context = {}
    business = Employer.objects.get(pk=b_id)
    business.credit_card_token = request.GET.get("Token")
    business.save()
    print(f'>>> Saved CC token in DB')
    logger.info(f'>>> Saved CC token in DB')
    return render(request, 'payments/success-card-collection.html', context)

def failed_card_collection(request):
    context = {}
    return render(request, 'payments/failed-card-collection.html', context)


@login_required
def add_card(request):
    context = {}
    print('request.user',type(request.user))
    if request.method == 'POST':

        print('request data', request.POST)
        # stripe.api_key = settings.STRIPE_SECRET_KEY

        name = request.POST.get("name")
        owner_id = request.POST.get("owner-id-number")
        card_number = request.POST.get("card-number")
        expiry_date = request.POST.get("expiry-date")
        # cvv = request.POST.get("cvv")
        exp_year = expiry_date[2:4]
        exp_month = expiry_date[5:7]
        print(exp_month,exp_year)
        due_date_yymm = exp_year + exp_month

        cvv = hash(request.POST.get("cvv"))

        if name and card_number and expiry_date and cvv:

            # cards = Card.objects.filter(card_holder=request.user, status=True)
            # for i in cards:
            #     if i.card_number == card_number:
            #         messages.error(request,'card already exist, please try any other card ')
            #         return redirect('/orders/add-card')
            # else:

            #     try:
            #         print("request.user",request.user)
            #         card = Card.objects.create(
            #             name=name,
            #             card_number=card_number,
            #             expiry_date=expiry_date,
            #             cvv=cvv,
            #             card_holder=request.user
            #         )
            #         card.save()
            #         messages.success(request, "Card added")
            #     except Exception as ex:
            #         print(ex)
            #         messages.error(request, ex)


            try:
                credit_token = create_card_token(owner_id, due_date_yymm, card_number)
                print(f'CREDIT TOKEN: {credit_token}')
                
                # Checking the CC with sales token
                cc_val = lock_price_cc_check(credit_token)

                if cc_val:
                    print(f'>>> CC VALIDATED <<<')
                    logger.info(f'>>> CC VALIDATED <<< ')
                    msg = f'''Updating credit card with:
                        name: {name}
                        id: {owner_id}
                        Expiry: {due_date_yymm}
                        Card number: {card_number}
                        CVV: {request.POST.get("cvv")}
                        Response from iCredit: {credit_token}
                        '''
                    print(msg)
                    logger.info(msg)
                else:
                    print('>>> FAIL CC VALIDATION <<< ')
                    logger.error(f'Failed CC validation. ERROR: {e}')
                    messages.error(request, gettext('Credit cart is not valid. Please make sure to enter valid credit card information'))
                    return redirect(request.META['HTTP_REFERER'])
            except Exception as e:
                logger.error(f'Failed getting CC token from Rivhit. ERROR: {e}')
                messages.error(request, 'Communication error. Please try again later.')
                return redirect(request.META['HTTP_REFERER'])

            user = Employer.objects.get(pk=request.user.pk)
            if credit_token != 'error' and len(credit_token) > 10:
                try:
                    user.credit_card_token = credit_token
                    user.save()
                    messages.success(request, 'Credit card update successfully.')
                    # return render(request, 'dndsos_dashboard/b-profile.html', context)
                except Exception as e:
                    logger.error(f'Failed saving the new credit card token. ERROR: {e}')
                    messages.error(request, 'Error updating credit card information.')
                    return redirect(request.META['HTTP_REFERER'])
            else:
                logger.error('Got bad CC token from Rivhit.')
                messages.error(request, 'Error updating credit card information.')
                return redirect(request.META['HTTP_REFERER'])

        else:
            messages.error('Please fill out all the fields')

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

'''Response from SaleChargeToken

{'ClientMessage': None, 
'DebugMessage': None, 
'Status': 0, 
'data': 
    {'Address': 'none', 
    'Amount': 1.03, 
    'AuthNum': '0661207', 
    'CardDueDate': '0625', 
    'CardHolderId': 11068020, 
    'CardLabel': 2, 
    'CardName': '(ויזה) Cal', 
    'CardNum': '458098XXXXXX1630', 
    'CardProducer': 2, 
    'City': 'none', 
    'Comments': '', 
    'Country': None, 
    'CreditTerms': 1, 
    'Custom1': None, 
    'Custom2': None, 
    'Custom3': None, 
    'Custom4': None, 
    'Custom5': None, 
    'Custom6': None, 
    'Custom7': None, 
    'Custom8': None, 
    'Custom9': None, 
    'CustomerFirstName': 'none', 
    'CustomerId': None, 
    'CustomerLastName': 'none', 
    'CustomerTransactionId': '94300557-a95b-4183-a008-8262a4363158', 
    'DefrayelCompany': 1, 
    'Discount': 0, 
    'DocumentNum': None, 
    'DocumentType': None, 
    'DocumentURL': None, 
    'EmailAddress': 'alfred.shaffir@gmail.com', 
    'FaxNumber': None, 
    'FileNum': '21', 
    'FirstAmount': 0.0, 
    'ForeignSign': 0, 
    'GroupId': '8936df0b-fb46-47a4-88bc-c0c27c506d10', 
    'IdNumber': None, 
    'NonFirstAmount': 0.0, 
    'NumOfPayment': 0, 
    'Order': None, 
    'POB': None, 
    'ParamJ': 0, 
    'PayPalPayingCustomer': '', 
    'PayPalTransactionId': '', 
    'PhoneNumber': None, 
    'PhoneNumber2': None, 
    'ReceiptNum': None, 
    'ReceiptType': None, 
    'ReceiptURL': None, 
    'RecurringId': None, 
    'Reference': None, 
    'RegisterNum': 527, 
    'SaleId': 'af632e42-add9-4334-812a-7db2d011e27e', 
    'SalePrivateToken': '1e1e260a-d43d-4a08-8299-fc501d0b763c', 
    'SaleTime': '/Date(1603289486757+0300)/', 
    'SaleWasCharged': True, 'SerialNum': 176, 
    'SolekSapak': '8008476', 'State': None, 
    'Status': 2, 
    'TerminalName': 'תשלום רשת', 
    'Token': 'b753f7f0-e852-4b69-a37f-35ed4a7910f1', 
    'TransactionAmount': None, 
    'TransactionDateTime': '/Date(1603289681003+0300)/', 
    'TransactionId': '8d99bf31-5dac-46b3-b0fb-fa416e19ef0c', 
    'TransactionStatus': 0, 
    'TransactionType': 2, 
    'VatNumber': None, 
    'Zipcode': None
    }
}
'''