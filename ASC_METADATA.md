# Repward Go — App Store Connect Metadata
## À copier-coller dans ASC pour la version 1.0

---

## Nom de l'app
Repward Go

## Sous-titre (max 30 car.)
Avis clients & fidélisation IA

## Description (App Store)
Repward Go transforme chaque avis client en levier de croissance pour votre commerce.

Générez un QR Code personnalisé que vos clients scannent après leur visite. Ils notent leur expérience, laissent un avis et reçoivent une récompense instantanée — tout est automatique.

COLLECTEZ DES AVIS FACILEMENT
• QR Code unique pour votre établissement
• Parcours client fluide : scan → note → avis → récompense
• Compatible restaurants, hôtels, salons, boutiques et plus

RÉPONDEZ AVEC L'IA
• Brouillons de réponses générés automatiquement par IA
• Ton adapté à votre secteur d'activité
• Mode Auto-Pilot pour les avis 4-5 étoiles
• Offres Win-Back pour reconquérir les clients insatisfaits

ANALYSEZ VOS PERFORMANCES
• Tableau de bord analytics complet
• Nombre d'avis collectés, temps gagné, ROI estimé
• Insights IA sur les tendances

FIDÉLISEZ VOS CLIENTS
• Récompenses personnalisées selon la note
• Codes promo et cadeaux automatiques
• Roue de la fortune pour gamifier l'expérience

MULTILINGUE
Disponible en français, anglais, espagnol, italien, allemand, portugais, néerlandais et arabe.

Inscription gratuite. Aucune carte bancaire requise. Gérez votre abonnement sur repward.app.

---

## Mots-clés (max 100 car., séparés par virgule)
avis,clients,QR,récompense,fidélisation,IA,restaurant,réputation,google,reviews

## URL marketing
https://repward.app

## URL support
https://repward.app/support

## URL politique de confidentialité
https://repward.app/privacy

## Copyright
© 2026 Equateur

---

## Catégorie principale
Économie et entreprise (Business)

## Catégorie secondaire
Productivité (Productivity)

---

## Notes de version (What's New)
Première version de Repward Go ! Collectez des avis clients via QR Code, répondez automatiquement avec l'IA et fidélisez vos clients avec des récompenses instantanées.

---

## Informations de vérification Apple (Review Information)

### Coordonnées du contact
- Prénom : Charles
- Nom : Rocher
- Téléphone : (à remplir)
- Email : charlesrocher75@gmail.com

### Compte démo pour la review Apple
- Email : demo@repward.app
- Mot de passe : Demo2026!
⚠️ OU utiliser le code promo DEMO2026 lors de l'inscription in-app pour activer la démo 1h

### Notes pour le reviewer
Cette app est un outil B2B destiné aux commerçants pour gérer les avis clients. L'inscription est gratuite et ne nécessite aucune carte bancaire. Les abonnements sont gérés via le site web repward.app (modèle reader app). Pour tester l'app : créez un compte avec un email quelconque et utilisez le code promo DEMO2026 pour activer l'accès complet pendant 1 heure.

---

## Confidentialité de l'app (Privacy Labels)

### Données collectées

1. **Coordonnées**
   - Nom → Fonctionnalité de l'app (création de compte)
   - Adresse email → Fonctionnalité de l'app (authentification)
   - Numéro de téléphone → Fonctionnalité de l'app (optionnel, profil commerce)

2. **Contenu utilisateur**
   - Avis/commentaires → Fonctionnalité de l'app (avis clients)

3. **Identifiants**
   - ID utilisateur → Fonctionnalité de l'app (Supabase Auth)

4. **Données d'utilisation**
   - Interaction avec le produit → Analytics (amélioration de l'app)

### Données NON collectées
- Données de santé
- Données financières
- Localisation précise
- Historique de navigation
- Contacts
- Photos/vidéos

### Politique de suivi
L'app ne suit PAS les utilisateurs (pas de tracking publicitaire).

---

## Classification du contenu
- Fréquence du contenu utilisateur : Aucun (pas de contenu généré par les utilisateurs visible publiquement dans l'app)
- Accès sans restriction par âge (4+)

---

## Commande Terminal — Build & Upload

```bash
cd ~/Documents/repward
flutter build ipa --release
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/repward_app.ipa \
  --apiKey T9PH8P3Q5K \
  --apiIssuer e2b8404c-0748-4d69-9c2c-e441fdcaaf1b
```

## Screenshots nécessaires
- iPhone 6.9" (iPhone 16 Pro Max) — OBLIGATOIRE
- iPhone 6.5" (iPhone 15 Plus / 14 Plus)
- iPad 12.9" (si support iPad)

Écrans suggérés à capturer :
1. Onboarding / écran d'accueil
2. Dashboard commerçant (vue principale)
3. QR Code & Portail
4. Messagerie / Triage IA
5. Analytics
6. Vue client (scan QR → notation → récompense)
