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
from django.urls import path
from . import views

urlpatterns = [
    path('', views.CommunityView.as_view(), name='Community'),
    path('comment', views.Community_comment.as_view(), name='Community_comment'),
]

# path('page=<int:page>', views.CommunityList.as_view(), name='community-list'),

# urlpatterns = [
#     path('', views.AccountView.as_view()), # as_view() = 클래스 기반 뷰를 함수로 변환, HTTP 메소드 (GET, POST, PUT, DELETE 등)를 처리하고, 적절한 메소드를 호출
# ]