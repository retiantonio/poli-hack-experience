# serializers.py
from rest_framework import serializers
from django.contrib.auth import authenticate

from .models import Location
from .users.models import CustomUser, SellerProfile, TouristProfile
######################################################
# 1. LOGIN SERIALIZER (Input)
class LoginSerializer(serializers.Serializer):
    """
    Checks if the email and password match.
    Does not save anything to the database.
    """
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        # Authenticate now uses the default behavior (checks username)
        user = authenticate(username=data['username'], password=data['password'])

        if user and user.is_active:
            return {'user': user}
        raise serializers.ValidationError("Invalid Credentials")

########################################################################################
# 2. REGISTRATION SERIALIZER (Input)
class RegistrationSerializer(serializers.ModelSerializer):
    """
    Creates a new CustomUser.
    Note: We don't create the Profile here because SIGNALS.PY does it automatically!
    """
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = CustomUser
        fields = ('username', 'email','password', 'role')

    def create(self, validated_data):
        user = CustomUser.objects.create_user(
            username=validated_data['username'],  # <--- ADD THIS
            email=validated_data.get('email'),  # Email is now optional/secondary
            password=validated_data['password'],
            role=validated_data['role']
        )
        return user

#############################################################################################
# 3. OUTPUT
class SellerProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = SellerProfile
        fields = ['description', 'latitude', 'longitude', 'phone_number']


class TouristProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = TouristProfile
        fields = []

class UserDataSerializer(serializers.ModelSerializer):
    # We define both, but only one will be populated per user
    seller_profile = SellerProfileSerializer(read_only=True)
    tourist_profile = TouristProfileSerializer(read_only=True)

    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'role', 'seller_profile', 'tourist_profile']

    def to_representation(self, instance):
        data = super().to_representation(instance)
        if instance.role == 'SELLER':
            data.pop('tourist_profile')  # Remove tourist data for sellers
        elif instance.role == 'TOURIST':
            data.pop('seller_profile')  # Remove seller data for tourists
        return data
##################################################################
# 4.Location Serializer
class LocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Location
        fields = ['id', 'name', 'latitude', 'longitude','image_url', 'radius']
