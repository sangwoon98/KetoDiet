"""ketodiet_django_project URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
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
from django.urls import include, path
# from . import views


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/settings', include('adminapp.urls')),
    path('api/account',include('user.urls')),
    path('api/community',include('community.urls')),
<<<<<<< HEAD
    path('api/challenge',include('diet.urls')),
    path('api/admin',include('adminview.urls')),
=======
    path('api/emailsend',include('diet.urls')),
>>>>>>> parent of 8588bd29 (06/11_back)
]
