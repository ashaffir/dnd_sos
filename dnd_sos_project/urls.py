"""dnd_sos_project URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from django.urls.conf import include
from django.conf import settings
from django.conf.urls.static import static

from django.contrib.auth import views as auth_views

from dndsos_dashboard.views import SignUpView

admin.site.site_header = 'DND-SOS'

app_name = 'dnd_sos_project'

urlpatterns = [
    path('', include('dndsos.urls')),
    path('dashboard/', include('dndsos_dashboard.urls')),
    path('core/', include('core.urls')),
    path('chat/', include('chat.urls')),
    path('notifier/', include('notifier.urls')),
    path('orders/', include('orders.urls')),
    path('geo/', include('geo.urls')),
    path('payments/', include('payments.urls')),
    # path('verify/', include('verify.urls')),

    path('api/sign_up/', SignUpView.as_view(), name='sign_up'),

# Password:
    # https://docs.djangoproject.com/en/3.0/topics/auth/default/
    
    path('password_change/', auth_views.PasswordChangeView.as_view(template_name='core/password_change.html'), name='password_change'),
    path('password_change/done', auth_views.PasswordChangeDoneView.as_view(template_name='core/password_change_done.html'), name='password_change_done'),
    path('password-reset/done', auth_views.PasswordResetCompleteView.as_view(template_name='core/password_reset_done.html'), name='password_reset_done'),
    path('reset/<uidb64>/<token>/', auth_views.PasswordResetConfirmView.as_view(template_name='core/reset_password.html'), name='password_reset_confirm'),
    path('reset/done/', auth_views.PasswordResetCompleteView.as_view(template_name='core/password_reset_complete.html'), name='password_reset_complete'),
    

    path('admin/', admin.site.urls),
]
if settings.DEBUG:
        urlpatterns += static(settings.MEDIA_URL,
                              document_root=settings.MEDIA_ROOT)
