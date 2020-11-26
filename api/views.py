import base64
import time
import platform
import json
import logging
import random
from datetime import date, datetime

from geopy.geocoders import Nominatim
from geopy.distance import geodesic, distance
from forex_python.converter import CurrencyRates # https://github.com/MicroPyramid/forex-python

from django.contrib.auth import login as django_login, logout as django_logout
from django.db.models import Q
from django.contrib.gis.geos import fromstr, Point
from django.http import HttpResponse, JsonResponse

from fcm_django.models import FCMDevice
from django.core import serializers as djangoSerializers
from django.conf import settings
# from django.contrib.auth.models import User
from rest_framework import viewsets, permissions
from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.authentication import TokenAuthentication, SessionAuthentication, BasicAuthentication
from rest_framework.authtoken.models import Token
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.pagination import (LimitOffsetPagination, PageNumberPagination,)

from core.models import User, Employee, Employer
from orders.models import Order
from dndsos.models import ContactUs, AdminParameters
from dndsos_dashboard.views import phone_verify
from dndsos_dashboard.utilities import send_mail, calculate_freelancer_total_rating

from .utils import clean_phone_number, check_profile_approved
from payments.views import create_card_token, lock_price_cc_check
from .serializers import (UserSerializer, LoginSerializer, 
                        ContactsSerializer, BusinessSerializer, 
                        UsernameSerializer, EmployeeProfileSerializer, EmployerProfileSerializer,)
from orders.serializers import OrderSerializer, OrderAPISerializer
from .permissions import IsOwnerOrReadOnly, IsOwner # Custom permission

logger = logging.getLogger(__file__)


today = date.today()

class UserLocationViewSet(APIView):
    authentication_classes = (TokenAuthentication,)

    def put(self, request, *args, **kwargs):

        # Checking Point is translated differently on Linux and Mac
        # for Mac:
        if platform.system() == 'Darwin':
            lat = float(self.request.data['lat'])
            lon = float(self.request.data['lon'])
        # On Linux is revered
        else:
            lat = float(self.request.data['lon'])
            lon = float(self.request.data['lat'])

        try:
            user_id = self.request.GET.get('user')
            user = Employee.objects.get(pk=user_id)
        except Exception as e:
            logger.error(f">>> API: Fail getting user ID correctly. ERROR: {e}")
            return Response({'response':'Bad user ID'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user.lat = lat
            user.lon = lon
            print(f">>> API: User LAT: {lat}")
            print(f">>> API: User LON: {lon}")
            
            user_location = Point(lat,lon)
            user.location = user_location
            user.save()
        except Exception as e:
            logger.error(f">>> API: Fail getting user location. ERROR: {e}")
            return Response({'response':'Bad coordinates'}, status=status.HTTP_400_BAD_REQUEST)

        return Response({'response':'Location updated'},status=200)

class UserAvailable(APIView):
    authentications_classes = (TokenAuthentication,)
    def put(self, request, *arg, **kwargs):
        try:
            user_id = self.request.GET.get('user')
            user = Employee.objects.get(pk=user_id)
        except Exception as e:
            return Response({'response':'Bad user ID.'}, status=status.HTTP_400_BAD_REQUEST)
            logger.error('Bad request for user. Error: {e}')

        try:
            user.is_available = self.request.data['available']
            user.save()
        except Exception as e:
            print(f'Failed updated user availability')
            return Response({'response':'User availability not updated'}, status=status.HTTP_400_BAD_REQUEST)

        return Response({'response':'Availability updated'},status=200)



class NewLoginViewSet(ObtainAuthToken):

    def post(self, request, *args, **kwargs):

        serializer = self.serializer_class(data=request.data,
                                           context={'request': request})
        serializer.is_valid(raise_exception=True)
        
        user = serializer.validated_data['user']
        token, created = Token.objects.get_or_create(user=user)
        
        # Checking if there is an FCM token for the push notifications
        try:
            fcm_token = FCMDevice.objects.filter(user=user.pk).first().registration_id
        except Exception as e:
            fcm_token = '0'

        is_employee = User.objects.get(pk=user.pk).is_employee
        print(f'Login RESPONSE: token: {token} \n user: {user.pk}\n is_employee: {user.is_employee}')

        if is_employee:
            # employee = Employee.objects.get_or_create(user=user)

            user_profile,_ = Employee.objects.get_or_create(pk=user.pk)

            active_orders = Order.objects.filter(
                (Q(freelancer=user.pk) & Q(updated__contains=today)) & 
                (Q(status='STARTED') | Q(status='IN_PROGRESS')))
            
            num_active_orders = len(active_orders)
            
            daily_orders = Order.objects.filter(Q(freelancer=request.user.pk) & Q(updated__contains=today) & Q(status='COMPLETED'))
             # Daily profit
            daily_profit = 0.0
            for order in daily_orders:
                daily_profit += order.fare

            daily_profit = round(daily_profit,2)

            # When a profile is new, there are no values. To avoid app crash, setting empty fields
            try:
                name = user_profile.name
            except:
                name = ''

            try: 
                phone = user_profile.phone
                if not phone:
                    phone = 'Not set'
            except:
                phone = ''

            
            try: 
                vehicle = user_profile.vehicle
                if not vehicle:
                    vehicle = "Not Set"

            except:
                vehicle = ''

            try: 
                freelancer_total_rating = user_profile.freelancer_total_rating
                if not freelancer_total_rating:
                    freelancer_total_rating = 0.0
            except:
                freelancer_total_rating = 0.0


            try:
                is_approved = user_profile.is_approved
            except:
                is_approved = ""


            return Response({'token': token.key,
                            'fcm_token':fcm_token,
                            "user":user.pk,
                            "is_employee": 1 if user.is_employee else 0,
                            "name": name,
                            "phone": phone,
                            "vehicle": vehicle,
                            "freelancer_total_rating": freelancer_total_rating,
                            "is_approved": 1 if is_approved else 0,
                            "num_active_orders":num_active_orders,
                            "daily_profit": daily_profit
                            })
        else:
            user_profile, _ = Employer.objects.get_or_create(pk=user.pk)
            orders_in_progress = Order.objects.filter(
                (Q(business=user.pk) & Q(updated__contains=today)) & 
                (Q(status='STARTED') | Q(status='IN_PROGRESS') | Q(status="REJECTED") | Q(status="REQUESTED") | Q(status="RE_REQUESTED")))
            
            print(f'USER PROF: {user_profile.business_name}')
            num_orders_in_progress = len(orders_in_progress)

            daily_orders = Order.objects.filter(business=user.pk, created__contains=today)
            num_daily_orders = len(daily_orders)

            # Daily cost
            daily_cost = 0.0
            for order in daily_orders:
                daily_cost += order.price

            daily_cost = round(daily_cost,2)
            
            # When a profile is new, there are no values. To avoid app crash, setting empty fields
            try:
                business_name = user_profile.business_name
            except:
                business_name = ""

            try: 
                phone = user_profile.phone
            except:
                phone = ''

            try:
                business_category = user_profile.business_category
            except:
                business_category = ""

            try:
                is_approved = user_profile.is_approved
            except:
                is_approved = ""

            try: 
                business_total_rating = user_profile.business_total_rating
                if not business_total_rating:
                    business_total_rating = 0.0
            except:
                business_total_rating = 0.0


            login_response = {'token': token.key,
                            'fcm_token':fcm_token,
                            "user":user.pk,
                            "is_employee": 1 if user.is_employee else 0,
                            "business_name":  business_name,
                            "phone": phone,
                            "business_category": business_category,
                            "is_approved": 1 if is_approved else 0,
                            "num_daily_orders": num_daily_orders,
                            "business_total_rating":business_total_rating,
                            "daily_cost": daily_cost,
                            "num_orders_in_progress": num_orders_in_progress
                            }
            print(f'>>>>> Login response: {login_response}')

            return Response(login_response)



class LoginView(APIView):
    
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True) # Block the code from continue if raised exception
        user = serializer.validated_data['user']
        django_login(request,user)
        token, created = Token.objects.get_or_create(user=user)
        return Response({"token":token.key}, status=200)

class LogoutView(APIView):
    authentication_classes = (TokenAuthentication,)

    def post(self, request):
        django_logout(request)
        return Response(status=204)

class OpenOrdersViewSet(viewsets.ModelViewSet):
    # serializer_class = OrderSerializer
    serializer_class = OrderAPISerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    # queryset = Order.objects.all()

    def get_queryset(self, *args, **kwargs):
        queryset_list = Order.objects.all()
        query = self.request.GET.get('q')
        print(f'Open Orders for user: {query}')
        if query:
            queryset_list = queryset_list.filter(
                Q(status='REQUESTED') |
                Q(status='RE_REQUESTED')
            )
        print(f'Open Orders for user {query}: {queryset_list}')
        
        return queryset_list

class BusinessOrdersViewSet(viewsets.ModelViewSet):
    serializer_class = OrderAPISerializer
    authentication_classes = [TokenAuthentication,]
    permission_classes = (IsAuthenticated,)

    # queryset = Order.objects.all()

    def get_queryset(self, *args, **kwargs):
        queryset_list = Order.objects.all()
        user = self.request.GET.get('user')
        print(f'Orders for User: {user}')
        if user:
            queryset_list = queryset_list.filter(
                Q(business=user) & 
                (
                    Q(status='STARTED') | 
                    Q(status="IN_PROGRESS") | 
                    Q(status="REQUESTED") |
                    Q(status="RE_REQUESTED") | 
                    Q(status="COMPLETED")  
                    ) 
            )
        return queryset_list

class BusinessRequestedOrdersViewSet(viewsets.ModelViewSet):
    serializer_class = OrderAPISerializer
    authentication_classes = [TokenAuthentication,]
    permission_classes = (IsAuthenticated,)

    # queryset = Order.objects.all()

    def get_queryset(self, *args, **kwargs):
        queryset_list = Order.objects.all()
        user = self.request.GET.get('user')
        print(f'New requested or re-requested Orders for User: {user}')

        if user:
            queryset_list = queryset_list.filter(
                Q(business=user) & (Q(status="REQUESTED") | Q(status='RE_REQUESTED')) 
            )
        return queryset_list


class BusinessRejectedOrdersViewSet(viewsets.ModelViewSet):
    serializer_class = OrderAPISerializer
    authentication_classes = [TokenAuthentication,]
    permission_classes = (IsAuthenticated,)

    # queryset = Order.objects.all()

    def get_queryset(self, *args, **kwargs):
        queryset_list = Order.objects.all()
        user = self.request.GET.get('user')
        print(f'Rejected Orders for User: {user}')

        if user:
            queryset_list = queryset_list.filter(
                Q(business=user) & (Q(status="REJECTED")) 
            )
        return queryset_list

class BusinessStartedOrdersViewSet(viewsets.ModelViewSet):
    serializer_class = OrderAPISerializer
    authentication_classes = [TokenAuthentication,]
    permission_classes = (IsAuthenticated,)

    # queryset = Order.objects.all()

    def get_queryset(self, *args, **kwargs):
        queryset_list = Order.objects.all()
        user = self.request.GET.get('user')
        print(f'Started Orders for User: {user}')
        if user:
            queryset_list = queryset_list.filter(
                Q(business=user) & (Q(status="STARTED")) 
            )
        return queryset_list

class BusinessInProgressOrdersViewSet(viewsets.ModelViewSet):
    serializer_class = OrderAPISerializer
    authentication_classes = [TokenAuthentication,]
    permission_classes = (IsAuthenticated,)

    # queryset = Order.objects.all()

    def get_queryset(self, *args, **kwargs):
        queryset_list = Order.objects.all()
        user = self.request.GET.get('user')
        print(f'In Progress Orders for User: {user}')
        if user:
            queryset_list = queryset_list.filter(
                Q(business=user) & (Q(status="IN_PROGRESS")) 
            )
        return queryset_list

class BusinessDeliveredOrdersViewSet(viewsets.ModelViewSet):
    serializer_class = OrderAPISerializer
    authentication_classes = [TokenAuthentication,]
    permission_classes = (IsAuthenticated,)

    # queryset = Order.objects.all()

    def get_queryset(self, *args, **kwargs):
        queryset_list = Order.objects.all()
        user = self.request.GET.get('user')
        print(f'Delivered/Completed Orders for User: {user}')

        if user:
            queryset_list = queryset_list.filter(
                Q(business=user) & (Q(status="COMPLETED")) 
            )
        return queryset_list


class OrdersView(viewsets.ModelViewSet):
    serializer_class = OrderSerializer
    permission_classes = (IsAuthenticated,)

    # permission_classes = (IsAuthenticated,)
    # authentication_classes = [TokenAuthentication,SessionAuthentication, BasicAuthentication]
    # permission_classes = (permissions.IsAuthenticatedOrReadOnly,)
    queryset = Order.objects.all()

    # pagination_class = PageNumberPagination
    # pagination_class = LimitOffsetPagination

    def get_queryset(self, *args, **kwargs):
        # queryset_list = Order.objects.filter(order_street_symbol=9000)
        queryset_list = Order.objects.all()
        query = self.request.GET.get('q')
        # if query:
        #     queryset_list = queryset_list.filter(
        #         Q(user=self.request.user)
        #     )
        return queryset_list

class ContactView(viewsets.ModelViewSet):
    queryset = ContactUs.objects.all()
    serializer_class = ContactsSerializer
    # permission_classes = (IsAuthenticated,)
    
    permission_classes = (IsAdminUser,)

class UserProfile(viewsets.ModelViewSet):
    pass


from django.core.files.base import ContentFile

@api_view(['POST',])
@permission_classes((IsAuthenticated,))
def user_profile_image(request):
    data = {}

    # print(f'IMAGE REQUEST: {request}')

    if request.data['is_employee'] == 'true':
        profile = Employee.objects.get(pk=request.data['user_id'])
    else:
        profile = Employer.objects.get(pk=request.data['user_id'])
        # serializer = EmployerProfileSerializer(user, data=request.data)


    country = request.data['country']
    image_string = request.data["image"]

    # profile = Employee.objects.get(pk=8)
    # file_name = settings.MEDIA_ROOT + f'/id_docs/{country}/id_doc_{profile.pk}_{request.data["file_name"]}'

    print('Processing profile image upload...')    
    try:
        profile.profile_pic = image_string
        profile.save()
        print('SAVED TO PROFILE')
        # data['response'] = 'ID updated'
        return Response(status.HTTP_202_ACCEPTED)
    except Exception as e:
        print(f'Failed saving profile image. ERROR: {e}')
        logger.error(f'Failed saving profile image. ERROR: {e}')
        # print(f'DATA: {request.data}')
        data['response'] = 'Failed updating profile image document'
        return Response(data)

@api_view(['POST',])
@permission_classes((IsAuthenticated,))
def user_photo_id(request):
    data = {}
    if request.data['is_employee'] == 'true':
        profile = Employee.objects.get(pk=request.data['user_id'])
    else:
        profile = Employer.objects.get(pk=request.data['user_id'])
        serializer = EmployerProfileSerializer(user, data=request.data)

    country = request.data['country']
    image_string = request.data["image"]
    id_doc_expiry_str = request.data['id_doc_expiry']

    id_doc_expiry_dt = datetime.strptime(id_doc_expiry_str, '%Y-%m-%d')

    # profile = Employee.objects.get(pk=8)
    # file_name = settings.MEDIA_ROOT + f'/id_docs/{country}/id_doc_{profile.pk}_{request.data["file_name"]}'

    print('Processing image upload...')    
    try:
        print(f'API: IMAGE TYPE {type(image_string)} Expiry {id_doc_expiry_str}')
        profile.id_doc = image_string
        profile.id_doc_expiry = id_doc_expiry_dt
        profile.save()
        print('SAVED TO PROFILE')

        # Updating the profile status
        check_profile_approved(user_id=request.user.pk, is_employee=1)

        # data['response'] = 'ID updated'
        return Response(status.HTTP_202_ACCEPTED)
    except Exception as e:
        print(f'Failed saving photo id. ERROR: {e}')
        logger.error(f'Failed saving photo id. ERROR: {e}')
        # print(f'DATA: {request.data}')
        data['response'] = 'Failed updating ID document'
        return Response(data)


@api_view(['PUT','POST',])
@permission_classes((IsAuthenticated,))
def user_profile(request):
    '''
    returns user profile information
    '''

    data = {}

    # try:
        # user = User.objects.get(pk=request.user.pk)
    if request.data['is_employee'] == 1:
        user = Employee.objects.get(pk=request.data['user_id'])
        serializer = EmployeeProfileSerializer(user, data=request.data)
    else:
        user = Employer.objects.get(pk=request.data['user_id'])
        serializer = EmployerProfileSerializer(user, data=request.data)

    if request.data['is_employee'] == 1:
        # Current active orders/deliveries (Freelancer)
        active_orders_today = Order.objects.filter(
                    (Q(freelancer=user.pk) & Q(updated__contains=today)) & 
                    (Q(status='STARTED') | Q(status='IN_PROGRESS')))
                
        num_active_orders_today = len(active_orders_today)

        active_orders_total = Order.objects.filter(
                    (Q(freelancer=user.pk) & 
                    (Q(status='STARTED') | Q(status='IN_PROGRESS'))))
                
        num_active_orders_total = len(active_orders_total)

        # Profile calculations
        daily_orders = Order.objects.filter(Q(freelancer=request.user.pk) & Q(updated__contains=today) & Q(status='COMPLETED'))
            # Daily profit
        daily_profit = 0.0
        for order in daily_orders:
            daily_profit += order.fare

        daily_profit = round(daily_profit,2)
    else:
        # Current orders in progress (Business)
        user_profile, _ = Employer.objects.get_or_create(pk=user.pk)
        orders_in_progress_today = Order.objects.filter(
                (Q(business=user.pk) & Q(updated__contains=today)) & 
                (Q(status='STARTED') | Q(status='IN_PROGRESS') | Q(status="REJECTED") | Q(status="REQUESTED") | Q(status="RE_REQUESTED")))

        orders_in_progress = Order.objects.filter(Q(business=user.pk) & 
                (Q(status='STARTED') | Q(status='IN_PROGRESS') | Q(status="REJECTED") | Q(status="REQUESTED") | Q(status="RE_REQUESTED")))

        orders_delivered_today = Order.objects.filter(Q(business=user.pk) & Q(updated__contains=today) & Q(status='COMPLETED'))

        print(f'USER PROF: {user_profile.business_name}')
        num_orders_in_progress = len(orders_in_progress)

        daily_orders = Order.objects.filter(business=user.pk, created__contains=today, status='COMPLETED')
        num_daily_orders = len(daily_orders)

        # Daily cost
        daily_cost = 0.0
        for order in orders_delivered_today:
            daily_cost += order.price

            daily_cost = round(daily_cost,2)
            

    
    # Sending user information to the app
    ########################
    if request.method == 'POST':
        print(f'REQUEST: {request.data}')
        data = {}
        # Currency handling
        try:
            c = CurrencyRates()
            usd_ils = c.get_rate('USD', 'ILS')
            usd_eur = c.get_rate('USD', 'EUR')
        except Exception as e:
            print(f'Failed to getting currencies from CurrencyRates model. ERROR: {e}')
            logger.error(f'Failed to getting currencies from CurrencyRates model. Setting defaults. ERROR: {e}')
            try:
                admin_params = AdminParameters.objects.all().first()
                usd_ils = admin_params.usd_ils_default
                usd_eur = admin_params.usd_eur_default
            except Exception as e:
                print(f'Failed to load default currencies. ERROR: {e}')
                logger.error(f'Failed to load currencies. Setting defaults. ERROR: {e}')
                usd_ils = 3.5
                usd_eur = 0.8

        if serializer.is_valid():
            data = serializer.data
            
            if request.data['is_employee'] == 1:
                data['num_active_orders_today'] = num_active_orders_today 
                data['num_active_orders_total'] = num_active_orders_total
                data['daily_profit'] = daily_profit
            else:
                data['orders_in_progress_today'] = len(orders_in_progress_today)
                data['num_daily_orders'] = num_daily_orders
                data['num_orders_in_progress'] = num_orders_in_progress
                data['daily_cost'] = daily_cost

            # Currency exchage rates
            data['usd_ils'] = round(usd_ils,2)
            data['usd_eur'] = round(usd_eur,2)

            print('SENDING PROFILE DATA')
        else:
            data = serializer.errors
            logger.error(f'Failed reading user profile. ERROR: {data}')

        data['account_level_rookie'] = settings.ROOKIE_LEVEL
        data['account_level_advanced'] = settings.ADVANCED_LEVEL
        data['account_level_expert'] = settings.EXPERT_LEVEL
        return Response(data)

    # Updating user profile information
    ######################
    elif request.method == 'PUT':
        print(f'REQUEST: {request.data}')
        if serializer.is_valid():
            try:
                serializer.save()
                print(f'SER: {serializer.data}')
                data = serializer.data
                data['response'] = 'Update successful'

                # Updating business user first name
                try:
                    user.user.first_name = request.data['business_name']
                    user.user.save()
                except Exception as e:
                    print(f'Business name was not updated. E: {e}')
                    logger.info(f'Business name was not updated. E: {e}')
            except Exception as e:
                print(f'Profile was not updated. E: {e}')
                logger.info(f'Profile was not updated. E: {e}')


            # try:
            #     if request.data['first_name']:
            #         print('> Updating name')
            #         updated_order = serializer.save()
            #         data = serializer.data
            #         data['response'] = 'Update successful'
            #         print(f'NAME update: {request.data["first_name"]}')
            # except Exception as e:
            #     print(f'Name was not updated. E: {e}')
            #     logger.info(f'Name was not updated. E: {e}')
            # try:
            #     if request.data['phone_number']:
            #         print('> Updating phone')
            #         updated_order = serializer.save()
            #         data = serializer.data
            #         data['response'] = 'Update successful'
            #         print(f'PHONE update: {request.data["phone_number"]}')
            # except Exception as e:
            #     print(f'Phone was not updated. E: {e}')
            #     logger.info(f'Phone was not updated. E: {e}')

            
            # try:
            #     if request.data['vehicle']:
            #         print('> Updating vehicle')
            #         updated_order = serializer.save()
            #         data = serializer.data
            #         data['response'] = 'Update successful'
            #         print(f'VEHICLE update: {request.data["vehicle"]}')
            # except Exception as e:
            #     print(f'Vehicle was not updated. E: {e}')
            #     logger.info(f'Vehicle was not updated. E: {e}')

            # try:
            #     if request.data['email']:
            #         print('> Updating email')
            #         updated_order = serializer.save()
            #         data = serializer.data
            #         data['response'] = 'Update successful'
            #         print(f'EMAIL update: {request.data["email"]}')
            #         print(f'HHHHHH: {data}')
            # except Exception as e:
            #     print(f'Email was not updated. E: {e}')
            #     logger.info(f'Email was not updated. E: {e}')

        else:
            data = serializer.errors
            logger.error(f'Failed updated user profile. ERROR: {data}')

        check_profile_approved(user.pk, request.data['is_employee'])

        return Response(data)
    else:
        return Response(status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST',])
@permission_classes((IsAuthenticated,))
def user_credit_card(request):
    print(f'CREDIT CARD REQUEST: {request.data}')
    logger.info(f'CREDIT CARD REQUEST: {request.data}')
    data = {}
    if request.data['is_employee'] == 1:
        user = Employee.objects.get(pk=request.data['user_id'])
        serializer = EmployeeProfileSerializer(user, data=request.data)
    else:
        user = Employer.objects.get(pk=request.data['user_id'])
        serializer = EmployerProfileSerializer(user, data=request.data)

    if request.method == 'POST':
        if serializer.is_valid():
            data = serializer.data
            try:
                owner_name = request.data['owner_name']
                due_date_yymm = request.data['expiry_date']
                card_number = "4580000000000000" if settings.DEBUG else request.data['card_number'];
                owner_id = request.data['owner_id']
                cvv = request.data['cvv']
                
                credit_token = create_card_token(owner_id, due_date_yymm, card_number)
                # Checking the CC with sales token
                cc_val = lock_price_cc_check(credit_token)

                if cc_val:
                    print(f'>>> CC VALIDATED <<<')
                    logger.info(f'>>> CC VALIDATED <<< ')

                    msg = f'''Updating credit card with:
                    one: {owner_name}
                    id: {owner_id}
                    Expiry: {due_date_yymm}
                    CVV: {cvv}
                    Card number: {card_number}
                    Response from iCredit: {credit_token}
                    '''

                    print(msg)
                    logger.info(msg)

                    if len(credit_token) < 10:
                        logger.error(f'Fail getting the token from iCredit server. ERROR: {credit_token}')
                        data["response"] = "Failed updating credit card"
                        return Response(f'Fail getting the token from iCredit server. ERROR: {credit_token}')
                else:
                    print('>>> FAIL CC VALIDATION <<< ')
                    logger.error(f'Failed CC validation. ERROR: {e}')
                    data["response"] =f'Failed CC validation. ERROR: {e}'
                    return Response(data)


            except Exception as e:
                logger.error(f'Fail communication with the iCredit server. ERROR: {e}')
                data["response"] =f'Fail communication with iCredit. ERROR: {e}'
                return Response(data)

            # Saving user's new Token
            try:
                user.credit_card_token = credit_token
                user.save()
                data["response"] = "Update successful"
                data["credit_card_token"] = credit_token
                check_profile_approved(user.pk, request.data['is_employee'])
                
                return Response(data)
            except Exception as e:
                logger.error(f'Failed saving the new credit card token. ERROR: {e}')
                data["response"] = "Failed updating credit card"
                return Response(f'Failed saving the new credit card token. ERROR: {e}')

    else:
        return Response(status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes((IsAuthenticated,))
def payment_method(request):
    data = {}
    if request.method == 'POST':

        if request.data['is_employee'] == 1:
            profile = Employee.objects.get(pk=request.data['user_id'])
        else:
            profile = Employer.objects.get(pk=request.data['user_id'])
        
        preferred_payment_method = request.data['payment_method']

        if preferred_payment_method == 'paypal':
            print(f'PAYPAL: {request.data["paypal"]}')
            paypal = request.data['paypal']
            if paypal is not None:
                profile.preferred_payment_method = 'PayPal'
                profile.paypal_account = paypal
                profile.save()
                data['response'] = "PayPal"
            else:
                data['response'] = 'paypal missing'
                return Response(data)

        elif preferred_payment_method == 'bank' and profile.bank_details is not None:
            profile.preferred_payment_method = 'Bank'
            profile.save()
            data['response'] = "Bank"
        else:
            data['response'] = "data missing"

        return Response(data)
    else:
        return Response(status.HTTP_400_BAD_REQUEST)




@api_view(['POST',])
@permission_classes((IsAuthenticated,))
def bank_details(request):
    data = {}
    if request.method == 'POST':
        if request.data['is_employee'] == 1:
            profile = Employee.objects.get(pk=request.data['user_id'])
        else:
            profile = Employer.objects.get(pk=request.data['user_id'])
        
        profile.bank_details = dict()

        try:
            iban = request.data['iban']
            name_account = request.data['name_account']

            try:
                swift = request.data['swift_code']
                profile.bank_details['swift'] = swift 
            except:
                swift = None
            profile.bank_details['iban'] = iban
            profile.bank_details['name_account'] = name_account
            
            profile.save()

        except Exception as e:
            print(f'Bank details not valid. Error: {e}')
            logger.error(f'Bank details not valid. Error: {e}')
            return Response('Bank details not valid')

        print('Bank details update successfully!')
        data['response'] = 'OK'
        data['iban'] = iban
        return Response(data, status=status.HTTP_200_OK)
    else:
        return Response(status.HTTP_400_BAD_REQUEST)




@api_view(['GET',])
@permission_classes((IsAdminUser,))
def all_users(request):
    '''
    Returns all users
    '''
    try:
        users = Employee.objects.all()
    except Exception as e:
        return Response(status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'GET':
        serializer = UsernameSerializer(users, data=request.data)
        data = {}
        if serializer.is_valid():
            print(f'++++++++ {serializer.data}')
            data['usernames'] = serializer.data
            data['response'] = 'Transmitted all users'
        else:
            print(f'--------> {serializer.data}')
            data = serializer.errors
        
        return Response(data)
 

@api_view(['GET',])
@permission_classes([IsAdminUser,])
def all_businesses(request):
    '''
    Returns the list of all businesses' names
    '''
    try:
        businesses_names = Employer.objects.all()
    except Exception as e:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = BusinessSerializer(businesses_names, data=request.data)
        data = {}
        if serializer.is_valid():
            data['businesses'] = serializer.data
            data['response'] = 'Business Names transmitted'
        else:
            data = serializer.errors
        
        return Response(data)


class ActiveOrdersViewSet(viewsets.ModelViewSet):
    serializer_class = OrderAPISerializer
    authentication_classes = [TokenAuthentication,]
    permission_classes = (IsAuthenticated,)

    # queryset = Order.objects.all()
    data = {}
    def get_queryset(self, *args, **kwargs):
        queryset_list = Order.objects.all()
        user = self.request.GET.get('user')
        if user:
            queryset_list = queryset_list.filter(
                Q(freelancer=user) & 
                (Q(status='STARTED') | Q(status="IN_PROGRESS")) 
            )
        print(f'Active Orders for User: {user}: {queryset_list}')
        return queryset_list




# @api_view(['GET',])
# @permission_classes((IsAuthenticated,))
# def open_orders_view(request):
#     '''
#     View open orders
#     '''
#     try:
#         open_orders = Order.objects.filter(Q(status='REQUESTED') | Q(status='RE_REQUESTED'))
#     except Order.DoesNotExist:
#         return Response(status=status.HTTP_404_NOT_FOUND)

#     if request.method == 'GET':
#         serializer = OrderSerializer(open_orders, data=request.data)
#         orders = []
#         for order in open_orders:
#             if serializer.is_valid():
#                 ser_order = serializer.data
#                 orders.append(ser_order)
#             else:
#                 print(f'ERROR: {serializer.errors}')
#                 data = serializer.errors
#         # data['response'] = 'Update successful'
#         data = json.dumps(orders)
#         print(data)
#         return Response(data)


@api_view(['GET',])
@permission_classes((IsAuthenticated,))
def order_view(request):
    '''
    View a particular order
    '''
    try:
        view_order = Order.objects.get(order_id=request.data['order_id'])
    except Order.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = OrderSerializer(view_order, data=request.data)
        data = {}
        if serializer.is_valid():
            data = serializer.data
            data['response'] = 'Update successful'
        else:
            data = serializer.errors
        
        return Response(data)

@api_view(['POST',])
@permission_classes((IsAuthenticated,))
def price_parameteres(request):
    data = {}
    data['base_price'] = settings.DEFAULT_BASE_PRICE
    data['unit_price'] = settings.DEFAULT_UNIT_PRICE
    return Response(data)

@api_view(['POST',])
@permission_classes((IsAuthenticated,))
def new_order(request):
    '''
    New order from Mobile user
    1) The first section is the price structuring and sending baack for sender to approve.
    2) The second section is the actual creation of the order when the sender approves.
    '''

    data = {}

    user = User.objects.get(pk=request.user.pk)

    if request.data['is_employee'] == 1:
        user_profile = Employee.objects.get(pk=request.data['user_id'])
    else:
        user_profile = Employer.objects.get(pk=request.data['user_id'])
    
    if not user_profile.is_approved:
        return Response('User is not approved')

    '''
    Calculating the price of an order before registering into the DB
    '''
    pickup_address = request.data['pickup_address']['name']
    pickup_address_id = request.data['pickup_address']['placeId']
    pickup_address_lat = float(request.data['pickup_address']['lat'])
    pickup_address_lng = float(request.data['pickup_address']['lng'])

    data['pick_up_address'] = pickup_address

    dropoff_address = request.data['dropoff_address']['name']
    dropoff_address_id = request.data['dropoff_address']['placeId']
    dropoff_address_lat = float(request.data['dropoff_address']['lat'])
    dropoff_address_lng = float(request.data['dropoff_address']['lng'])

    data['drop_off_address'] = dropoff_address

    order_urgency = request.data['urgency']
    package_type = request.data['package_type']

    geolocator = Nominatim(user_agent="dndsos", timeout=3)
        
    try:
        # Checking OS
        if platform.system() == 'Darwin':
            order_location = Point(dropoff_address_lat,dropoff_address_lng)
        else:
            order_location = Point(dropoff_address_lng, dropoff_address_lat)
        
        order_coords = (dropoff_address_lat,dropoff_address_lng)

        data['order_location'] = order_location
        data['order_lon'] = dropoff_address_lng
        data['order_lat'] = dropoff_address_lat
        data['business_lon'] = pickup_address_lng
        data['business_lat'] = pickup_address_lat
                
    except Exception as e:
        print(f'Failed getting the location for {dropoff_address}')
        logger.error(f'Failed getting the location for {dropoff_address}')
        order_location = None
        order_coords = None
        order_lat = None
        order_lon = None


        data['order_location'] = order_location
        data['order_lon'] = dropoff_address_lng
        data['order_lat'] = dropoff_address_lat

    # Calculate distance between drop off address the sender location
    try:
        business_coords = (pickup_address_lat, pickup_address_lng)

        order_to_business_distance = distance(business_coords, order_coords).km
        order_to_business_distance_meters = order_to_business_distance * 1000
    except Exception as e:
        logger.error(f'''Fail getting sender location. ERROR: {e}
                        pickup  address: {pickup_address}
                        pickup address ID: {pickup_address_id}
                    ''')
        # Setting a default distance to order if address not found
        settings.DEFAULT_ORDER_TO_BUISINESS_DISTANCE = 1000

    # Calculating the price for the order (price calculation)
    urgency = 2 if order_urgency == 'Urgent' else 1

    if order_to_business_distance_meters > 1000:
        price = urgency * (settings.DEFAULT_BASE_PRICE + settings.DEFAULT_UNIT_PRICE * (order_to_business_distance_meters - 1000)/settings.DISTANCE_UNIT)
        data['price'] = round(price,2)
        data['fare'] = str(round(price * (1 - settings.PICKNDELL_COMMISSION),2))
        data['distance_to_business'] = round(order_to_business_distance,2)
    else:
        price = settings.DEFAULT_BASE_PRICE
        data['price'] = float(round(price,2))
        data['fare'] = str(round(price * (1 - settings.PICKNDELL_COMMISSION),2))
        data['distance_to_business'] = round(order_to_business_distance,2)

    if request.data['price_order']:
        return Response(data['price'])
    
    else:
        try:
            user_profile.location = Point(pickup_address_lat,pickup_address_lng)
            user_profile.address = pickup_address
            user_profile.lat = pickup_address_lat
            user_profile.lon = pickup_address_lng
            user_profile.save()

            user.lat = pickup_address_lat
            user.lon = pickup_address_lng
            user.save()

        except Exception as e:
            print('>>> API: Failed writing sender location to DB.')
            logger.error('>>> API: Failed writing sender location to DB.')
            
        data['order_type'] = package_type
        data['business'] = User.objects.get(pk=user_profile.pk)
        data['is_urgent'] = True if order_urgency == 'Urgent' else False; 

        instance = Order.objects.create(**data)
        print(f'ORDER INSTANCE: {instance}')
        instance.new_message = {
            'business': '',
            'freelancer':''
            }
        instance.save()

        print(f'DATA: {data}')
        # print(f"REQUEST: {request.data}")
        return Response('Order Created')


@api_view(['POST',])
@permission_classes((IsAuthenticated,))
def order_delivery(request):

    try:
        update_order = Order.objects.get(order_id=request.data['order_id'])
    except Order.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'POST':
        data = {}
        order = Order.objects.get(pk=request.data['order_id'])
        old_status = order.status
        new_status = request.data["status"]
        if old_status == 'IN_PROGRESS' and new_status == 'COMPLETED':
            order.status = new_status
            try:
                image = request.data['image']
                order.delivery_photo = image
            except:
                print('NO IMAGE')
                pass
            
            order.save()
            # data['response'] = 'Update successful'
            return Response(status.HTTP_202_ACCEPTED)
        else:
            return Response("Wrong status configuration", status=status.HTTP_400_BAD_REQUEST)
    
    return Response(status.HTTP_400_BAD_REQUEST)


@api_view(['POST',])
@permission_classes((IsAuthenticated,))
def order_ratings(request):
    try:
        update_order = Order.objects.get(order_id=request.data['order_id'])
    except Order.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'POST':
        data = {}
        order = Order.objects.get(pk=request.data['order_id'])
        if request.data['is_employee'] == 0:
            rating = request.data['freelancer_rating']
            order.freelancer_rating = rating            
            order.save()
            calculate_freelancer_total_rating(order.freelancer.freelancer.pk)
            data['response'] = 'Update successful'
            return Response(data, status.HTTP_200_OK)
    else:
        return Response("Wrong status configuration", status=status.HTTP_400_BAD_REQUEST)
    
    return Response(status.HTTP_400_BAD_REQUEST)


@api_view(['PUT',])
@permission_classes((IsAuthenticated,))
def order_update_view(request):
    '''
    Update a particular order
    var: order_id
    '''

    try:
        update_order = Order.objects.get(order_id=request.data['order_id'])
    except Order.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    # Identifying the business for the location and the phone
    business = Employer.objects.get(pk=update_order.business.pk)
    print(f'ORDER UPDATE: BUSINESS OWNER: {business} Location: {business.location} Lat: {business.lat} Lon: {business.lon}')

    if request.method == 'PUT':
        serializer = OrderSerializer(update_order, data=request.data)
        data = {}
        old_status = update_order.status
        new_status = request.data["status"]
        if serializer.is_valid():
            if new_status:
                if (new_status == 'STARTED' and old_status == 'REQUESTED') or  (new_status == 'STARTED' and old_status == 'RE_REQUESTED'):
                    updated_order = serializer.save()
                    data = serializer.data
                    data['response'] = 'Update successful'
                elif new_status == 'IN_PROGRESS' and old_status == 'STARTED':
                    updated_order = serializer.save()
                    data = serializer.data
                    data['response'] = 'Update successful'
                elif new_status == 'COMPLETED' and old_status == 'IN_PROGRESS':
                    updated_order = serializer.save()
                    data = serializer.data

                    # Updating delivery photo if exist
                    try:
                        update_order.delivery_photo = request.data["image"]
                        update_order.save()
                    except:
                        pass
                    data['response'] = 'Update successful'
                elif new_status == 'REJECTED' and old_status == 'STARTED':
                    # request.data['freelancer'] = None
                    print(f'REQ: {request.data}')
                    print(f'SER: {serializer}')
                    updated_order = serializer.save()
                    update_order.freelancer = None
                    update_order.save()
                    data = serializer.data
                    data['response'] = 'Update successful'
                elif new_status == 'RE_REQUESTED':
                    updated_order = serializer.save()
                    data = serializer.data
                    data['response'] = 'Update successful'
                elif new_status == 'ARCHIVED' and (old_status == 'REQUESTED' or old_status == 'RE_REQUESTED'):
                    updated_order = serializer.save()
                    data = serializer.data
                    data['response'] = 'Update successful'

                else:
                    data['response'] = f'Update failed. Wrong order status. in: {new_status} current: {old_status}'

                data['business_lat'] = business.lat
                data['business_lon'] = business.lon
                data['business_phone'] = business.phone

            else:
                data['response'] = "Update failed. Missing status parameter."
        else:
            data = serializer.errors
        
        return Response(data)

@api_view(['GET',])
@permission_classes((IsAdminUser,))
def all_user_orders(request):
    '''
    User orders
    '''
    if request.method == 'GET':
        serializer = UserSerializer(data=request.data)
        order_data = {}
        if serializer.is_valid():
            account = serializer.save()
            order_data['token'] = Token.objects.get(user=account).key
            
            if request.user.is_employee:
                data = Order.objects.filter(freelancer=request.user.pk)
            else:
                data = Order.objects.filter(business=request.user.pk)
        else:
            order_data = serializer.errors
    
        return Response(order_data)

@api_view(['POST',])
def registration_view(request):
    '''
    Register a new user with the API
    '''
    if request.method == 'POST':
        serializer = UserSerializer(data=request.data)
        data = {}
        if serializer.is_valid():
            # Creating the new User account
            account = serializer.save()
            data['response'] = 'Success registration.'
            data['email'] = account.email
            data['username'] = account.username
            token = Token.objects.get(user=account).key
            print(f'TOKEN: {token}')
            data['token'] = token

            # Creating the profile
            if account.is_employer:
                employer = Employer.objects.get_or_create(pk=account.pk)
            else:
                employee = Employee.objects.get_or_create(pk=account.pk)

        else:
            data = serializer.errors
        
        return Response(data)
        
@api_view(['POST',])
@permission_classes((IsAuthenticated,))
def phone_verification(request):
    '''
    1) Receive phone update request from the user
    2) Send the phone number to Twilio (that sends a code to the user via SMS)
    3) Receive the code from the user
    4) Post the code to Twilio with the phone number
    5) On approved status from Twilio: 
        a) update the phone in DB 
        b) send confirmation to the user
    '''
    data = {}
    if request.data['is_employee'] == 1:
        user = Employee.objects.get(pk=request.data['user_id'])
        serializer = EmployeeProfileSerializer(user, data=request.data)
    else:
        user = Employer.objects.get(pk=request.data['user_id'])
        serializer = EmployerProfileSerializer(user, data=request.data)

    if request.method == 'POST':
        # Items 1 and 2
        if request.data['action'] == 'new_phone' :
            new_phone = request.data['phone']
            country_code = request.data['country_code']
            
            # Checking phone validity before sending to Twilio
            valid_new_phone_number = clean_phone_number(new_phone, country_code)
            
            if (valid_new_phone_number):
                print(f'Phone is good: {new_phone}. Country: {country_code}. Sending to Twilio')
                
                if settings.DEBUG:
                    timer = 0
                    while timer < 3:
                        print('simulating sending to Twilio...')
                        time.sleep(1)
                        timer += 1
                    sent_sms_status = True
                else:
                    print('Sending SMS code request to Twilio')
                    logger.info('>>> API: Sending SMS code request to Twilio')
                    sent_sms_status = phone_verify(request, action='send_verification_code', phone=new_phone, code=None)


                if sent_sms_status:
                    data['response'] = 'Update successful'
                    return Response(data)
                else:
                    print(f'>>> API: Bad phone request. ERROR: {sent_sms_status}')
                    logger.error(f'>>> API: Bad phone request. ERROR: {sent_sms_status}')
                    data['response'] = f'Bad phone request. ERROR: {sent_sms_status}'
                    return Response(data)
                
                # TESTING
                # data['response'] = 'Update successful'
                return Response(data)
            else:
                print(f'Bad phone number. Phone: {new_phone}')
                data['response'] = f'Bad phone number.'
                return Response(data)


        # Items 3, 4, 5
        elif request.data['action'] == "verify_code":
            user_code = request.data['verification_code']
            new_phone = request.data['phone']
            



            if settings.DEBUG:
                timer = 0
                while timer < 3:
                    print('simulating checking SMS...')
                    time.sleep(1)
                    timer += 1
                sent_sms_status = True
                verification_status = 'approved'
            else:
                print('Sending approval request to Twilio')
                verification_status = phone_verify(request, action='verify_code', phone=new_phone, code=user_code)

            if serializer.is_valid():            
                data = serializer.data
                if verification_status == 'approved':
                    # Save to profile
                    try:
                        user.phone = new_phone
                        user.save()
                        data['response'] = 'Update successful'
                        check_profile_approved(user.pk, request.data['is_employee'])
                    except Exception as e:
                        print(f'Faied to update PROFILE phone. E: {e}')
                        logger.error(f'Faied to update PROFILE phone. E: {e}')
                        data['response'] = 'Update Profile phone Failed'
                        
                    # Save to User
                    try:
                        user.user.phone_number = new_phone
                        user.user.save()
                        data['response'] = 'Update successful'
                    except Exception as e:
                        print(f'Faied to update USER phone. E: {e}')
                        logger.error(f'Faied to update USER phone. E: {e}')
                        data['response'] = 'Update USER phone Failed'

                    return Response(data)
                else:
                    data['response'] = f'Bad phone request. ERROR: {verification_status}'
                    return Response(data)
            else:
                return Response(serializer.errors)
        
        return Response(status.HTTP_400_BAD_REQUEST)


@api_view(['POST',])
@permission_classes((IsAuthenticated,))
def email_verification(request):
    data = {}

    if platform.system() == 'Darwin': # MAC
        current_site = 'http://127.0.0.1:8000' if settings.DEBUG else settings.DOMAIN_PROD
    else:
        current_site = settings.DOMAIN_PROD

    if request.data['is_employee'] == 1:
        user = Employee.objects.get(pk=request.data['user_id'])
        serializer = EmployeeProfileSerializer(user, data=request.data)
    else:
        user = Employer.objects.get(pk=request.data['user_id'])
        serializer = EmployerProfileSerializer(user, data=request.data)

    if request.method == 'POST':
        if (request.data['check'] == 'send_code'):
            email = request.data['email']
            verification_code = random.randint(10001,99999)
            print(f'SENDING EMAIL VRIFICATION CODE {verification_code} EMAIL TO: {email}')
            subject = 'Verify new email'

            message = {
                'user': user,
                'verification_code': verification_code
            }

            send_mail(subject, email_template_name=None,
                    context=message, to_email=[email],
                    html_email_template_name='dndsos/email_verification_email.html')
            # Saving the code in user profile
            user.verification_code = verification_code
            user.save()

            # user = User.objects.get(pk=request.data['user_id'])
            # user.email = email
            # user.username = email
            # user.save()
            
            data['response'] = 'Update successful'
            return Response(data)
        elif (request.data['check'] == 'test_result'):
            server_code = user.verification_code
            user_code = request.data['code']
            new_email = request.data["email"]
            if user_code == server_code:
                if serializer.is_valid():
                    data = serializer.data
                    print(f'Updating email with: {new_email}')
                    # Updating Profile
                    user.email = new_email
                    user.username = new_email
                    user.save()
                    
                    # Updating User model
                    user = User.objects.get(pk=request.data['user_id'])
                    user.email = new_email
                    user.username = new_email
                    user.save()

                    check_profile_approved(user.pk, request.data['is_employee'])

                    data['response'] = 'Update successful'
                    return Response(data)
            else:
                data['response'] = "Update failed"
                return Response(data)
    else:
        return Response(status.HTTP_400_BAD_REQUEST)


class UserRecordView(APIView):
    """
    API View to create or get a list of all the registered
    users. GET request returns the registered users whereas
    a POST request allows to create a new user.
    """

    # queryset = User.objects.all()
    # serializer_class = UserSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAdminUser,)

    def get(self, format=None):
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid(raise_exception=ValueError):
            serializer.create(validated_data=request.data)
            return Response(
                serializer.data,
                status=status.HTTP_201_CREATED
            )
        return Response(
            {
                "error": True,
                "error_msg": serializer.error_messages,
            },
            status=status.HTTP_400_BAD_REQUEST
        )
