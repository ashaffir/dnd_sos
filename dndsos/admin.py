from django.contrib import admin

from .models import ContactUs, ContentPage

@admin.register(ContactUs)
class ContactUs(admin.ModelAdmin):
    list_display = ('created','fname','email', 'subject')
    search_fields = ('name','email')
    ordering = ('-created',)

admin.site.register(ContentPage)
