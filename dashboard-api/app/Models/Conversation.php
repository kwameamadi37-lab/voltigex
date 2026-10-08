<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Conversation extends Model
{
    protected $fillable = [
        'user_one_id',
        'user_two_id',
    ];

    /**
     * Normalise la paire de participants pour garantir l'unicité:
     * le plus petit ID devient user_one_id, le plus grand user_two_id.
     *
     * @return array{0:int,1:int}
     */
    public static function normalizeParticipantIds(int $a, int $b): array
    {
        return $a <= $b ? [$a, $b] : [$b, $a];
    }

    protected static function booted(): void
    {
        $normalize = function (self $conversation): void {
            $a = (int) $conversation->user_one_id;
            $b = (int) $conversation->user_two_id;
            [$min, $max] = self::normalizeParticipantIds($a, $b);
            $conversation->user_one_id = $min;
            $conversation->user_two_id = $max;
        };

        static::creating($normalize);
        static::updating($normalize);
    }

    /**
     * Premier participant.
     */
    public function userOne(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_one_id');
    }

    /**
     * Second participant.
     */
    public function userTwo(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_two_id');
    }

    /**
     * Messages de la conversation.
     */
    public function messages(): HasMany
    {
        return $this->hasMany(Message::class)->orderBy('created_at');
    }

    /**
     * Dernier message (pour inbox / API `last_message`).
     */
    public function lastMessage(): HasOne
    {
        return $this->hasOne(Message::class)->latestOfMany('created_at');
    }

    /**
     * Retourne l'autre participant par rapport à l'utilisateur donné.
     */
    public function otherParticipant(int $userId): ?User
    {
        if ((int) $this->user_one_id === $userId) {
            return $this->userTwo;
        }
        if ((int) $this->user_two_id === $userId) {
            return $this->userOne;
        }
        return null;
    }

    /**
     * Vérifie si l'utilisateur fait partie de la conversation.
     */
    public function hasParticipant(int $userId): bool
    {
        return (int) $this->user_one_id === $userId || (int) $this->user_two_id === $userId;
    }
}
