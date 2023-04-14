from django.contrib import admin
from community.models import CommunityDB, CommunitycommentDB

@admin.register(CommunityDB)
class CommunityDB(admin.ModelAdmin):
    list_display = ['post_num','title']

@admin.register(CommunitycommentDB)
class CommentDB(admin.ModelAdmin):
    list_display = ['comment_num','post_num','content']