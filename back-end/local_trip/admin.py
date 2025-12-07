from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .users.models import CustomUser, SellerProfile, TouristProfile
from .models import Location

admin.site.register(CustomUser)
admin.site.register(SellerProfile)
admin.site.register(TouristProfile)
admin.site.register(Location)

