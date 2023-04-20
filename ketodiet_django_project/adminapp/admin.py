from django.contrib import admin
from adminapp.models import AdminSettingsDB

@admin.register(AdminSettingsDB)
class AdminSettingsDB(admin.ModelAdmin):
    list_display = ['key','int','str']