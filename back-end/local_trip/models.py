from django.db import models

# Create your models here.
from abc import ABC, abstractmethod

class MapNode(ABC):

    def __init__(self, name, lat, lon, description, osm_id, picture_url):
        self.name = name
        self.lat = lat
        self.lon = lon
        self.description = description
        self.picture_url = picture_url

        self.osm_id = osm_id

    def to_json(self):
        return {
            "name": self.name,
            "lat": self.lat,
            "lon": self.lon,
            "description": self.description,
            "id": self.osm_id,
            "image": self.picture_url,
            "type": self.get_type()
        }

    @abstractmethod
    def get_type(self):
        pass

class ObjectiveNode(MapNode):

    def __init__(self, name, lat, lon, description, osm_id, picture_url):
        super().__init__(name, lat, lon, description, osm_id, picture_url)
        self.isCompleted = False

    def get_type(self):
        return "Point of Interest"


class VendorNode(MapNode):

    def __init__(self, name, lat, lon, description, osm_id, picture_url):
        super().__init__(name, lat, lon, description, osm_id, picture_url)

    def get_type(self):
        return "Vendor"

class Trip:
    def __init__(self, route):
        self.route = route

        self.current_index = 0
        self.current_location = self.route[0]

    def get_current_location(self):
        return self.current_location

    def jump_to_next_location(self):
        if self.current_location.isCompleted and self.current_index < len(self.route) - 1:
            self.current_index += 1
            self.current_location = self.route[self.current_index]

    def to_json(self):
        response_list = []
        for i, node in enumerate(self.route):
            data = node.to_json()

            # THE KEY FEATURE: Mark the current node
            if i == self.current_index:
                data['status'] = 'current'
            elif i < self.current_index:
                data['status'] = 'completed'
            else:
                data['status'] = 'locked'

            response_list.append(data)

        return response_list