from user.models import UserDB
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status
import requests
import base64
import json
import jwt
#____________________________________
# from rest_framework.views import APIView
#_______________________________________

from rest_framework.views import APIView
from rest_framework.response import Response
import requests
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
            raise ValueError(f'Failed to get access token info from Kakao API: {error}')
    
    def access_token_to_id(self, request):
        access_token = request.headers.get('Authorization', '').split()[1]
        try:
            data = self.access_token_validation(access_token)
            id = data['id']
            return id
        except (ValueError, KeyError):
            return Response({'error': 'Failed to get access token info from Kakao API.'}, status = status.HTTP_401_UNAUTHORIZED)

        
    def get(self, request):
        id = self.access_token_to_id(request) # 유효성 검증 후 access_token의 id 를 가져옴.
        qs = UserDB.objects.filter(id=id).first()
        if qs:
            return Response(status = status.HTTP_200_OK)
        else:
            return Response({'message': 'signup'}, status = status.HTTP_404_NOT_FOUND)
        
        
    def post(self, request):
        id = self.access_token_to_id(request) # 유효성 검증 후 access_token의 id 를 가져옴.
        body_json = json.loads(request.body)
        name = body_json.get('name')
        
        if UserDB.objects.filter(name = name).exists():
            return Response(status=status.HTTP_409_CONFLICT)
        try:
            UserDB.objects.create(id = id,name=name)
        except:
            return Response(status = status.HTTP_400_BAD_REQUEST)
        
        return Response(status = status.HTTP_201_CREATED)
    
    def delete(self, request):
        id = self.access_token_to_id(request) # 유효성 검증 후 access_token의 id 를 가져옴.
        try:
            user=UserDB.objects.get(id=id)
            user.delete()
            return Response(status = status.HTTP_200_OK) # 정상 처리
        except UserDB.DoesNotExist: 
            return Response(status = status.HTTP_404_NOT_FOUND) # 사용자가 이용중에 admin이 탈퇴 시켰을 경우 가능
        except Exception as e:
            return Response(status = status.HTTP_500_INTERNAL_SERVER_ERROR) # 그 외의 모든 에러
        
        



# def access_token_validation(access_token): # 액세스 토큰 유효성 검사 함수
#     headers = {
#         'Authorization': f'Bearer {access_token}',
#     }
#     url = 'https://kapi.kakao.com/v1/user/access_token_info'
#     response = requests.get(url, headers=headers)
#     return response
    

# @api_view(['GET'])
# def account(request):
#     access_token = request.headers.get('Authorization').split()[1] 

#     response = access_token_validation(access_token) # 액세스 토큰 유효성 검사
    
#     if response.status_code == status.HTTP_200_OK:
#         data = response.json()
#         id = data['id']
#         qs = UserDB.objects.filter(id=id).first()
        
#         if qs:
#             return Response(status = status.HTTP_200_OK) # 로그인 정상처리
#         else:   
#             return Response({"message": "signup"}, status = status.HTTP_404_NOT_FOUND) # 회원가입 진행
            
#     else:
#         return Response({'error': 'Failed to get access token info from Kakao API.'}, status = status.HTTP_401_UNAUTHORIZED) # 미승인된 토큰





    # # decoded_token = jwt.decode(access_token, verify=False)

    # # print(decoded_token)
    # # id_token을 .으로 구분하여 헤더, 페이로드, 서명으로 분리합니다.
    # header_b64, payload_b64, signature_b64 = id_token.split('.')

    # # 헤더와 페이로드를 디코딩합니다.
    # header = json.loads(base64.b64decode(header_b64).decode('utf-8'))
    # payload = json.loads(base64.b64decode(payload_b64).decode('utf-8'))

    # # 결과를 출력합니다.
    # print('Header:', header)
    # print('Payload:', payload)
    # print('Signature:', signature_b64)
    # print('access_token: ',access_token)
    
    # if access_token:
    #     return Response({'scopes': scopes})
    # else:
    #     return Response({'scopes': 'None'}, status=400)
    
    # access_token = request.GET.get('access_token', None)
    # expires_at = request.GET.get('expires_at', None)
    # refresh_token = request.GET.get('refresh_token', None)
    # refresh_token_expires_at = request.GET.get('refresh_token_expires_at', None)
    # scopes = request.GET.get('scopes', None)
    # id_token = request.GET.get('id_token', None)
    # print('access_token: ',access_token)
    # print('expires_at: ', expires_at)
    # print('refresh_token: ', refresh_token)
    # print('refresh_token_expires_at: ',refresh_token_expires_at)
    # print('scopes: ',scopes)
    # print('id_token: ',id_token)


# # views.py
# from rest_framework.views import APIView
# from rest_framework.response import Response
# from rest_framework import status
# import requests

# class AccessTokenInfoAPIView(APIView):
#     def get(self, request, format=None):
#         access_token = request.META.get('HTTP_AUTHORIZATION', '').split(' ')[1]
#         headers = {
#             'Authorization': f'Bearer {access_token}',
#         }
#         url = 'https://kapi.kakao.com/v1/user/access_token_info'
#         response = requests.get(url, headers=headers)

#         if response.status_code == status.HTTP_200_OK:
#             data = response.json()
#             return Response(data)
#         else:
#             return Response({'error': 'Failed to get access token info from Kakao API.'}, status=status.HTTP_400_BAD_REQUEST)
