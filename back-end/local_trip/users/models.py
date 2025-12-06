from django.contrib.auth.models import AbstractUser
from django.db import models


    # Base of User
class CustomUser(AbstractUser):
    class Role(models.TextChoices):
        ADMIN = "ADMIN", "Administrator"
        SELLER = "SELLER", "Seller"
        TOURIST = "TOURIST", "Tourist"

    role = models.CharField(max_length=50, choices=Role.choices, default=Role.TOURIST)
    email = models.EmailField(unique=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    groups = models.ManyToManyField(
        'auth.Group', related_name='customuser_set', blank=True
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission', related_name='customuser_set', blank=True
    )

    def __str__(self):
        return self.email

    # Vendor Model Class
class SellerProfile(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='seller_profile')
    description = models.TextField(blank=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    phone_number = models.CharField(max_length=20, blank=True, null=True)

    def __str__(self):
        return f"Seller: {self.user.username}"

    #Tourist Model Class
class TouristProfile(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='tourist_profile')

    def __str__(self):
        return f"Tourist: {self.user.username}"