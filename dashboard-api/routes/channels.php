<?php

use Illuminate\Support\Facades\Broadcast;
use App\Models\Conversation;

/*
|--------------------------------------------------------------------------
| Broadcast Channels
|--------------------------------------------------------------------------
|
| Here you may register all of the event broadcasting channels that your
| application supports. The given channel authorization callbacks are
| used to check if an authenticated user can listen to the channel.
|
*/

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

Broadcast::channel('chat.admin.{adminId}', function ($user, $adminId) {
    return ($user->role ?? '') === 'admin'
        && (int) $user->id === (int) $adminId;
});

Broadcast::channel('chat.inbox.{userId}', function ($user, $userId) {
    return (int) $user->id === (int) $userId;
});

Broadcast::channel('chat.{conversationId}', function ($user, $conversationId) {
    // Tous les rôles doivent être participants de la conversation
    $conversation = Conversation::find($conversationId);

    if (! $conversation) {
        return false;
    }

    return $conversation->hasParticipant((int) $user->id);
});

/*
| Présence globale (liste conversations, pastilles en ligne).
| Côté client Pusher : canal `presence-app` (nom normalisé : `app`).
| Laravel 10 : utiliser Broadcast::channel + retour tableau (pas Broadcast::presence).
*/
Broadcast::channel('app', function ($user) {
    if (! $user) {
        return false;
    }

    $label = trim(($user->prenom ?? '').' '.($user->nom ?? ''));
    if ($label === '') {
        $label = $user->alias ?? $user->email ?? 'Utilisateur';
    }

    return [
        'id' => (string) $user->id,
        'name' => $label,
    ];
});
