import math

import osmnx as ox
import pandas as pd

import wikipedia

from geopy.distance import geodesic

from local_trip.models import VendorNode, ObjectiveNode, MapNode


class PoisGenerator:
    def __init__(self, user, chosen_city):
        self.user = user
        self.chosen_city = chosen_city

    def extract_pois(self, vendors, radius = 500, limit = 20):
        all_pois = []
        seen_names = set()

        city_lat, city_lon = ox.geocode(self.chosen_city)

        for i, vendor in enumerate(vendors):
            vendor_name = vendor.user.username

            vendor_node = VendorNode(
                name = vendor_name,
                lat = float(vendor.latitude),
                lon = float(vendor.longitude),

                description = vendor.description,
                osm_id= f"v_{i}",
                picture_url= "mbnfdnbdfbfkbmfc"
            )

            if self._calc_dist((city_lat, city_lon), vendor_node) < 10000:
                all_pois.append(vendor_node)
                seen_names.add(vendor_name)

        # Tags
        tags = {
            'amenity': ['cafe', 'bar', 'pub', 'restaurant'],
            'tourism': ['artwork', 'museum', 'viewpoint'],
            'historic': ['monument', 'memorial']
        }

        vendor_coordinates = []
        for elem in all_pois:
            vendor_coordinates.append((elem.lat, elem.lon))

        for i, point in enumerate(vendor_coordinates):
            try:
                # Extract from specific point
                gdf = ox.features_from_point(point, tags=tags, dist=radius)

                for index, row in gdf.iterrows():
                    # Geometry check
                    if row.geometry.geom_type == 'Point':
                        lat, lon = row.geometry.y, row.geometry.x
                    else:
                        lat, lon = row.geometry.centroid.y, row.geometry.centroid.x

                    name = row.get('name', 'Unknown Spot')

                    # Deduplication check
                    if name in seen_names or name == 'Unknown':
                        continue

                    if isinstance(name, float) and math.isnan(name):
                        continue

                    wiki_tag = row.get('wikipedia')
                    wiki_description, wiki_image = self._fetch_wiki_data(wiki_tag)

                    if wiki_description:
                        final_description = wiki_description
                        final_image_url = wiki_image
                    else:
                        poi_type = row.get('amenity') or row.get('tourism') or row.get(
                            'historic') or "General attraction"
                        final_description = f"A prominent {poi_type} in the area."
                        final_image_url = "https://placehold.co/600x400?text=Sightseeing"


                    # Create Object
                    node = ObjectiveNode(
                        name = name,
                        lat = lat,
                        lon = lon,
                        description = final_description,
                        osm_id = f"osm_{index}",
                        picture_url = final_image_url,
                    )

                    all_pois.append(node)
                    seen_names.add(name)

            except Exception as e:
                print(f"No data found near point {point}: {e}")

        return all_pois[:limit]

    def _fetch_wiki_data(self, wiki_tag):
        """Fetches summary and image URL from Wikipedia using the OSM tag."""
        if not wiki_tag:
            return None, None

        try:
            # 1. Parse the tag (e.g., "en:Council Tower, Sibiu" -> "Council Tower, Sibiu")
            # We assume the default language in the OSM tag if it exists
            parts = wiki_tag.split(':')
            if len(parts) > 1:
                title = parts[-1].strip()
            else:
                title = wiki_tag.strip()

            # 2. Get the Wikipedia page object
            page = wikipedia.page(title, auto_suggest=False, redirect=True)

            # 3. Extract data
            description = page.summary
            image_url = page.images[0] if page.images else None  # Get the first image

            # Limit description length for mobile display
            if len(description) > 300:
                description = description[:300] + "..."

            return description, image_url

        except wikipedia.exceptions.PageError:
            # Page not found on Wikipedia
            return None, None
        except wikipedia.exceptions.DisambiguationError:
            # Ambiguous search term
            return None, None
        except Exception:
            # General connection error, etc.
            return None, None

        # Calculate distance between two points

    def _calc_dist(self, obj1, obj2):
        c1 = self._get_coords(obj1)
        c2 = self._get_coords(obj2)
        return geodesic(c1, c2).meters

    def _get_coords(self, obj):
        if isinstance(obj, MapNode):
            return obj.lat, obj.lon
        if isinstance(obj, tuple):
            return obj
        return None


class RouteOptimizer:
    def __init__(self, start_point, end_point, intermediate_points):
        self.start_point = start_point
        self.end_point = end_point
        self.unvisited = intermediate_points.copy()

    def createRoute(self):
        current_location = self.start_point
        route_path = [current_location]

        while self.unvisited:
            nearest_location = None
            min_distance = float('inf')
            nearest_index = -1

            for index, candidate in enumerate(self.unvisited):
                dist = self._calc_dist(current_location, candidate)
                if dist < min_distance:
                    nearest_location = candidate
                    min_distance = dist
                    nearest_index = index

            route_path.append(nearest_location)
            current_location = nearest_location

            self.unvisited.pop(nearest_index)

        route_path.append(self.end_point)

        return route_path

    # Calculate distance between two points
    def _calc_dist(self, obj1, obj2):
        c1 = self._get_coords(obj1)
        c2 = self._get_coords(obj2)
        return geodesic(c1, c2).meters

    def _get_coords(self, obj):
        if isinstance(obj, MapNode):
            return obj.lat, obj.lon
        if isinstance(obj, tuple):
            return obj
        return None


