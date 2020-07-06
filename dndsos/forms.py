from django import forms
from django.forms import ModelForm

from .models import ContactUs

class ContactForm(forms.ModelForm):
    fname = forms.CharField(max_length=100, required=True, widget=forms.TextInput(attrs={'class': 'form-control rounded-1', 'placeholder': 'First Name'}))
    lname = forms.CharField(max_length=100, required=True, widget=forms.TextInput(attrs={'class': 'form-control rounded-1', 'placeholder': 'Last Name'}))
    email = forms.EmailField(max_length=100, required=True, widget=forms.TextInput(attrs={'class': 'form-control rounded-1', 'placeholder': 'eMail'}))
    subject = forms.CharField(max_length=100, required=True, widget=forms.TextInput(attrs={'class': 'form-control rounded-1', 'placeholder': 'Subject'}))
    message = forms.CharField(required=True, widget=forms.Textarea(attrs={'rows': 4, 'cols': 40,'class': 'form-control rounded-1', 'placeholder': 'Message'}))
    
    class Meta:
        model = ContactUs
        fields = ['fname','lname','email','subject','message',]
