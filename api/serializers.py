from django.contrib.auth import get_user_model, authenticate
from rest_framework import serializers, exceptions
from rest_framework.validators import UniqueTogetherValidator

from core.models import User, Employee, Employer
from dndsos.models import ContactUs

class EmployeeProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Employee
        # fields = ['email','name','phone','vehicle',]
        # fields = '__all__'
        exclude = ('user', )

class EmployerProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Employer
        # fields = ['email','business_name','phone',]
        # fields = '__all__'
        exclude = ('user', )

class emailSerializer(serializers.Serializer):
    email = serializers.CharField()

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField()

    def validate(self, data):
        username = data.get('username', "")
        password = data.get('password', "")

        if username and password:
            user = authenticate(username=username, password=password)
            if user:
                if user.is_active:
                    data['user'] = user
                else:
                    msg = 'User is not active'
                    raise exceptions.ValidationError(msg)
            else:
                msg = 'Unable to login with given credentials'
                raise exceptions.ValidationError(msg)

        else:
            msg = 'Username and Password must be entered'
            raise exceptions.ValidationError(msg)
        
        return data

class UserSerializer(serializers.ModelSerializer):

    password1 = serializers.CharField(write_only=True)
    password2 = serializers.CharField(write_only=True)

    def validate(self, data):
        if data['password1'] != data['password2']:
            raise serializers.ValidationError('Passwords must match.')
        return data

    def create(self, validated_data):
        data = {
            key: value for key, value in validated_data.items()
            if key not in ('password1', 'password2')
        }
        data['password'] = validated_data['password1']
        return self.Meta.model.objects.create_user(**data)

    class Meta:
        model = get_user_model()
        fields = (
            'id','username','password1', 'password2','email', 'is_employee', 'is_employer',
            # 'is_employee', 'is_employer','phone_number',
        )
        read_only_fields = ('id',)

class ContactsSerializer(serializers.ModelSerializer):
    class Meta:
        model = ContactUs
        fields = '__all__'

class BusinessSerializer(serializers.ModelSerializer):
    class Meta:
        model = Employer
        fields = ('business_name',)

class UsernameSerializer(serializers.ModelSerializer):
    user = serializers.SerializerMethodField()
    
    class Meta:
        model = Employee
        fields = ('user', 'name', 'city',)

    def get_user(self, obj):
        users = []
        for u in obj:
            users.append(u.name)
        return str(users)

