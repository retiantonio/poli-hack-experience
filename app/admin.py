from django.contrib import admin
from .models import Producatori, Categorii, ProducatoriCategorii, Produse, Utilizatori

# Inline pentru ManyToMany cu through
class ProducatoriCategoriiInline(admin.TabularInline):
    model = ProducatoriCategorii
    extra = 1
    autocomplete_fields = ['idCategorie']

@admin.register(Producatori)
class ProducatoriAdmin(admin.ModelAdmin):
    list_display = ('nume', 'email', 'nrTelefon')
    search_fields = ('nume', 'email')
    inlines = [ProducatoriCategoriiInline]

@admin.register(Categorii)
class CategoriiAdmin(admin.ModelAdmin):
    list_display = ('tip',)
    search_fields = ('tip',)

@admin.register(Utilizatori)
class UtilizatoriAdmin(admin.ModelAdmin):
    list_display = ('nume', 'email')
    search_fields = ('nume', 'email')

@admin.register(Produse)
class ProduseAdmin(admin.ModelAdmin):
    list_display = ('nume', 'idProducator', 'pret')
    search_fields = ('nume',)
