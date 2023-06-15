from django.db import models

class UserDB(models.Model):
    id = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=12)
    isAdmin = models.BooleanField(default=False)
    
    def __str__(self):
        return self.name
    
    
    
