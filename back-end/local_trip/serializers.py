# serializers.py
from rest_framework import serializers
from .users.models import CustomUser, SellerProfile, TouristProfile

# 1. LOGIN SERIALIZER (Input)
class LoginSerializer(serializers.Serializer):
    """
    Checks if the email and password match.
    Does not save anything to the database.
    """
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        email = data.get('email')
        password = data.get('password')

        if email and password:
            # This authenticates against the CustomUser table
            user = authenticate(request=self.context.get('request'),
                                username=email, password=password)

            if not user:
                raise serializers.ValidationError("Invalid email or password.")
        else:
            raise serializers.ValidationError("Must include 'email' and 'password'.")

        data['user'] = user
        return data
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
        fields = ('email', 'password', 'role')

    def create(self, validated_data):
        # We must use create_user to ensure the password is HASHED securely
        user = CustomUser.objects.create_user(
            email=validated_data['email'],
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

