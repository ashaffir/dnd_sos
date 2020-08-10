from django.db.models.signals import post_save
from django.dispatch import receiver, Signal
from django.core.signals import request_finished
from django.conf import settings
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_text
# from django.contrib.auth.models import User

from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

from dndsos_dashboard.utilities import send_mail
from core.models import User, Employee, Employer
from core.tokens import account_activation_token
from core.forms import EmployeeSignupForm, EmployerSignupForm
# from dndsos_dashboard.models import FreelancerProfile
# from orders.models import Order

@receiver(post_save, sender=User)
def announce_new_user(sender, instance, created, **kwargs):
    if created:
        print(f'=========== SIGNAL: New User ===============: {instance}')
        user = User.objects.all().last()
        user.is_active = False
        user.save()

        print(f'USER: {user.pk}')
        # form = EmployerSignupForm(instance)
    
        # user = form.save() # add employer to db with is_active as False

        # send an accout activation email
        if instance.is_employer:
            employer = Employer.objects.create(user=user, email=instance.email)
        else:
            employee = Employee.objects.create(user=user)

        current_site = 'http://127.0.0.1:8000' if settings.DEBUG else settings.DOMAIN_PROD
        subject = 'Activate Employer Account'

        message = {
            'user': user,
            'domain': current_site,
            'uid': urlsafe_base64_encode(force_bytes(user.pk)),
            'token': account_activation_token.make_token(user)
        }

        send_mail(subject, email_template_name=None,
                context=message, to_email=[user.email],
                html_email_template_name='registration/account_activation_email.html')


# @receiver(post_save, sender=Order)
# def signal_order_update(sender, instance, update_fields, **kwargs):        
#     business_id = instance.business_id
#     print(f'>>>>>>> SIGNAL >>> Order Status Change: {instance.status}. ID: {instance.order_id}')  
    
#     if instance.status == 'STARTED':
#         # print(f''''
#         # >>>>>>> SIGNAL: Order STARTED: {instance.order_id}  
#         # update: {instance.status} type: {type(instance.status)}
#         # update: {instance.order_id} type: {type(instance.order_id)}
#         # update: {instance.business_id} type: {type(instance.business_id)}
#         # ''')
#         channel_layer = get_channel_layer()
#         async_to_sync(channel_layer.group_send)(
#             str(instance.order_id), {
#                 # 'type':"order.accepted",
#                 'type':"update.order",
#                 'data': {
#                     'event': 'Order Accepted',
#                     'order_id': str(instance.order_id), 
#                     'business_id': business_id,
#                     'status': str(instance.status)
#                 }
#             }
#         )
#     elif instance.status == 'REQUESTED':
#         channel_layer = get_channel_layer()
#         async_to_sync(channel_layer.group_send)(
#             str(instance.order_id), {
#                 'type':"update.order",
#                 # 'type':"order.canceled",
#                 'data': {
#                     'event': 'Order Canceled',
#                     'order_id': str(instance.order_id), 
#                     'business_id': business_id,
#                     'status': str(instance.status)
#                 }
#             }
#         )
    
#     elif instance.status == 'RE_REQUESTED': # Avoiding second update through the sigmnl
#         print('RE-REQUEST. No action on this signal.')
#         pass

#     elif instance.status == 'ARCHIVED':
#         channel_layer = get_channel_layer()
#         async_to_sync(channel_layer.group_send)(
#             str(instance.order_id), {
#                 'type':"echo.message",
#                 # 'type':"order.canceled",
#                 'data': {
#                     'event': 'Order Canceled',
#                     'order_id': str(instance.order_id),
#                     'freelancer': str(instance.freelancer.pk),
#                     'business_id': business_id,
#                     'status': str(instance.status)
#                 }
#             }
#         )

    # elif instance.status == 'IN_PROGRESS':
    #     print(f''''
    #     >>>>>>> SIGNAL: Order In Progress: {instance.order_id}  
    #     update: {instance.status} type: {type(instance.status)}
    #     update: {instance.order_id} type: {type(instance.order_id)}
    #     update: {instance.business_id} type: {type(instance.business_id)}
    #     update: {instance.freelancer.pk} type: {type(instance.freelancer.pk)}
    #     ''')
    #     channel_layer = get_channel_layer()
    #     async_to_sync(channel_layer.group_send)(
    #         str(instance.order_id), {
    #             'type':"order.dispached",
    #             'event': 'Order Dispached',
    #             'order_id': str(instance.order_id), 
    #             'business': business_id,
    #             'freelancer': instance.freelancer.pk,
    #             'status': str(instance.status)
    #         }
    #     )




# alert_new_order = Signal(providing_args=['b_id', 'order_id', 'f_list'])

# alert_freelancer_accepted = Signal(providing_args=['f_id', 'order_id'])

# @receiver(alert_freelancer_accepted)
# def alert_freelancer_accepted_receiver(sender, **kwargs):
#     print(f'>>>> Freelancer accepted offer. ARGS: {kwargs}')