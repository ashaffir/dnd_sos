"""
Django settings for dnd_sos_project project.

Generated by 'django-admin startproject' using Django 3.0.6.

For more information on this file, see
https://docs.djangoproject.com/en/3.0/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/3.0/ref/settings/
"""

import os

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/3.0/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'zijbaj^_lv)!8-1ex(&a-00l%t+)fa)b)&)8#hegij@1cuns=('

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = ['*']


# Application definition

INSTALLED_APPS = [
    'core',
    'chat',
    'dndsos',
    'channels',
    # 'orders',
    'payments',
    'dndsos_dashboard',
    'orders.apps.OrdersConfig',
    
    'django_extensions',
    'ckeditor',
    'rest_framework', #https://www.django-rest-framework.org/
    'qr_code', # https://github.com/dprog-philippe-docourt/django-qr-code
    
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

# Channels
ASGI_APPLICATION = 'dnd_sos_project.routing.application'

ASGI_APPLICATION = 'dnd_sos_project.routing.application'
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            "hosts": [('127.0.0.1', 6379)],
            # "hosts": [os.environ['REDIS_URL']],
        },
    },
}

#This is to stop the Async-to-Sync ERROR message in the consumer orders gathering process
# https://docs.djangoproject.com/en/3.0/topics/async/
os.environ["DJANGO_ALLOW_ASYNC_UNSAFE"] = "true" 


MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'dnd_sos_project.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [
            os.path.join(BASE_DIR,'templates'),
            os.path.join(BASE_DIR,'dndsos/templates'),
            os.path.join(BASE_DIR,'core/templates'),
            os.path.join(BASE_DIR,'payments/templates'),
            os.path.join(BASE_DIR,'dndsos_dashboard/templates'),
            os.path.join(BASE_DIR,'notifier/templates'),
        ],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
                'dndsos_dashboard.context_processors.business_type',
                'dndsos_dashboard.context_processors.debugMode',
                # 'dndsos_dashboard.context_processors.requested_freelancer',                
            ],
        },
    },
]

WSGI_APPLICATION = 'dnd_sos_project.wsgi.application'


# Database
# https://docs.djangoproject.com/en/3.0/ref/settings/#databases

# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.sqlite3',
#         'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
#     }
# }
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'dndsos', #LIVE DAATABASE
        'USER': 'alfreds',
        'PASSWORD': '!Q2w3e4r%T',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}

# Password validation
# https://docs.djangoproject.com/en/3.0/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# use custom auth model
AUTH_USER_MODEL = 'core.User'

# auth urls
LOGIN_URL = 'core:login'
LOGOUT_URL = 'core:logout'
LOGIN_REDIRECT_URL = 'core:login_redirect'
LOGOUT_REDIRECT_URL = 'core:home'

# Internationalization
# https://docs.djangoproject.com/en/3.0/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/3.0/howto/static-files/

STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR,'media')

# Email Setup
EMAIL_USE_TLS = True
EMAIL_HOST = 'in-v3.mailjet.com'
EMAIL_HOST_USER = '59821dd394d97be74449840fe384c8b5'
EMAIL_HOST_PASSWORD = '7075700fa37924a22ebe6b5ffcdac824'
EMAIL_PORT = 587
DEFAULT_FROM_EMAIL = 'ashaffir@gmail.com'

# use bootstrap friendly message tags
from django.contrib.messages import constants as messages
MESSAGE_TAGS = {
    messages.DEBUG: 'alert-info',
    messages.INFO:  'alert-info',
    messages.WARNING: 'alert-warning',
    messages.SUCCESS: 'alert-success',
    messages.ERROR: 'alert-danger',
}