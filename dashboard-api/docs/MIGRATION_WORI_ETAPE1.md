# Migration Wori → Laravel — Point des modifications (Étape 1)

## Contexte

- **Backend Laravel (Voltigex)** : auth Sanctum, virements, KYC, table `users` existante.
- **Backend Node (Wori)** : chat temps réel (Socket.io), conversations, messages, contacts, PostgreSQL.
- **Objectif** : supprimer `Backend/wori-app-backend` et migrer la logique chat/contacts dans Laravel, avec Pusher pour le temps réel.

## Règles retenues

- Uniquement **Eloquent** pour les nouveaux modèles.
- Nouvelles routes chat dans **routes/api.php** avec **auth:sanctum**.
- Authentification via la table **users** existante (pas de table users Wori séparée).

---

## Schéma Wori (PostgreSQL) → Laravel (MySQL)

| Wori (PostgreSQL) | Laravel (MySQL) |
|-------------------|-----------------|
| `users` (Wori) avec UUID | **Non migré** : on utilise la table `users` Laravel (id bigint) |
| `conversations` (participant_one, participant_two UUID) | `conversations` avec `user_one_id`, `user_two_id` (foreignId → users.id) |
| `messages` (conversation_id, sender_id UUID, type, content, media_*, is_read, …) | `messages` avec `conversation_id`, `user_id` (sender), champs alignés |
| `contacts` (user_id, contact_id UUID) | `contacts` avec `user_id`, `contact_id` (foreignId → users.id) |

---

## Fichiers créés pour validation (Étape 1)

### 1. Migrations

- **`*_create_conversations_table.php`**  
  - `id` (bigIncrements)  
  - `user_one_id`, `user_two_id` (foreignId → users.id)  
  - `timestamps`  
  - Unique (`user_one_id`, `user_two_id`). **À respecter en code** : toujours créer une conversation avec `user_one_id = min(a,b)` et `user_two_id = max(a,b)` pour éviter (A,B) et (B,A).

- **`*_create_messages_table.php`**  
  - `id` (bigIncrements)  
  - `conversation_id` (foreignId → conversations.id, onDelete cascade)  
  - `user_id` (sender, foreignId → users.id)  
  - `type` (string 10 : 'text' | 'media')  
  - `content` (text nullable)  
  - `media_type`, `media_url`, `thumbnail_url` (nullable)  
  - `media_width`, `media_height` (unsignedInteger nullable)  
  - `blurhash` (string nullable)  
  - `metadata` (json nullable)  
  - `is_read` (boolean default false)  
  - `is_pinned`, `is_deleted` (boolean default false)  
  - `timestamps`

- **`*_create_contacts_table.php`**  
  - `id` (bigIncrements)  
  - `user_id`, `contact_id` (foreignId → users.id)  
  - `timestamps`  
  - Unique (`user_id`, `contact_id`)

### 2. Modèles

- **`Conversation.php`**  
  - `belongsTo(User::class, 'user_one_id')`, `belongsTo(User::class, 'user_two_id')`  
  - `hasMany(Message::class)`  
  - Méthode helper pour récupérer "l'autre participant" à partir de l'utilisateur connecté.

- **`Message.php`**  
  - `belongsTo(Conversation::class)`  
  - `belongsTo(User::class, 'user_id')` (expéditeur)  
  - Casts : `is_read`, `is_pinned`, `is_deleted` en booléen, `metadata` en array.

### 3. À faire ensuite (après validation)

- **ChatController** : lister conversations, historique messages, envoyer message.
- **Event MessageSent** : implémenter `ShouldBroadcast` pour Pusher.
- **Routes API** : ajout dans `api.php` sous `auth:sanctum`.

---

## Résumé des changements par rapport à Wori

| Aspect | Wori (Node) | Laravel (après migration) |
|--------|-------------|----------------------------|
| IDs | UUID | bigint auto-increment |
| Users | Table users Wori (username, email, profile_image) | Table `users` existante (nom, prenom, email, etc.) |
| Conversations | participant_one / participant_two (UUID) | user_one_id / user_two_id (FK users) |
| Messages | sender_id (UUID) | user_id (FK users) |
| Contacts | user_id, contact_id (UUID) | user_id, contact_id (FK users) |
| Temps réel | Socket.io | À remplacer par Pusher (Event MessageSent) |

---

*Document de référence pour la validation des migrations et modèles avant de poursuivre avec le ChatController et le broadcasting.*
