from cmath import isfinite

from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework import permissions, generics
from rest_framework.response import Response
from .core import PoisGenerator, RouteOptimizer

from knox.models import AuthToken
from .serializers import (
    LoginSerializer,
    RegistrationSerializer,
    UserDataSerializer
)

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

# LOGIN AND USER SIDED VIEWS

    # 1. REGISTRATION API
class RegisterAPI(generics.GenericAPIView):
    serializer_class = RegistrationSerializer

    def post(self, request, *args, **kwargs):
        # 1. Validate Input (The 'Bouncer' check)
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # 2. Save User (This triggers signals.py automatically!)
        user = serializer.save()

        # 3. Create Token
        # AuthToken.objects.create returns a tuple (instance, token). We only need the token.
        _, token = AuthToken.objects.create(user)

        # 4. Return Response
        # We use UserDataSerializer here so Flutter gets the full profile structure immediately
        return Response({
            "user": UserDataSerializer(user, context=self.get_serializer_context()).data,
            "token": token
        })


    # 2. LOGIN API
class LoginAPI(generics.GenericAPIView):
    serializer_class = LoginSerializer

    def post(self, request, *args, **kwargs):
        # 1. Validate Email/Password
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # 2. Get the User object from the serializer
        user = serializer.validated_data['user']

        # 3. Create Token
        _, token = AuthToken.objects.create(user)

        # 4. Return User Data + Token
        return Response({
            "user": UserDataSerializer(user, context=self.get_serializer_context()).data,
            "token": token
        })


    # 3. USER DATA API (The Persistence Fetcher)
class UserProfileAPI(generics.RetrieveAPIView):
    # This ensures only logged-in users with a valid token can access this
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = UserDataSerializer

    def get_object(self):
        # Automatically looks up the user associated with the token in the header
        return self.request.user