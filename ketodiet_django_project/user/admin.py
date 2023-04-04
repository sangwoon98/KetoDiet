from django.contrib import admin
from user.models import UserDB

@admin.register(UserDB)
class UserDB(admin.ModelAdmin):
    list_display = ['id']
