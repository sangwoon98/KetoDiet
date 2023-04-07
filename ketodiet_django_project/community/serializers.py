from rest_framework import serializers
from .models import CommunityDB

class CommunityDBSerializer(serializers.ModelSerializer):
    class Meta:
        model = CommunityDB
        fields = '__all__'