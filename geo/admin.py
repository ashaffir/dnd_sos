from django.contrib import admin
from django.contrib.gis.admin import OSMGeoAdmin

from .models import City,Country , Entry, BusinessLocation, UserLocation, CityModel, Street

@admin.register(CityModel)
class CityModel(admin.ModelAdmin):
    list_display = ('city_symbol','hebrew_name',)
    search_fields = ('hebrew_name',)
    ordering = ('city_symbol',)

@admin.register(Street)
class Street(admin.ModelAdmin):
    list_display = ('country','street_id','street_name', 'city_symbol', 'city_name',)
    list_filter = ('city_name','country',)
    search_fields = ['street_name', 'city_name']
    ordering = ('street_id',)

# @admin.register(Entry)
# class EntryAdmin(OSMGeoAdmin):
#     # default_lon = 3872758
#     # default_lat = 3773892
#     # default_zoom = 10

#     default_lon = 1400000
#     default_lat = 7495000
#     default_zoom = 12

#     #...

# @admin.register(BusinessLocation)
# class BusinessLocation(OSMGeoAdmin):
#     list_display = ('name', 'address', 'city',)
#     ordering = ('name',)

# @admin.register(UserLocation)
# class UserLocation(OSMGeoAdmin):
#     list_display = ('user_id', 'user_location',)
#     ordering = ('user_id',)


# DEMO
# @admin.register(City)
# class City(OSMGeoAdmin):
#     list_display = ('pk','name',)
#     search_fields = ('name',)
#     ordering = ('name',)

# @admin.register(Country)
# class Country(OSMGeoAdmin):
#     list_display = ('name',)
#     search_fields = ('name',)
#     ordering = ('name',)

