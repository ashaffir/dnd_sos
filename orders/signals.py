import os
import platform
from datetime import datetime
from fcm_django.models import FCMDevice

from django.db.models.signals import post_save
from django.dispatch import receiver, Signal
from django.core.signals import request_finished
from django.conf import settings
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_text
# from django.contrib.auth.models import User
from django.db.models import Q
from django.utils.translation import gettext
from django.contrib.gis.geos import fromstr, Point

from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

from dndsos_dashboard.utilities import send_mail
from core.models import User, Employee, Employer
from core.tokens import account_activation_token
from core.forms import EmployeeSignupForm, EmployerSignupForm
# from dndsos_dashboard.models import FreelancerProfile
from orders.models import Order
from orders.serializers import ReadOnlyOrderSerializer, OrderSerializer
from payments.views import lock_delivery_price, complete_charge
from payments.models import Payment


# Create and configure logger
import logging
# LOG_FORMAT = '%(levelname)s %(asctime)s - %(message)s'
# logging.basicConfig(filename=os.path.join(settings.BASE_DIR,'logs/signals.log'),level=logging.INFO,format=LOG_FORMAT, filemode='w')
# logger = logging.getLogger()

logger = logging.getLogger(__file__)


@receiver(post_save, sender=User)
def announce_new_user(sender, instance, created, **kwargs):
    if created:
        print(
            f'=========== SIGNAL: New User ===============: {instance.is_staff}')
        logger.info(
            f'=========== SIGNAL: New User ===============: {instance.is_staff}')
        if not instance.is_staff:
            user = User.objects.all().last()
            user.is_active = False
            user.save()

            print(f'USER: {user.pk}')

            if platform.system() == 'Darwin':  # MAC
                current_site = 'http://127.0.0.1:8000' if settings.DEBUG else settings.DOMAIN_PROD
            else:
                current_site = settings.DOMAIN_PROD

            subject = 'Activate PickNdell Account'

            message = {
                'user': user,
                'domain': current_site,
                'uid': urlsafe_base64_encode(force_bytes(user.pk)),
                'token': account_activation_token.make_token(user)
            }

            send_mail(subject, email_template_name=None,
                      context=message, to_email=[user.email],
                      html_email_template_name='registration/account_activation_email.html')

# REFERENCE: FCM: https://github.com/xtrinch/fcm-django


@receiver(post_save, sender=Order)
def order_signal(sender, instance, update_fields, **kwargs):
    if kwargs['created']:
        print(f'=========== SIGNAL: New Order ===============: {instance}')
        logger.info(
            f'=========== SIGNAL: New Order ===============: {instance}')

        # Check for active and approved freelancers in range
        relevant_freelancers = Employee.objects.filter(
            Q(is_approved=True) & Q(is_available=True) & Q(is_delivering=False))

        pickup_location = Point(instance.business_lat, instance.business_lon)

        for freelancer in relevant_freelancers:
            # Checking distance to freelancer

            freelancer_location = freelancer.location
            order_range_to_freelancer = round(
                pickup_location.distance(freelancer_location) * 100, 3)  # In KM
            if (order_range_to_freelancer < settings.MAX_RANGE_TO_FREELANCER):
                print(
                    f'>>> SIGNALS: Sending push message to freelancer: {freelancer}. Distance to pickup: {order_range_to_freelancer} kilometers')
                logger.info(
                    f'>>> SIGNALS: Sending push message to freelancer: {freelancer}. Distance to pickup: {order_range_to_freelancer} kilometers')
                device = FCMDevice.objects.filter(user=freelancer.pk).first()
                device.send_message(
                    title="New Order available",
                    body=f"New order from {instance.business.business.business_name}",
                    data={
                        'order_id': str(instance.order_id),
                        'pick_up_address': instance.pick_up_address,
                        "drop_off_address": instance.drop_off_address,
                        'price': instance.price,
                        'created': str(instance.created),
                        'updated': str(instance.updated),
                        'order_type': instance.order_type,
                        'order_city_name': instance.order_city_name,
                        'order_street_name': instance.order_street_name,
                        'distance_to_business': instance.distance_to_business,
                        'status': instance.status
                    })
            else:
                print(
                    f'>>> SIGNALS: freelancer {freelancer} is too far. Distance to pickup: {order_range_to_freelancer} meters')
                logger.info(
                    f'>>> SIGNALS: freelancer {freelancer} is too far. Distance to pickup: {order_range_to_freelancer} meters')

    # fcm_send_topic_message(topic_name='My topic', message_body='Hello', message_title='A message')
    # device = FCMDevice.objects.all().first()
    # device.send_message(title='title', body='message')

    # devices.send_message(title="Title", body="Message", data={"test": "test"})
    # devices.send_message(data={"test": "test"})

#     business_id = instance.business_id
#     print(f'>>>>>>> SIGNAL >>> Order Status Change: {instance.status}. ID: {instance.order_id}')

    # STARTED (Accepted by the freelancer)
    #################################
    elif instance.status == 'STARTED' and not instance.private_sale_token:
        print(f'ORDER {instance.order_id} updated with status: STARTED')

        order_data = ReadOnlyOrderSerializer(instance).data

        # Updating WS
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            str(instance.order_id), {
                # 'type':"order.accepted",
                # 'type':"update.order",
                'type': 'echo.message',
                'data': {
                        # 'event': 'Order Accepted',
                        # 'order_id': str(instance.order_id),
                        # 'business_id': business_id,
                        # 'status': str(instance.status)
                        'data': order_data
                }
            }
        )

        # Locking the price
        ####################
        print('>>> SIGNALS: getting private token')
        logger.info('>>> SIGNALS: getting private token')
        private_sale_token = lock_delivery_price(instance)
        instance.private_sale_token = private_sale_token
        print('>>> SIGNALS: Saved pending transaction token')
        instance.save()

    # REJECTED (canceled by the freelancer)
    elif instance.status == 'REJECTED':
        print(f'ORDER {instance.order_id} updated with status: REJECTED')
        order_data = ReadOnlyOrderSerializer(instance).data
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            str(instance.order_id), {
                'type': 'echo.message',
                'data': {
                    'data': order_data
                }
            }
        )

    # COMPLETED / DELIVERED
    #################################
    elif instance.status == 'COMPLETED' and not instance.sale_id:
        print(
            f'ORDER {instance.order_id} updated with status: DELIVERED (COMPLETED)')
        order_data = ReadOnlyOrderSerializer(instance).data

        freelancer = User.objects.get(pk=instance.freelancer.pk)
        business = User.objects.get(pk=instance.business.pk)

        # Updating the involved parties relationships
        #######################################
        if not freelancer.relationships:
            freelancer.relationships = {'businesses': [business.pk]}
        else:
            businesses_list = freelancer.relationships['businesses']
            businesses_list.append(business.pk)
            freelancer.relationships['businesses'] = list(set(businesses_list))

        if not business.relationships:
            business.relationships = {'freelancers': [freelancer.pk]}
        else:
            freelancers_list = business.relationships['freelancers']
            freelancers_list.append(freelancer.pk)
            business.relationships['freelancers'] = list(set(freelancers_list))

        # Updating iCredit/Rivhit
        #########################
        try:
            print(
                f'>>> SIGNALS: Updating iCredit with completed order {instance}')
            logger.info(
                f'>>> SIGNALS: Updating iCredit with completed order {instance}')
            order_private_sale_token = instance.private_sale_token
            complete_charge_information = complete_charge(
                order_private_sale_token)
            icredit_status = complete_charge_information['Status']
            if icredit_status != 0:
                return

            print(f'''DocumentURL: {complete_charge_information['data']['DocumentURL']}
            SaleId: {complete_charge_information['data']['SaleId']}
            CustomerTransactionId: {complete_charge_information['data']['CustomerTransactionId']}
            TransactionId: {complete_charge_information['data']['TransactionId']}
            CardNum: {complete_charge_information['data']['CardNum']}
            ''')
            instance.invoice_url = complete_charge_information['data']['DocumentURL']
            instance.sale_id = complete_charge_information['data']['SaleId']
            instance.order_cc = complete_charge_information['data']['CardNum'][-4:]

            # instance.sale_id = complete_charge_information['data']['SaleId']
            # instance.invoice_url = complete_charge_information['data']['DocumentURL']
            instance.save()
            print(
                f">>> SIGNALS: INVOICE: {complete_charge_information['data']['DocumentURL']}")
            logger.info(
                f">>> SIGNALS: INVOICE: {complete_charge_information['data']['DocumentURL']}")

        except Exception as e:
            print(f'>>> SIGNALS: Failed generating invoice URL. ERROR: {e}')
            logger.error(
                f'>>> SIGNALS: Failed generating invoice URL. ERROR: {e}')
            return

        # Updating Freelance balance:
        ###############
        print(f'OPEN BALANCE: {freelancer.freelancer.balance}')
        logger.info(f'OPEN BALANCE: {freelancer.freelancer.balance}')
        freelancer.freelancer.balance += instance.price
        print(f'CLOSE BALANCE: {freelancer.freelancer.balance}')
        logger.info(f'CLOSE BALANCE: {freelancer.freelancer.balance}')

        freelancer.freelancer.save()
        freelancer.save()
        business.save()

        # Creating payment for the completed order
        print(
            f'>>> SIGNALS: creating payment: business - {business}  Freelancer: {freelancer}')
        logger.info(
            f'>>> SIGNALS: creating payment: business - {business}  Freelancer: {freelancer}')
        Payment.objects.create(
            created=datetime.now(),
            order=instance,
            freelancer=freelancer.freelancer,
            business=business.business,
            amount=instance.price
        )

        # Updating the WS channels
        ###########
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            str(instance.order_id), {
                'type': 'echo.message',
                'data': {
                    'data': order_data
                }
            }
        )

        # Sending email to the Sender with order summary
        ##########################
        print(
            f'>>> SIGNALS: Sending summary email to sender: {business.business.email}')
        logger.info(
            f'>>> SIGNALS: Sending summary email to sender: {business.business.email}')
        try:
            subject = gettext('Thank you for choosing PickNdell')
            message = {}
            email_content = gettext('Thank you for choosing PickNdell')
            currency = '₪'
            message['order'] = instance
            message['user'] = business.business
            message['currency'] = currency
            message['email_content'] = email_content
            send_mail(subject, email_template_name=None,
                      context=message, to_email=[business.business.email],
                      html_email_template_name='dndsos_dashboard/emails/sender_order_summary_email.html')
        except Exception as e:
            print(
                f'SIGNALS: Failed sending summary email to sender. ERROR: {e}')
            logger.error(
                f'SIGNALS: Failed sending summary email to sender. ERROR: {e}')

    else:
        print(
            f'SIGNALS: ORDER {instance.order_id} updated with status: {instance.status}')


# alert_new_order = Signal(providing_args=['b_id', 'order_id', 'f_list'])

# alert_freelancer_accepted = Signal(providing_args=['f_id', 'order_id'])

# @receiver(alert_freelancer_accepted)
# def alert_freelancer_accepted_receiver(sender, **kwargs):
#     print(f'>>>> Freelancer accepted offer. ARGS: {kwargs}')
