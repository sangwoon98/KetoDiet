from http.client import BAD_REQUEST
from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.core.paginator import Paginator
from django.http import HttpRequest
#---------------------------------
from rest_framework import generics, pagination

from user.models import UserDB

from .serializers import CommunityDBSerializer
from .models import CommunityDB, CommunitycommentDB
from rest_framework import serializers
from user.views import AccountView



# DB 모델 인스턴스나 QuerySet 데이터를 JSON으로 반환 , 출력값: fields로 고정, data={'name':name}형태로 삽입후 직렬화 가능,
class CommunityDBSerializer(serializers.ModelSerializer): 
    class Meta:
        model = CommunityDB
        fields = '__all__' # 모든값들을 직렬화 시킴

class CommunityDBSerializerNoContent(serializers.ModelSerializer):
    class Meta:
        model = CommunityDB
        fields = 'post_num','category','title','name','create_date','hit','recommend','comment_count' # 모든값들을 직렬화 시킴
        

class CommunityListPagination(pagination.PageNumberPagination): # DRF에서 제공하는 pagination을 상속
    page_size = 20

class CommunityList(generics.ListAPIView): # serializer_class,pagination_class 두가지만 지정해주면 DRF에서 response까지 보냄.
    # queryset = CommunityDB.objects.order_by('-post_num')
    serializer_class = CommunityDBSerializerNoContent  
    pagination_class = CommunityListPagination

    def get_queryset(self):
        category = self.request.query_params.get('category')
        if category:
                try :
                    queryset = CommunityDB.objects.filter(category=category).order_by('-post_num')
                except:
                    queryset = CommunityDB.objects.none() 
        else:
            try:
                queryset = CommunityDB.objects.all().order_by('-post_num')
            except:
                queryset = CommunityDB.objects.none() 
        return queryset



class CommunityView(APIView):
    
    def body_get_multy_value(self, request, keys):
        return [request.data.get(key) for key in keys]

    def get(self, request): # hit 기능 추가
        page = self.request.query_params.get('page')
        http_request = HttpRequest()
        http_request.GET=request.GET
        http_request.method = 'GET'

        if page:
            serializer = CommunityList.as_view()(http_request).data
            return Response({'serializer':serializer,'page':page}, status=status.HTTP_200_OK)
        
        else:
            post_num = request.query_params.get('post_num')
            try: 
                qs = CommunityDB.objects.get(post_num=post_num)
                community_serializer = CommunityDBSerializer(qs)
                return Response(community_serializer.data, status=status.HTTP_200_OK) 
            except: 
                return Response(status=status.HTTP_400_BAD_REQUEST) # post_num값이 잘못됨
           

    def post(self, request):
        id = AccountView.access_token_to_id
        try:
            name= UserDB.objects.get(id=id).name
            data = self.body_get_multy_value(request, ['title', 'content','category'])
            serializer = CommunityDBSerializer(data={'id':id, 'name': name, 'title': data[0], 'content': data[1], 'category':data[2]}) 
            if serializer.is_valid():
                serializer.save()
                return Response(status=status.HTTP_201_CREATED)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST) # 입력값 오류
        except:
            return Response(status=status.HTTP_403_FORBIDDEN) # 알수 없는 사용자
            

    def patch(self, request):
        id = AccountView.access_token_to_id
        post_num = request.query_params.get('post_num')
        community = CommunityDB.objects.get(post_num)
        
        if community.id == id: # 본인이 작성한게 맞다면
            data = {}
            for key in request.data.keys():
                data[key] = request.data[key]
            serializer = CommunityDBSerializer(community, data=data, partial=True) # 수정일 문제 해결
            if serializer.is_valid():
                serializer.save()
                return Response(status=status.HTTP_200_OK)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(status= status.HTTP_403_FORBIDDEN) # 권한 없음

    def delete(self, request):
        id = AccountView.access_token_to_id
        post_num = request.query_params.get('post_num')
        try:
            community = CommunityDB.objects.get(post_num)
            if community.id == id:
                community.delete()
                return Response(status=status.HTTP_200_OK)
            else:
                if UserDB.objects.get(id).isAdmin == True:
                    community.delete()
                    return Response(status= status.HTTP_200_OK)
                else:
                    return Response(status=status.HTTP_403_FORBIDDEN) # 권한 없음
        except:
            return Response(status=status.HTTP_400_BAD_REQUEST)
            
            
            
class CommentDBSerializer(serializers.ModelSerializer): 
    class Meta:
        model = CommunitycommentDB
        fields = '__all__' # 모든값들을 직렬화 시킴
        
class Comment_notall_DBSerializer(serializers.ModelSerializer): 
    class Meta:
        model = CommunitycommentDB
        fields = 'comment_num','name','content','create_date' # 모든값들을 직렬화 시킴
        
class CommentListPagination(pagination.PageNumberPagination): # DRF에서 제공하는 pagination을 상속
    page_size = 20
        
from rest_framework import generics

class CommunityCommentList(generics.ListAPIView):
    serializer_class = Comment_notall_DBSerializer
    pagination_class = CommentListPagination

    def get_queryset(self):
        post_num = self.request.GET.get('post_num')
        if not post_num:
            # post_num parameter가 전달되지 않으면 400 Bad Request 반환
            raise BAD_REQUEST('post_num parameter is required')
        
        # post_num parameter로 필터링된 댓글들을 comment_num 기준 내림차순으로 정렬하여 반환
        queryset = CommunitycommentDB.objects.filter(post_num=post_num).order_by('-comment_num')
        return queryset
            
            
class Community_comment(APIView):
    
    def get(self, request):
        page = request.query_params.get('page')
        http_request = HttpRequest()
        http_request.GET = request.GET
        http_request.method = 'GET'
        serializer = CommunityCommentList.as_view()(http_request).data
        return Response({'serializer':serializer,'page':page}, status=status.HTTP_200_OK)
        
        # post_num = request.GET.get('post_num')
        # page_number = request.GET.get('page')
        # comments = CommunitycommentDB.objects.filter(post_num=post_num).order_by('-comment_num')
        # paginator = Paginator(comments, 20)  # 한 페이지에 20개의 댓글
        # page_obj = paginator.get_page(page_number)
        # serializer = CommentDBSerializer(page_obj, many=True)
        # return Response(serializer.data)
    
    def post(self, request):
        id = AccountView.access_token_to_id
        try:
            qs = UserDB.objects.get(id=id)
            name = qs.name
            content = request.body.get('content')
            post_num = request.query_params.get('post_num')
            serializer = CommentDBSerializer(data={'id':id, 'name':name, 'content':content, 'post_num':post_num})
            if serializer.is_valid():
                serializer.save()
                com_qs = CommunityDB.objects.get(post_num=post_num)
                com_qs.comment_count+=1
                com_qs.save()
                return Response(status=status.HTTP_201_CREATED) #정상
            else:
                return Response(status=status.HTTP_400_BAD_REQUEST) # 요청 값 오류   
        except:
            return Response(status=status.HTTP_403_FORBIDDEN) # 알수 없는 사용자
    
    def patch(self, request):
        id = AccountView.access_token_to_id
        if CommunitycommentDB.id == id:
            try:
                comment_num = request.query_params.get('comment_num')
                comment = CommunitycommentDB.objects.get(comment_num)
                data = {}
                for key in request.data.keys(): # body의 데이터를 딕셔너리로
                    data[key] = request.data[key]
                serializer = CommentDBSerializer(comment, data=data, partial=True)
                if serializer.is_valid():
                    serializer.save()
                    return Response(status=status.HTTP_200_OK)
                else:
                    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST) 
            except:
                return Response(status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(status=status.HTTP_403_FORBIDDEN) # 알수 없는 사용자
            

    def delete(self, request):
        id = AccountView.access_token_to_id
        comment_num = request.query_params.get('comment_num')
        try:
            comment = CommunitycommentDB.objects.get(comment_num)
            post_num = comment.post_num
            if comment.id == id:
                comment.delete()
                com_qs = CommunityDB.objects.get(post_num=post_num)
                com_qs.comment_count-=1
                com_qs.save()
                return Response(status=status.HTTP_200_OK)
            else:
                if UserDB.objects.get(id).isAdmin == True:
                    comment.delete()
                    com_qs = CommunityDB.objects.get(post_num=post_num)
                    com_qs.comment_count-=1
                    com_qs.save()
                    return Response(status= status.HTTP_200_OK)
                else:
                    return Response(status=status.HTTP_403_FORBIDDEN) # 권한 없음
        except:
            return Response(status= status.HTTP_400_BAD_REQUEST)


        
        
    # def put(self, request, pk):
    #     community = CommunityDB.objects.get(pk=pk)
    #     data = self.body_get_multy_value(request, ['name', 'title', 'content'])
    #     serializer = CommunityDBSerializer(community, data={'name': data[0], 'title': data[1], 'content': data[2]})
    #     if serializer.is_valid():
    #         serializer.save()
    #         return Response(serializer.data)
    #     else:
    #         return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



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