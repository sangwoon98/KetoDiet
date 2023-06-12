from rest_framework.views import APIView
from .tasks import send_email_task
from django.http import HttpResponse
import json



class EmailSend(APIView):
    def post(self, request):
        body_json = json.loads(request.body)
        email = body_json.get('email')
        content = body_json.get('content')
        send_email_task.delay('KetoDiet에서 식단 계산 결과가 도착했습니다.', content, 'dbstkddns123456@gamail.com', [email])
        return HttpResponse('Email Sent!')


# class NutrientsCalculate(APIView):
   
#     def body_get_multy_value(self, request, keys):
#         return [request.data.get(key) for key in keys]
    
#     def post(self, request):
#         data = self.body_get_multy_value(request, ['sex', 'double','category'])
#         serializer = CommunityDBSerializer(data={'id':id, 'name': name, 'title': data[0], 'content': data[1], 'category':data[2]}) 
#         if serializer.is_valid():
#             serializer.save()
#             #post_num , 생성날짜 똑같이맞춰주고, 글조회시 커맨트가 없으면 빈리스트
#             return Response({'post_num':serializer.instance.post_num},status=status.HTTP_201_CREATED)
#         else:
#             return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST) # 입력값 오류


        