import platform
from django.contrib import admin
from django.urls import path
from django.urls.conf import include
from django.conf import settings
from django.conf.urls.static import static

from django.contrib.auth import views as auth_views
from rest_framework.authtoken import views as api_views
from django.views.generic.base import TemplateView
# from django.views.generic import TemplateView
from dndsos_dashboard.views import SignUpView

if platform.system() == 'Darwin':  # MAC
    admin.site.site_header = 'PickNdell-Development'
else:
    admin.site.site_header = 'PickNdell'

app_name = 'dnd_sos_project'

urlpatterns = [
    path('i18n/', include('django.conf.urls.i18n')),
    path('admin/', admin.site.urls),
    path("robots.txt", TemplateView.as_view(
        template_name="dnd_sos/robots.txt", content_type="text/plain")),

    path('', include('dndsos.urls')),
    path('', include('newsletters_app.urls')),
    path('dashboard/', include('dndsos_dashboard.urls')),
    path('core/', include('core.urls')),
    # path('chat/', include('chat.urls')),
    # path('notifier/', include('notifier.urls')),
    path('orders/', include('orders.urls')),
    path('geo/', include('geo.urls')),
    path('payments/', include('payments.urls')),


    path('api/', include('api.urls', namespace='api')),
    path('api-token-auth/', api_views.obtain_auth_token, name='api-token-auth'),

    # Password:
    # https://docs.djangoproject.com/en/3.0/topics/auth/default/

    path('password_change/', auth_views.PasswordChangeView.as_view(
        template_name='core/password_change.html'), name='password_change'),
    path('password_change/done', auth_views.PasswordChangeDoneView.as_view(
        template_name='core/password_change_done.html'), name='password_change_done'),
    path('password-reset/done', auth_views.PasswordResetCompleteView.as_view(
        template_name='core/password_reset_done.html'), name='password_reset_done'),
    path('reset/<uidb64>/<token>/', auth_views.PasswordResetConfirmView.as_view(
        template_name='core/reset_password.html'), name='password_reset_confirm'),
    path('reset/done/', auth_views.PasswordResetCompleteView.as_view(
        template_name='core/password_reset_complete.html'), name='password_reset_complete'),

]
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL,
                          document_root=settings.MEDIA_ROOT)
