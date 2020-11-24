from django.contrib import admin
from .models import Newsletter

@admin.register(Newsletter)
class ContactUs(admin.ModelAdmin):
    list_display = ('created','name','sent', 'sent_date','recipients_count',)
    search_fields = ('name',)
    ordering = ('-created',)

# admin.site.register(Newsletter)

