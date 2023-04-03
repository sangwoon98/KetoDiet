from ketodiet_django_app.models import UserDB
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

@api_view(['GET'])
def account(request):
    access_token = request.GET.get('access_token', None)
    expires_at = request.GET.get('expires_at', None)
    refresh_token = request.GET.get('refresh_token', None)
    refresh_token_expires_at = request.GET.get('refresh_token_expires_at', None)
    scopes = request.GET.get('scopes', None)
    id_token = request.GET.get('id_token', None)
    print('access_token: ',access_token)
    print('expires_at: ', expires_at)
    print('refresh_token: ', refresh_token)
    print('refresh_token_expires_at: ',refresh_token_expires_at)
    print('scopes: ',scopes)
    print('id_token: ',id_token)
    
    
    def access_token_validation(access_token): # 액세스 토큰 유효성 검사
        headers = {
            'Authorization': f'Bearer {access_token}',
        }
        url = 'https://kapi.kakao.com/v1/user/access_token_info'
        response = requests.get(url, headers=headers)
        return response
    
    response = access_token_validation(access_token) # 액세스 토큰 유효성 검사
    if response.status_code == status.HTTP_200_OK:
        data = response.json()
        id = data['id']
        
        try: # 아이디가 존재하는가?
            qs = UserDB.objects.get(id = id)
            
        except UserDB.DoesNotExist: # 존재하지 않는다면 None처리
            qs = None
        
        if qs:
            return Response(status = status.HTTP_200_OK) # 로그인 정상처리
        else:
            return Response({"message": "signup"}, status = status.HTTP_404_NOT_FOUND) # 회원가입 진행
            
    else:
        return Response({'error': 'Failed to get access token info from Kakao API.'}, status = status.HTTP_401_UNAUTHORIZED) # 미승인된 토큰





    # decoded_token = jwt.decode(access_token, verify=False)

    # print(decoded_token)
    # id_token을 .으로 구분하여 헤더, 페이로드, 서명으로 분리합니다.
    header_b64, payload_b64, signature_b64 = id_token.split('.')

    # 헤더와 페이로드를 디코딩합니다.
    header = json.loads(base64.b64decode(header_b64).decode('utf-8'))
    payload = json.loads(base64.b64decode(payload_b64).decode('utf-8'))

    # 결과를 출력합니다.
    print('Header:', header)
    print('Payload:', payload)
    print('Signature:', signature_b64)
    print('access_token: ',access_token)
    
    if access_token:
        return Response({'scopes': scopes})
    else:
        return Response({'scopes': 'None'}, status=400)


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
