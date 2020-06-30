from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.db import transaction

from .models import (User, Employer, Employee, Asset, AssignedAsset)

# employer signup form
class EmployerSignupForm(UserCreationForm):
    # business_name = forms.CharField()
    
    class Meta(UserCreationForm.Meta):
        model = User
        fields = ('email', 'password1', 'password2')
    
    @transaction.atomic
    def save(self):
        user = super().save(commit=False)
        user.is_employer = True
        user.is_active = False
        user.save()
        
        # create employer profile for user
        # business_name = self.cleaned_data.get('business_name')
        no_of_emp = self.cleaned_data.get('number_of_employees')
        employer = Employer.objects.create(
            user=user,
            # business_name=business_name
            # number_of_employees=no_of_emp
        )
        
        return user

# employee signup form
class EmployeeSignupForm(UserCreationForm):
    
    CHOICES = (
        ('', 'Choose'),
        ('car', 'Car'),
        ('bicycle', 'Bicycle'),
        ('motorcycle', 'Motorcycle'),
        ('scooter', 'Scooter'),
        ('other', 'Other'),
    )

    ACTIVE_HOURS = (
        ('08:00-12:00', '08:00-12:00'),
        ('12:00-16:00', '12:00-16:00'),
        ('16:00-20:00', '16:00-20:00'),
        ('20:00-00:00', '20:00-00:00'),
    )

    # vehicle = forms.ChoiceField(choices=CHOICES, widget=forms.Select(attrs={'class':'form-group form-control'}))
    
    class Meta(UserCreationForm.Meta):
        model = User
        fields = ('email', 'password1', 'password2')
    
    @transaction.atomic
    def save(self):
        user = super().save(commit=False)
        user.is_employee = True
        user.is_active = False
        user.save()
        
        # create freelancer profile for user
        vehicle = self.cleaned_data.get('vehicle')
        employee = Employee.objects.create(
            user=user,
            vehicle=vehicle
        )
        
        return user


# employer view/update profile 
class EmployerProfileForm(forms.ModelForm):
    business_name = forms.CharField()
    
    CHOICES = (
        ('', 'Choose...'),
        ('10', '10 Employees'),
        ('50', '50 Employees'),
        ('100', '100 Employees'),
        ('1000', '1000 Employees'),
    )
    number_of_employees = forms.ChoiceField(choices=CHOICES)
    
    class Meta:
        model = User
        fields = (
            'username',
            'email',
            'phone_number',
        )
    
    def save(self):
        user = super().save()
        
        # update corresponding employer profile
        user.employer.business_name = self.cleaned_data.get('business_name')
        user.employer.number_of_employees = self.cleaned_data.get('number_of_employees')
        user.employer.save()
        
        return user
        
# employee creation form.
class EmployeeCreationForm(forms.ModelForm):
    
    class Meta:
        model = User
        fields = ['username', 'email', 'position']
    
    # designate user as an employee
    @transaction.atomic
    def save(self, commit=True):
        user = super().save(commit=False)
        user.is_employee = True
        user.save()
        
        return user

# employee position change form
class EmployeePositionChangeForm(forms.ModelForm):
    
    class Meta:
        model = User
        fields = ['email', 'position']
    

# employee view/update profile 
class EmployeeProfileForm(forms.ModelForm):
    
    name = forms.CharField()
    vehicle = forms.CharField()
    bio = forms.TextInput()
    city = forms.CharField()
    active_hours = forms.CharField()
    profile_pic = forms.FileField()

    class Meta:
        model = User
        fields = (
            'username',
            'email',
            'phone_number',
        )



# form for adding a new asset
class AssetCreationForm(forms.ModelForm):
    
    class Meta:
        model = Asset
        fields = ['asset', 'description']
    
    # asset belongs to an employer
    def set_employer(self, employer):
        self.employer = employer
    
    @transaction.atomic
    def save(self, commit=True):
        asset = super().save(commit=False)
        asset.employer = self.employer # expects employer to have been set
        asset.save()
        
        return asset

# assign an asset
class AssignAssetForm(forms.Form):
    asset_id = forms.CharField()
    employee_email = forms.EmailField()
    
# reclaim an asset
class ReclaimAssetForm(forms.Form):
    asset_id = forms.CharField()











