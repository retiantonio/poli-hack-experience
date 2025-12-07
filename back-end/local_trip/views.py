from cmath import isfinite

from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework import permissions, generics
from rest_framework.response import Response
from .core import PoisGenerator, RouteOptimizer
import json

from knox.models import AuthToken
from .serializers import (
    LoginSerializer,
    RegistrationSerializer,
    UserDataSerializer, LocationSerializer
)

import math

from .models import ObjectiveNode, MapNode, Trip, Location
from .users.models import SellerProfile, CustomUser


# Create your views here.

@api_view(['GET'])
def get_optimized_route(request):
    # Get from Flutter
    city = request.GET.get('city', 'Brasov')

    vendor_data_queryset = SellerProfile.objects.exclude(
        latitude__isnull=True
    ).exclude(
        longitude__isnull=True
    )

    pois_generator = PoisGenerator("User", city)
    mixed_stops = pois_generator.extract_pois(vendor_data_queryset[:6], radius=500, limit=20)

    for elem in mixed_stops:
        print(elem.get_type)

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
        # === DEBUGGING START ===
        print("------------------------------------------------")
        print("📢 RECEIVED REQUEST DATA:")
        print(request.data)  # This prints the parsed JSON as a Python dict
        print("------------------------------------------------")
        # === DEBUGGING END ===

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

        # === DEBUGGING START ===
        print("------------------------------------------------")
        print("📢 RECEIVED REQUEST DATA:")
        print(request.data)  # This prints the parsed JSON as a Python dict
        print("------------------------------------------------")
        # === DEBUGGING END ===

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # 2. Get the User object from the serializer
        user = serializer.validated_data['user']

        # 3. Create Token
        _, token = AuthToken.objects.create(user)

        user_data = UserDataSerializer(user, context=self.get_serializer_context()).data

        response_data = {
            "user": user_data,
            "token": token
        }

        # 2. PRINT IT TO THE TERMINAL (Pretty printed)
        print("------------------------------------------------")
        print("📦 SENDING TO FLUTTER:")
        print(json.dumps(response_data, indent=4, default=str))
        print("------------------------------------------------")

        # 3. Send it
        return Response(response_data)


    # 3. USER DATA API (The Persistence Fetcher)
class UserProfileAPI(generics.RetrieveAPIView):
    # This ensures only logged-in users with a valid token can access this
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = UserDataSerializer

    def get_object(self):
        # Automatically looks up the user associated with the token in the header
        return self.request.user

    # 4. LOCATION DATA API (For Persistance)
class LocationListAPI(generics.ListAPIView):
    queryset = Location.objects.all()
    serializer_class = LocationSerializer