from django.urls import path
from . import views

urlpatterns = [
    path('', views.Settings.as_view(), name='Settings'),
]