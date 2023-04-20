from http.client import BAD_REQUEST
from django.utils import timezone
from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework import status
from django.core.paginator import Paginator
from django.http import HttpRequest
#---------------------------------
from rest_framework import generics, pagination

from user.models import UserDB
from adminapp.models import AdminSettingsDB

from .serializers import CommunityDBSerializer
from .models import CommunityDB, CommunitycommentDB, CategoryDB
from rest_framework import serializers
from user.views import AccountView

#-----
# from django.conf import settings
from rest_framework.response import Response
from rest_framework.views import APIView

from django.db.models import Q
import json, math, urllib.parse

# DB 모델 인스턴스나 QuerySet 데이터를 JSON으로 반환 , 출력값: fields로 고정, data={'name':name}형태로 삽입후 직렬화 가능,
class CommunityDBSerializer(serializers.ModelSerializer): 
    class Meta:
        model = CommunityDB
        fields = '__all__' # 모든값들을 직렬화 시킴
        
        def update(self, instance, validated_data):
            instance = super().update(instance, validated_data)
            instance.update_date = timezone.now()
            instance.save()
            return instance

class CommunityDBSerializerNoContent(serializers.ModelSerializer):
    class Meta:
        model = CommunityDB
        fields = 'post_num','category','title','name','create_date','update_date','hit','recommend','comment_count','isRecommend' # 모든값들을 직렬화 시킴
        

class CommunityListPagination(pagination.PageNumberPagination): # DRF에서 제공하는 pagination을 상속
    page_size = 30

class CommunityList(generics.ListAPIView):
    serializer_class = CommunityDBSerializerNoContent  
    pagination_class = CommunityListPagination

    def get_queryset(self):
        category = self.request.query_params.get('category')
        target = self.request.query_params.get('target')
        keyword = self.request.query_params.get('keyword')
        isRecommend = self.request.query_params.get('isRecommend')
        # recommend = self.request.query_params.get('recommend')
        
        category = urllib.parse.unquote(category) if category else None
        target = urllib.parse.unquote(target) if target else None
        keyword = urllib.parse.unquote(keyword) if keyword else None
        
        queryset = CommunityDB.objects.all().order_by('-post_num')
        comment_queryset = CommunitycommentDB.objects.all().order_by('-post_num')
        
        if category:
            queryset = CommunityDB.objects.all().order_by('-post_num').filter(category=category)

        if isRecommend:
            queryset = CommunityDB.objects.all().order_by('-post_num').filter(isRecommend=True)
            
        # if recommend and category:
        #     queryset = CommunityDB.objects.all().order_by('-post_num').filter(category=category).filter(isRecommend=True)
            
        if isRecommend and category:
            queryset = CommunityDB.objects.all().order_by('-post_num').filter(category=category).filter(isRecommend=True)
        
        if target and keyword:
            
            if target == 'all':
                # 게시글 검색
                search_queryset = queryset.filter(Q(title__contains=keyword) | Q(name__contains=keyword) | Q(content__contains=keyword)).distinct()
                # 댓글 검색
                comment_queryset_search = comment_queryset.filter(content__contains=keyword).values_list('post_num', flat=True).distinct()
                # 게시글과 댓글 합치기
                queryset = search_queryset | queryset.filter(post_num__in=comment_queryset_search).distinct()
                
            elif target == 'title':
                queryset = queryset.filter(title__contains=keyword)
            elif target == 'name':
                queryset = queryset.filter(name__contains=keyword)
            elif target == 'content':
                queryset = queryset.filter(content__contains=keyword)
            elif target == 'comment':
                comment_queryset = comment_queryset.filter(content__contains=keyword).values_list('post_num', flat=True).distinct()
                queryset = queryset.filter(post_num__in=comment_queryset).distinct()
        return queryset


#___________________________전역 함수____________________________

def get_post_num_order(post_num, all_list, division_number):
    import math
    post_num=int(post_num)
    """
    all_list에서 post_num이 몇번째에 위치하는지 찾는 함수
    """
    # all_list에서 post_num과 같은 객체의 인덱스를 반환합니다.
    index = next((i for i, obj in enumerate(all_list) if obj.post_num == post_num), None)

    # post_num을 가진 객체가 없으면 None을 반환합니다.
    if index is None:
        return None
    # post_num을 가진 객체의 인덱스를 1부터 시작하는 순서로 변환하여 반환합니다.
    return math.ceil((index+1)/division_number)

def get_http_request_to_request(request):
    http_request = HttpRequest()
    http_request.GET=request.GET
    http_request.method = 'GET'
    http_request.META['SERVER_NAME'] = request.META['SERVER_NAME']
    http_request.META['SERVER_PORT'] = request.META['SERVER_PORT']
    return(http_request)

#___________________________전역 함수 끝____________________________



class CommunityView(APIView):
    def body_get_multy_value(self, request, keys):
        return [request.data.get(key) for key in keys]

    def get(self, request):
        page = self.request.query_params.get('page')
        category = self.request.query_params.get('category')
        keyword = self.request.query_params.get('keyword')
        target = self.request.query_params.get('target')
        isRecommend = self.request.query_params.get('isRecommend')
        categories = CategoryDB.objects.all().values_list('categorys', flat=True)
 
        if page:
            # page 파라미터가 존재하는 경우에 대한 처리
            http_request = get_http_request_to_request(request)
            serializer = CommunityList.as_view()(http_request).data
            return Response({'category':categories, 'page':serializer}, status=status.HTTP_200_OK)
        else:
            # post_num 파라미터가 있는 경우에 대한 처리
            post_num = request.query_params.get('post_num')
            
             #__________________________________글_____________________________________________________
                # 글, 목록, 댓글 가져오기
            try: 
                qs = CommunityDB.objects.get(post_num=post_num)
                qs.hit += 1
                qs.save()
                community_serializer = CommunityDBSerializer(qs).data
            except CommunityDB.DoesNotExist:
                qs = None
                community_serializer = {"detail":"invalid page."}

        #__________________________________목록_____________________________________________________
            all_list = CommunityDB.objects.all().order_by('-post_num')
            
            if category:
                all_list=all_list.filter(category=category)
            if qs:
                page_number = get_post_num_order(post_num, all_list, 30)
            else:
                page_number = 1
            
            if page_number is None:
                list_serializer = []  # 목록에 없을때, 이게 필요한가..?
            else:
                http_request = HttpRequest()
                http_request.method = 'GET'
                http_request.META['SERVER_NAME'] = request.META['SERVER_NAME']
                http_request.META['SERVER_PORT'] = request.META['SERVER_PORT']
                http_request.GET['page'] = page_number
                http_request.GET['category']=category
                http_request.GET['target']=target
                http_request.GET['keyword']=keyword
                http_request.GET['isRecommend']=isRecommend
                list_serializer = CommunityList.as_view()(http_request).data
        #__________________________________댓글_____________________________________________________
        
            if qs:
                all_list = CommunitycommentDB.objects.filter(post_num=post_num)
            
                comment_page = math.ceil(len(all_list)/20)
                if comment_page==0:
                    comment_serializer={
                        "count": 0,
                        "next": None,
                        "previous": None,
                        "results": []
                    }
                else:
                    http_request = HttpRequest()
                    http_request.method = 'GET'
                    http_request.META['SERVER_NAME'] = request.META['SERVER_NAME']
                    http_request.META['SERVER_PORT'] = request.META['SERVER_PORT']
                    http_request.GET['page'] = comment_page
                    http_request.GET['post_num'] = post_num
                    comment_serializer = CommunityCommentList.as_view()(http_request).data
            #_______________________________________________________________________________________
            else:
                comment_serializer={"detail":"invalid page."}
                
            return Response({
                'page_num': page_number,
                'category': categories,
                'post': community_serializer,
                'comment': comment_serializer,
                'page': list_serializer
            }, status=status.HTTP_200_OK)
            
            # else:
            #     return Response({'detail': 'Invalid post_num.'}, status=status.HTTP_400_BAD_REQUEST)
            
            # except:
            #     # 그 외의 예외 상황에 대한 처리
            #     return Response({'detail': 'An error has occurred.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


    def post(self, request):
        id = AccountView.access_token_to_id(self, request)
        try:
            name= UserDB.objects.get(id=id).name   
        except:
            return Response(status=status.HTTP_403_FORBIDDEN) # 알수 없는 사용자
            
        data = self.body_get_multy_value(request, ['title', 'content','category'])
        serializer = CommunityDBSerializer(data={'id':id, 'name': name, 'title': data[0], 'content': data[1], 'category':data[2]}) 
        if serializer.is_valid():
            serializer.save()
            #post_num , 생성날짜 똑같이맞춰주고, 글조회시 커맨트가 없으면 빈리스트
            return Response({'post_num':serializer.instance.post_num},status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST) # 입력값 오류


    def patch(self, request):
        try:
            id = AccountView.access_token_to_id(self, request)
            post_num = request.query_params.get('post_num')
            community = CommunityDB.objects.get(post_num=post_num)
        except:
            return Response( status=status.HTTP_404_NOT_FOUND)
        
        if community.id == id: # 본인이 작성한게 맞다면
            data = {}
            for key in request.data.keys():
                data[key] = request.data[key]
            serializer = CommunityDBSerializer(community, data=data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response(status=status.HTTP_200_OK)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        elif UserDB.objects.get(id=id).isAdmin==True:
            data={}
            data['category']= request.data.get('category')
            serializer = CommunityDBSerializer(community, data=data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response(status=status.HTTP_200_OK)
            else:
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(status= status.HTTP_403_FORBIDDEN) # 권한 없음


    def delete(self, request):
        id = AccountView.access_token_to_id(self, request)
        post_num = request.query_params.get('post_num')
        try:
            community = CommunityDB.objects.get(post_num=post_num)
        except:
            return Response(status=status.HTTP_400_BAD_REQUEST)
        if community:
            
            if community.id == id:
                community.delete()
                try:
                    comment_list=CommunitycommentDB.objects.filter(post_num=post_num)
                except:
                    comment_list=None
                if comment_list:
                    comment_list.delete()
                return Response(status=status.HTTP_200_OK)
            elif UserDB.objects.get(id=id).isAdmin == True:
                community.delete()
                try:
                    comment_list=CommunitycommentDB.objects.filter(post_num=post_num)
                except:
                    comment_list=None
                if comment_list:
                    comment_list.delete()
                return Response(status= status.HTTP_200_OK)
            else:
                return Response(status=status.HTTP_403_FORBIDDEN) # 권한 없음

class CommentDBSerializer(serializers.ModelSerializer):
    class Meta:
        model = CommunitycommentDB
        fields = '__all__' # 모든값들을 직렬화 시킴
        
class Comment_notall_DBSerializer(serializers.ModelSerializer): 
    class Meta:
        model = CommunitycommentDB
        fields = 'comment_num','name','content','create_date','update_date' 
        
class CommentListPagination(pagination.PageNumberPagination): # DRF에서 제공하는 pagination을 상속
    page_size = 20
        


class CommunityCommentList(generics.ListAPIView):
    serializer_class = Comment_notall_DBSerializer
    pagination_class = CommentListPagination

    def get_queryset(self):
        post_num = self.request.GET.get('post_num')
        queryset = CommunitycommentDB.objects.filter(post_num=post_num).order_by('comment_num')
        return queryset

            
            
class Community_comment(APIView):
    
    def get(self, request):
        http_request = HttpRequest()
        http_request.GET = request.GET
        http_request.method = 'GET'
        http_request.META['SERVER_NAME'] = request.META['SERVER_NAME']
        http_request.META['SERVER_PORT'] = request.META['SERVER_PORT']
        serializer = CommunityCommentList.as_view()(http_request).data
        return Response({'comment':serializer}, status=status.HTTP_200_OK)
    
    def post(self, request):
        id = AccountView.access_token_to_id(self, request)
        try:
            qs = UserDB.objects.get(id=id)
        except:
            return Response(status=status.HTTP_403_FORBIDDEN) # 알수 없는 사용자
        name = qs.name
        content = request.data.get('content')
        post_num = request.query_params.get('post_num')
        serializer = CommentDBSerializer(data={'id':id, 'name':name, 'content':content, 'post_num':post_num})
        if serializer.is_valid():
            com_qs = CommunityDB.objects.get(post_num=post_num)
            serializer.save()
            com_qs.comment_count+=1
            com_qs.save()
            return Response(status=status.HTTP_201_CREATED) #정상
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST) # 요청 값 오류   

    
    def patch(self, request):
        id = AccountView.access_token_to_id(self, request)
        comment_num = request.query_params.get('comment_num')
        try:
            comment = CommunitycommentDB.objects.get(comment_num=comment_num)
        except:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
        if comment.id == id:
            try:
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
        id = AccountView.access_token_to_id(self, request)
        comment_num = request.query_params.get('comment_num')
        try:
            comment = CommunitycommentDB.objects.get(comment_num=comment_num)
        except:
            return Response(status= status.HTTP_400_BAD_REQUEST)
        post_num = comment.post_num
        if comment.id == id:
            com_qs = CommunityDB.objects.get(post_num=post_num)
            comment.delete()
            com_qs.comment_count-=1
            com_qs.save()
            return Response(status=status.HTTP_200_OK)
        else:
            if UserDB.objects.get(id=id).isAdmin == True:
                com_qs = CommunityDB.objects.get(post_num=post_num)
                comment.delete()
                com_qs.comment_count-=1
                com_qs.save()
                return Response(status= status.HTTP_200_OK)
            else:
                return Response(status=status.HTTP_403_FORBIDDEN) # 권한 없음

        

class Category(APIView):
    
    def get(self, request):
        try:
            categories = CategoryDB.objects.all().values_list('categorys', flat=True)
            if not categories: # 만약 카테고리가 하나도 없다면 빈 리스트를 반환
                categories = []
        except:
            return Response(status= status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response({'category': categories})
    
    def post(self, request):
        id = AccountView.access_token_to_id(self, request)
        try:
            isAdmin = UserDB.objects.get(id=id).isAdmin
        except:
            isAdmin= None
        
        if isAdmin:
            category = request.data.get('category') # 파라미터의 카테고리
            all_categories = CategoryDB.objects.all().values_list('categorys', flat=True) # 저장된 모든 카테고리를 리스트로 가져옵니다.
            if category not in all_categories: # 새로운 카테고리가 all_categories에 없으면 추가합니다.
                CategoryDB.objects.create(categorys=category)
                categories = CategoryDB.objects.all().values_list('categorys', flat=True)
                return Response({'category': categories}, status= status.HTTP_201_CREATED)
            else:
                return Response({'category': all_categories},status= status.HTTP_400_BAD_REQUEST)
        else:
            return Response(status= status.HTTP_403_FORBIDDEN)

    def patch(self, request):
        id = AccountView.access_token_to_id(self, request)
        try:
            isAdmin = UserDB.objects.get(id=id).isAdmin
        except:
            isAdmin = None

        if isAdmin:
            new_category = request.data.get('newcategory')  # 교체 하려는 카테고리
            category_name = request.data.get('category')  # 기존 카테고리 이름
            category = CategoryDB.objects.get(categorys=category_name)
            categories = CategoryDB.objects.all().values_list('categorys', flat=True)
            if new_category not in categories:
                category.categorys = new_category
                category.save()
                CommunityDB.objects.filter(category=category_name).update(category=new_category) # 카테고리가 변경된 글들의 카테고리를 업데이트
                categories = CategoryDB.objects.all().values_list('categorys', flat=True)
                return Response({'category': categories}, status=status.HTTP_200_OK)
            else:
                return Response({'category': categories}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(status=status.HTTP_403_FORBIDDEN)
        
    
    def delete(self, request):
        id = AccountView.access_token_to_id(self, request)
        try:
            isAdmin = UserDB.objects.get(id=id).isAdmin
        except:
            isAdmin = None
        if isAdmin:
            category = request.data.get('category') # 파라미터의 카테고리
            try:
                category = CategoryDB.objects.get(categorys=category)
            except:
                category= None
                
            if category:
                category.delete()
                try:
                    categories = CategoryDB.objects.all().values_list('categorys', flat=True)
                except:
                    categories = None
                    
                if not categories: # 만약 카테고리가 하나도 없다면 빈 리스트를 반환
                    categories = []
            else:
                categories = CategoryDB.objects.all().values_list('categorys', flat=True)
                return Response({'category': categories}, status= status.HTTP_404_NOT_FOUND)
                
            return Response({'category': categories}, status= status.HTTP_200_OK)
        else:
            return Response(status= status.HTTP_403_FORBIDDEN)
        
        
class Recommend(APIView):
    
    def get(self, request):
        post_num=request.query_params.get('post_num')
        community=CommunityDB.objects.get(post_num=post_num)
        recommend=community.recommend
        return Response({'recommend': recommend})
    
    def post(self, request):
        id = AccountView.access_token_to_id(self, request)
        if id:
            post_num = request.query_params.get('post_num')
            community = CommunityDB.objects.get(post_num=post_num)
            recommends = community.recommend
            if id not in recommends:
                recommends.append(id)
                community.recommend = recommends
                cutline=AdminSettingsDB.objects.get(key='recommend_cutline')
                if len(community.recommend) >= cutline:
                    community.isRecommend = True
                community.save()
                    
            return Response({'recommend': community.recommend}, status=status.HTTP_201_CREATED)
        else:
            return Response(status=status.HTTP_403_FORBIDDEN)

    def delete(self, request):
        id = AccountView.access_token_to_id(self, request)
        if id:
            post_num = request.query_params.get('post_num')
            community = CommunityDB.objects.get(post_num=post_num)
            recommends = json.loads(community.recommend)
            if id in recommends:
                recommends.remove(id)
                community.recommend = json.dumps(recommends)
                community.save()
                return Response({'recommend': community.recommend})
            else:
                return Response({'recommend': community.recommend},status=status.HTTP_404_NOT_FOUND)
        else:
            return Response(status=status.HTTP_403_FORBIDDEN)



# import importlib
# from . import config

# class Category(APIView):
    
#     def post(self, request):
#         # id = AccountView.access_token_to_id
#         id = 1
#         try:
#             isAdmin = UserDB.objects.get(id=id).isAdmin
#             if isAdmin:
#                 category = request.data.get('category')
#                 if category not in config.CATEGORIES:
#                     print(config.CATEGORIES)
#                     config.CATEGORIES.append(category)
#                     print(config.CATEGORIES)
#                     new_config = importlib.import_module('.config', __package__)
#                     setattr(new_config, 'CATEGORIES', config.CATEGORIES)
#                 return Response({'success': True, 'categories': config.CATEGORIES})
#             else:
#                 return Response({'success': False, 'message': 'Unauthorized'})
#         except UserDB.DoesNotExist:
#             return Response({'success': False, 'message': 'User does not exist'})

#     def delete(self, request):
#         # id = AccountView.access_token_to_id
#         id = 1
#         try:
#             isAdmin = UserDB.objects.get(id=id).isAdmin
#             if isAdmin:
#                 category = request.query_params.get('category')
#                 if category in config.CATEGORIES:
#                     config.CATEGORIES.remove(category)
#                     new_config = importlib.import_module('.config', __package__)
#                     setattr(new_config, 'CATEGORIES', config.CATEGORIES)
#                 return Response({'success': True, 'categories': config.CATEGORIES})
#             else:
#                 return Response({'success': False, 'message': 'Unauthorized'})
#         except UserDB.DoesNotExist:
#             return Response({'success': False, 'message': 'User does not exist'})

        
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