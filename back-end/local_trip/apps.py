from django.apps import AppConfig

class LocalTripConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'local_trip'

    def ready(self):
        # Această metodă este vitală
        import local_trip.signals