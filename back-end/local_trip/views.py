from cmath import isfinite

from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .core import PoisGenerator, RouteOptimizer

import math

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

    pois_gen = PoisGenerator("User", city)
    mixed_stops = pois_gen.extract_pois(vendors, radius=500, limit=10)

    if not mixed_stops:
        return Response({"error": "No data found"}, status=404)

    pois_indexes = [i for i, stop in enumerate(mixed_stops) if stop["type"] != "vendor"]

    start_node = mixed_stops.pop(pois_indexes[0])
    end_node = mixed_stops.pop(pois_indexes[0])

    optimizer = RouteOptimizer(start_node, end_node, mixed_stops)
    final_route = optimizer.createRoute()

    json_ready_list = []

    for stop in final_route:
        if isinstance(stop, dict):
            name = stop.get('name')
            lat = stop.get('lat')
            lon = stop.get('lon')
            obj_type = stop.get('type', 'poi')

        if lat is None or lon is None:
            continue

        try:
            lat = float(lat)
            lon = float(lon)
        except (ValueError, TypeError):
            continue

        if math.isnan(lat) or math.isnan(lon) or math.isinf(lat) or math.isinf(lon):
            continue

        if isinstance(name, float) and math.isnan(name):
            name = "Unknown"

        if name is None:
            name = "Unknown"

        final_name = str(name)
        final_type = str(obj_type) if obj_type is not None else "poi"

        json_ready_list.append({
            "name": final_name,
            "type": final_type,
            "lat": lat,
            "lon": lon
        })

    return Response(json_ready_list)