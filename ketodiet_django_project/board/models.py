from django.db import models
from datetime import datetime

class CommunityDB(models.Model):
    num=models.AutoField(primary_key=True)
    name=models.CharField(max_length=15)
    title=models.CharField(max_length=50)
    content=models.CharField(max_length=1000)
    hit=models.IntegerField(default=0)
    recommend=models.IntegerField(default=0)
    createdate = models.DateTimeField(default=datetime.now())
    updatedate = models.DateTimeField(default=datetime.now())
    
    def __str__(self):
        return self.title