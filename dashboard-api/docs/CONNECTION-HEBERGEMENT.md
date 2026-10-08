# Connexion en hébergement (pourquoi ça marche en local mais pas en prod)

Ce document liste les fichiers qui gèrent la **connexion web** (login admin) et ce qui peut **bloquer** en production.

---

## 1. Fichiers qui gèrent la connexion

| Fichier | Rôle |
|--------|------|
| **routes/web.php** | Route `GET /login`, `POST /login` (via Laravel), route `POST /logout`, groupe `auth` + `admin` pour `/admin-virements` |
| **app/Http/Controllers/Auth/LoginController.php** | Validation login, vérification `role === 'admin'`, `attemptLogin`, `sendLoginResponse`, `authenticated`, redirection vers `/admin-virements` |
| **app/Http/Middleware/Authenticate.php** | Si non connecté → redirection vers `route('login')` (d’où le 302 vers `/login` si la session n’est pas reconnue) |
| **app/Http/Middleware/RedirectIfAuthenticated.php** | Si déjà connecté (guest) → redirection admin ou logout si non-admin |
| **app/Http/Middleware/EncryptCookies.php** | Chiffrement des cookies (pas d’exception par défaut) |
| **app/Http/Middleware/VerifyCsrfToken.php** | Vérification CSRF (exclusion `api/auth/*`) |
| **app/Http/Middleware/CheckSessionTimeout.php** | Déconnexion après 10 min d’inactivité, met à jour `last_activity` |
| **app/Http/Kernel.php** | Groupes `web` (session, CSRF, cookies) et `api` (Sanctum stateful), alias `auth`, `guest`, `admin` |
| **config/session.php** | `SESSION_DRIVER`, `SESSION_DOMAIN`, `SESSION_SECURE_COOKIE`, `same_site` → **critiques en HTTPS** |
| **config/sanctum.php** | `stateful` = domaines pour cookies API (Sanctum) ; pas utilisé pour le login web formulaire |
| **app/Http/Middleware/TrustProxies.php** | Faire confiance à `X-Forwarded-Proto`, `X-Forwarded-Host` pour que Laravel sache que la requête est en HTTPS |

---

## 2. Pourquoi “en local ça va, en hébergement ça ne se connecte pas”

En local, la requête arrive directement en HTTP sur Laravel. En hébergement, la requête passe souvent par **nginx/apache** (HTTPS) puis vers PHP (HTTP). Sans configuration adaptée :

1. **TrustProxies**  
   Si les proxies ne sont pas reconnus, `$request->secure()` reste `false`. Laravel peut alors émettre un cookie de session sans flag `Secure` ou avec une mauvaise base d’URL, et le navigateur peut refuser de renvoyer le cookie sur HTTPS.

2. **SESSION_SECURE_COOKIE**  
   En HTTPS, ce réglage doit être à `true`. Sinon le cookie peut être émis sans `Secure` et certains navigateurs ne l’envoient pas correctement sur une page HTTPS.

3. **SESSION_DOMAIN**  
   Doit être le **domaine nu** (ex. `bank.voltigex.de`), **sans** `https://` ni `:443`. Si vide, Laravel utilise le host de la requête (souvent correct si le host est bon grâce à TrustProxies).

4. **APP_URL**  
   Doit être l’URL réelle du site (ex. `https://bank.voltigex.de`) pour les redirections et les liens.

5. **Cookie non renvoyé**  
   Après le POST `/login`, la réponse doit contenir un `Set-Cookie` (session). Si le domaine, le `Secure` ou le `SameSite` ne correspondent pas au contexte (HTTPS, domaine), le navigateur ne renvoie pas le cookie sur la requête suivante (GET `/admin-virements`) → Laravel ne voit pas de session → middleware `auth` → 302 vers `/login`.

---

## 3. Checklist .env en production (hébergement HTTPS)

À adapter selon votre domaine (ex. `bank.voltigex.de`) :

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://bank.voltigex.de

# Session / cookies (obligatoire pour que la connexion tienne)
SESSION_DOMAIN=bank.voltigex.de
SESSION_SECURE_COOKIE=true

# Si vous utilisez l’API depuis le même domaine (SPA / app)
SANCTUM_STATEFUL_DOMAINS=bank.voltigex.de,localhost,127.0.0.1
```

Après modification du `.env` :

```bash
php artisan config:clear
php artisan config:cache
```

---

## 4. Modifications déjà faites dans le projet

- **TrustProxies** : `$proxies = '*'` pour que les en-têtes `X-Forwarded-*` soient pris en compte derrière un reverse proxy.
- **CORS** : `config/cors.php` inclut `APP_URL` et optionnellement `CORS_ORIGINS` pour autoriser l’origine de production.
- **.env.example** : exemples et commentaires pour `SESSION_DOMAIN`, `SESSION_SECURE_COOKIE`, `SANCTUM_STATEFUL_DOMAINS`.

---

## 5. Vérifications rapides en production

1. **Réponse POST /login**  
   Dans les DevTools (Network), vérifier que la réponse contient un en-tête **Set-Cookie** (ex. `laravel_session=...` ou le nom défini par `SESSION_COOKIE`). Vérifier que le cookie a bien `Secure` et `Domain` cohérents.

2. **Requête GET /admin-virements**  
   Vérifier que la requête suivante envoie bien le cookie (**Cookie** dans les en-têtes). Si le cookie n’est pas envoyé, revoir `SESSION_DOMAIN`, `SESSION_SECURE_COOKIE` et TrustProxies.

3. **Compte admin**  
   Seuls les utilisateurs avec `role = 'admin'` peuvent utiliser le login web. Vérifier en base : `SELECT id, email, alias, role FROM users WHERE ...`.

4. **Logs**  
   En cas d’erreur : `storage/logs/laravel.log` et logs du serveur web (nginx/apache).

---

## 6. Résumé des fichiers à garder en tête

- **Connexion / auth web** : `LoginController`, `Authenticate`, `RedirectIfAuthenticated`, `EncryptCookies`, `VerifyCsrfToken`, `CheckSessionTimeout`, `config/session.php`, `TrustProxies`.
- **Routes** : `routes/web.php` (login, logout, groupes `auth` et `admin`).
- **Config hébergement** : `.env` (APP_URL, SESSION_DOMAIN, SESSION_SECURE_COOKIE), `config/session.php`, `config/cors.php`, `app/Http/Middleware/TrustProxies.php`.

Une fois TrustProxies, APP_URL, SESSION_DOMAIN et SESSION_SECURE_COOKIE corrects, la connexion en hébergement devrait fonctionner comme en local.

---

## 7. Images / stockage (404 sur /storage/documents/...)

Sur certains hébergeurs (ex. Namecheap), le lien symbolique `public/storage` → `storage/app/public` n’existe pas ou n’est pas autorisé. Les URLs comme `https://voltigex.de/storage/documents/pieces_identite/xxx.png` renvoient alors **404**.

**Solution déjà en place** : une route de secours dans `routes/web.php` sert les fichiers depuis `storage/app/public` pour toute requête `GET /storage/{path}`. Aucune action côté hébergeur nécessaire : tant que les requêtes passent par Laravel (`.htaccess` → `index.php`), les images s’affichent.

**Si les 404 persistent** :
1. Vérifier que les fichiers sont bien présents sur le serveur dans `storage/app/public/documents/` (pieces_identite, avis_imposition, etc.).
2. Vérifier les permissions : `storage/app/public` et sous-dossiers en lecture pour le serveur web.
3. Optionnel : exécuter `php artisan storage:link` sur le serveur si l’hébergeur autorise les symlinks (alors le serveur web servira les fichiers directement sans passer par Laravel).

---

## 8. Support client (/admin/support) : les utilisateurs ne s'affichent pas

La page Support client charge la liste des conversations via l'API `GET /api/chat/conversations`. Si la liste reste vide ou affiche « Session expirée / non autorisée » :

1. **Sanctum stateful** : le domaine de l'admin (ex. `voltigex.de`) doit être dans `SANCTUM_STATEFUL_DOMAINS` pour que le cookie de session soit accepté sur les requêtes `/api/*`. Sinon l'API renvoie 401 et les conversations ne se chargent pas.
2. **Données** : les conversations ont deux participants (`user_one_id`, `user_two_id`). L'« autre » utilisateur affiché est celui qui n'est pas admin. Si un participant est manquant en base, le code affiche un libellé de repli (alias, email ou « Client #id »).
3. En cas de 401, la page affiche un message invitant à se reconnecter.
