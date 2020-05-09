from django.contrib import admin
# from import_export.admin import ImportExportModelAdmin ## Source: https://simpleisbetterthancomplex.com/packages/2016/08/11/django-import-export.html
from django.contrib.admin.views.main import ChangeList
from django.utils.html import format_html
from django.conf.urls import url
from django.shortcuts import redirect
from django.http import HttpResponse
from .models import Order, BusinessProfile, FreelancerProfile, Email



@admin.register(Order)
class Order(admin.ModelAdmin):
    list_display = (
        'created',
        'order_business',
        'order_id',
        'order_dispatched',
        'order_delivered',
        'status',
        'order_city',
        )
    search_fields = ('order_id','city','order_notes','order_business',)
    ordering = ('-created',)
    
    list_filter = (
        'status',
    )
    readonly_fields = (
        'id', 'created',
    )

@admin.register(Email)
class Email(admin.ModelAdmin):
    list_display = ('name', 'mail_subject','mail_title', 'mail_body')
    search_fields = ('name',)
    ordering = ('-name',)
# @admin.register(FreelancerProfile)
# class FreelancerProfile(admin.ModelAdmin):
#     list_display = (
#         'created',
#         'user',
#         'city',
#         'vehicle',
#         'active_hours',
#         )
#     search_fields = ('bio','city','vehicle',)
#     ordering = ('-created',)


# # admin.site.register(Profile)
# admin.site.register(Order)

# @admin.register(BusinessProfile)
# class BusinessProfile(admin.ModelAdmin):
#     list_display = (
#         'created',
#         'id',
#         'email', 
#         'phone')
#     search_fields = ('email',)
#     ordering = ('-created',)

# @admin.register(FreelancerProfile)
# class FreelancerProfile(admin.ModelAdmin):
#     list_display = (
#         'created',
#         'id',
#         'user', 
#         'email', 
#         'phone')
#     search_fields = ('email',)
#     ordering = ('-created',)

# @admin.register(Order)
# class Order(admin.ModelAdmin):
#     list_display = (
#         'created',
#         'id',
#         'status',
#         'order_time',
#         'order_ready',
#         'order_dispatched',
#         'order_delivered',
#         'business',
#         'freelancer'
#     )

#     search_fields = (
#         'business',
#         'freelancer',
#         'order_time',
#     )

#     ordering = ('-created',)