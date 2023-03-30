from rest_framework.response import Response
from rest_framework.decorators import api_view


@api_view(['GET'])
def loginCheck(request):
    value = request.GET.get('value', None)
    if value:
        return Response({'value': value})
    else:
        return Response({'value': 'None'}, status=400)
