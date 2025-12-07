# users/signals.py

# THESE ARE BUILT-IN DJANGO IMPORTS
from django.db.models.signals import post_save
from django.dispatch import receiver

# THESE ARE YOUR MODELS
from local_trip.users.models import CustomUser, SellerProfile, TouristProfile

# THIS IS YOUR LOGIC
@receiver(post_save, sender = CustomUser)
def create_user_profile(sender, instance, created, **kwargs):

    print(f"--- SIGNAL TRIGGERED for user: {instance.username}, Role: {instance.role} ---")

    if created:
        if instance.role == "SELLER":
            SellerProfile.objects.get_or_create(user = instance)
        elif instance.role == "TOURIST":
            TouristProfile.objects.get_or_create(user = instance)