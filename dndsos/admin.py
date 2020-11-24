from django.contrib import admin

from .models import ContactUs, ContentPage, FreelancerFeedback, AdminParameters, AlertMessage

@admin.register(ContactUs)
class ContactUs(admin.ModelAdmin):
    list_display = ('created','fname','email', 'subject')
    search_fields = ('name','email')
    ordering = ('-created',)

@admin.register(AlertMessage)
class ContactUs(admin.ModelAdmin):
    list_display = ('alert_message_page','alert_message_title',)
    search_fields = ('alert_message_page','alert_message_title')
    # ordering = ('-created',)

admin.site.register(AdminParameters)

@admin.register(ContentPage)
class ContentPage(admin.ModelAdmin):
    list_display = ('name','section','active',)
    search_fields = ('name','section',)
    ordering = ('name',)

@admin.register(FreelancerFeedback)
class FreelancerFeedback(admin.ModelAdmin):
    list_display = ('freelancer','overall',)
    search_field = ('freelancer')