from django.urls import path
from . import views

urlpatterns = [
    path('logincheck', views.loginCheck),
]
