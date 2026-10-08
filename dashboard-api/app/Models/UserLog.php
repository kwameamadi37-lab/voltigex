<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'action',
        'event_type',
        'description',
        'metadata',
        'ip_address',
        'user_agent',
        'session_id'
    ];

    protected $casts = [
        'metadata' => 'array',
    ];

    /**
     * Relation avec l'utilisateur
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Créer un log d'événement
     */
    public static function log($action, $eventType = 'info', $description = null, $userId = null, $metadata = [], $request = null)
    {
        return self::create([
            'user_id' => $userId,
            'action' => $action,
            'event_type' => $eventType,
            'description' => $description,
            'metadata' => $metadata,
            'ip_address' => $request ? $request->ip() : null,
            'user_agent' => $request ? $request->userAgent() : null,
            'session_id' => $request && $request->hasSession() ? $request->session()->getId() : null,
        ]);
    }

    /**
     * Scope pour les événements de succès
     */
    public function scopeSuccess($query)
    {
        return $query->where('event_type', 'success');
    }

    /**
     * Scope pour les événements d'échec
     */
    public function scopeFailure($query)
    {
        return $query->where('event_type', 'failure');
    }

    /**
     * Scope pour une action spécifique
     */
    public function scopeAction($query, $action)
    {
        return $query->where('action', $action);
    }
}
