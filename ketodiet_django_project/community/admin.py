from django.contrib import admin
from community.models import CommunityDB

@admin.register(CommunityDB)
class CommunityDB(admin.ModelAdmin):
    list_display = ['post_num','title']
