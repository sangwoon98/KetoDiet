# celery.py

import os
from celery import Celery

# 프로젝트의 Django 설정 모듈을 지정합니다.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ketodiet_django_project.settings')

app = Celery('ketodiet_django_project')

# Django 설정 파일(settings.py)에서 Celery 설정을 가져옵니다.
app.config_from_object('django.conf:settings', namespace='CELERY')

# Celery 작업을 등록하는 모듈을 자동으로 탐색합니다.
app.autodiscover_tasks()
