# API Documentation - Einbanks Mobile

Documentation complète de l'API REST pour l'application mobile Einbanks.

## Authentification

L'API utilise **Laravel Sanctum** pour l'authentification par token.

### Obtenir un token

Après une connexion réussie via `/api/auth/mobile-login`, vous recevrez un token dans la réponse. Ce token doit être inclus dans toutes les requêtes protégées.

### Utilisation du token

Incluez le token dans l'en-tête `Authorization` de toutes les requêtes protégées :

```
Authorization: Bearer {votre_token}
```

### Expiration du token

Les tokens sont valides jusqu'à ce que l'utilisateur se déconnecte ou que le token soit révoqué.

---

## Base URL

```
Production: https://einbanks.com/api
Développement: http://localhost/api
```

---

## Codes d'erreur

| Code | Signification |
|------|---------------|
| 200 | Succès |
| 201 | Créé avec succès |
| 400 | Requête invalide |
| 401 | Non authentifié |
| 403 | Accès refusé |
| 404 | Ressource non trouvée |
| 422 | Erreur de validation |
| 429 | Trop de requêtes (rate limiting) |
| 500 | Erreur serveur |

---

## Endpoints

### 🔐 Authentification

#### 1. Connexion Mobile

**Endpoint :** `POST /api/auth/mobile-login`  
**Contrôleur :** `App\Http\Controllers\AppController::mobileLogin`  
**Authentification :** Non requise  
**Paramètres URL :** Aucun  
**Query Parameters :** Aucun

**Body (requis) :**

```json
{
  "email": "string (requis)",
  "password": "string (requis)"
}
```

**Exemple de requête :**

```bash
curl -X POST http://localhost/api/auth/mobile-login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jean.dupont@example.com",
    "password": "MonMotDePasse123!"
  }'
```

**Réponse de succès (200) :**

```json
{
  "success": true,
  "message": "Connexion réussie.",
  "data": {
    "user": {
      "id": 1,
      "email": "jean.dupont@example.com",
      "phone": "+33612345678",
      "alias": "jean.dupont",
      "role": "user",
      "email_verified": true,
      "phone_verified": true,
      "email_and_phone_verified": true,
      "fully_verified": true
    },
    "token": "1|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  }
}
```

**Réponse d'erreur (403) - Email/Téléphone non vérifiés :**

```json
{
  "success": false,
  "message": "Votre email et/ou votre téléphone ne sont pas vérifiés. Veuillez compléter la vérification."
}
```

**Réponse d'erreur (401) - Identifiants incorrects :**

```json
{
  "success": false,
  "message": "Identifiants incorrects."
}
```

---

#### 2. Déconnexion

**Endpoint :** `POST /api/auth/logout`  
**Contrôleur :** `App\Http\Controllers\AuthApiController::logout`  
**Authentification :** Requise (Bearer token)  
**Paramètres URL :** Aucun  
**Query Parameters :** Aucun  
**Body :** Aucun

**Headers :**

```
Authorization: Bearer {token}
```

**Réponse de succès (200) :**

```json
{
  "success": true,
  "message": "Déconnexion réussie."
}
```

---

#### 3. Déconnexion de tous les appareils

**Endpoint :** `POST /api/auth/logout-all`  
**Contrôleur :** `App\Http\Controllers\AuthApiController::logoutAll`  
**Authentification :** Requise (Bearer token)  
**Paramètres URL :** Aucun  
**Query Parameters :** Aucun  
**Body :** Aucun

**Réponse de succès (200) :**

```json
{
  "success": true,
  "message": "Déconnexion de tous les appareils réussie."
}
```

---

### 👤 Utilisateur

#### 4. Informations de l'utilisateur connecté

**Endpoint :** `GET /api/user`  
**Contrôleur :** Route closure dans `routes/api.php`  
**Authentification :** Requise (Bearer token)  
**Paramètres URL :** Aucun  
**Query Parameters :** Aucun  
**Body :** Aucun

**Note :** Cette route retourne automatiquement les informations de l'utilisateur authentifié via le token. Aucun ID n'est nécessaire.

**Réponse de succès (200) :**

```json
{
  "id": 1,
  "email": "jean.dupont@example.com",
  "phone": "+33612345678",
  "alias": "jean.dupont",
  "role": "user",
  "email_verified": true,
  "phone_verified": true
}
```

---

#### 5. Dashboard utilisateur

**Endpoint :** `GET /api/user/dashboard`  
**Contrôleur :** `App\Http\Controllers\UtilisateurController::carte`  
**Authentification :** Requise (Bearer token)  
**Paramètres URL :** Aucun  
**Query Parameters :** Aucun  
**Body :** Aucun

**Note :** Retourne les virements et l'historique de l'utilisateur connecté. Aucun ID n'est nécessaire.

**Réponse de succès (200) :**

```json
{
  "success": true,
  "data": {
    "virements": [
      {
        "id": 1,
        "montant": 100.00,
        "statut": "termine",
        "created_at": "2024-01-15T10:30:00.000000Z"
      }
    ],
    "historiques": [
      {
        "id": 1,
        "type": "credit",
        "titre": "Virement reçu",
        "montant": 500.00,
        "date_transaction": "2024-01-15T10:30:00.000000Z"
      }
    ]
  }
}
```

---

#### 6. Mettre à jour le profil

**Endpoint :** `PUT /api/user/profile`  
**Contrôleur :** `App\Http\Controllers\UtilisateurController::profilstore`  
**Authentification :** Requise (Bearer token)  
**Paramètres URL :** Aucun  
**Query Parameters :** Aucun

**Note :** Met à jour le profil de l'utilisateur connecté. Aucun ID n'est nécessaire.

**Body (requis) :**

```json
{
  "nom": "string (requis, max 255)",
  "prenom": "string (requis, max 255)",
  "phone": "string (requis, max 20)"
}
```

**Exemple de requête :**

```bash
curl -X PUT http://localhost/api/user/profile \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "Dupont",
    "prenom": "Jean",
    "phone": "+33612345678"
  }'
```

**Réponse de succès (200) :**

```json
{
  "success": true,
  "message": "Vos informations ont été mises à jour avec succès."
}
```

---

#### 7. Changer le mot de passe

**Endpoint :** `PUT /api/user/password`  
**Contrôleur :** `App\Http\Controllers\UtilisateurController::updatepassword`  
**Authentification :** Requise (Bearer token)  
**Paramètres URL :** Aucun  
**Query Parameters :** Aucun

**Note :** Change le mot de passe de l'utilisateur connecté. Aucun ID n'est nécessaire.

**Body (requis) :**

```json
{
  "oldpass": "string (requis, mot de passe actuel)",
  "newpass": "string (requis, nouveau mot de passe, min 8 caractères)",
  "confpass": "string (requis, doit correspondre à newpass)"
}
```

**Réponse de succès (200) :**

```json
{
  "success": true,
  "message": "Votre mot de passe a été modifié avec succès."
}
```

**Réponse d'erreur (401) - Mot de passe incorrect :**

```json
{
  "success": false,
  "message": "Le mot de passe actuel est incorrect."
}
```

---

#### 8. Liste des virements

**Endpoint :** `GET /api/user/virements`  
**Contrôleur :** `App\Http\Controllers\UtilisateurController::virements`  
**Authentification :** Requise (Bearer token)  
**Paramètres URL :** Aucun  
**Body :** Aucun

**Note :** Retourne la liste des virements de l'utilisateur connecté. Aucun ID n'est nécessaire.

**Query Parameters (optionnels) :**

- `page` (optionnel) : Numéro de page (défaut: 1)
- `per_page` (optionnel) : Nombre d'éléments par page (défaut: 5)

**Exemple de requête :**

```bash
curl -X GET "http://localhost/api/user/virements?page=1&per_page=5" \
  -H "Authorization: Bearer {token}"
```

**Réponse de succès (200) :**

```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "montant": 100.00,
        "nombanque": "Banque ABC",
        "iban": "FR7630006000011234567890189",
        "statut": "en_cours",
        "pourcentage": 45,
        "code": "CAC-123456",
        "created_at": "2024-01-15T10:30:00.000000Z"
      }
    ],
    "total": 10,
    "per_page": 5,
    "last_page": 2
  }
}
```

---

### 💸 Virements

#### 9. Créer un virement

**Endpoint :** `POST /api/virements`  
**Contrôleur :** `App\Http\Controllers\VirementController::virementstore`  
**Authentification :** Requise (Bearer token)  
**Paramètres URL :** Aucun  
**Query Parameters :** Aucun

**Note :** Crée un nouveau virement pour l'utilisateur connecté. Aucun ID n'est nécessaire dans l'URL.

**Body (requis) :**

```json
{
  "titulaire": "string (requis, max 50, nom du bénéficiaire)",
  "nombanque": "string (requis, max 255, nom de la banque)",
  "iban": "string (requis, max 34, format IBAN valide)",
  "bic": "string (optionnel, max 11, format BIC valide)",
  "montant": "number (requis, minimum 1)"
}
```

**Exemple de requête :**

```bash
curl -X POST http://localhost/api/virements \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "titulaire": "Marie Martin",
    "nombanque": "Banque XYZ",
    "iban": "FR7630006000011234567890189",
    "bic": "BNPAFRPPXXX",
    "montant": 250.50
  }'
```

**Réponse de succès (200) :**

```json
{
  "success": true,
  "virement_id": 1,
  "redirect_url": "/virement/1/progress",
  "message": "Virement en cours"
}
```

**Réponse d'erreur (400) - Solde insuffisant :**

```json
{
  "success": false,
  "message": "Solde insuffisant pour ce virement"
}
```

---

#### 10. Détails d'un virement

**Endpoint :** `GET /api/virements/{id}/progress`  
**Contrôleur :** `App\Http\Controllers\UtilisateurController::virementProgress`  
**Authentification :** Requise (Bearer token)  
**Query Parameters :** Aucun  
**Body :** Aucun

**Paramètres URL (requis) :**

- `{id}` : ID du virement (integer, requis)

**Note :** Remplacez `{id}` par l'ID numérique du virement dans l'URL. Exemple : `/api/virements/1/progress`

**Exemple de requête :**

```bash
curl -X GET http://localhost/api/virements/1/progress \
  -H "Authorization: Bearer {token}"
```

**Réponse de succès (200) :**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "montant": 250.50,
    "nombanque": "Banque XYZ",
    "iban": "FR7630006000011234567890189",
        "statut": "en_cours",
        "pourcentage": 45,
        "code": "CAC-123456",
        "created_at": "2024-01-15T10:30:00.000000Z"
  }
}
```

**Réponse d'erreur (403) - Accès refusé :**

```json
{
  "success": false,
  "message": "Accès non autorisé. Ce virement ne vous appartient pas."
}
```

---

#### 11. Confirmer un virement

**Endpoint :** `POST /api/virements/{id}/confirm`  
**Contrôleur :** `App\Http\Controllers\UtilisateurController::confirmVirement`  
**Authentification :** Requise (Bearer token)  
**Query Parameters :** Aucun

**Paramètres URL (requis) :**

- `{id}` : ID du virement (integer, requis)

**Note :** Remplacez `{id}` par l'ID numérique du virement dans l'URL. Exemple : `/api/virements/1/confirm`

**Body (requis) :**

```json
{
  "code": "string (requis, code de confirmation, ex: CAC-123456)"
}
```

**Exemple de requête :**

```bash
curl -X POST http://localhost/api/virements/1/confirm \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "CAC-123456"
  }'
```

**Réponse de succès (200) :**

```json
{
  "success": true,
  "progress": 60,
  "montant": 250.50,
  "redirect_url": "/virement-finalisation-success?montant=250.50"
}
```

**Progression du virement :**

- Étape 1 : 45% → 60% (première confirmation)
- Étape 2 : 60% → 89% (deuxième confirmation)
- Étape 3 : 89% → 95% (troisième confirmation)
- Étape 4 : 95% → 99% (quatrième confirmation)
- À 99% : Le virement est terminé (`statut: "termine"`)

**Réponse d'erreur (422) - Code invalide :**

```json
{
  "success": false,
  "message": "Code de confirmation invalide"
}
```

---

### 💳 Cartes

#### 12. Activer une carte bancaire

**Endpoint :** `POST /api/card/activate`  
**Contrôleur :** `App\Http\Controllers\VirementController::activationStore`  
**Authentification :** Requise (Bearer token)  
**Paramètres URL :** Aucun  
**Query Parameters :** Aucun

**Note :** Active la carte bancaire de l'utilisateur connecté. Aucun ID n'est nécessaire.

**Body (requis) :**

```json
{
  "card_holder": "string (requis, max 100, nom du titulaire)",
  "card_number": "string (requis, max 19, numéro de carte sans espaces)",
  "expiry_date": "string (requis, max 5, format MM/YY, ex: 12/25)",
  "cvv": "string (requis, max 4, code de sécurité)"
}
```

**Exemple de requête :**

```bash
curl -X POST http://localhost/api/card/activate \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "card_holder": "JEAN DUPONT",
    "card_number": "4532123456789012",
    "expiry_date": "12/25",
    "cvv": "123"
  }'
```

**Réponse de succès (200) :**

```json
{
  "success": true,
  "message": "Votre carte a été soumise pour activation avec succès."
}
```

**Réponse d'erreur (422) - Carte déjà utilisée :**

```json
{
  "success": false,
  "message": "Ce numéro de carte est déjà utilisé par un autre utilisateur.",
  "errors": {
    "card_number": ["Ce numéro de carte est déjà utilisé par un autre utilisateur."]
  }
}
```

---

### 🔔 Notifications

#### 13. Liste des notifications

**Endpoint :** `GET /api/user/notifications`  
**Contrôleur :** `App\Http\Controllers\UtilisateurController::notifications`  
**Authentification :** Requise (Bearer token)  
**Paramètres URL :** Aucun  
**Body :** Aucun

**Note :** Retourne les notifications de l'utilisateur connecté. Aucun ID n'est nécessaire.

**Query Parameters (optionnels) :**

- `page` (optionnel) : Numéro de page (défaut: 1)
- `per_page` (optionnel) : Nombre d'éléments par page (défaut: 10)

**Exemple de requête :**

```bash
curl -X GET "http://localhost/api/user/notifications?page=1&per_page=10" \
  -H "Authorization: Bearer {token}"
```

**Réponse de succès (200) :**

```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "title": "Virement reçu",
        "message": "Vous avez reçu un virement de 500.00 €",
        "is_read": false,
        "created_at": "2024-01-15T10:30:00.000000Z"
      }
    ],
    "total": 5,
    "per_page": 10
  }
}
```

---

#### 14. Marquer une notification comme lue

**Endpoint :** `POST /api/user/notifications/{id}/read`  
**Contrôleur :** `App\Http\Controllers\UtilisateurController::markNotificationAsRead`  
**Authentification :** Requise (Bearer token)  
**Query Parameters :** Aucun  
**Body :** Aucun

**Paramètres URL (requis) :**

- `{id}` : ID de la notification (integer, requis)

**Note :** Remplacez `{id}` par l'ID numérique de la notification dans l'URL. Exemple : `/api/user/notifications/1/read`

**Exemple de requête :**

```bash
curl -X POST http://localhost/api/user/notifications/1/read \
  -H "Authorization: Bearer {token}"
```

**Réponse de succès (200) :**

```json
{
  "success": true,
  "unread_count": 4
}
```

---

#### 15. Marquer toutes les notifications comme lues

**Endpoint :** `POST /api/user/notifications/mark-all-read`  
**Contrôleur :** `App\Http\Controllers\UtilisateurController::markAllNotificationsAsRead`  
**Authentification :** Requise (Bearer token)  
**Paramètres URL :** Aucun  
**Query Parameters :** Aucun  
**Body :** Aucun

**Note :** Marque toutes les notifications non lues de l'utilisateur connecté. Aucun ID n'est nécessaire.

**Exemple de requête :**

```bash
curl -X POST http://localhost/api/user/notifications/mark-all-read \
  -H "Authorization: Bearer {token}"
```

**Réponse de succès (200) :**

```json
{
  "success": true,
  "unread_count": 0
}
```

---

#### 16. Nombre de notifications non lues

**Endpoint :** `GET /api/user/notifications/count`  
**Contrôleur :** `App\Http\Controllers\UtilisateurController::getUnreadNotificationsCount`  
**Authentification :** Requise (Bearer token)  
**Paramètres URL :** Aucun  
**Query Parameters :** Aucun  
**Body :** Aucun

**Note :** Retourne le nombre de notifications non lues de l'utilisateur connecté. Aucun ID n'est nécessaire.

**Exemple de requête :**

```bash
curl -X GET http://localhost/api/user/notifications/count \
  -H "Authorization: Bearer {token}"
```

**Réponse de succès (200) :**

```json
{
  "count": 5
}
```

---

#### 17. Notifications récentes

**Endpoint :** `GET /api/user/notifications/recent`  
**Contrôleur :** `App\Http\Controllers\UtilisateurController::getRecentNotifications`  
**Authentification :** Requise (Bearer token)  
**Paramètres URL :** Aucun  
**Query Parameters :** Aucun  
**Body :** Aucun

**Note :** Retourne les 3 notifications les plus récentes de l'utilisateur connecté. Aucun ID n'est nécessaire.

**Exemple de requête :**

```bash
curl -X GET http://localhost/api/user/notifications/recent \
  -H "Authorization: Bearer {token}"
```

**Réponse de succès (200) :**

```json
{
  "notifications": [
    {
      "id": 1,
      "title": "Virement reçu",
      "message": "Vous avez reçu un virement de 500.00 €",
      "is_read": false,
      "created_at": "2024-01-15T10:30:00.000000Z"
    }
  ]
}
```

---



