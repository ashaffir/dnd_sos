from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DefaultUserAdmin
from django.contrib.gis.admin import OSMGeoAdmin

from .models import Order

@admin.register(Order)
class OrderAdmin(OSMGeoAdmin):
    fields = ( # changed
        'order_id', 'order_type','order_city_name', 'pick_up_address', 'drop_off_address', 'status','is_urgent',
        'order_lat', 'order_lon','business_lat', 'business_lon', 'order_location',
        'distance_to_business','trip_completed', 'price','fare','private_sale_token','invoice_url', 'order_cc','sale_id',
        'freelancer','freelancer_rating','freelancer_rating_report', 'business','business_rating',
        'selected_freelancers', 'delivery_photo',
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
        'status','order_type'
    )
    readonly_fields = (
        'order_id', 'created', 'updated',
    )

    search_fields = ('freelancer__email', 'business__email', 'order_id', )

    ordering = ('-updated',)