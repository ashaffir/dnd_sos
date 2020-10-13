from django import forms
from .models import Place

class LocationForm(forms.ModelForm):
    class Meta:
        model = Place
        fields = ('__all__')
