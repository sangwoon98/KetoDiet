from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from ketodiet_django_project.board.models import CommunityDB
from django.core.paginator import Paginator


#---------------------------------
from rest_framework import generics, pagination
from .serializers import CommunityDBSerializer
from .models import CommunityDB


from rest_framework import serializers
from .models import CommunityDB

class CommunityDBSerializer(serializers.ModelSerializer):
    class Meta:
        model = CommunityDB
        fields = '__all__'

class CommunityListPagination(pagination.PageNumberPagination): # DRF에서 제공하는 pagination을 상속
    page_size = 20

class CommunityList(generics.ListAPIView): # serializer_class,pagination_class 두가지만 지정해주면 DRF에서 response까지 보냄.
    queryset = CommunityDB.objects.order_by('-num')
    serializer_class = CommunityDBSerializer  
    pagination_class = CommunityListPagination

class Community(APIView):
    
    def body_get_multy_value(self, request, keys):
        return [request.data.get(key) for key in keys]

    def get(self, request):
        community_list = CommunityList.as_view()(request).data
        return Response(community_list)

    def post(self, request):
        data = self.body_get_multy_value(request, ['name', 'title', 'content'])
        serializer = CommunityDBSerializer(data={'name': data[0], 'title': data[1], 'content': data[2]})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, pk):
        community = CommunityDB.objects.get(pk=pk)
        data = self.body_get_multy_value(request, ['name', 'title', 'content'])
        serializer = CommunityDBSerializer(community, data={'name': data[0], 'title': data[1], 'content': data[2]})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def patch(self, request, pk):
        community = CommunityDB.objects.get(pk=pk)
        data = {}
        for key in request.data.keys():
            data[key] = request.data[key]
        serializer = CommunityDBSerializer(community, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        community = CommunityDB.objects.get(pk=pk)
        community.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


#---------------------------------

# class Community(APIView):
    
#     def get(self, request): #page를 받아야함. 쿼리셋으로 받을까? ㅇㅇ
#         page=request.headers.get('page') # page= 1
#         communityDB_datas= CommunityDB.objects.order_by('-num') # 역순으로 정렬
#         pagenator=Paginator(communityDB_datas, 20) # 20개당 1 page로 정렬
#         page_data=pagenator.get_page(page)
#         return Response({'page_data': page_data},status= status.HTTP_200_OK)
        
#     def body_get_multy_value(self, request, key):
#         len(key)
#         name=request.body.get(key[0])
#         title=request.body.get(key[1])
#         content=request.body.get(key[2])
#         data=[name,title,content]
#         return data

# class Community(APIView):
    
#     def body_get_multy_value(self, request, keys):
#         return [request.data.get(key) for key in keys]

#     def post(self, request):
#         key=['name','title','content']
#         data=self.body_get_multy_value(request, key)
#         qs=CommunityDB
#         qs.name=data[0]
#         qs.title=data[1]
#         qs.content=data[2]
#         qs.save()
#         return Response(status= status.HTTP_200_OK)
    
   
    # request.headers.get('Authorization')
    
    # 



    # def post(self, request):
    #     keys = ['name', 'title', 'content']
    #     data = self.body_get_multy_value(request, keys)
    #     qs = CommunityDB(**dict(zip(keys, data)))
    #     qs.save()
    #     return Response(status=status.HTTP_200_OK)


    
    
    # class Community(APIView):
    
    # def get_keys(self, data, keys):
    #     return [data.get(key) for key in keys]
        
    # def post(self, request):
    #     keys=['name','title','content']
    #     values=self.get_keys(request.data, keys)
    #     qs = CommunityDB.objects.create(
    #         name=values[0],
    #         title=values[1],
    #         content=values[2]
    #     )
    #     return Response(status=status.HTTP_200_OK)