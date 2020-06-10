from django import forms
from django.forms import ModelForm

from .models import ContactUs

class ContactForm(ModelForm):
    class Meta:
        model = ContactUs
        fields = ['fname','lname','email','subject','message',]
