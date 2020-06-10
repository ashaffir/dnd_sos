from django.contrib import admin

from .models import ContactUs

@admin.register(ContactUs)
class ContactUs(admin.ModelAdmin):
    list_display = ('created','fname','email', 'subject')
    search_fields = ('name','email')
    ordering = ('-created',)
