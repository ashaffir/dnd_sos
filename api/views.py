import platform
import json
import logging
import random
from datetime import date
from django.contrib.auth import login as django_login, logout as django_logout
from django.db.models import Q
from django.contrib.gis.geos import fromstr, Point
from fcm_django.models import FCMDevice
from django.core import serializers as djangoSerializers
from django.conf import settings
# from django.contrib.auth.models import User
from rest_framework import viewsets, permissions
from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.authentication import TokenAuthentication, SessionAuthentication, BasicAuthentication
from rest_framework.authtoken.models import Token
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.pagination import (LimitOffsetPagination, PageNumberPagination,)

from core.models import User, Employee, Employer
from orders.models import Order
from dndsos.models import ContactUs
from dndsos_dashboard.views import phone_verify
from dndsos_dashboard.utilities import send_mail

from .serializers import (UserSerializer, LoginSerializer, 
                        ContactsSerializer, BusinessSerializer, 
                        UsernameSerializer, EmployeeProfileSerializer, EmployerProfileSerializer,)
from orders.serializers import OrderSerializer, OrderAPISerializer
from .permissions import IsOwnerOrReadOnly # Custom permission

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
            return Response({'response':'Bad user ID'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user_location = Point(lat,lon)
            user.location = user_location
            user.save()
        except Exception as e:
            return Response({'response':'Bad coordinates'}, status=status.HTTP_400_BAD_REQUEST)

        return Response({'response':'Location updated'},status=200)

class UserAvailable(APIView):
    authentications_classes = (TokenAuthentication,)
    def put(self, request, *arg, **kwargs):
        try:
            user_id = self.request.GET.get('user')
            user = Employee.objects.get(pk=user_id)
        except Exception as e:
            return Response({'response':'Bad user ID'}, status=status.HTTP_400_BAD_REQUEST)

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
                daily_profit += order.price

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
            orders_in_progress = active_orders = Order.objects.filter(
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

            login_response = {'token': token.key,
                            'fcm_token':fcm_token,
                            "user":user.pk,
                            "is_employee": 1 if user.is_employee else 0,
                            "business_name":  business_name,
                            "phone": phone,
                            "business_category": business_category,
                            "is_approved": 1 if is_approved else 0,
                            "num_daily_orders": num_daily_orders,
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

class ActiveOrdersViewSet(viewsets.ModelViewSet):
    serializer_class = OrderAPISerializer
    authentication_classes = [TokenAuthentication,]
    permission_classes = (IsAuthenticated,)

    # queryset = Order.objects.all()

    def get_queryset(self, *args, **kwargs):
        queryset_list = Order.objects.all()
        user = self.request.GET.get('user')
        print(f'Active Orders for User: {user}')
        if user:
            queryset_list = queryset_list.filter(
                Q(freelancer=user) & 
                (Q(status='STARTED') | Q(status="IN_PROGRESS")) 
            )
        return queryset_list

class BusinessOrdersViewSet(viewsets.ModelViewSet):
    serializer_class = OrderAPISerializer
    authentication_classes = [TokenAuthentication,]
    permission_classes = (IsAuthenticated,)

    # queryset = Order.objects.all()

    def get_queryset(self, *args, **kwargs):
        queryset_list = Order.objects.all()
        user = self.request.GET.get('user')
        print(f'User: {user}')
        if user:
            queryset_list = queryset_list.filter(
                Q(business=user) & 
                (
                    Q(status='STARTED') | 
                    Q(status="IN_PROGRESS") | 
                    Q(status="REQUESTED") |
                    Q(status="RE_REQUESTED") 
                    ) 
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
        print(f'User: {user}')
        if user:
            queryset_list = queryset_list.filter(
                Q(business=user) & (Q(status="REJECTED")) 
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


@api_view(['PUT','POST',])
# @permission_classes((IsAuthenticated,))
@permission_classes((IsAuthenticated,))
def user_profile(request):
    '''
    returns user profile information
    '''

    # try:
        # user = User.objects.get(pk=request.user.pk)
    if request.data['is_employee'] == 1:
        user = Employee.objects.get(pk=request.data['user_id'])
        serializer = EmployeeProfileSerializer(user, data=request.data)
    else:
        user = Employer.objects.get(pk=request.data['user_id'])
        serializer = EmployerProfileSerializer(user, data=request.data)

    # except Exception as e:
    #     return Response(status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'POST':
        data = {}
        if serializer.is_valid():
            data = serializer.data
            print('SENDING PROFILE DATA')
        else:
            data = serializer.errors
            logger.error(f'Failed reading user profile. ERROR: {data}')

        return Response(data)

    elif request.method == 'PUT':
        data = {}
        if serializer.is_valid():
            # if (new_status == 'STARTED' and old_status == 'REQUESTED') or  (new_status == 'STARTED' and old_status == 'RE_REQUESTED'):
            try:
                if request.data['first_name']:
                    updated_order = serializer.save()
                    data = serializer.data
                    data['response'] = 'Update successful'
                    print(f'NAME update: {request.data["first_name"]}')
            except:
                pass
            try:
                if request.data['phone_number']:
                    updated_order = serializer.save()
                    data = serializer.data
                    data['response'] = 'Update successful'
                    print(f'PHONE update: {request.data["phone_number"]}')
            except:
                pass
            
            try:
                if request.data['vehicle']:
                    updated_order = serializer.save()
                    data = serializer.data
                    data['response'] = 'Update successful'
                    print(f'VEHICLE update: {request.data["vehicle"]}')
            except:
                pass

            try:
                if request.data['email']:
                    updated_order = serializer.save()
                    data = serializer.data
                    data['response'] = 'Update successful'
                    print(f'EMAIL update: {request.data["email"]}')
            except:
                pass

        else:
            data = serializer.errors
            logger.error(f'Failed updated user profile. ERROR: {data}')

        return Response(data)
    else:
        return Response(status=status.HTTP_400_BAD_REQUEST)



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



@api_view(['GET',])
@permission_classes((IsAuthenticated,))
def open_orders_view(request):
    '''
    View open orders
    '''
    try:
        open_orders = Order.objects.filter(Q(status='REQUESTED') | Q(status='RE_REQUESTED'))
    except Order.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = OrderSerializer(open_orders, data=request.data)
        orders = []
        for order in open_orders:
            if serializer.is_valid():
                ser_order = serializer.data
                orders.append(ser_order)
            else:
                print(f'ERROR: {serializer.errors}')
                data = serializer.errors
        # data['response'] = 'Update successful'
        data = json.dumps(orders)
        print(data)
        return Response(data)


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
                else:
                    data['response'] = f'Update failed. Wrong order status. in: {new_status} current: {old_status}'
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
    else:
        user = Employer.objects.get(pk=request.data['user_id'])

    if request.method == 'POST':
        # Items 1 and 2
        if request.data['action'] == 'new_phone' :
            new_phone = request.data['phone']
            # user.verification_code = new_phone
            sent_sms_status = phone_verify(request, action='send_verification_code', phone=new_phone, code=None)
            if sent_sms_status:
                # user.save()
                data['response'] = 'Update successful'
                return Response(data)
            else:
                data['response'] = f'Bad phone request. ERROR: {sent_sms_status}'
                return Response(data)

        # Items 3, 4, 5
        elif request.data['action'] == "verify_code":
            user_code = request.data['code']
            new_phone = request.data['phone']
            verification_status = phone_verify(request, action='verify_code', phone=new_phone, code=user_code)
            if verification_status == 'approved':
                user.phone = new_phone
                user.save()
                data['response'] = 'Update successful'
                return Response(data)
            else:
                data['response'] = f'Bad phone request. ERROR: {verification_status}'
                return Response(data)
        
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
    else:
        user = Employer.objects.get(pk=request.data['user_id'])

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
            data['response'] = 'Update successful'
            return Response(data)
        elif (request.data['check'] == 'test_result'):
            server_code = user.verification_code
            user_code = request.data['code']
            if user_code == server_code:
                print(f'Updating email with: {request.data["email"]}')
                user.email = request.data['email']
                user.save()
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
