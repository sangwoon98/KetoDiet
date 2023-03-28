**CAUTION**

- cd ketodiet_flutter_project

**Frontend Server**

- flutter run -d chrome --web-hostname=127.0.0.1 --web-port=8000

**Backend Server**

- python manage.py runserver 127.0.0.1:8001

**Kill Port**

- sudo lsof -t -i tcp:8000 | xargs kill -9
