from user.models import UserDB
from community.models import CommunityDB, CommunitycommentDB
from rest_framework.response import Response
# from rest_framework.decorators import api_view
from rest_framework import status
import requests
import base64
import json
#____________________________________ 
# from rest_framework.views import APIView.
#_______________________________________

from rest_framework.views import APIView
from .models import UserDB


class AccountView(APIView):
        
    def access_token_validation(self, access_token):
        headers = {
            'Authorization': f'Bearer {access_token}',
        }
        url = 'https://kapi.kakao.com/v1/user/access_token_info'
        try:
            response = requests.get(url, headers=headers)
            response.raise_for_status() # status code = 200 이상 일때 requests.exceptions.HTTPError 예외 발생
            return response.json()
        except requests.exceptions.HTTPError as error:
            return None # access_token이 유효하지 않은 경우 None 반환
    
    def access_token_to_id(self, request):
        access_token = request.headers.get('Authorization', '').split()[1]
        data = AccountView.access_token_validation(self, access_token)
        if data is None: # 토큰값이 없거나 잘못돼서 id값을 가져오지 못했을때
            return Response({'error': 'Invalid access token.'}, status=status.HTTP_401_UNAUTHORIZED)
        id = data.get('id')
        if not id: # 카카오 api가 변경돼었을 때
            return Response({'error': 'Failed to get access token info from Kakao API.'}, status=status.HTTP_401_UNAUTHORIZED) 
        return id
    
    def body_to_json_value(self, request, key):
        try:
            body_json = json.loads(request.body)
            value = body_json.get(key)
        
        except json.JSONDecodeError as e:
            # JSON 디코딩에 문제가 있는 경우 400 Bad Request 상태 코드와 함께 에러 메시지를 응답으로 반환
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        return value
            
            
        
    def get(self, request):
        id = self.access_token_to_id(request) # 유효성 검증 후 access_token의 id 를 가져옴.
        qs = UserDB.objects.filter(id=id).first() # first method 사용시 요청이 존재하지 않으면 NONE으로 처리
        if qs:
            name = qs.name
            isAdmin = qs.isAdmin
            return Response({'name': name, 'isAdmin':isAdmin},status = status.HTTP_200_OK)
        else:
            return Response({'message': 'signup'}, status = status.HTTP_404_NOT_FOUND)
        
        
    def post(self, request):
        id = self.access_token_to_id(request) # 유효성 검증 후 access_token의 id 를 가져옴.
        name = self.body_to_json_value(request, 'name') # key 값을 넣으면 body에서 value를 가져옴.
        
        if UserDB.objects.filter(name = name).exists():
            return Response(status=status.HTTP_409_CONFLICT) # 아이디 중복
        try:
            UserDB.objects.create(id = id,name=name)
        except:
            return Response(status = status.HTTP_400_BAD_REQUEST) # 생성에 실패 했을때
        
        return Response(status = status.HTTP_201_CREATED) #정상적으로 생성
    
    
    def patch(self, request):
        id = self.access_token_to_id(request)
        newname = self.body_to_json_value(request, 'name')
        
        if UserDB.objects.filter(name = newname).exists():
            return Response(status=status.HTTP_409_CONFLICT) # 아이디 중복
        else:
            user = UserDB.objects.get(id=id)
            nowname = user.name
            user.name = newname
            user.save()
            CommunityDB.objects.filter(name = nowname).update(name = newname) # 현재 이름 으로 작성된 커뮤니티 전부 변경
            CommunitycommentDB.objects.filter(name = nowname).update(name = newname) # 현재 이름 으로 작성된 댓글 전부 변경
            return Response(status=status.HTTP_200_OK)
            
            
    def delete(self, request):
        id = self.access_token_to_id(request) # 유효성 검증 후 access_token의 id 를 가져옴.
        try:
            user=UserDB.objects.get(id=id)
            user.delete()
            return Response(status = status.HTTP_200_OK) # 정상 처리
        except UserDB.DoesNotExist: 
            return Response(status = status.HTTP_404_NOT_FOUND) # 사용자가 이용중에 admin이 탈퇴 시켰을 경우 가능
        except Exception:
            return Response(status = status.HTTP_500_INTERNAL_SERVER_ERROR) # 그 외의 모든 에러
    