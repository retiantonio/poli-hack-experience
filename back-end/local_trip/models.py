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


class ObjectiveNode(MapNode):

    def __init__(self, name, lat, lon, description, osm_id, picture_url):
        super().__init__(name, lat, lon, description, osm_id, picture_url)
        self.isCompleted = False

class VendorNode(MapNode):

    def __init__(self, name, lat, lon, description, osm_id, picture_url):
        super().__init__(name, lat, lon, description, osm_id, picture_url)

class Trip:
    def __init__(self, route):
        self.route = route

        self.current_index = 0
        self.current_location = self.route[0]

    def get_current_location(self):
        return self.current_location

    def jump_to_next_location(self):
        if self.current_location.isCompleted:
            self.current_index += 1
            self.current_location = self.route[self.current_index]