from django import forms
from .models import Producatori, Categorii
from django.core.exceptions import ValidationError

class ProducatorRegisterForm(forms.ModelForm):
    parola = forms.CharField(
        widget=forms.PasswordInput,
        label="Parolă",
        required=True
    )
    parola2 = forms.CharField(
        widget=forms.PasswordInput,
        label="Confirmare parolă",
        required=True
    )
    # nou: select pentru categorie
    categorie = forms.ModelChoiceField(
        queryset=Categorii.objects.all(),
        label="Categorie",
        required=True
    )

    class Meta:
        model = Producatori
        fields = ['nume', 'email', 'parola', 'parola2', 'nrTelefon', 'descriere', 'latitudine', 'longitudine', 'categorie']

    def clean_email(self):
        email = self.cleaned_data.get('email')
        if Producatori.objects.filter(email=email).exists():
            raise ValidationError("Acest email este deja folosit.")
        return email

    def clean(self):
        cleaned_data = super().clean()
        p1 = cleaned_data.get("parola")
        p2 = cleaned_data.get("parola2")
        if p1 and p2 and p1 != p2:
            raise ValidationError("Parolele nu coincid.")
        return cleaned_data

    def save(self, commit=True):
        instance = super().save(commit=False)
        # hash parola dacă vrei
        if commit:
            instance.save()
            # inserare automată în tabela ProducatoriCategorii
            categorie = self.cleaned_data['categorie']
            instance.categorii.add(categorie)  # folosește ManyToMany direct
        return instance


class ProducatorLoginForm(forms.Form):
    email = forms.EmailField(label="Email", required=True)
    parola = forms.CharField(widget=forms.PasswordInput, label="Parolă", required=True)
