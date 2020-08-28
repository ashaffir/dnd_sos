from django.contrib import admin
from .models import Card, Payment

@admin.register(Payment)
class Payment(admin.ModelAdmin):
    fields = ( 
        'order', 'freelancer', 'business','amount', 'payment_received', 'payment_date',
        'paid_freelancer','payment_freelancer_date',
    )
    list_display = ( 
        'created','order','freelancer', 'business','amount',
    )
    list_filter = (
        'business','freelancer', 'created',
    )

    search_fields = ('order', 'freelancer', 'business',) 
    ordering = ('-created',)

admin.site.register(Card)
# admin.site.register(Payment)
