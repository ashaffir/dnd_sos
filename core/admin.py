from django.contrib import admin
from imagekit.admin import AdminThumbnail

from core.models import User, Employer, Employee, Asset, AssignedAsset, BankDetails
from django.contrib.gis.admin import OSMGeoAdmin

class PhotoAdmin(admin.ModelAdmin):
    list_display = ('__str__', 'admin_thumbnail')
    admin_thumbnail = AdminThumbnail(image_field='profile_pic')

# admin.site.register(Employer, PhotoAdmin)
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
                'email', 'phone','credit_card_token',
                'address','street', 'building_number', 'city', 'lat', 'lon', 'location',
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
        'address',
        'city',
        'vehicle',
        'is_approved',
        'is_available',
        'is_delivering',
        )
    search_fields = ('bio','city','business_name',)

@admin.register(User)
class User(admin.ModelAdmin):
    list_display = ['pk','email','is_employer','is_employee']
    search_fields = ('username','email')

admin.site.register(BankDetails)
# admin.site.register(Employer)
# admin.site.register(Employee)
# admin.site.register(Asset)
# admin.site.register(AssignedAsset)