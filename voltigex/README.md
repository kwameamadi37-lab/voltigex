# Voltigex

**Cursor :** avant toute modification sur les fichiers de chat (`conversations_page.dart`, `chat_page.dart`, `chat_list_layout.dart`, `chat_status_view.dart`, `chat_bloc.dart`, etc.), lis **« Mémoire projet — Chat (solutions critiques) »** puis **« Système de Messagerie (Style Messenger) »** pour les contraintes métier (suture, URLs, retry) et de design atomique.

---

## Messagerie — architecture & fonctionnalités (temps réel)


Vue d’ensemble professionnelle du module chat mobile et de son couplage backend. Le détail d’implémentation (bulles, médias, checklist) reste documenté plus bas dans **Mémoire projet — Chat** et **Système de Messagerie (Style Messenger)**.

### 1. Fonctionnalités implémentées

#### Messagerie temps réel

- Intégration **Pusher** côté mobile (`pusher_channels_flutter`) avec l’API **Laravel** (écosystème **Broadcasting** — sur le web, **Laravel Echo** joue un rôle analogue). Réception en direct des **nouveaux messages**, **mises à jour de médias** et **événements de lecture / frappe** sur des canaux authentifiés.
- Les **notifications push** (**Firebase Cloud Messaging**) complètent le flux lorsque l’application est en arrière-plan ou fermée.

#### Gestion des médias

- Envoi d’**images** et de **documents** (PDF, bureautique) avec **prévisualisation locale immédiate** (UI optimiste) puis **synchronisation serveur** après upload et persistance en base.

#### Indicateurs « premium »

| Fonctionnalité | Comportement |
|----------------|--------------|
| **Typing indicator** | Caractère **asymétrique**. **Visibilité exclusive :** seul l’**Admin** voit le **Client** écrire pour garantir la **confidentialité des réponses du support**. Animation **waveDots** (`loading_animation_widget`). Le trafic est **optimisé** : pas d’appel HTTP à chaque frappe ; **rafraîchissement périodique** pendant la saisie, **`is_typing: false`** après courte inactivité ou **immédiatement à l’envoi** du message. |
| **Read receipts** | **Avatar du partenaire** positionné sur le **dernier message envoyé par l’utilisateur courant** que le partenaire a lu ; **déplacement fluide** via **`TweenAnimationBuilder`** et **`AnimatedSwitcher`**, permettant à l’avatar de **glisser visuellement** vers sa nouvelle position ; **persistance du repère** même après l’arrivée de nouveaux messages **reçus**. |

#### Ouverture native des fichiers

- Ouverture des pièces jointes via les applications système (**galerie**, **lecteur PDF**, etc.) grâce au package **`open_filex`**.
- Prise en charge des formats **image** (JPG, PNG) et **documents** (PDF, DOCX) avec **gestion du cache local** (téléchargement / réutilisation des fichiers pour l’ouverture).

### 2. Architecture technique

| Couche | Rôle |
|--------|------|
| **Frontend** | **Flutter** ; **pattern BLoC** pour l’état des conversations et du fil de messages (`ChatBloc`, coordinateur inbox, etc.). |
| **Backend** | **Laravel** (`dashboard-api`) : REST, stockage des messages et médias, **Broadcast** des événements (lecture, envoi, frappe). Les événements sensibles à la latence (ex. **`UserTyping`**) utilisent **`ShouldBroadcastNow`** pour éviter la file d’attente des jobs. |
| **Temps réel** | **Canaux privés Pusher** — convention côté client : `private-chat.{id}` (préfixe `private-` Laravel). Cela **restreint la diffusion** aux participants autorisés (authentification canal Laravel / Sanctum). |

Canaux typiques utilisés par le client :

- **`private-chat.{conversationId}`** — conversation ouverte (messages, frappe, lectures selon les événements souscrits).
- **`private-chat.inbox.{userId}`** — signaux boîte de réception utilisateur.
- **`private-chat.admin.{adminId}`** — flux support / admin.

Les noms exacts côté Laravel sont définis dans les classes **`Event`** (`broadcastOn`) et dans **`routes/channels.php`**.

### 3. Logique de synchronisation

**Gestion des doublons via `client_id`**

- Chaque message envoyé depuis le mobile reçoit un **`client_id`** (UUID) **avant** la réponse serveur.
- Ce champ est envoyé dans le corps des requêtes, persisté côté API (souvent dans les **métadonnées**) et renvoyé dans les JSON.
- Le **`ChatBloc`** résout les collisions ainsi : priorité à l’**`id` serveur** ; à défaut, **fusion par `client_id`** pour remplacer l’entrée optimiste **sans dupliquer** la ligne dans la liste.

**Mise à jour en masse des messages « lus »**

- **Côté Flutter** : lorsqu’un accusé de lecture valide un **dernier message lu** d’identifiant **X**, les messages **que vous avez envoyés** avec **`id ≤ X`** sont passés en **`is_read = 1`** localement, en cohérence avec le repère affiché (**`partnerLastSeenMessageId`** / avatar).
- **Côté Laravel** : l’endpoint de lecture de conversation exécute une **`UPDATE` groupée** (`id <= borne`) sur les messages de l’interlocuteur encore non lus, encapsulée dans une **`DB::transaction`** pour garantir une mise à jour atomique.

### 4. Installation & débogage

#### Variables d’environnement — mobile

Dans **`lib/core/constants.dart`**, aligner au minimum :

| Constante | Rôle |
|-----------|------|
| `backendServerAddress` / `baseUrl` | URL de base de l’API Laravel (`APP_URL`). |
| `pusherKey` | Clé publique — même valeur que **`PUSHER_APP_KEY`** (sûre côté client). |
| `pusherCluster` | Identique à **`PUSHER_APP_CLUSTER`** (ex. `mt1`, `eu`). |

#### Variables d’environnement — Laravel (`dashboard-api/.env`)

Exemple minimal pour activer la diffusion temps réel :

```env
BROADCAST_DRIVER=pusher

PUSHER_APP_ID=your-app-id
PUSHER_APP_KEY=your-key
PUSHER_APP_SECRET=your-secret
PUSHER_APP_CLUSTER=mt1

# Optionnel — hébergement Pusher / cluster personnalisé
# PUSHER_HOST=
# PUSHER_PORT=443
# PUSHER_SCHEME=https
```

En développement, vérifier que **`QUEUE_CONNECTION`** et le driver de broadcast permettent bien l’émission (pour **`ShouldBroadcastNow`**, la diffusion est synchrone ; pour les autres événements, un worker de queue peut être nécessaire).

#### Exemples de payloads JSON (référence)

**Frappe** — contenu typique diffusé par Laravel (`UserTyping`) :

```json
{
  "user_id": "12",
  "conversation_id": "5",
  "is_typing": true
}
```

**Lecture** — schéma indicatif (réponse API ou payload d’événement) :

```json
{
  "success": true,
  "last_read_message_id": 210,
  "unread_count": 0
}
```

**Message** — corrélation optimiste / serveur (extrait) :

```json
{
  "id": "210",
  "client_id": "550e8400-e29b-41d4-a716-446655440000",
  "conversation_id": "5",
  "sender_id": "12",
  "is_read": 0
}
```

#### Dashboard Pusher — « Client Events »

Dans le [dashboard Pusher](https://dashboard.pusher.com/), l’option **Client Events** autorise l’application mobile à **émettre** des événements directement sur un canal (sans passer par votre serveur).  

Dans la configuration actuelle du projet, la **frappe** est déclenchée via un **POST HTTP** Laravel (`/api/chat/conversations/{id}/typing`), puis **re-diffusée par le serveur** : les *Client Events* ne sont **pas requis** pour cette fonctionnalité. Activez-les si vous ajoutez des scénarios basés sur `pusher.trigger` côté client ou pour des tests spécifiques.

#### Débogage rapide

- Vérifier l’abonnement aux canaux privés dans les logs Pusher (connexion, auth endpoint).
- Contrôler que la clé/cluster Flutter correspondent au même jeu **`PUSHER_*`** que le backend.
- Pour la réception différée des événements non-`Now`, lancer **`php artisan queue:work`** si le driver de queue n’est pas `sync`.

---

## Getting Started (Flutter)

Ressources officielles : [codelab](https://docs.flutter.dev/get-started/codelab), [cookbook](https://docs.flutter.dev/cookbook), [documentation](https://docs.flutter.dev/).

## Mémoire projet — Chat (solutions critiques)

Référence pour éviter les régressions sur le module chat (médias, URLs, fusion locale/serveur, retry, UI). À lire avant toute modification sur `chat_page.dart`, `chat_bloc.dart`, `message_entity.dart`, `message_model.dart`, `MediaPathUtils`.

### 1. Continuité visuelle (médias)

- **`_LockedChatImagePreview`** (`StatefulWidget` dans `chat_page.dart`) est **obligatoire** pour les images envoyées : il conserve dans l’état du widget un chemin local **`_lockedLocalPath`** pendant le passage de l’état *en attente* (optimistic UI) à *succès* (réponse API). Sans ce verrou, la liste peut reconstruire le fils avec une URL réseau avant que la prévisualisation locale soit prête → flash ou disparition du média.
- Sur **`Image.file`**, utiliser **`gaplessPlayback: true`** pour limiter les frames vides lors du changement de source / taille pendant le swap.
- **`Hero`** : le tag doit **impérativement** s’appuyer sur **`message.clientId`** (tant qu’il est non vide) pour une transition stable ; un tag basé seulement sur l’`id` serveur casse la transition tant que l’`id` est encore vide.

### 2. Architecture des URLs médias

- **Base de données (Laravel) et API** : les chemins sont stockés et exposés comme **chemins relatifs** (ex. préfixe type `storage/...` ou organisation type `chat_medias/...` selon le déploiement), **pas** comme URL HTTP complète.
- **Client Flutter** : reconstruction de l’URL affichable / téléchargeable avec **`Constants.baseUrl`** et **`MediaPathUtils.resolveApiMediaUrlForDisplay`** (`lib/core/media_path_utils.dart`), pour suivre l’hôte du backend et les chemins relatifs.

### 3. Suture et anti-doublon (`clientId`)

- **`clientId`** : UUID généré **côté mobile** sur chaque message pending ; il est **envoyé** dans le corps des requêtes (`client_id`) et **persisté** côté Laravel dans **`metadata['client_id']`**, puis **renvoyé** dans les JSON (racine et/ou métadonnées) pour corrélation.
- **`ChatBloc._mergePendingFromPostResponse`** : trouve l’entrée locale par **`m.clientId == clientId`** (états pending / échec), puis **remplace** la ligne par le `MessageModel` issu de la réponse serveur **sans ajouter** une deuxième ligne — **clé logique = `clientId`**.
- Lors de la suture, les **métadonnées locales** (notamment **`localFilePath`**) sont **réinjectées** pour garder l’accès au fichier physique jusqu’à bascule complète vers l’URL relative serveur.

### 4. Réessai — `RetrySendMessageEvent`

- Événement **`RetrySendMessageEvent`** : l’utilisateur relance l’envoi d’un message en échec (`isSaved == 0`) ; le bloc remet l’état d’envoi, relance upload/API si besoin, puis appelle la **même** logique de suture que l’envoi classique (`_mergePendingFromPostResponse`).
- **`MessageEntity.copyWith`** : le champ **`isSaved`** (`int?`) utilise une **valeur sentinelle** (voir `_copyWithIsSavedUnset` dans `message_entity.dart`) pour distinguer « ne pas modifier » et « remettre explicitement à **`null`** ». Sans cela, `copyWith(isSaved: null)` ne peut pas repasser en *en cours* après un échec, et la fusion post-API ne trouve pas le pending → UI bloquée sur l’icône d’erreur et risque de doublons au rechargement.

### 5. UI et design — constantes validées

- **Groupement temporel** : deux messages du même auteur forment un groupe visuel **serré** si l’écart en secondes est **&lt; 120** (`kMessengerShowTimestampGapSeconds` dans `chat_message.dart` ; logique dans `chat_list_layout.dart`).
- **Marges entre bulles groupées** : **`2.0` px** en haut de bulle dans le groupe (`kChatBubbleTightTopMargin` dans `chat_list_layout.dart`) ; marge plus lâche (**`8.0` px**) hors groupe ou après rupture.
- **BorderRadius des bulles** : coins « serrés » **`4.0`** et coins « larges » **`20.0`** selon la position dans le groupe (`_kBubbleRadiusTightCorner` / `_kBubbleRadiusMain` dans `chat_list_layout.dart`) — voir aussi la section détaillée **Design des bulles** ci-dessous.

## Système de Messagerie (Style Messenger)

Référence technique pour l’implémentation de `conversations_page.dart`, `chat_page.dart` et des widgets associés (`chat_list_layout.dart`, `chat_status_view.dart`, bloc chat, modèles).

### Rôles (client vs admin support)

- **Simple User (client)** : conversation 1‑à‑1 avec un interlocuteur ; navigation habituelle depuis la liste des conversations ; pas de barre système « retour » imposée par le rôle (selon `MainScreen` / routes).
- **Admin (support)** : accès aux conversations support ; `SessionController.instance.isAdminSupport` pilote l’UI (ex. `leading` AppBar sur `ChatPage`, marges). Le **profil affiché dans les accusés de lecture** (avatar « Vu ») est toujours celui du **partenaire** de la conversation, que l’utilisateur connecté soit client ou admin.

### Logique de groupement temporel et auteur

Deux messages consécutifs **dans l’ordre chronologique** forment un **même groupe visuel** si et seulement si :

```text
senderId(A) == senderId(B)
ET
(second.createdAt - first.createdAt) en secondes < 120
```

En Dart (domaine / layout), voir `_isTightVisualGroupPair` et `kMessengerShowTimestampGapSeconds` (120).

**Conséquences visuelles pour un groupe serré** (suite de messages, `compactTop == true` pour tout sauf le premier du bloc) :

- **Messages reçus** : pas d’avatar répété sur les lignes intermédiaires (`showAvatarAndName` faux si même expéditeur que le message précédent dans le groupe).
- **Timestamps** : pas d’heure sur les messages intermédiaires du bloc (voir section Timestamps).
- **Marges** : `bubbleTopMargin == 2.0` px (`kChatBubbleTightTopMargin`) sur **la bulle seule** (texte ou média) ; hors groupe ou après rupture : `8.0` px (`kChatBubbleLooseTopMargin`).

### Design des bulles (BorderRadius dynamique)

Les coins sont calculés dans `buildChatListItems` (`chat_list_layout.dart`) à partir de `compactTop` (liaison avec le message **plus ancien** dans le groupe) et `sameNext` (liaison avec le message **plus récent** dans le groupe, même fenêtre 120 s).

**Messages envoyés (droite)** — `_bubbleRadiusSent` :

- `topRight` : **4** si `compactTop` (suite du groupe), sinon **20**.
- `bottomRight` : **4** si `sameNext` (il existe un message plus récent du même expéditeur dans la fenêtre 120 s), sinon **20**.
- `topLeft` / `bottomLeft` : **20**.

**Messages reçus (gauche)** — `_bubbleRadiusReceived` (miroir) :

- `topLeft` : **4** si `compactTop`, sinon **20**.
- `bottomLeft` : **4** si `sameNext`, sinon **20**.
- `topRight` / `bottomRight` : **20**.

**Lecture « premier / milieu / dernier » du groupe** :

- **Premier du groupe** : `compactTop == false` → coins « larges » (20) côté extérieur du haut ; le côté **bas** peut déjà être serré (4) si `sameNext == true` (il y a encore des messages du même auteur en dessous).
- **Milieu** : `compactTop && sameNext` → coins serrés (4) en **haut et bas** du côté expéditeur (droite ou gauche selon le sens).
- **Dernier du groupe** : `compactTop && !sameNext` → coin serré en **haut** (4), coins larges en **bas** (20) côté expéditeur.

### Accusés de lecture (read receipts)

- **`is_read == 1` (côté message envoyé « lu par le partenaire »)** : **aucune coche grise** (`deliveredCheck` ne doit pas s’afficher). Le widget `ChatMessengerReadReceiptSlot` retourne `SizedBox.shrink()` pour tout indicateur autre que l’avatar ciblé lorsque `messageIsRead == 1`.
- **Avatar du partenaire** : affiché **uniquement** sur le message dont `message.id` (trim) est strictement égal à `effectivePartnerLastSeenMessageId` (même valeur que celle utilisée pour `_sentReadReceiptFor` + slot).
- **Fallback** : si l’ID global API (`partnerLastSeenMessageId` dans le state) est absent ou vide, calcul local via `computeLastReadSentMessageId` puis, si besoin, `_fallbackLastReadSentMessageIdChronological` (dernier message **envoyé par moi** avec `isRead == 1` dans la liste triée).

Pseudo-code :

```dart
if (isSent && msg.isRead == 1) {
  // pas de coche
  if (msg.id == effectivePartnerLastSeenMessageId) {
    ui = readRecipientAvatar; // seul cas visible sous forme d’avatar
  } else if (idNum(msg) < idNum(partner)) {
    ui = readTrailShrink; // pas de traînée d’avatars
  } else {
    ui = none;
  }
} else if (isSent && msg.isRead == 0) {
  ui = deliveredCheck;
}
```

### Position des timestamps

La liste est rendue avec `ListView.builder(reverse: true)` : l’index **0** est le message le plus **récent** (bas de l’écran).

Dans `_applyMessengerShowTimestamps`, **`showTimestamp`** est `true` uniquement pour le **dernier message visuel du bloc** (celui juste avant une rupture : autre auteur ou écart **≥ 120 s** par rapport au message plus récent au-dessus dans la liste).

```dart
final previousNewer = messageAuDessusDansLaListe(); // plus récent
final showTimestamp = previousNewer == null ||
    !_isTightVisualGroupPair(current, previousNewer);
```

L’heure s’affiche donc sous le message le plus bas du groupe (ex. « test3 »), pas sous le premier message du bloc (« début tests »).

### Gestion du clavier

- **`Scaffold.resizeToAvoidBottomInset: true`** sur `ChatPage` : le corps se redimensionne avec le clavier IME.
- **Ne pas** ajouter de `Padding` / `EdgeInsets` basés sur `MediaQuery.viewInsetsOf(context).bottom` autour de la barre de saisie (double compensation et sauts d’UI).
- **`SafeArea(bottom: false)`** autour du champ : évite une marge basse systématique qui empêcherait le champ de coller au clavier.

### Cas limites — médias

- Les **images** et **PDF** suivent la **même** règle de groupement, marges (`bubbleTopMargin`) et `BorderRadius` que le texte : tout est porté par `ChatListItem.bubbleRadius` et `bubbleTopMargin`, appliqués dans `chat_page.dart` au conteneur / `ClipRRect` de la bulle.
- **Image seule** : le `BorderRadius` du message s’applique au `ClipRRect` / conteneur qui enveloppe le média ; les miniatures internes n’imposent pas leur propre rayon arrondi qui masquerait l’emboîtement (coins internes à `BorderRadius.zero` si besoin, clip externe = bulle).

**Détail implémentation (verrou média, Hero, URLs)** : voir **« Mémoire projet — Chat »** § *Continuité visuelle* et § *Architecture des URLs médias*.

- Résumé : **`_LockedChatImagePreview`** + **`gaplessPlayback: true`** sur `Image.file` + **`Hero`** sur **`message.clientId`** ; chemins **relatifs** côté API, URL complète côté client via **`MediaPathUtils.resolveApiMediaUrlForDisplay`** et **`Constants.baseUrl`**.

### Données API / modèle

- **`is_read`** : reçu comme **entier** `0` ou `1` (voir `MessageEntity.isRead`). Toujours tester avec **égalité stricte** (`== 0`, `== 1`) ou convertir explicitement en booléen si tu centralises la logique — ne pas supposer un booléen JSON natif.

```dart
// Correct
if (message.isRead == 1) { ... }

// Éviter les suppositions implicites sur le type runtime
```

### Logique de Persistance et Synchronisation

Objectif : garantir une UX fluide (offline-first), éviter les doublons visuels, et garder une source de vérité serveur sans casser l’affichage local.

- **Stratégie Offline-First (envoi)** :
  - À l’envoi, créer immédiatement un message local (optimistic UI) avec `clientId` unique, `isSaved == null` ou `0` selon l’étape, pour affichage instantané dans la `ListView`.
  - Tenter l’envoi API en arrière-plan.
  - En cas de succès, remplacer/patcher l’entrée locale avec les champs serveur (`id`, `createdAt`, `isSaved == 1`, etc.).
  - En cas d’échec réseau, conserver le message local en échec (`isSaved == 0`) pour permettre une reprise/réémission.

- **Synchronisation des accusés de lecture** :
  - Les messages envoyés utilisent `isRead` (0/1) + `partnerLastSeenMessageId` (ou `effectivePartnerLastSeenMessageId`).
  - `isRead == 1` : aucune coche grise ne doit rester visible ; seul l’avatar du partenaire est autorisé sur le message ciblé.
  - Si l’ID global est absent, fallback local chronologique : dernier message envoyé par moi avec `isRead == 1`.

- **Déduplication stricte (fetch anciens / refresh)** :
  - Clé primaire logique de fusion : **`id` serveur** (quand disponible).
  - Le `clientId` sert de corrélation temporaire (optimistic UI) tant que l’`id` serveur n’est pas revenu.
  - Règle pratique :
    - si `id` identique => update de l’existant (ne jamais insérer un doublon),
    - sinon, si message local temporaire (`clientId` match) => remplacer par la version serveur,
    - sinon => insertion normale.

- **Ordre chronologique canonique** :
  - Avant tout calcul d’UI (groupes, timestamps, coins), trier les messages par `createdAt` croissant (`sortMessagesChronological`).
  - L’affichage final utilise `ListView.builder(reverse: true)` : le message le plus récent est en bas de l’écran.
  - Les calculs de groupement (`samePrev`, `sameNext`) et de timestamp doivent rester cohérents avec cet ordre (pas de logique mixte entre ordre serveur brut et ordre écran).

- **Pagination / récupération des anciens messages** :
  - L’ajout de pages anciennes ne doit pas casser la continuité visuelle :
    - fusion + dédup d’abord,
    - tri chronologique ensuite,
    - recalcul des `ChatListItem` (marges, radius, timestamps) enfin.
  - Toujours conserver un identifiant de conversation effectif stable pendant le fetch (`conversationId`) pour éviter de mélanger des fils distincts.

- **Résolution de conflit local vs serveur** :
  - Le serveur reste source de vérité pour `id`, `createdAt`, `isRead`, `isPinned`, etc.
  - Le local peut conserver des métadonnées d’UI/transitoires (`clientId`, états pending/error), mais ne doit pas écraser les valeurs serveur confirmées.
  - En cas de divergence, priorité aux valeurs serveur, puis recalcul des états dérivés (`effectivePartnerLastSeenMessageId`, `showTimestamp`, groupement).

- **Invariants à préserver (checklist rapide)** :
  - pas de doublons d’`id` serveur dans la `ListView`,
  - pas de coche affichée pour `isRead == 1`,
  - avatar lecture visible uniquement sur `effectivePartnerLastSeenMessageId`,
  - tri et groupement recalculés après chaque merge local/serveur.

Exemple de merge (pseudo-code) :

```dart
for (final incoming in fetchedMessages) {
  final byServerId = local.firstWhereOrNull((m) => m.id == incoming.id && m.id.isNotEmpty);
  if (byServerId != null) {
    patch(byServerId, incoming); // update in-place
    continue;
  }

  final byClientId = local.firstWhereOrNull(
    (m) => m.clientId.isNotEmpty && m.clientId == incoming.clientId,
  );
  if (byClientId != null) {
    replace(byClientId, incoming); // swap optimistic -> server
    continue;
  }

  local.add(incoming);
}

local = sortMessagesChronological(local);
final listItems = buildChatListItems(...); // recalc UI model
```

## SETUP
### Splash Screen
````bash
 dart run flutter_native_splash:create --path=flutter_native_splash.yaml
````

### Change Notifications Icon
1. Allez sur [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/icons-notification.html#source.type=image&source.space.trim=1&source.space.pad=0&name=notification_icon)

👉 Uploadez votre PNG → il génère toutes les tailles (mdpi, hdpi, xhdpi, etc.)
👉 Récupérez le ZIP, vous le collez et le dézippez dans android/app/src/main/res/

Vous aurez un dossier res/ contenant des sous-dossiers comme :

    drawable-mdpi/
    drawable-hdpi/
    drawable-xhdpi/
    drawable-xxhdpi/
    drawable-xxxhdpi/

2. Copiez le contenu (les sous-dossiers drawable-*) dans :
```
    android/app/src/main/res/
```

Remplacez les anciens dossiers par les nouveaux s'il y en avait.

3. Vérifiez que tes icônes sont bien placées dans :
```
    android/app/src/main/res/drawable-mdpi/notification_icon.png
    android/app/src/main/res/drawable-hdpi/notification_icon.png
```

4. Dans le code où vous initialisez les notifications (souvent dans main.dart ou ton service de notification) :
```
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/ic_stat_notification');
```

5. Enfin, nettoyez et relancez l’app
```
    flutter clean
    flutter pub get
    flutter run
```

### Change the App Name
Le petit texte nom de l’appli affiché à côté du nom de l’utilisateur dans une notification s'appelle le App name.

Par défaut, il est pris dans
```css
    android/app/src/main/AndroidManifest.xml
```
à cette partie:
```
<application
    android:label="MonApp"
    ... >
```

La méthode "Expert" (Automatisée) pour le changer:

Si vous ne voulez pas fouiller dans les dossiers natifs, il existe un package très pratique qui fait tout le travail pour vous, y compris pour les configurations complexes : rename_app.

Installation :

```Bash
flutter pub add rename_app --dev
```

Ensuite :

```Bash
flutter pub run rename_app:main all="Mon Nouveau Nom"
```
Cette commande mettra à jour Android et iOS simultanément.



## Gestion de la session utilisateur
* Lorsque l'utilisateur se connecte, une session contenant son id et son token est créée. 

* Lorsqu'il fait une requête et obtient une erreur 401 (token expiré), la session est détruite et il est redirigé vers la page de login 
  * (géré par un intercepteur Dio client)

* Lorsqu'il se déconnecte:
  * la session est détruite
  * son fcm relié à ce téléphone est supprimé de la BD (TODO)
  * il est redirigé vers la page login

* A chaque fois que l'appli est rechargée, le splash screen vérifie si la session est valide et redirige l'utilisateur en fonction 
