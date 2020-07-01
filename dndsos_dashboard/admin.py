from django.contrib import admin
# from import_export.admin import ImportExportModelAdmin ## Source: https://simpleisbetterthancomplex.com/packages/2016/08/11/django-import-export.html
from django.contrib.admin.views.main import ChangeList
from django.utils.html import format_html
from django.conf.urls import url
from django.shortcuts import redirect
from django.http import HttpResponse
from .models import Email

@admin.register(Email)
class EmailTemplates(admin.ModelAdmin):
    list_display = ('name', 'mail_subject','mail_title', 'mail_body')
    search_fields = ('name',)
    ordering = ('-name',)
