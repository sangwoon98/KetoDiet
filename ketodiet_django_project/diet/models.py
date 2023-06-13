from django.db import models
from django.utils import timezone

class ChallengeDB(models.Model):
    
    userid = models.IntegerField()
    gender = models.CharField(max_length=10)
    height = models.IntegerField()
    weight = models.IntegerField()
    knowBodyFat = models.BooleanField()
    neck = models.IntegerField(null=True)
    waist = models.IntegerField(null=True)
    hip = models.IntegerField(null=True)
    bodyFat = models.IntegerField()
    bmr = models.IntegerField()
    activityLevel = models.FloatField()
    totalEnergy = models.IntegerField()
    carbs = models.IntegerField()
    protein = models.IntegerField()
    fat = models.IntegerField()
    activity = models.JSONField()
    change = models.IntegerField(null=True)
    dateTime = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return str(self.userid)

    def to_dict(self):
        data = {
            'dateTime': self.dateTime,
            'gender': self.gender,
            'height': self.height,
            'weight': self.weight,
            'knowBodyFat': self.knowBodyFat,
            'neck': self.neck,
            'waist': self.waist,
            'hip': self.hip,
            'bodyFat': self.bodyFat,
            'bmr': self.bmr,
            'activityLevel': self.activityLevel,
            'totalEnergy': self.totalEnergy,
            'carbs': self.carbs,
            'protein': self.protein,
            'fat': self.fat,
            'activity': self.activity,
            'change': self.change,
        }
        return data