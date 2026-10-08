<?php

namespace App\Http\Controllers\Api;

use App\Events\ConversationRead;
use App\Events\MessageSent;
use App\Events\UserTyping;
use App\Helpers\MessageMetadataHelper;
use App\Http\Controllers\Controller;
use App\Jobs\SendChatMessageNotification;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Intervention\Image\Laravel\Facades\Image;

class ChatController extends Controller
{
    /**
     * Id du dernier message **envoyé par l’utilisateur courant** que le partenaire a lu (accusé « Vu »).
     */
    private function partnerLastSeenMessageIdForViewer(Conversation $conversation, User $viewer): ?int
    {
        $max = Message::query()
            ->where('conversation_id', $conversation->id)
            ->where('user_id', $viewer->id)
            ->where('is_read', true)
            ->max('id');

        return $max !== null ? (int) $max : null;
    }

    private function formatMessagePayload(Message $message): array
    {
        $meta = $message->metadata;

        return [
            'id' => $message->id,
            'conversation_id' => $message->conversation_id,
            'client_id' => MessageMetadataHelper::clientId($meta),
            'type' => $message->type,
            'internal_type' => $message->internal_type,
            'content' => $message->content,
            'media_type' => $message->media_type,
            'media_url' => $message->media_url,
            'thumbnail_url' => $message->thumbnail_url,
            'media_width' => $message->media_width,
            'media_height' => $message->media_height,
            'blurhash' => $message->blurhash,
            'metadata' => MessageMetadataHelper::forJson($meta),
            'is_read' => (bool) $message->is_read,
            'is_pinned' => (bool) $message->is_pinned,
            'is_deleted' => (bool) $message->is_deleted,
            'sender' => [
                'id' => $message->user_id,
                'role' => $message->user->role ?? 'user',
                'nom' => $message->user->nom ?? 'Client',
            ],
            'sender_id' => $message->user_id,
            'created_at' => $message->created_at?->toISOString(),
            'updated_at' => $message->updated_at?->toISOString(),
        ];
    }

    /**
     * URL publique de la photo (champs stockés sur le disque public Laravel).
     */
    private function userProfilePhotoPublicUrl(?User $user): ?string
    {
        if (! $user) {
            return null;
        }

        return $user->profilePhotoPublicUrl();
    }

    /**
     * Filtre les conversations dont le participant affiché (l’autre utilisateur) correspond au terme LIKE
     * sur nom, prénom, alias ou email.
     */
    private function applyConversationParticipantSearch(Builder $query, User $user, string $searchTerm): void
    {
        $like = '%'.addcslashes($searchTerm, '%_\\').'%';

        if ($user->role === 'admin') {
            $query->where(function ($outer) use ($like) {
                $outer->whereHas('userOne', function ($u) use ($like) {
                    $u->where(function ($r) {
                        $r->whereNull('role')->orWhere('role', '!=', 'admin');
                    })->where(function ($n) use ($like) {
                        $n->where('nom', 'like', $like)
                            ->orWhere('prenom', 'like', $like)
                            ->orWhere('alias', 'like', $like)
                            ->orWhere('email', 'like', $like);
                    });
                })->orWhereHas('userTwo', function ($u) use ($like) {
                    $u->where(function ($r) {
                        $r->whereNull('role')->orWhere('role', '!=', 'admin');
                    })->where(function ($n) use ($like) {
                        $n->where('nom', 'like', $like)
                            ->orWhere('prenom', 'like', $like)
                            ->orWhere('alias', 'like', $like)
                            ->orWhere('email', 'like', $like);
                    });
                });
            });

            return;
        }

        $userId = $user->id;
        $query->where(function ($outer) use ($like, $userId) {
            $outer->where(function ($sub) use ($like, $userId) {
                $sub->where('user_one_id', $userId)
                    ->whereHas('userTwo', function ($u) use ($like) {
                        $u->where(function ($n) use ($like) {
                            $n->where('nom', 'like', $like)
                                ->orWhere('prenom', 'like', $like)
                                ->orWhere('alias', 'like', $like)
                                ->orWhere('email', 'like', $like);
                        });
                    });
            })->orWhere(function ($sub) use ($like, $userId) {
                $sub->where('user_two_id', $userId)
                    ->whereHas('userOne', function ($u) use ($like) {
                        $u->where(function ($n) use ($like) {
                            $n->where('nom', 'like', $like)
                                ->orWhere('prenom', 'like', $like)
                                ->orWhere('alias', 'like', $like)
                                ->orWhere('email', 'like', $like);
                        });
                    });
            });
        });
    }

    private function findOrCreateSupportConversation(User $first, User $second): Conversation
    {
        $idA = $first->getKey();
        $idB = $second->getKey();
        if ($idA === null || $idB === null || (int) $idA < 1 || (int) $idB < 1) {
            Log::error('findOrCreateSupportConversation: identifiants participants invalides', [
                'idA' => $idA,
                'idB' => $idB,
            ]);

            throw new HttpResponseException(response()->json(['message' => 'Participants invalides.'], 422));
        }

        [$userOneId, $userTwoId] = Conversation::normalizeParticipantIds((int) $idA, (int) $idB);

        $conversation = Conversation::where('user_one_id', $userOneId)
            ->where('user_two_id', $userTwoId)
            ->first();

        if (! $conversation) {
            $conversation = Conversation::create([
                'user_one_id' => $userOneId,
                'user_two_id' => $userTwoId,
            ]);
        }

        return $conversation;
    }

    public function getSupportConversation(Request $request)
    {
        /** @var User $user */
        $user = $request->user();

        $configuredAdminId = env('SUPPORT_ADMIN_ID');
        $admin = null;

        if (! empty($configuredAdminId)) {
            $admin = User::where('id', (int) $configuredAdminId)
                ->where('role', 'admin')
                ->first();
        }

        if (! $admin) {
            $admin = User::where('role', 'admin')->orderBy('id')->first();
        }

        if (! $admin) {
            return response()->json([
                'message' => 'Aucun administrateur support disponible.',
            ], 422);
        }

        if ((int) $user->id === (int) $admin->id) {
            return response()->json([
                'message' => 'Route with-support réservée aux utilisateurs standard.',
            ], 422);
        }

        $conversation = $this->findOrCreateSupportConversation($user, $admin);

        $messages = Message::with('user')
            ->where('conversation_id', $conversation->id)
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(fn (Message $message) => $this->formatMessagePayload($message))
            ->values();

        $displayName = trim(($admin->nom ?? '') . ' ' . ($admin->prenom ?? ''));
        if ($displayName === '') {
            $displayName = $admin->alias ?? $admin->email ?? 'Support';
        }

        return response()->json([
            'conversation_id' => $conversation->id,
            'participant' => [
                'id' => $admin->id,
                'nom' => $admin->nom ?? '',
                'prenom' => $admin->prenom ?? '',
                'alias' => $admin->alias ?? '',
                'email' => $admin->email ?? '',
                'role' => $admin->role ?? 'admin',
                'display_name' => $displayName,
            ],
            'data' => $messages,
        ]);
    }

    /**
     * Règle support 1:1 :
     * - un utilisateur "standard" ne peut converser qu'avec un admin
     * - un admin peut accéder à toutes les conversations support
     */
    private function assertSupportAccess(User $user, Conversation $conversation): void
    {
        if ($user->role === 'admin') {
            return;
        }

        if (! $conversation->hasParticipant((int) $user->id)) {
            abort(response()->json(['message' => 'Accès non autorisé à cette conversation.'], 403));
        }

        $other = $conversation->otherParticipant((int) $user->id);
        if (! $other || ($other->role ?? null) !== 'admin') {
            abort(response()->json(['message' => 'Conversation non autorisée (support uniquement).'], 403));
        }
    }

    /**
     * ID de conversation existante entre deux utilisateurs, ou null.
     */
    private function conversationIdBetweenUsers(User $a, User $b): ?int
    {
        [$one, $two] = Conversation::normalizeParticipantIds((int) $a->id, (int) $b->id);
        $row = Conversation::query()
            ->where('user_one_id', $one)
            ->where('user_two_id', $two)
            ->first();

        return $row?->id;
    }

    /**
     * Base : utilisateurs avec lesquels le viewer peut chatter (même périmètre que la recherche, sans filtre texte).
     */
    private function chatEligibleUsersBaseQuery(User $viewer): Builder
    {
        $query = User::query()->where('id', '!=', $viewer->id);
        if (($viewer->role ?? '') !== 'admin') {
            $query->where('role', 'admin');
        }

        return $query;
    }

    /**
     * @return array<string, mixed>
     */
    private function mapUserToChatContactJson(User $u, User $viewer): array
    {
        $display = trim(($u->nom ?? '').' '.($u->prenom ?? ''));
        if ($display === '') {
            $display = $u->alias ?? $u->email ?? 'Utilisateur #'.$u->id;
        }

        $photoUrl = $this->userProfilePhotoPublicUrl($u);
        $convId = $this->conversationIdBetweenUsers($viewer, $u);

        return [
            'id' => $u->id,
            'nom' => $u->nom ?? '',
            'prenom' => $u->prenom ?? '',
            'alias' => $u->alias ?? '',
            'email' => $u->email ?? '',
            'role' => $u->role ?? 'user',
            'display_name' => $display,
            'profile_photo_url' => $photoUrl,
            'profile_image' => $photoUrl,
            'conversation_id' => $convId,
        ];
    }

    /**
     * Liste complète des contacts éligibles (barre horizontale). Même schéma JSON que la recherche.
     */
    public function listContactsForChat(Request $request)
    {
        /** @var User $user */
        $user = $request->user();

        $users = $this->chatEligibleUsersBaseQuery($user)
            ->orderBy('created_at', 'desc')
            ->orderBy('id', 'desc')
            ->limit(500)
            ->get();

        return response()->json(
            $users->map(fn (User $u) => $this->mapUserToChatContactJson($u, $user))->values()
        );
    }

    /**
     * Recherche d'utilisateurs pour démarrer une conversation.
     * - Admin : tous les utilisateurs sauf soi (nom, prénom, alias, email).
     * - Non-admin : uniquement les comptes admin (support).
     * Inclut [conversation_id] si une conversation existe déjà avec le contact.
     *
     * Réponse : liste d’utilisateurs (pas d’objets conversation). Pour l’aperçu du
     * dernier message par conversation, utiliser l’endpoint getConversations (clé `last_message`).
     */
    public function searchUsersForChat(Request $request)
    {
        /** @var User $user */
        $user = $request->user();

        $q = trim((string) $request->query('q', ''));
        if (mb_strlen($q) < 1) {
            return response()->json([]);
        }

        $like = '%'.addcslashes($q, '%_\\').'%';

        $query = $this->chatEligibleUsersBaseQuery($user);
        $query->where(function (Builder $b) use ($like) {
            $b->where('email', 'like', $like)
                ->orWhere('alias', 'like', $like)
                ->orWhere('nom', 'like', $like)
                ->orWhere('prenom', 'like', $like);
        });

        $users = $query->orderBy('email')->limit(25)->get();

        return response()->json(
            $users->map(fn (User $u) => $this->mapUserToChatContactJson($u, $user))->values()
        );
    }

    /**
     * Crée la conversation support (si besoin) et envoie le premier message en une seule requête.
     */
    public function createConversationAndSendMessage(Request $request)
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validate([
            'recipient_user_id' => ['required', 'integer', 'exists:users,id'],
            'content' => ['nullable', 'string'],
            'type' => ['required', 'string', 'in:text,media'],
            'internal_type' => ['nullable', 'string', 'max:100'],
            'media_type' => ['nullable', 'string', 'max:20'],
            'media_url' => ['nullable', 'string'],
            'thumbnail_url' => ['nullable', 'string'],
            'media_width' => ['nullable', 'integer', 'min:1'],
            'media_height' => ['nullable', 'integer', 'min:1'],
            'blurhash' => ['nullable', 'string'],
            'metadata' => ['nullable', 'array'],
            'client_id' => ['nullable', 'string', 'max:100'],
        ]);

        if ((int) $validated['recipient_user_id'] === (int) $user->id) {
            return response()->json(['message' => 'Destinataire invalide.'], 422);
        }

        $recipient = User::findOrFail((int) $validated['recipient_user_id']);

        $roles = [
            (string) ($user->role ?? ''),
            (string) ($recipient->role ?? ''),
        ];
        $adminCount = collect($roles)->filter(fn ($r) => $r === 'admin')->count();
        if ($adminCount !== 1) {
            return response()->json(['message' => 'Conversation support invalide : il faut exactement un admin et un client.'], 422);
        }

        $conversation = $this->findOrCreateSupportConversation($user, $recipient);

        if ($validated['type'] === 'text' && empty($validated['content'])) {
            return response()->json([
                'message' => 'Le contenu du message est requis pour un message texte.',
            ], 422);
        }

        if ($validated['type'] === 'media' && empty($validated['media_url'])) {
            return response()->json([
                'message' => 'media_url est requis pour un message média.',
            ], 422);
        }

        $meta = $validated['metadata'] ?? [];
        if (! empty($validated['client_id'] ?? null)) {
            $meta['client_id'] = $validated['client_id'];
        }

        $message = Message::create([
            'conversation_id' => $conversation->id,
            'user_id' => $user->id,
            'type' => $validated['type'],
            'internal_type' => $validated['internal_type'] ?? null,
            'content' => $validated['content'] ?? null,
            'media_type' => $validated['media_type'] ?? null,
            'media_url' => $validated['media_url'] ?? null,
            'thumbnail_url' => $validated['thumbnail_url'] ?? null,
            'media_width' => $validated['media_width'] ?? null,
            'media_height' => $validated['media_height'] ?? null,
            'blurhash' => $validated['blurhash'] ?? null,
            'metadata' => ! empty($meta) ? $meta : null,
        ]);

        try {
            broadcast(new MessageSent($message))->toOthers();
        } catch (\Throwable $e) {
            Log::error('Erreur lors du broadcast du message', [
                'message_id' => $message->id,
                'conversation_id' => $message->conversation_id,
                'error' => $e->getMessage(),
            ]);
        }

        $recipientUser = $conversation->otherParticipant((int) $user->id);
        if ($recipientUser) {
            SendChatMessageNotification::dispatch($message, $recipientUser);
        }

        $metaOut = $message->metadata;

        return response()->json([
            'conversation_id' => $conversation->id,
            'id' => $message->id,
            'client_id' => MessageMetadataHelper::clientId($metaOut),
            'content' => $message->content,
            'type' => $message->type,
            'internal_type' => $message->internal_type,
            'media_type' => $message->media_type,
            'media_url' => $message->media_url,
            'thumbnail_url' => $message->thumbnail_url,
            'media_width' => $message->media_width,
            'media_height' => $message->media_height,
            'blurhash' => $message->blurhash,
            'metadata' => MessageMetadataHelper::forJson($metaOut),
            'is_read' => (bool) $message->is_read,
            'is_pinned' => (bool) $message->is_pinned,
            'is_deleted' => (bool) $message->is_deleted,
            'sender_id' => $message->user_id,
            'created_at' => $message->created_at?->toISOString(),
            'updated_at' => $message->updated_at?->toISOString(),
        ], 201);
    }

    /**
     * Liste les conversations de l'utilisateur connecté avec le dernier message.
     */
    public function getConversations(Request $request)
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validate([
            'since' => ['nullable', 'string', 'max:64'],
            'q' => ['nullable', 'string', 'max:255'],
        ]);

        $search = trim((string) ($validated['q'] ?? ''));

        $query = Conversation::query();

        // Si ce n'est pas un admin, on limite aux conversations support (l'autre participant doit être admin)
        if ($user->role !== 'admin') {
            $query->where(function ($q) use ($user) {
                $q->where(function ($q2) use ($user) {
                    $q2->where('user_one_id', $user->id)
                        ->whereHas('userTwo', function ($u) {
                            $u->where('role', 'admin');
                        });
                })->orWhere(function ($q2) use ($user) {
                    $q2->where('user_two_id', $user->id)
                        ->whereHas('userOne', function ($u) {
                            $u->where('role', 'admin');
                        });
                });
            });
        }

        if ($search !== '') {
            $this->applyConversationParticipantSearch($query, $user, $search);
        } elseif (! empty($validated['since'])) {
            try {
                $since = \Illuminate\Support\Carbon::parse($validated['since']);
                $query->where('updated_at', '>', $since);
            } catch (\Throwable $e) {
                // since invalide : ignorer le filtre
            }
        }

        $conversations = $query
            ->with([
                'userOne',
                'userTwo',
                'lastMessage',
            ])
            ->orderByDesc('updated_at')
            ->get();

        $data = $conversations->map(function (Conversation $conversation) use ($user) {
            $lastMessage = $conversation->lastMessage;

            $participant = null;
            if ($user->role === 'admin') {
                // Pour un admin : l'autre participant est le client (celui qui n'est pas admin)
                $one = $conversation->userOne;
                $two = $conversation->userTwo;
                if ($one && $two) {
                    $participant = $one->role === 'admin' ? $two : $one;
                } else {
                    // Un des deux utilisateurs manquant (supprimé ou non renseigné) : prendre celui qui reste
                    $participant = $one ?? $two;
                    if ($participant && $participant->role === 'admin') {
                        $participant = null; // on n'affiche pas l'admin comme "client"
                    }
                }
            } else {
                $participant = $conversation->otherParticipant($user->id);
            }

            // Nom d'affichage pour le client (fallback si nom/prenom vides)
            $participantPayload = null;
            if ($participant) {
                $displayName = trim(($participant->nom ?? '') . ' ' . ($participant->prenom ?? ''));
                if ($displayName === '') {
                    $displayName = $participant->alias ?? $participant->email ?? 'Client #' . $participant->id;
                }
                $photoUrl = $this->userProfilePhotoPublicUrl($participant);
                $participantPayload = [
                    'id' => $participant->id,
                    'nom' => $participant->nom ?? '',
                    'prenom' => $participant->prenom ?? '',
                    'alias' => $participant->alias ?? '',
                    'email' => $participant->email ?? '',
                    'role' => $participant->role ?? 'user',
                    'display_name' => $displayName,
                    'profile_photo_url' => $photoUrl,
                    'profile_image' => $photoUrl,
                    'created_at' => $participant->created_at?->toISOString(),
                ];
            }

            // Compte des messages non lus (simples, à optimiser si besoin plus tard)
            $unreadCount = Message::where('conversation_id', $conversation->id)
                ->where('user_id', '!=', $user->id)
                ->where('is_read', false)
                ->count();

            return [
                'id' => $conversation->id,
                'updated_at' => $conversation->updated_at?->toISOString(),
                'last_message' => $lastMessage ? [
                    'id' => $lastMessage->id,
                    'content' => $lastMessage->content,
                    'type' => $lastMessage->type,
                    'internal_type' => $lastMessage->internal_type,
                    'media_type' => $lastMessage->media_type,
                    'media_url' => $lastMessage->media_url,
                    'thumbnail_url' => $lastMessage->thumbnail_url,
                    'media_width' => $lastMessage->media_width,
                    'media_height' => $lastMessage->media_height,
                    'blurhash' => $lastMessage->blurhash,
                    'metadata' => $lastMessage->metadata,
                    'is_read' => (bool) $lastMessage->is_read,
                    'is_pinned' => (bool) $lastMessage->is_pinned,
                    'is_deleted' => (bool) $lastMessage->is_deleted,
                    'sender_id' => $lastMessage->user_id,
                    'created_at' => $lastMessage->created_at?->toISOString(),
                ] : null,
                'participant' => $participantPayload,
                'unread_count' => $unreadCount,
            ];
        });

        return response()->json($data);
    }

    /**
     * Pour l'admin : récupère ou crée une conversation avec un client donné.
     * Utilisé depuis /utilisateur quand l'admin clique sur "Démarrer une conversation".
     *
     * Le segment de route doit s'appeler {user} et le paramètre de méthode $user,
     * sinon la résolution implicite ne s'applique pas (User vide, id null → 0 en base).
     */
    public function getOrCreateConversationWithUser(Request $request, User $user)
    {
        /** @var User $admin */
        $admin = $request->user();

        if ($admin->role !== 'admin') {
            return response()->json(['message' => 'Non autorisé.'], 403);
        }

        // Règle stricte support: exactement 1 admin parmi les 2 participants
        $roles = [
            (string) ($admin->role ?? ''),
            (string) ($user->role ?? ''),
        ];
        $adminCount = collect($roles)->filter(fn ($r) => $r === 'admin')->count();
        if ($adminCount !== 1) {
            return response()->json(['message' => 'Conversation support invalide : il faut exactement un admin et un client.'], 422);
        }

        // Unicité garantie par tri (min/max) + unique index sur (user_one_id, user_two_id)
        $conversation = $this->findOrCreateSupportConversation($admin, $user);

        $displayName = trim(($user->nom ?? '') . ' ' . ($user->prenom ?? ''));
        if ($displayName === '') {
            $displayName = $user->alias ?? $user->email ?? 'Client #'.$user->id;
        }

        $photoUrl = $this->userProfilePhotoPublicUrl($user);

        return response()->json([
            'conversation_id' => $conversation->id,
            'participant' => [
                'id' => $user->id,
                'nom' => $user->nom ?? '',
                'prenom' => $user->prenom ?? '',
                'alias' => $user->alias ?? '',
                'email' => $user->email ?? '',
                'role' => $user->role ?? 'user',
                'display_name' => $displayName,
                'profile_photo_url' => $photoUrl,
                'profile_image' => $photoUrl,
            ],
        ]);
    }

    /**
     * Messages d'une conversation.
     * Sécurité : l'utilisateur doit appartenir à la conversation, sauf s'il est admin.
     * Implémentation simplifiée (get() sans pagination) pour faciliter le debug local.
     */
    public function getMessages(Request $request, Conversation $conversation)
    {
        try {
            /** @var User $user */
            $user = $request->user();

            $this->assertSupportAccess($user, $conversation);

            $validated = $request->validate([
                'after_id' => ['nullable', 'integer', 'min:1'],
                'before_id' => ['nullable', 'integer', 'min:1'],
                'limit' => ['nullable', 'integer', 'min:1', 'max:100'],
                'updated_after' => ['nullable', 'date'],
            ]);

            $baseQuery = Message::with('user')
                ->where('conversation_id', $conversation->id);

            // Pagination « plus anciens » : messages avec id < before_id, tri chronologique croissant côté JSON
            if (! empty($validated['before_id'])) {
                $lim = isset($validated['limit']) ? (int) $validated['limit'] : 50;
                $lim = max(1, min($lim, 100));

                $batch = (clone $baseQuery)
                    ->where('id', '<', (int) $validated['before_id'])
                    ->orderBy('id', 'desc')
                    ->limit($lim)
                    ->get()
                    ->sortBy('id')
                    ->values();

                $data = $batch->map(function (Message $message) {
                    return $this->formatMessagePayload($message);
                });

                return response()->json([
                    'conversation_id' => $conversation->id,
                    'partner_last_seen_message_id' => $this->partnerLastSeenMessageIdForViewer($conversation, $user),
                    'data' => $data,
                ]);
            }

            $query = clone $baseQuery;

            $afterId = ! empty($validated['after_id']) ? (int) $validated['after_id'] : null;
            $updatedAfter = ! empty($validated['updated_after'])
                ? Carbon::parse($validated['updated_after'])
                : null;

            if ($afterId !== null && $updatedAfter !== null) {
                $query->where(function (Builder $q) use ($afterId, $updatedAfter) {
                    $q->where('id', '>', $afterId)
                        ->orWhere('updated_at', '>', $updatedAfter);
                });
            } elseif ($afterId !== null) {
                $query->where('id', '>', $afterId);
            } elseif ($updatedAfter !== null) {
                $query->where('updated_at', '>', $updatedAfter);
            }

            $messages = $query
                ->orderBy('created_at', 'asc')
                ->get();

            $data = $messages->map(function (Message $message) {
                return $this->formatMessagePayload($message);
            });

            return response()->json([
                'conversation_id' => $conversation->id,
                'partner_last_seen_message_id' => $this->partnerLastSeenMessageIdForViewer($conversation, $user),
                'data' => $data,
            ]);
        } catch (\Exception $e) {
            // Log de l'erreur exacte pour le debug local
            Log::error('Erreur Chat API: '.$e->getMessage(), [
                'conversation_id' => $conversation->id ?? null,
            ]);

            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    /**
     * Envoi d'un message dans une conversation existante.
     * Sécurité : l'utilisateur doit appartenir à la conversation, sauf s'il est admin.
     */
    public function sendMessage(Request $request)
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validate([
            'conversation_id' => ['required', 'exists:conversations,id'],
            'content' => ['nullable', 'string'],
            'type' => ['required', 'string', 'in:text,media'],
            'internal_type' => ['nullable', 'string', 'max:100'],
            'media_type' => ['nullable', 'string', 'max:20'],
            'media_url' => ['nullable', 'string'],
            'thumbnail_url' => ['nullable', 'string'],
            'media_width' => ['nullable', 'integer', 'min:1'],
            'media_height' => ['nullable', 'integer', 'min:1'],
            'blurhash' => ['nullable', 'string'],
            'metadata' => ['nullable', 'array'],
            'client_id' => ['nullable', 'string', 'max:100'],
        ]);

        $conversation = Conversation::findOrFail($validated['conversation_id']);

        $this->assertSupportAccess($user, $conversation);

        if ($validated['type'] === 'text' && empty($validated['content'])) {
            return response()->json([
                'message' => 'Le contenu du message est requis pour un message texte.',
            ], 422);
        }

        if ($validated['type'] === 'media' && empty($validated['media_url'])) {
            return response()->json([
                'message' => 'media_url est requis pour un message média.',
            ], 422);
        }

        $meta = $validated['metadata'] ?? [];
        if (! empty($validated['client_id'] ?? null)) {
            $meta['client_id'] = $validated['client_id'];
        }

        $message = Message::create([
            'conversation_id' => $conversation->id,
            'user_id' => $user->id,
            'type' => $validated['type'],
            'internal_type' => $validated['internal_type'] ?? null,
            'content' => $validated['content'] ?? null,
            'media_type' => $validated['media_type'] ?? null,
            'media_url' => $validated['media_url'] ?? null,
            'thumbnail_url' => $validated['thumbnail_url'] ?? null,
            'media_width' => $validated['media_width'] ?? null,
            'media_height' => $validated['media_height'] ?? null,
            'blurhash' => $validated['blurhash'] ?? null,
            'metadata' => ! empty($meta) ? $meta : null,
        ]);

        // Diffusion en temps réel aux autres clients connectés
        try {
            
            broadcast(new MessageSent($message))->toOthers();
        } catch (\Throwable $e) {
            Log::error('Erreur lors du broadcast du message', [
                'message_id' => $message->id,
                'conversation_id' => $message->conversation_id,
                'error' => $e->getMessage(),
            ]);
        }

        // Push FCM asynchrone via queue
        $recipient = $conversation->otherParticipant((int) $user->id);
        
        if ($recipient) {
            
            SendChatMessageNotification::dispatch($message, $recipient);
        }

        $metaOut = $message->metadata;

        return response()->json([
            'id' => $message->id,
            'conversation_id' => $message->conversation_id,
            'client_id' => MessageMetadataHelper::clientId($metaOut),
            'content' => $message->content,
            'type' => $message->type,
            'internal_type' => $message->internal_type,
            'media_type' => $message->media_type,
            'media_url' => $message->media_url,
            'thumbnail_url' => $message->thumbnail_url,
            'media_width' => $message->media_width,
            'media_height' => $message->media_height,
            'blurhash' => $message->blurhash,
            'metadata' => MessageMetadataHelper::forJson($metaOut),
            'is_read' => (bool) $message->is_read,
            'is_pinned' => (bool) $message->is_pinned,
            'is_deleted' => (bool) $message->is_deleted,
            'sender_id' => $message->user_id,
            'created_at' => $message->created_at?->toISOString(),
            'updated_at' => $message->updated_at?->toISOString(),
        ], 201);
    }

    /**
     * Marque tous les messages d'une conversation comme lus pour l'utilisateur courant.
     * Seuls les messages dont l'expéditeur n'est pas l'utilisateur actuel sont mis à jour.
     */
    /**
     * Indique que l’utilisateur est en train d’écrire : diffusion Pusher côté serveur (pas d’événements client).
     */
    public function broadcastTyping(Request $request, Conversation $conversation)
    {
        /** @var User $user */
        $user = $request->user();

        $this->assertSupportAccess($user, $conversation);

        $validated = $request->validate([
            'is_typing' => ['required', 'boolean'],
        ]);

        broadcast(new UserTyping(
            (int) $conversation->id,
            (int) $user->id,
            (bool) $validated['is_typing'],
        ))->toOthers();

        return response()->noContent();
    }

    public function markConversationRead(Request $request, Conversation $conversation)
    {
        /** @var User $user */
        $user = $request->user();

        $this->assertSupportAccess($user, $conversation);

        $otherId = (int) $conversation->user_one_id === (int) $user->id
            ? (int) $conversation->user_two_id
            : (int) $conversation->user_one_id;

        // Messages de l’interlocuteur non encore lus : marquage en masse (id ≤ dernier non lu), une transaction.
        DB::transaction(function () use ($conversation, $otherId): void {
            $lastUnreadId = Message::query()
                ->where('conversation_id', $conversation->id)
                ->where('user_id', $otherId)
                ->where('is_read', false)
                ->max('id');

            if ($lastUnreadId !== null) {
                Message::query()
                    ->where('conversation_id', $conversation->id)
                    ->where('user_id', $otherId)
                    ->where('id', '<=', $lastUnreadId)
                    ->where('is_read', false)
                    ->update(['is_read' => true, 'updated_at' => now()]);
            }
        });

        $lastReadMessageId = Message::query()
            ->where('conversation_id', $conversation->id)
            ->where('user_id', $otherId)
            ->where('is_read', true)
            ->max('id');

        try {
            broadcast(new ConversationRead(
                (int) $conversation->id,
                (int) $user->id,
                $lastReadMessageId !== null ? (int) $lastReadMessageId : null,
            ))->toOthers();
        } catch (\Throwable $e) {
            Log::warning('Broadcast ConversationRead échoué', [
                'conversation_id' => $conversation->id,
                'error' => $e->getMessage(),
            ]);
        }

        // Recalcule le nombre de messages non lus pour cette conversation
        $unreadCount = Message::where('conversation_id', $conversation->id)
            ->where('user_id', '!=', $user->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'success' => true,
            'unread_count' => $unreadCount,
            'last_read_message_id' => $lastReadMessageId,
        ]);
    }

    /**
     * Upload d'un média/document pour un message de chat.
     * Retourne un payload compatible Flutter.
     */
    public function uploadMedia(Request $request)
    {
        $validated = $request->validate([
            'file' => ['required', 'file', 'max:20480'], // 20MB
        ]);

        /** @var \Illuminate\Http\UploadedFile $file */
        $file = $validated['file'];

        $mime = (string) ($file->getMimeType() ?? '');
        $extension = strtolower((string) $file->getClientOriginalExtension());
        $allowedExtensions = [
            'jpeg', 'png', 'jpg', 'gif', 'webp',
            'mp4', 'mov',
            'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'zip', 'rar', 'csv',
        ];
        $allowedMimeTypes = [
            'image/jpeg',
            'image/png',
            'image/gif',
            'image/webp',
            'video/mp4',
            'video/quicktime',
            'application/pdf',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'application/vnd.ms-excel',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'text/plain',
            'text/csv',
            'application/csv',
            'application/zip',
            'application/x-zip-compressed',
            'application/x-rar-compressed',
            'application/vnd.rar',
            'application/octet-stream',
        ];
        if (! in_array($extension, $allowedExtensions, true)) {
            return response()->json([
                'message' => 'Extension de fichier non supportée.',
            ], 422);
        }
        if ($mime !== '' && ! in_array($mime, $allowedMimeTypes, true) && ! str_starts_with($mime, 'image/')) {
            return response()->json([
                'message' => 'Type MIME de fichier non supporté.',
            ], 422);
        }

        $originalName = $file->getClientOriginalName();
        $safeExt = $extension !== '' ? ('.' . strtolower($extension)) : '';
        $filename = now()->format('YmdHis') . '_' . Str::random(16) . $safeExt;

        $path = $file->storePubliclyAs('chat_medias', $filename, 'public');

        $absolutePath = Storage::disk('public')->path($path);
        $publicUrl = asset(Storage::disk('public')->url($path));

        $width = null;
        $height = null;
        $blurhash = null;

        $isImage = in_array($extension, ['jpeg', 'jpg', 'png', 'gif', 'webp'], true);
        $isVideo = in_array($extension, ['mp4', 'mov'], true);

        if ($isImage) {
            try {
                $img = Image::read($absolutePath);
                $width = $img->width();
                $height = $img->height();
            } catch (\Throwable $e) {
                Log::warning('Impossible de lire les dimensions de l’image', [
                    'path' => $path,
                    'error' => $e->getMessage(),
                ]);
            }

            try {
                // 4x3, maxSize=32 (cohérent avec le client Flutter et l’ancienne implémentation)
                $blurhash = app('blurhash')
                    ->setComponentX(4)
                    ->setComponentY(3)
                    ->setMaxSize(32)
                    ->encode($absolutePath);
            } catch (\Throwable $e) {
                Log::warning('Impossible de générer le blurhash', [
                    'path' => $path,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        // Colonne DB `media_type` varchar(20) : on conserve un type court côté message.
        $typeOut = $isImage ? 'image' : ($isVideo ? 'video' : 'document');

        $storedPath = str_replace('\\', '/', $path);
        $relativeMediaUrl = str_starts_with($storedPath, 'storage/')
            ? $storedPath
            : 'storage/'.$storedPath;

        return response()->json([
            'url' => $publicUrl,
            'relative_media_url' => $relativeMediaUrl,
            'type' => $typeOut,
            'mime' => $mime,
            'width' => $width,
            'height' => $height,
            'blurhash' => $blurhash,
            'size' => (int) $file->getSize(),
            'originalName' => $originalName,
        ]);
    }
}
