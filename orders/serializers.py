from django.contrib.auth import get_user_model
from rest_framework import serializers
from .models import Order
from core.models import Employer, User

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
            'id', 'username', 'password1', 'password2',
            'first_name', 'last_name',
        )
        read_only_fields = ('id',)


class EmployerSerializer(serializers.ModelSerializer):
    business = UserSerializer()
    class Meta:
        model = User
        fields = ('business',)

class OrderSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Order
        fields = ('order_id','status','pick_up_address','created', 'updated', 
                'drop_off_address', 'distance_to_business','order_location', 'order_lon', 'order_lat',
                'price','fare','private_sale_token','customer_transaction_id','invoice_url', 'transaction_auth_num',
                'order_type','business', 'freelancer',)

class OrderAPISerializer(serializers.ModelSerializer):
    # business_name = serializers.SlugRelatedField(read_only=True, slug_field='business_name')
    
    class Meta:
        model = Order
        fields = ('order_id','status','pick_up_address','created', 'updated', 
                'drop_off_address', 'distance_to_business','order_lon', 'order_lat',
                'price','fare', 'order_type','business', 'freelancer',)
        # read_only_fields = ('id', 'created', 'updated',)
        # fields = '__all__'
        depth=1   


class ReadOnlyOrderSerializer(serializers.ModelSerializer):
    freelancer_ser = UserSerializer(read_only=True)
    business_ser = UserSerializer(read_only=True)

    class Meta:
        model = Order
        fields = '__all__'