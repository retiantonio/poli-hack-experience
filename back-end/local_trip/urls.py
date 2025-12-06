from django.urls import path, include
from rest_framework import routers
from .views import CategoriiViewSet, RegisterProducatorView, login_producator

router = routers.DefaultRouter()
router.register(r'categorii', CategoriiViewSet, basename='categorii')

urlpatterns = [
    path('', include(router.urls)),
    path('register/', RegisterProducatorView.as_view(), name='register-producator'),
    path('login/', login_producator, name='login-producator'),
]