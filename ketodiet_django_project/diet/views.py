from rest_framework.views import APIView
from .tasks import send_email_task
from django.http import HttpResponse
from rest_framework import status
import json
from .models import ChallengeDB
from rest_framework.response import Response
from rest_framework import serializers
from user.views import AccountView

class EmailSend(APIView):
    
    def post(self, request):
        body_json = json.loads(request.body)
        email = body_json.get('email')
        image_encoded = body_json.get('image')
        message = 'KetoDiet에서 도착한 식단 입니다.'
        sender_email = 'dbstkddns123456@gmail.com'
        subject = 'KetoDiet에서 식단 계산 결과가 도착했습니다.'
        send_email_task.delay(subject, message ,sender_email, email, image_encoded)
        return HttpResponse('Email Sent!', status=status.HTTP_201_CREATED)

class ChallengeDB_Serializer(serializers.ModelSerializer):
    class Meta:
        model = ChallengeDB
        fields = '__all__' # 모든값들을 직렬화 시킴
        

class ChallengeAPIView(APIView):
    def body_get_multy_value(self, request, keys):
        return [request.data.get(key) for key in keys]

    def get(self, request):
        userid = AccountView.access_token_to_id(self, request)
        all_list = ChallengeDB.objects.all().order_by('-dateTime').filter(userid=userid)
        all_list_serialized = [item.to_dict() for item in all_list]
        return Response(all_list_serialized, status=status.HTTP_200_OK)
    
    def post(self, request):
        userid = AccountView.access_token_to_id(self, request)
        data = self.body_get_multy_value(request, ['gender', 'height', 'weight', 'knowBodyFat', 'neck', 'waist', 'hip', 'bodyFat', 'bmr', 'activityLevel', 'totalEnergy', 'carbs', 'protein', 'fat', 'activity', 'change'])
        serializer = ChallengeDB_Serializer(data={'userid':userid, 'gender': data[0], 'height': data[1], 'weight': data[2], 'knowBodyFat': data[3], 'neck': data[4], 'waist': data[5], 'hip': data[6], 'bodyFat': data[7], 'bmr': data[8], 'activityLevel': data[9], 'totalEnergy': data[10], 'carbs': data[11], 'protein': data[12], 'fat': data[13], 'activity': data[14], 'change': data[15]})
        if serializer.is_valid():
            serializer.save()
            return Response(status=status.HTTP_201_CREATED)
        else:
            errors = serializer.errors
            print(errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# class EmailSend(APIView):
#     def post(self, request):
#         body_json = json.loads(request.body)
#         email = body_json.get('email')
#         content = body_json.get('content')
#         send_email_task.delay('KetoDiet에서 식단 계산 결과가 도착했습니다.', content, 'dbstkddns123456@gamail.com', [email])
#         return HttpResponse('Email Sent!')


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


        