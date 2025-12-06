from django.db import models

class Categorii(models.Model):
    tip = models.CharField(max_length=100, unique=True)

    class Meta:
        db_table = 'Categorii'
        managed = False  # Django nu creează tabela, folosește ce există
        verbose_name = "Categorie"
        verbose_name_plural = "Categorii"

    def __str__(self):
        return self.tip


class Producatori(models.Model):
    nume = models.CharField(max_length=100)
    email = models.CharField(max_length=100, unique=True)
    parola = models.CharField(max_length=255)
    nrTelefon = models.CharField(max_length=20, blank=True, null=True)
    descriere = models.TextField(blank=True, null=True)
    latitudine = models.FloatField()
    longitudine = models.FloatField()
    image = models.BinaryField(blank=True, null=True)  # folosește MEDIUMBLOB din BD
    categorii = models.ManyToManyField(
        Categorii,
        through='ProducatoriCategorii',
        related_name='producatori'
    )

    class Meta:
        db_table = 'Producatori'
        managed = False
        verbose_name = "Producator"
        verbose_name_plural = "Producatori"

    def __str__(self):
        return self.nume


class ProducatoriCategorii(models.Model):
    idProducator = models.ForeignKey(
        Producatori,
        on_delete=models.CASCADE,
        db_column='idProducator'
    )
    idCategorie = models.ForeignKey(
        Categorii,
        on_delete=models.CASCADE,
        db_column='idCategorie'
    )

    class Meta:
        db_table = 'ProducatoriCategorii'
        managed = False
        unique_together = ('idProducator', 'idCategorie')
        verbose_name = "ProducatorCategorie"
        verbose_name_plural = "ProducatoriCategorii"

    def __str__(self):
        return f"{self.idProducator.nume} - {self.idCategorie.tip}"


class Produse(models.Model):
    idProducator = models.ForeignKey(
        Producatori,
        on_delete=models.CASCADE,
        related_name='produse',
        db_column='idProducator'  # folosește exact coloana din BD
    )
    nume = models.CharField(max_length=100)
    pret = models.FloatField(blank=True, null=True)

    class Meta:
        db_table = 'Produse'
        managed = False  # să nu încerce Django să recreeze tabela
        verbose_name = "Produs"
        verbose_name_plural = "Produse"

    def __str__(self):
        return f"{self.nume} ({self.idProducator.nume})"


class Utilizatori(models.Model):
    nume = models.CharField(max_length=100)
    email = models.CharField(max_length=100, unique=True)
    parola = models.CharField(max_length=255)

    class Meta:
        db_table = 'Utilizatori'
        managed = False
        verbose_name = "Utilizator"
        verbose_name_plural = "Utilizatori"

    def __str__(self):
        return self.nume
