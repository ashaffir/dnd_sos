import phonenumbers
from django import forms
from django.forms import ModelForm
from django.core.exceptions import ValidationError
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth import get_user_model

# from django_select2 import ModelSelect2Widget 

from orders.models import Order
from core.models import Employer, Employee, BankDetails

class BusinessUpdateForm(forms.ModelForm):

    # Adding these for the "required=False" so that it wont be mandatory to fill out everything in the form
    phone = forms.CharField(required=False, widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Phone'}))
    building_number = forms.CharField(required=False, widget=forms.TextInput(attrs={'class': 'form-control'}))
    street = forms.CharField(required=False, widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Street'}))
    city = forms.CharField(required=False, widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'City'}))
    business_name = forms.CharField(required=False, widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Business Name'}))
 
    business_category = forms.ChoiceField(
        required=False, 
        widget=forms.Select(attrs={'class': 'form-control'}),
        choices=(
            ('Restaurant', _('Restaurant')),
            ('Clothes', _('Clothes')),
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
            # 'phone',
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
    # phone = forms.CharField(required=True, widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Phone'}))
    
    # country = forms.ChoiceField(
    #     required=True, 
    #     widget=forms.Select(attrs={'class': 'form-control', 'placeholder': 'Country'}),
    #     choices=(
    #         ('IL', 'Israel'),
    #         ('USA', 'USA'),
    #     ))

    vehicle = forms.ChoiceField(
        label=_('Vehicle'), 
        required=False, 
        widget=forms.Select(attrs={'class': 'form-control'}),
        choices=(
            ('Car', _("Car")),
            ('Scooter', _("Scooter")),
            ('Bicycle', _("Bicycle")),
            ('Motorcycle', _("Motorcycle")),
            ('Truck', _("Truck")),
        ))
    
    active_hours = forms.ChoiceField(widget=forms.Select(attrs={'class': 'form-control'}), choices=Employee.ACTIVE_HOURS)

    def clean_phone_number(self):
            phone_number = self.cleaned_data.get("phone")
            z = phonenumbers.parse(phone_number, self.cleaned_data.get('country'))
            
            if not phonenumbers.is_valid_number(z):
                raise forms.ValidationError("Phone number not valid")
            return z.national_number

    class Meta:
        model = Employee
        fields = [
            'name',
            'city',
            # 'country',
            'bio',
            'email',
            # 'phone',
            'vehicle',
            'active_hours',
            'profile_pic',
            'id_doc',
            'newsletter_optin',
            ]
        
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Name'}),
            'vehicle': forms.Select(attrs={'class': 'form-control'}),
            # 'phone': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Phone'}),
            'bio': forms.Textarea(attrs={'class': 'form-control ', 'rows':'3','cols':'50', 'placeholder': 'Bio'}),
            'city': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'City'}),
            # 'newsletter_optin': forms.CheckboxInput(attrs={'class': 'form-control checkbox-custom checkbox-primary'})
        }


class BankDetailsForm(forms.Form):
    # Owner details
    COUNTRIES = (
        (('IL'), ('Israel')),
        (('USA'), ('USA')),
    )
    first_name = forms.CharField(max_length=100, required=False, widget=forms.TextInput(attrs={'class':'form-control'}))
    last_name = forms.CharField(max_length=100, required=False, widget=forms.TextInput(attrs={'class':'form-control'}))
    national_id_number = forms.CharField(max_length=100, required=False, widget=forms.TextInput(attrs={'class':'form-control'}))
    full_name_in_native_language = forms.CharField(max_length=100, required=False, widget=forms.TextInput(attrs={'class':'form-control'}))
    name_on_the_account = forms.CharField(max_length=100, required=True, widget=forms.TextInput(attrs={'class':'form-control'}))
    address = forms.CharField(max_length=100, required=False, widget=forms.TextInput(attrs={'class':'form-control'}))
    city = forms.CharField(max_length=100, required=False, widget=forms.TextInput(attrs={'class':'form-control'}))
    country = forms.ChoiceField(required=True, choices=COUNTRIES, widget=forms.Select(attrs={'class':'form-control'}))
    phone_number = forms.CharField(max_length=100, required=False, widget=forms.TextInput(attrs={'class':'form-control'}))

    # Bank Details
    iban = forms.CharField(max_length=100, required=True, widget=forms.TextInput(attrs={'class':'form-control'}))
    swift = forms.CharField(max_length=100, required=False, widget=forms.TextInput(attrs={'class':'form-control'}))
    account_number = forms.CharField(max_length=100, required=False, widget=forms.TextInput(attrs={'class':'form-control'}))
    account_ownership = forms.BooleanField(required=True, widget=forms.CheckboxInput(attrs={'class':''}))

    # def clean_phone_number(self):
    #         phone_number = self.cleaned_data.get("phone_number")
    #         z = phonenumbers.parse(phone_number, self.cleaned_data.get('country'))
            
    #         if not phonenumbers.is_valid_number(z):
    #             raise forms.ValidationError("Phone number not valid")
    #         return z.national_number

    # class Meta:
    #     model = BankDetails
    #     fields = [
    #         'first_name',
    #         'last_name',
    #         'full_name_in_native_language',
    #         'name_on_the_account',
    #         'address',
    #         'city',
    #         'country',
    #         'phone_number',
    #         'account_ownership',
    #         'national_id_number',
    #         'iban',
    #         'swift',
    #         'account_number',
    #     ]
