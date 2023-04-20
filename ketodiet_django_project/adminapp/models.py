from django.db import models

class AdminSettingsDB(models.Model):
    key = models.CharField(primary_key=True, max_length=100)
    int = models.IntegerField(null=True, blank=True)
    str = models.CharField(max_length=100, null=True, blank=True)
    
    def __str__(self):
        return self.key
