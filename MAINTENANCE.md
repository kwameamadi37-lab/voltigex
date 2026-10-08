# Guide Technique du Projet

Ce document centralise les operations de demarrage, de configuration et de maintenance pour les deux composants du projet :
- Backend Laravel : `dashboard-api`
- Frontend Flutter : `Mobile`

## 1. Commandes de Demarrage

### Laravel (Dev)
Executer dans `dashboard-api` :

```bash
composer install
php artisan migrate
php artisan serve --host=0.0.0.0
php artisan queue:listen
maildev
```

Notes :
- préférer `queue:listen` en developpement et `queue:listen` en production; requis pour les traitements asynchrones (notifications/Pusher/events).
- `maildev` c'est le serveur mail local
- Verifier que `.env` est correctement configuré avant migration.



### Laravel (Prod)
Executer dans `dashboard-api` apres deploiement :

```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan queue:work
```

### Flutter
Executer dans `Mobile` :

```bash
flutter pub get
flutter gen-l10n
flutter run
```

Note : `flutter gen-l10n` est obligatoire des qu'un fichier de traduction est modifié.

## 2. Configuration des Services Tiers

### Pusher
En cas de changement d'identifiants pour Pusher :
- Backend : mettre a jour les variables `PUSHER_*` dans `dashboard-api/.env`
- Frontend : mettre a jour les constantes de connexion dans `Voltigex/lib/core/constants.dart`

#### Débogage rapide

- Vérifier l’abonnement aux canaux privés dans les logs Pusher (connexion, auth endpoint).
- Contrôler que la clé/cluster Flutter correspondent au même jeu **`PUSHER_*`** que le backend.
- Pour la réception différée des événements non-`Now`, lancer **`php artisan queue:work`** si le driver de queue n’est pas `sync`.

### Notifications Push (Firebase)
En cas de changement de projet Firebase :
- Android : remplacer `Mobile/android/app/google-services.json`
- iOS : remplacer `Mobile/ios/Runner/GoogleService-Info.plist`
- API Laravel : mettre a jour la cle serveur/compte de service Firebase utilise par le backend

## 3. Procedures de Maintenance

### Localisation
Apres chaque modification des fichiers `.arb` :

```bash
cd Mobile
flutter gen-l10n
```

### Depannage
Commandes de nettoyage utiles :

```bash
# Backend Laravel
cd dashboard-api
php artisan cache:clear

# Frontend Flutter
cd Mobile
flutter clean
```

## 4. Rappel i18n & Documents

- Le backend chat accepte desormais les formats documents et medias suivants :
  - `jpeg`, `png`, `jpg`, `gif`, `webp`, `mp4`, `mov`, `pdf`, `doc`, `docx`, `xls`, `xlsx`, `txt`, `zip`, `rar`, `csv`
- La validation d'upload a ete etendue pour eviter les rejets 422 sur les documents modernes (notamment `.docx`, `.xlsx`, `.zip`).
- Cote Flutter, le `contentType` multipart est detecte automatiquement via le package `mime`.

---

Reference complementaire : `dashboard-api/api_doc`
