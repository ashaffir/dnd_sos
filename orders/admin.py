from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DefaultUserAdmin

from .models import Order

# @admin.register(Order)
# class Order(admin.ModelAdmin):
#     list_display = (
#         'created',
#         'order_business',
#         'order_id',
#         'order_dispatched',
#         'order_delivered',
#         'status',
#         'order_city',
#         )
#     search_fields = ('order_id','city','order_notes','order_business',)
#     ordering = ('-created',)
    
#     list_filter = (
#         'status',
#     )
#     readonly_fields = (
#         'id', 'created',
#     )

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    fields = ( # changed
        'order_id', 'pick_up_address', 'drop_off_address', 'status', 'notes',
        'freelancer', 'business',
        'selected_freelancers',
        'created', 'updated',
    )
    list_display = ( # changed
        'order_id', 'pick_up_address', 'drop_off_address', 'status','notes',
        'freelancer', 'business',
        'updated',
    )
    list_filter = (
        'status',
    )
    readonly_fields = (
        'order_id', 'created', 'updated',
    )

    ordering = ('-updated',)