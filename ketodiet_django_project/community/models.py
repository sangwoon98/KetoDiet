from django.db import models
from django.utils import timezone

class CommunityDB(models.Model):
    post_num=models.AutoField(primary_key=True)
    id = models.IntegerField()
    name=models.CharField(max_length=12)
    category=models.CharField(max_length=10)
    title=models.CharField(max_length=30)
    content = models.TextField()
    hit=models.IntegerField(default=0)
    recommend = models.JSONField(default=list)
    comment_count=models.IntegerField(default=0)
    create_date = models.DateTimeField(default=timezone.now)
    update_date = models.DateTimeField(default=timezone.now)
    isRecommend= models.BooleanField(default=False)
    
    def save(self, *args, **kwargs):
        if not self.post_num:
            self.create_date = timezone.now()
        self.update_date = self.create_date
        super().save(*args, **kwargs)
    
    def __str__(self):
        return self.title
    

class CommunitycommentDB(models.Model):
    comment_num=models.AutoField(primary_key=True)
    post_num=models.IntegerField()
    id = models.IntegerField()
    name=models.CharField(max_length=12)
    content = models.TextField()
    create_date= models.DateTimeField(default=timezone.now)
    update_date = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return self.content
    
class CategoryDB(models.Model):
    categorys=models.CharField(default='일반', max_length=16)
    
    def __str__(self):
        return self.categorys