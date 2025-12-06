from rest_framework import viewsets, generics
from .models import Categorii, Producatori
from .serializers import CategoriiSerializer, ProducatoriSerializer
from rest_framework.response import Response
from rest_framework.decorators import api_view

# Endpoint pentru listarea categoriilor
class CategoriiViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Listare categoriilor existente
    """
    queryset = Categorii.objects.all()
    serializer_class = CategoriiSerializer


# Endpoint pentru register producator
class RegisterProducatorView(generics.CreateAPIView):
    """
    Creează un producător nou și îl asociază cu categoria selectată
    """
    serializer_class = ProducatoriSerializer

    def perform_create(self, serializer):
        # Salvăm producătorul
        producator = serializer.save()
        # Preluăm categoria din request (idCategorie)
        id_categorie = self.request.data.get('idCategorie')
        if id_categorie:
            try:
                categorie = Categorii.objects.get(id=id_categorie)
                # Asociem producătorul cu categoria
                producator.categorii.add(categorie)
            except Categorii.DoesNotExist:
                pass  # opțional: poți returna eroare sau mesaj


# Optional: login producator simplu
@api_view(['POST'])
def login_producator(request):
    """
    Endpoint simplu de login: caută producător după email și parola
    """
    email = request.data.get('email')
    parola = request.data.get('parola')
    try:
        producator = Producatori.objects.get(email=email, parola=parola)
        serializer = ProducatoriSerializer(producator)
        return Response(serializer.data)
    except Producatori.DoesNotExist:
        return Response({"error": "Email sau parola invalide"}, status=400)
