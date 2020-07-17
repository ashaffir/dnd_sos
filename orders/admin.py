from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DefaultUserAdmin
from django.contrib.gis.admin import OSMGeoAdmin

from .models import Order

@admin.register(Order)
class OrderAdmin(OSMGeoAdmin):
    fields = ( # changed
        'order_id', 'order_type','order_city_name', 'pick_up_address', 'drop_off_address', 'status','order_location',
        'distance_to_business','trip_completed', 'price','private_sale_token','invoice_url',
        'freelancer','freelancer_rating', 'business','business_rating',
        'selected_freelancers',
        'trip',
        'chat', 
        'created', 'updated','new_message',
    )
    list_display = ( # changed
        'order_id','order_type', 'pick_up_address', 'drop_off_address','distance_to_business', 'status',
        'freelancer', 'business',
        'new_message',
        'updated',
    )
    list_filter = (
        'status',
    )
    readonly_fields = (
        'order_id', 'created', 'updated',
    )

    ordering = ('-updated',)