# KetoDiet Project

KetoDiet은 두명의 개발자가 각각 Front-end와 Back-end를 맡아 개발하고 있는 웹 서비스 입니다.\
Front-end는 Flutter를 이용하여 웹 페이지를 제작하고 있으며 스마트폰 앱 또한 지원 할 예정입니다.\
Back-end는 Django를 이용하여 REST API와 DB 등을 구현합니다.

## 서버 실행 방법

### Front-end Server

```
$ cd $HOME/Programming/KetoDiet/ketodiet_flutter_project

$ flutter run -d chrome --web-hostname=127.0.0.1 --web-port=8000
```

### Back-end Server

```
$ cd $HOME/Programming/KetoDiet/ketodiet_django_project

$ source venv/bin/activate

$ python manage.py runserver 127.0.0.1:8001
```

### Kill Port

    $ sudo lsof -t -i tcp:8000 | xargs kill -9

## Git & Github 사용법

### 내 컴퓨터에 프로젝트 파일을 새로 받기

    $ git clone [url]

### 현재 작업하고 있는 브랜치 확인하기

    $ git branch

### 작업 할 브랜치 변경하기

    $ git switch [브랜치 명]

### 작업 중 [main] 브랜치가 새로 Commit 된 경우

- 내가 수정하던 파일과 다른 파일이 Commit 된 경우

```
$ git pull origin main
```

- 내가 수정하던 파일과 같은 파일이 Commit 된 경우

```
$ git add .

$ git commit -m "[메시지]"

$ git switch main

$ git pull

$ git switch [작업 중인 브랜치 명]

$ git merge main
```

### 작업 완료 후 [main] 브랜치와 병합 할 경우

```
$ git add .

$ git commit -m "[메시지]"

$ git push origin [작업 완료한 브랜치 명]

$ git switch main

$ git merge [작업 완료한 브랜치 명]

$ git push

$ git switch [다시 작업하러 갈 브랜치 명]
```

### 작업 완료 후 병합은 불필요 하지만 기록을 남기고 싶은 경우

```
$ git add .

$ git commit -m "[메시지]"

$ git push origin [작업 완료한 브랜치 명]
```

### 주의 할 점

- Git과 Github는 다릅니다.

```
Git : 사용자의 컴퓨터 저장소에 있는 분산 버전 관리 시스템
Github : Git을 사용하는 프로젝트를 효과적으로 관리 할 수 있도록 해주는 웹 서비스
```

이러한 차이점 때문에 아래와 같은 상황이 발생 할 수 있습니다.\

예) 홍길동이 [hello] 브랜치에서 작업을 마친 후 [main] 브랜치와 merge를 하고 팀원들이 병합이 완료된 [main] 브랜치를 pull 하려 하는 상황에서의 에러

```
홍길동 :
 $ git add .
 $ git commit -m "My Commit"
 $ git push origin hello
 $ git switch main
 $ git merge hello

팀원 :
 $ git pull origin main <= 에러
```

홍길동이 merge는 하였지만 push를 안하였기 때문에 팀원들은 pull을 할 수 없습니다.\
pull과 push를 제외한 모든 명령은 사용자의 컴퓨터 저장소에서 일어나는 일입니다.\
반드시 pull또는 push를 사용 해야만 Github(원격저장소)와 통신을 하여 타인과 작업이 가능합니다.

반대로 굳이 Github에 올리지 않아도 되는, 나 혼자만 수정하는 브랜치 같은 경우에는 add와 commit만 사용하여 작업해도 무방합니다.\
다만 push를 안하고 commit을 할 경우 Github 홈페이지에서 push를 하지 않은 커밋은 확인이 불가능합니다.

기억하십시오. push는 Github에 커밋을 올리는 명령, pull은 Github에서 최신 커밋을 다운로드 하는 명령일 뿐입니다.
