<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Message extends Model
{
    protected $fillable = [
        'conversation_id',
        'user_id',
        'type',
        'internal_type',
        'content',
        'media_type',
        'media_url',
        'thumbnail_url',
        'media_width',
        'media_height',
        'blurhash',
        'metadata',
        'is_read',
        'is_pinned',
        'is_deleted',
    ];

    protected $casts = [
        'is_read' => 'boolean',
        'is_pinned' => 'boolean',
        'is_deleted' => 'boolean',
        'metadata' => 'array',
    ];

    /**
     * Met à jour automatiquement la date de mise à jour de la conversation.
     *
     * @var array
     */
    protected $touches = ['conversation'];

    /**
     * Conversation du message.
     */
    public function conversation(): BelongsTo
    {
        return $this->belongsTo(Conversation::class);
    }

    /**
     * Utilisateur expéditeur.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
