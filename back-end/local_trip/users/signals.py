# users/signals.py

# THESE ARE BUILT-IN DJANGO IMPORTS
from django.db.models.signals import post_save
from django.dispatch import receiver

# THESE ARE YOUR MODELS
from .models import CustomUser, SellerProfile, TouristProfile

# THIS IS YOUR LOGIC
@receiver(post_save, sender = CustomUser)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        if instance.role == "SELLER":
            SellerProfile.objects.create(user = instance)
        elif instance.role == "TOURIST":
            TouristProfile.objects.create(user = instance)