
# REFERENCE: custsom tags for templates: https://docs.djangoproject.com/en/3.1/howto/custom-template-tags/
from django import template

register = template.Library()

@register.filter(name='multiply')
def multiply(value, arg):
    return float(value) * float(arg)

@register.filter(name='round_float')
def round_float(value):
    return round(value,2)