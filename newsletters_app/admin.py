from django.contrib import admin
from .models import Newsletter, EmailTemplate

@admin.register(Newsletter)
class NewletterAdmin(admin.ModelAdmin):
    list_display = ('created','name','sent', 'sent_date','recipients_count',)
    search_fields = ('name',)
    ordering = ('-created',)

@admin.register(EmailTemplate)
class ContactUs(admin.ModelAdmin):
    list_display = ('name','subject', 'title', 'language',)
    search_fields = ('name','subject','title',)
    # ordering = ('-created',)

# admin.site.register(Newsletter)

