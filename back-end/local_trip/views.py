from cmath import isfinite

from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .core import PoisGenerator, RouteOptimizer

import math

from .models import ObjectiveNode, MapNode, Trip


# Create your views here.

@api_view(['GET'])
def get_optimized_route(request):
    # Get from Flutter
    city = request.GET.get('city', 'Sibiu')

    vendors = [
        (45.7977, 24.1512),  # Kulinarium Restaurant (Piața Mică) - A good "Vendor" location
        (45.7965, 24.1518),  # The Large Square (Piața Mare) - Central Landmark
        (45.7976, 24.1521),  # The Council Tower (Turnul Sfatului)
    ]

    pois_generator = PoisGenerator("User", city)
    mixed_stops = pois_generator.extract_pois(vendors, radius=500, limit=10)

    if not mixed_stops:
        return Response({"error": "No data found"}, status=404)

    pois_indexes = [i for i, stop in enumerate(mixed_stops) if isinstance(stop, ObjectiveNode)]

    start_node = mixed_stops.pop(pois_indexes[0])
    end_node = mixed_stops.pop(pois_indexes[0])

    optimizer = RouteOptimizer(start_node, end_node, mixed_stops)
    final_route = optimizer.createRoute()

    trip_route = Trip(final_route)
    json_ready_list = trip_route.to_json()

    return Response(json_ready_list)

from rest_framework import viewsets, generics
from .models import Categorii, Producatori
from .serializers import CategoriiSerializer, ProducatoriSerializer
from rest_framework.authtoken.models import Token
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator

# Listare categorii
class CategoriiViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Categorii.objects.all()
    serializer_class = CategoriiSerializer

# Register producator
@method_decorator(csrf_exempt, name='dispatch')
class RegisterProducatorView(generics.CreateAPIView):
    serializer_class = ProducatoriSerializer

    def perform_create(self, serializer):
        producator = serializer.save()
        id_categorie = self.request.data.get('idCategorie')
        if id_categorie:
            try:
                categorie = Categorii.objects.get(id=id_categorie)
                producator.categorii.add(categorie)
            except Categorii.DoesNotExist:
                pass

# Login producator cu token
@csrf_exempt
@api_view(['POST'])
def login_producator(request):
    email = request.data.get('email')
    parola = request.data.get('parola')
    try:
        producator = Producatori.objects.get(email=email, parola=parola)
        # returnăm token pentru persistenta loginului
        token, created = Token.objects.get_or_create(user=producator)
        return Response({
            "id": producator.id,
            "nume": producator.nume,
            "email": producator.email,
            "token": token.key
        })
    except Producatori.DoesNotExist:
        return Response({"error": "Email sau parola invalide"}, status=400)
