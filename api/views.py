import json
from datetime import date
from django.contrib.auth import login as django_login, logout as django_logout
from django.db.models import Q
from django.contrib.gis.geos import fromstr, Point
from fcm_django.models import FCMDevice
from django.core import serializers as djangoSerializers

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

from .serializers import (UserSerializer, LoginSerializer, 
                        ContactsSerializer, BusinessSerializer, 
                        UsernameSerializer,UserProfileSerializer,)
from orders.serializers import OrderSerializer, OrderAPISerializer
from .permissions import IsOwnerOrReadOnly # Custom permission


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
                vehicle = user_profile.vehicle
            except:
                vehicle = ''

            try: 
                freelancer_total_rating = user_profile.freelancer_total_rating
            except:
                freelancer_total_rating = ''


            try:
                is_approved = user_profile.is_approved
            except:
                is_approved = ""


            return Response({'token': token.key,
                            'fcm_token':fcm_token,
                            "user":user.pk,
                            "is_employee": 1 if user.is_employee else 0,
                            "name": name,
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
        print(f'Q: {query}')
        if query:
            queryset_list = queryset_list.filter(
                Q(status='REQUESTED') |
                Q(status='RE_REQUESTED')
            )
        return queryset_list

class ActiveOrdersViewSet(viewsets.ModelViewSet):
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


@api_view(['GET',])
@permission_classes((IsAuthenticated,))
def user_profile(request):
    '''
    returns user profile information
    '''

    try:
        print(f'>>> DATA: {request.user.pk}')
        user = Employer.objects.get(pk=request.user.pk)
        user_token = Token.objects.get(user_id=request.user.pk)

    except Exception as e:
        return Response(status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'GET':
        serializer = UserProfileSerializer(user, data=request.data)
        data = {}
        if serializer.is_valid():
            data = serializer.data
            print(f'>>> Token: {Token.objects.get(user_id=request.user.pk)}')
        else:
            data = serializer.errors

        return Response(data)

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
            data['token'] = token

            # Creating the profile
            if account.is_employer:
                employer = Employer.objects.get_or_create(pk=account.pk)
            else:
                employee = Employee.objects.get_or_create(pk=account.pk)

        else:
            data = serializer.errors
        
        return Response(data)
        

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
