from django.contrib import admin

from core.models import User, Employer, Employee, Asset, AssignedAsset
from django.contrib.gis.admin import OSMGeoAdmin

@admin.register(Employer)
class Employer(OSMGeoAdmin):
    list_display = (
        'pk',
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
        'pk',
        'user',
        'name',
        'city',
        'vehicle',
        'is_approved',
        'is_available',
        'is_active',
        )
    search_fields = ('bio','city','business_name',)

@admin.register(User)
class User(admin.ModelAdmin):
    list_display = ['pk','email','is_employer','is_employee']
    search_fields = ('username','email')

# admin.site.register(User)
# admin.site.register(Employer)
# admin.site.register(Employee)
# admin.site.register(Asset)
# admin.site.register(AssignedAsset)