from django.db import models
from django.utils import timezone

class CommunityDB(models.Model):
    post_num=models.AutoField(primary_key=True)
    id = models.CharField(max_length=30)
    name=models.CharField(max_length=15)
    category=models.CharField(max_length=50)
    title=models.CharField(max_length=50)
    content=models.CharField(max_length=1000)
    hit=models.IntegerField(default=0)
    recommend=models.IntegerField(default=0)
    comment_count=models.IntegerField(default=0)
    create_date = models.DateTimeField(default=timezone.now)
    update_date = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return self.title
    

class CommunitycommentDB(models.Model):
    comment_num=models.AutoField(primary_key=True)
    post_num=models.IntegerField()
    id = models.CharField(max_length=30)
    name=models.CharField(max_length=15)
    content=models.CharField(max_length=300)
    create_date= models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return self.content