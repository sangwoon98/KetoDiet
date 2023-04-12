from django.db import models

class UserDB(models.Model):
    id = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=12)
    isAdmin = models.BooleanField(default=False)
    
    def __str__(self):
        return self.name
    
    
    
