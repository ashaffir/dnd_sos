from django.contrib import admin

from core.models import User, Employer, Employee, Asset, AssignedAsset
from django.contrib.gis.admin import OSMGeoAdmin

@admin.register(Employer)
class Employer(OSMGeoAdmin):
    list_display = (
        'user',
        'business_name',
        'city',
        'is_approved',
        )
    
    fields = (  'user', 'business_name', 'business_category',
                'email', 'phone',
                'street', 'building_number', 'city', 'lat', 'lon', 'location',
                'b_freelancers',
                'profile_pic',
                'newsletter_optin',
                'is_approved'
            )

    search_fields = ('bio','city','business_name',)
    # ordering = ('-created',)

@admin.register(Employee)
class Employee(OSMGeoAdmin):
    list_display = (
        'user',
        'city',
        'vehicle',
        'is_available',
        'is_approved',
        )
    search_fields = ('bio','city','business_name',)

@admin.register(User)
class User(admin.ModelAdmin):
    list_display = ['email','is_employer','is_employee']
    fields = ['username','email', 'is_employer', 'is_employee',
                'phone_number', 'relationships'
            ]
    search_fields = ('username','email')

# admin.site.register(Employer)
# admin.site.register(Employee)
admin.site.register(Asset)
admin.site.register(AssignedAsset)