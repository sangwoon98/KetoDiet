from django.shortcuts import render
from rest_framework import generics, pagination,status,serializers
from user.models import UserDB
from community.views import get_http_request_to_request
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Q
from user.views import AccountView

class UserListPagination(pagination.PageNumberPagination): # DRF에서 제공하는 pagination을 상속
    page_size = 30

class UserListSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserDB
        fields = 'id','name','isAdmin' # 모든값들을 직렬화 시킴
        
class CommunityList(generics.ListAPIView):
    serializer_class = UserListSerializer
    pagination_class = UserListPagination
    def get_queryset(self):
        keyword = self.request.query_params.get('keyword')
        if not keyword:
            queryset = UserDB.objects.all().order_by('name')
        else :
            queryset = UserDB.objects.filter(Q(name__contains=keyword)).order_by('name')
        return queryset

class UserDBView(APIView):
    def get(self, request):
        id = AccountView.access_token_to_id(self, request)
        if UserDB.objects.get(id=id).isAdmin==True:
            http_request = get_http_request_to_request(request)
            serializer = CommunityList.as_view()(http_request).data
            return Response({'page':serializer}, status=status.HTTP_200_OK)
        else:
            return Response(status=status.HTTP_401_UNAUTHORIZED)
    
    def patch(self, request):
        id = AccountView.access_token_to_id(self, request)
        if UserDB.objects.get(id=id).isAdmin==True:
            uid= self.request.data.get('uid')
            isAdmin_val = self.request.data.get('isAdmin')
            try:
                userinfo = UserDB.objects.get(id=uid)
                userinfo.isAdmin = isAdmin_val
                userinfo.save()
            except:
                return Response(status=status.HTTP_204_NO_CONTENT)
            return Response(status=status.HTTP_200_OK)
        else:
            return Response(status=status.HTTP_401_UNAUTHORIZED)
    
    def delete(self, request):
        id = AccountView.access_token_to_id(self, request)
        if UserDB.objects.get(id=id).isAdmin==True:
            uid= self.request.data.get('uid')
            try:
                userinfo=UserDB.objects.get(id=uid)
                userinfo.delete()
            except:
                return Response(status=status.HTTP_204_NO_CONTENT)
            return Response(status=status.HTTP_200_OK)
        else:
            return Response(status=status.HTTP_401_UNAUTHORIZED)
    

    
    
    