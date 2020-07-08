from django.contrib import admin
from .models import Card, Payment

@admin.register(Payment)
class Payment(admin.ModelAdmin):
    fields = ( 
        'order', 'freelancer', 'business','amount', 'payment_received', 'payment_date',
        'paid_freelancer','payment_freelancer_date',
    )
    list_display = ( 
        'order','freelancer', 'business','amount',
    )
    list_filter = (
        'business','freelancer', 'date',
    )

    search_fields = ('order', 'freelancer', 'business',) 
    ordering = ('-date',)

admin.site.register(Card)
