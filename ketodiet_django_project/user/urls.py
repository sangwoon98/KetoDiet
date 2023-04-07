from django.urls import path
from . import views

urlpatterns = [
    path('', views.AccountView.as_view()), # as_view() = 클래스 기반 뷰를 함수로 변환, HTTP 메소드 (GET, POST, PUT, DELETE 등)를 처리하고, 적절한 메소드를 호출
]
