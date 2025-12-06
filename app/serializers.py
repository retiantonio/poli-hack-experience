from rest_framework import serializers
from .models import Producatori, Categorii, Produse, ProducatoriCategorii

class CategoriiSerializer(serializers.ModelSerializer):
    class Meta:
        model = Categorii
        fields = ['id', 'tip']


class ProduseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Produse
        fields = ['id', 'nume', 'pret']


class ProducatoriSerializer(serializers.ModelSerializer):
    produse = ProduseSerializer(many=True, read_only=True)
    categorii = serializers.PrimaryKeyRelatedField(
        queryset=Categorii.objects.all(), many=True, write_only=True
    )

    class Meta:
        model = Producatori
        fields = ['id', 'nume', 'email', 'parola', 'nrTelefon', 'descriere',
                  'latitudine', 'longitudine', 'categorii', 'produse']

    def create(self, validated_data):
        categorii_data = validated_data.pop('categorii', [])
        produse_data = validated_data.pop('produse', [])

        producator = Producatori.objects.create(**validated_data)

        for categorie in categorii_data:
            ProducatoriCategorii.objects.create(idProducator=producator, idCategorie=categorie)

        for produs in produse_data:
            Produse.objects.create(producator=producator, **produs)

        return producator
