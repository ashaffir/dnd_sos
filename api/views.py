from django.contrib.auth import login as django_login, logout as django_logout
from django.db.models import Q

# from django.contrib.auth.models import User
from rest_framework import viewsets, permissions
from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.authentication import TokenAuthentication, SessionAuthentication, BasicAuthentication
from rest_framework.authtoken.models import Token
from rest_framework.pagination import (LimitOffsetPagination, PageNumberPagination,)

from core.models import User, Employee, Employer
from orders.models import Order
from dndsos.models import ContactUs

from .serializers import (UserSerializer, LoginSerializer, 
                        ContactsSerializer, BusinessSerializer, 
                        UsernameSerializer,UserProfileSerializer,)
from orders.serializers import OrderSerializer
from .permissions import IsOwnerOrReadOnly # Custom permission

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


class OrdersView(viewsets.ModelViewSet):
    serializer_class = OrderSerializer

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
    
    # permission_classes = (IsAdminUser,)

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
        print(f'USER: {user}')
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
def open_order_view(request):
    '''
    View open orders
    '''
    try:
        open_orders = Order.objects.get(order_id=request.data['order_id'])
    except Order.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = OrderSerializer(open_orders, data=request.data)
        data = {}
        if serializer.is_valid():
            data = serializer.data
            data['response'] = 'Update successful'
        else:
            data = serializer.errors
        
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
        if serializer.is_valid():
            updated_order = serializer.save()
            data['response'] = 'Update successful'
        else:
            data = serializer.errors
        
        return Response(data)

@api_view(['GET',])
# @permission_classes((IsAuthenticated,))
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
            account = serializer.save()
            data['response'] = 'Success registration.'
            data['email'] = account.email
            data['username'] = account.username
            token = Token.objects.get(user=account).key
            data['token'] = token
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
