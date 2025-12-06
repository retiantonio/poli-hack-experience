import osmnx as ox
import pandas as pd

from geopy.distance import geodesic

from local_trip.models import VendorNode


class PoisGenerator:
    def __init__(self, user, chosen_city):
        self.user = user
        self.chosen_city = chosen_city

    def extract_pois(self, vendor_coordinates, radius = 500, limit = 10):
        all_pois = []
        seen_names = set()

        for i, v_point in enumerate(vendor_coordinates):
            vendor_name = f"Vendor Location {i + 1}"

            vendor_node = VendorNode(
                name = vendor_name,
                lat = v_point[0],
                lon = v_point[1],

                description = "nvjfdbvjdniodsnifos!",
                osm_id= f"v_{i}",
                picture_url= "mbnfdnbdfbfkbmfc"
            )

            all_pois.append(vendor_node)
            seen_names.add(vendor_name)

        # Tags
        tags = {
            'amenity': ['cafe', 'bar', 'pub', 'restaurant'],
            'tourism': ['artwork', 'museum', 'viewpoint'],
            'historic': ['monument', 'memorial']
        }

        for i, point in enumerate(vendor_coordinates):
            try:
                # Extract from specific point
                gdf = ox.features_from_point(point, tags=tags, dist=radius)

                for index, row in gdf.iterrows():
                    # Handle geometry (Points vs Polygons)
                    if row.geometry.geom_type == 'Point':
                        lat, lon = row.geometry.y, row.geometry.x
                    else:
                        lat, lon = row.geometry.centroid.y, row.geometry.centroid.x

                    name = row.get('name', 'Unknown')

                    all_pois.append({
                        "name": row.get('name', 'Unknown'),
                        "type": row.get('amenity'),
                        "lat": lat,
                        "lon": lon,
                    })
                    seen_names.add(name)

            except Exception as e:
                print(f"No data found near point {point}: {e}")

        # Remove Duplicates
        df = pd.DataFrame(all_pois)
        if not df.empty:
            df = df.drop_duplicates(subset=['lat', 'lon'])
            return df.head(10).to_dict('records')

        return []

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
        if isinstance(obj, tuple):
            return obj
        elif isinstance(obj, dict):
            return (obj['lat'], obj['lon'])
        else:
            return (obj.geometry.y, obj.geometry.x)

