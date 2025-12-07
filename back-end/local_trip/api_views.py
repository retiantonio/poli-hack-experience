from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Categorii, Producatori, Produse
from .serializers import CategoriiSerializer, ProducatoriSerializer, ProduseSerializer

# Lista categorii
class CategoriiListView(generics.ListAPIView):
    queryset = Categorii.objects.all()
    serializer_class = CategoriiSerializer


# Înregistrare producător
class RegisterProducatorView(APIView):
    def post(self, request):
        serializer = ProducatoriSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Login simplu producător (email + parola)
class LoginProducatorView(APIView):
    def post(self, request):
        email = request.data.get('email')
        parola = request.data.get('parola')
        try:
            producator = Producatori.objects.get(email=email, parola=parola)
            serializer = ProducatoriSerializer(producator)
            return Response(serializer.data)
        except Producatori.DoesNotExist:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)


# Lista produse
class ProduseListView(generics.ListAPIView):
    queryset = Produse.objects.all()
    serializer_class = ProduseSerializer
