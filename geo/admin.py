from django.contrib import admin
from django.contrib.gis.admin import OSMGeoAdmin

from .models import City, Entry

@admin.register(City)
class City(admin.ModelAdmin):
    list_display = ('name',)
    search_fields = ('name',)
    ordering = ('name',)


@admin.register(Entry)
class EntryAdmin(OSMGeoAdmin):
    # default_lon = 3872758
    # default_lat = 3773892
    # default_zoom = 10

    default_lon = 1400000
    default_lat = 7495000
    default_zoom = 12

    #...
