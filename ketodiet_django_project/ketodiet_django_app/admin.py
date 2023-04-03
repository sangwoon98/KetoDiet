from django.contrib import admin
from ketodiet_django_app.models import UserDB

@admin.register(UserDB)
class UserDB(admin.ModelAdmin):
    list_display = ['id']
