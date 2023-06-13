from django.contrib import admin
from diet.models import ChallengeDB

@admin.register(ChallengeDB)
class ChallengeDB(admin.ModelAdmin):
    list_display = ['userid','dateTime']
