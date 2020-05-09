from django.contrib import admin

from core.models import User, Employer, Employee, Asset, AssignedAsset

@admin.register(Employer)
class Employer(admin.ModelAdmin):
    list_display = (
        'business_name',
        'user',
        'city',
        )
    search_fields = ('bio','city','business_name',)
    # ordering = ('-created',)

@admin.register(Employee)
class Employee(admin.ModelAdmin):
    list_display = (
        'user',
        'city',
        'vehicle',
        )
    search_fields = ('bio','city','business_name',)

admin.site.register(User)
# admin.site.register(Employer)
# admin.site.register(Employee)
admin.site.register(Asset)
admin.site.register(AssignedAsset)