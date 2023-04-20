from rest_framework.views import APIView
from rest_framework.response import Response
from .models import AdminSettingsDB
from user.models import UserDB
from rest_framework import status
from user.views import AccountView


class Settings(APIView):
    
    def get(self, request):
        cutline = AdminSettingsDB.objects.get(key='recommend_cutline')
        cutline = cutline.int
        return Response({'cutline':cutline}, status=status.HTTP_200_OK)
        
    def patch(self, request):
        # id = AccountView.access_token_to_id(self, request)
        # if id:
            # if UserDB.objects.get(id=id).isAdmin == True:
        newnum = self.request.data.get('num')
        cutline = AdminSettingsDB.objects.get(key='recommend_cutline')
        cutline.int=int(newnum)
        cutline.save()
        return Response({'cutline':cutline}, status = status.HTTP_200_OK)
        #     else:
        #         return Response(status=status.HTTP_403_FORBIDDEN)     
        # else:
        #     return Response(status=status.HTTP_403_FORBIDDEN)
            
            
