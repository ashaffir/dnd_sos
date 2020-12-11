import logging
import platform
# import mailchimp_marketing as MailchimpMarketing
# from mailchimp_marketing.api_client import ApiClientError

from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages
from django.http import HttpResponse, HttpResponseForbidden, JsonResponse, HttpResponseRedirect
from django.contrib.sites.shortcuts import get_current_site
from django.utils.encoding import force_bytes, force_text
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.template.loader import render_to_string
from django.contrib.auth.forms import SetPasswordForm
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_POST
from django.conf import settings
from django.contrib.auth.models import Group
from django.contrib.auth.tokens import default_token_generator

from dndsos_dashboard.utilities import send_mail
from django.utils.translation import gettext

from dndsos.models import AdminParameters, AlertMessage
from .forms import *
from .models import User, Employer, Employee, Asset, AssignedAsset
from .tokens import account_activation_token
from .decorators import employer_required, employee_required
from newsletters_app.models import EmailTemplate

logger = logging.getLogger(__file__)


def home(request):
    '''
    handles requests to the home page.
    '''
    # return render(request, 'core/home.html')
    return redirect('core:login')

# handles employer signup requests


def employer_signup(request):

    if request.method == 'POST':
        form = EmployerSignupForm(request.POST)
        if form.is_valid():
            user = form.save()  # add employer to db with is_active as False
            user.username = user.email
            user.save()

            messages.success(request, gettext(
                'An accout activation link has been sent to your email'))
            return redirect('dndsos:home')
        else:
            messages.error(request, 'Error')

    else:
        form = EmployerSignupForm()

    context = {}
    context['form'] = form

    alert_language = request.LANGUAGE_CODE

    try:
        try:
            alert = AlertMessage.objects.get(
                alert_message_page='business_signup', alert_message_active=True, alert_message_language=alert_language)
        except:
            alert = AlertMessage.objects.get(
                alert_message_page='business_signup', alert_message_active=True, alert_message_language='en')

        if alert.alert_message_active:
            context['show_message'] = True
            context['alert_message_title'] = alert.alert_message_title
            context['alert_message_content'] = alert.alert_message_content
    except Exception as e:
        logger.info(f">>> CORE: No alerts on signup business page.")

    return render(request, 'core/employer/signup.html', context)

# handles freelancer signup requests


def employee_signup(request):
    if request.method == 'POST':
        form = EmployeeSignupForm(request.POST)
        if form.is_valid():
            user = form.save()  # add freelancer to db with is_active as False
            user.username = user.email
            user.save()

            ####################################
            # MailChimp newsletter subscription
            ####################################
            # mailchimp = MailchimpMarketing.Client()
            # mailchimp.set_config({
            # "api_key": settings.MAILCHIMP_API_KEY,
            # "server": settings.MAILCHIMP_DATA_CENTER
            # })

            # list_id = settings.MAILCHIMP_EMAIL_LIST_ID

            # member_info = {
            #     "email_address": user.email,
            #     "status": "subscribed",
            #     "merge_fields": {
            #         "FNAME": "A",
            #         "LNAME": "B"
            #     }
            # }

            # try:
            #     response = mailchimp.lists.add_list_member(list_id, member_info)
            #     print(">>> CORE VIEWS: Mailchimp response: {}".format(response))
            #     logger.info(">>> CORE VIEWS: Mailchimp response: {}".format(response))
            # except ApiClientError as error:
            #     print(">>> CORE VIEWS: Failed MailChimp communication. ERROR: {}".format(error.text))
            #     logger.error(">>> CORE VIEWS: Failed MailChimp communication. ERROR: {}".format(error.text))
            ####################################

            messages.success(request, gettext(
                'An accout activation link has been sent to your email'))
            return redirect('dndsos:home')
        else:
            messages.error(request, 'Error')

    else:
        form = EmployeeSignupForm()

    return render(request, 'core/employee/signup.html', {
        'form': form
    })


# employer profile
@employer_required
@login_required
def employer_profile(request):
    user = request.user
    form = EmployerProfileForm(request.POST or None, instance=user, initial={
        'company_name': user.employer.company,
        'number_of_employees': user.employer.number_of_employees
    })

    if request.method == 'POST':
        if form.is_valid():
            user = form.save()
            messages.success(request, gettext(
                "Profile has been updated successfully"))
            return redirect('core:employer_profile')

    return render(request, 'core/employer/profile.html', {'form': form})

# the employer dashboard


@employer_required
@login_required
def employer_dashboard(request):
    return render(request, 'core/employer/dashboard.html')

# the employee dashboard


@employee_required
@login_required
def employee_dashboard(request):
    return render(request, 'core/employee/dashboard.html')

# redirect employer to employer_dashboard and employee to employee_dashboard


@login_required
def login_redirect(request):
    if request.user.is_employer:
        return redirect(f'dndsos_dashboard:b-dashboard', b_id=(request.user.pk))
    return redirect('dndsos_dashboard:f-dashboard', f_id=(request.user.pk))


# displays all employees associated with the current user,
# a form to add a new employee and another to change the employee position
@employer_required
@login_required
def employees_list(request):
    user = request.user

    # filter all Employees that belong to me (Employer) i.e user.employer
    employees = Employee.objects.filter(employer=user.employer)
    employees = [e.user for e in employees]

    emp_creation_form = EmployeeCreationForm()
    employee_position_edit_form = EmployeePositionChangeForm()

    return render(request, 'core/employer/employees.html', {
        'employees': employees,
        'employee_creation_form': emp_creation_form,
        'employee_position_edit_form': employee_position_edit_form
    })

# displays all assets associated with  the current user,
# a form to add a  new asset and another form to assign an asset.


@employer_required
@login_required
def employer_assets(request):
    user = request.user
    employer_assets = Asset.objects.filter(employer=user.employer)
    all_assigned_assets = AssignedAsset.objects.all()  # not effective

    # build a list of tuples, (asset, employee_assigned_to or None)
    assets = []
    l = [a.asset for a in all_assigned_assets]
    for asset in employer_assets:
        try:
            i = l.index(asset)  # if asset is assigned, get it index in l
            assets.append((asset, all_assigned_assets[i].employee))
        except ValueError:
            assets.append((asset, None))

    new_asset_form = AssetCreationForm()
    asset_assign_form = AssignAssetForm()
    asset_reclaim_form = ReclaimAssetForm()

    return render(request, 'core/employer/assets.html', {
        'assets': assets,
        'assigned_assets': l,
        'new_asset_form': new_asset_form,
        'asset_assign_form': asset_assign_form,
        'asset_reclaim_form': asset_reclaim_form
    })


# displays a real time notifications page for the current user,
# the notifications are delivered using pusher/channels
@employer_required
@login_required
def employer_notifications(request):

    return render(request, 'core/employer/notifications.html')


# add employee
@employer_required
@login_required
def employee_add(request):
    if request.method == 'POST':
        form = EmployeeCreationForm(request.POST)
        if form.is_valid():
            employee = form.save(commit=False)
            employee.is_active = False
            employee.save()

            # current user becomes the employer of employee
            Employee.objects.create(
                user=employee,
                employer=request.user.employer
            )

            # send employee a account activation email
            current_site = get_current_site(request)
            subject = 'Activate Employee Account'
            message = render_to_string('registration/account_activation_email.html', {
                'user': employee,
                'domain': current_site.domain,
                'uid': urlsafe_base64_encode(force_bytes(employee.pk)),
                'token': account_activation_token.make_token(employee)
            })
            employee.email_user(
                subject, message, from_email=settings.DEFAULT_FROM_EMAIL)

            messages.info(request, 'Employee '+employee.email +
                          ' has been added successfully and an account activation link sent to their email')
            return redirect('core:employee_add')
    else:
        form = EmployeeCreationForm()

    return render(request, 'core/employer/employee_add.html', {'employee_creation_form': form})

# edit employee position


@employer_required
@login_required
def employee_position_edit(request):
    if request.method == 'POST':
        email = request.POST['email']
        employee = User.objects.get(email=email)
        form = EmployeePositionChangeForm(request.POST, instance=employee)
        if form.is_valid():
            # new_position = form.cleaned_data.get('position')
            employee = form.save()

            messages.success(request, 'Employee {} position changed to {}'.format(
                employee.email,
                employee.position
            ))
            return redirect('core:employee_position_edit')
    else:
        form = EmployeePositionChangeForm()

    return render(request, 'core/employer/employee_position_edit.html', {'employee_position_edit_form': form})


# add company asset
@employer_required
@login_required
def asset_add(request):
    if request.method == 'POST':
        form = AssetCreationForm(request.POST)
        if form.is_valid():
            # set the owner/employer before save
            form.set_employer(request.user.employer)
            asset = form.save()

            messages.success(request, 'Asset ' +
                             asset.asset + ' added successfully.')
            return redirect('core:asset_add')
    else:  # GET
        form = AssetCreationForm()

    return render(request, 'core/employer/asset_add.html', {'new_asset_form': form})

# display employee assigned asset


@employee_required
@login_required
def employee_assigned_assets(request):
    assigned_assets = AssignedAsset.objects.filter(
        employee=request.user.employee)
    assets = [a.asset for a in assigned_assets]

    return render(request, 'core/employee/assigned_assets.html', {'assets': assets})


# employee profile
@employee_required
@login_required
def employee_profile(request):
    form = EmployeeProfileForm(request.POST or None, instance=request.user)

    if request.method == 'POST':
        if form.is_valid():
            user = form.save()

            messages.success(request, gettext(
                'Your profile has been updated.'))

    return render(request, 'core/employee/profile.html', {'form': form})


# assign an asset to an employee
@employer_required
@login_required
def asset_assign(request):
    if request.method == 'POST':
        form = AssignAssetForm(request.POST)
        if form.is_valid():
            asset_id = form.cleaned_data.get('asset_id')
            employee_email = form.cleaned_data.get('employee_email')

            asset = AssignedAsset.objects.create(
                asset=Asset.objects.get(asset=asset_id),
                employee=User.objects.get(email=employee_email).employee
            )

            messages.success(request,
                             'Asset ' + asset.asset.asset + ' has been assigned to ' + asset.employee.user.email)
            return redirect('core:asset_assign')  # for assigning another asset
    else:
        form = AssignAssetForm()

    return render(request, 'core/employer/asset_assign.html', {'asset_assign_form': form})

# reclaim an assigned asset


@employer_required
@login_required
def asset_reclaim(request):
    if request.method == 'POST':
        form = ReclaimAssetForm(request.POST)
        if form.is_valid():
            asset_id = form.cleaned_data.get('asset_id')

            assigned_asset = AssignedAsset.objects.get(asset_id=asset_id)
            assigned_asset.delete()

            messages.success(request,
                             'Asset ' + assigned_asset.asset.asset + ' has been re-claimed from ' + assigned_asset.employee.user.email)
            # for reclaiming another asset
            return redirect('core:asset_reclaim')
    else:
        form = ReclaimAssetForm()

    return render(request, 'core/employer/asset_reclaim.html', {'asset_reclaim_form': form})

# activate account by clicking on activation email link


def activate_account(request, uidb64, token):
    try:
        uid = force_text(urlsafe_base64_decode(uidb64))
        user = User.objects.get(pk=uid)

    except (TypeError, ValueError, OverflowError, User.DoesNotExist):
        user = None

    if user is not None and account_activation_token.check_token(user, token):
        user.is_active = True

        if user.is_employer:
            group = 'business'
        else:
            group = 'freelancer'

        user_group, _ = Group.objects.get_or_create(name=group)
        user.groups.add(user_group)
        user.language = request.LANGUAGE_CODE
        user.save()

        if user.is_employer:
            user_profile = Employer.objects.get(user=user)
        else:
            user_profile = Employee.objects.get(user=user)

        user_profile.language = request.LANGUAGE_CODE
        user_profile.email = user.email
        user_profile.save()

        # Send activation/welcome email
        ###############################
        if platform.system() == 'Darwin':  # MAC
            current_site = 'http://127.0.0.1:8000' if settings.DEBUG else settings.DOMAIN_PROD
        else:
            current_site = settings.DOMAIN_PROD

        try:
            email_language = user_profile.language
            email_template = EmailTemplate.objects.get(
                name='account_activated', language=email_language)
            subject = email_template.subject
            content = email_template.content
            title = email_template.title

            message = {
                'user': user_profile,
                'title': title,
                'content': content,
                'lang': email_language,
                'domain': current_site
            }

            send_mail(subject, email_template_name=None,
                      context=message, to_email=[user_profile.email],
                      html_email_template_name='core/emails/profile_approved_email.html')
        except Exception as e:
            logger.error(
                f'>>> CORE: Failed sending account activated to the user. ERROR: {e}')
            print(
                f'>>> CORE: Failed sending account activated to the user. ERROR: {e}')

        messages.success(request, gettext(
            'You have successfully confirmed your email'))
        return redirect('core:login')
        # else:
        #     messages.info(request, 'Set a password for your Employee account.')
        #     return redirect('core:employee_set_password', uid=user.id)

    # invalid link
    messages.error(
        request, 'Account activation link is invalid or has expired. Contact system administratior for assistance')
    return redirect('core:home')

# account activation email sent


def account_activation_sent(request):
    return HttpResponse(gettext('<p>An activation link has been sent to your Email</p>'))


# upon activating account, employee should set password
def employee_set_password(request, uid):
    user = get_object_or_404(User, pk=uid)

    if request.method == 'POST':
        form = SetPasswordForm(user, request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)

            messages.success(request, gettext(
                'Welcome ')+user.email+gettext('. Your account is now operational'))
            return redirect('core:login_redirect')
    else:
        form = SetPasswordForm(user)

    return render(request, 'core/employee/set_password.html', {'set_password_form': form, 'user': user})


def reset_password(request):
    if request.method == "POST":
        user = request.user
        password1 = request.POST.get("new_password1")
        password2 = request.POST.get("new_password2")
        error = False
        if not password1:
            enter_password_msg = gettext("Enter password")
            messages.error(request, enter_password_msg)
            error = True
        elif len(password1) < 8:
            pwd_too_short_msg = gettext("Minimum password length should be 8")
            messages.error(request, pwd_too_short_msg)
            error = True
        elif not (password1 == password2):
            pwd_missmatch_msg = gettext("Mismatch password")
            messages.error(request, )
            error = True

        if error:
            return HttpResponseRedirect(request.META.get('HTTP_REFERER'))

        try:
            user.set_password(password1)
            user.save()
            changed_pwd_msg = gettext(
                "Successfully changed the password, please login again.")
            messages.success(request, changed_pwd_msg)
            logout(request)
            return redirect('core:login')
        except Exception as ex:
            messages.error(request, ex.message)

    return render(request, 'core/reset-password.html', {})


def forgot_password(request):
    if request.method == "POST":
        email = request.POST.get("login_email")

        if email:
            print(f"EMAIL: ***************{email}****************")
            if '@' in email:

                user = User.objects.filter(email=email).first()
                print(f'>>>>>>>  USER: {user}')
                # return HttpResponse(user)
                if user is not None:
                    token_generator = default_token_generator

                    context = {
                        'domain': request._current_scheme_host,
                        'uidb64':  urlsafe_base64_encode(force_bytes(user.pk)),
                        'token': token_generator.make_token(user),
                        'user': user
                    }

                    try:
                        send_mail('Reset Password', email_template_name=None,
                                  context=context, to_email=[email],
                                  html_email_template_name='core/emails/change-password-email.html')

                        check_email_message = gettext(
                            "Check your mail inbox to reset password")
                        messages.success(request, check_email_message)
                        return redirect('dndsos:home')

                    except Exception as ex:
                        print(ex)
                        messages.error(
                            request, "Email configurations Error !!!")

                    return redirect('core:login')
                else:
                    not_registered_message = gettext(
                        "This email is not registered to us. Please register first ")
                    messages.error(request, not_registered_message)
                    return redirect('dndsos:home')
            else:
                valid_email_message = gettext("Please enter a valid email")
                messages.error(request, valid_email_message)
                return redirect('core:forgot-password')
        else:
            enter_email_msg = gettext("Please do enter the email")
            messages.error(request, enter_email_msg)
            return redirect('core:forgot-password')
    else:
        return render(request, 'core/forgot_password.html', {})


def email_activation(request):
    context = {}
    context['test'] = True
    return render(request, 'registration/account_activation_email.html', context)
