from rest_framework.response import Response
from rest_framework.decorators import api_view
import requests
import base64
import json

@api_view(['GET'])
def loginCheck(request):
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
 

    # id_token을 .으로 구분하여 헤더, 페이로드, 서명으로 분리합니다.
    header_b64, payload_b64, signature_b64 = id_token.split('.')

    # 헤더와 페이로드를 디코딩합니다.
    header = json.loads(base64.b64decode(header_b64).decode('utf-8'))
    payload = json.loads(base64.b64decode(payload_b64).decode('utf-8'))

    # 결과를 출력합니다.
    print('Header:', header)
    print('Payload:', payload)
    print('Signature:', signature_b64)

    
    if access_token:
        return Response({'scopes': scopes})
    else:
        return Response({'scopes': 'None'}, status=400)
