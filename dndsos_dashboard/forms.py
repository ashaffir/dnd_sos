from django import forms
from django.forms import ModelForm
from django.core.exceptions import ValidationError
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth import get_user_model

# from django_select2 import ModelSelect2Widget 

from orders.models import Order
from core.models import Employer, Employee

class BusinessUpdateForm(forms.ModelForm):

    # Adding these for the "required=False" so that it wont be mandatory to fill out everything in the form
    phone = forms.CharField(required=False, widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Phone'}))
    building_number = forms.CharField(required=False, widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Building number'}))
    street = forms.CharField(required=False, widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Street'}))
    city = forms.CharField(required=False, widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'City'}))
    business_name = forms.CharField(required=False, widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Business Name'}))
 
    business_category = forms.ChoiceField(
        required=False, 
        widget=forms.Select(attrs={'class': 'form-control'}),
        choices=(
            ('Restaurant', _('Restaurant')),
            ('Cothing', _('Clothing')),
            ('Convenience', _('Convenience')),
            ('Grocery', _('Grocery')),
            ('Office', _('Office')),
            ('Other', _('Other')),
        ))

    class Meta:
        model = Employer
        fields = [
            'business_name',
            'business_category',
            'phone',
            'street',
            'building_number',
            'city',
            'newsletter_optin'
        ]
        widgets = {
            # 'business_name': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Business Name'}),
            # 'business_category': forms.Select(attrs={'class': 'form-control'}),
            # 'phone': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Phone'}),
            # 'street': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Street'}),
            # 'building_number': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Building number'}),
            # 'city': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'City'}),
            'newsletter_optin': forms.CheckboxInput(attrs={'class': '', 'style':'margin-top:3%'})
        }

class FreelancerUpdateForm(forms.ModelForm):
    phone = forms.CharField(required=False, widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Phone'}))
    city = forms.CharField(required=False, widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'City'}))
    vehicle = forms.ChoiceField(
        label=_('Vehicle'), 
        required=False, 
        widget=forms.Select(attrs={'class': 'form-control'}),
        choices=(
            ('Car', _("Car")),
            ('Scooter', _("Scooter")),
            ('Bicycle', _("Bicycle")),
            ('Motorcycle', _("Motorcycle")),
            ('Other', _("Other")),
        ))
    active_hours = forms.ChoiceField(widget=forms.Select(attrs={'class': 'form-control'}), choices=Employee.ACTIVE_HOURS)

    class Meta:
        model = Employee
        fields = [
            'name',
            'vehicle',
            'phone',
            'bio',
            'city',
            'newsletter_optin',
            'id_doc',
        ]
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Name'}),
            'vehicle': forms.Select(attrs={'class': 'form-control'}),
            'phone': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Phone'}),
            'bio': forms.Textarea(attrs={'class': 'form-control ', 'rows':'3','cols':'50', 'placeholder': 'Bio'}),
            'city': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'City'}),
            # 'newsletter_optin': forms.CheckboxInput(attrs={'class': 'form-control checkbox-custom checkbox-primary'})
        }
