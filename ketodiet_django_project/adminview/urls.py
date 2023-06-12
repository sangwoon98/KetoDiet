from django.urls import path
from . import views

urlpatterns = [
    path('', views.UserDBView.as_view(), name='adminview'),
]