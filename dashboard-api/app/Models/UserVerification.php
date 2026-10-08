<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class UserVerification extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'email',
        'phone',
        'verification_code',
        'type',
        'expires_at',
        'is_used',
        'attempts',
        'last_attempt_at',
        'cooldown_until'
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'is_used' => 'boolean',
        'last_attempt_at' => 'datetime',
        'cooldown_until' => 'datetime'
    ];

    /**
     * Relation avec l'utilisateur
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Vérifier si le code est expiré
     */
    public function isExpired()
    {
        return $this->expires_at < Carbon::now();
    }

    /**
     * Vérifier si le code est valide (non utilisé et non expiré)
     */
    public function isValid()
    {
        return !$this->is_used && !$this->isExpired() && !$this->isInCooldown();
    }

    /**
     * Vérifier si le code est en période de cooldown
     */
    public function isInCooldown()
    {
        return $this->cooldown_until && $this->cooldown_until > Carbon::now();
    }

    /**
     * Vérifier si le nombre maximum de tentatives est atteint
     */
    public function hasMaxAttempts()
    {
        return $this->attempts >= 3;
    }

    /**
     * Incrémenter le nombre de tentatives
     */
    public function incrementAttempts()
    {
        $this->increment('attempts');
        $this->update(['last_attempt_at' => Carbon::now()]);
        
        // Si 3 tentatives atteintes, mettre en cooldown
        if ($this->attempts >= 3) {
            $this->update(['cooldown_until' => Carbon::now()->addMinutes(15)]);
        }
    }

    /**
     * Réinitialiser les tentatives
     */
    public function resetAttempts()
    {
        $this->update([
            'attempts' => 0,
            'last_attempt_at' => null,
            'cooldown_until' => null
        ]);
    }

    /**
     * Marquer le code comme utilisé
     */
    public function markAsUsed()
    {
        $this->update(['is_used' => true]);
    }

    /**
     * Générer un code de vérification à 6 chiffres
     */
    public static function generateCode()
    {
        return str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
    }

    /**
     * Scope pour les codes non expirés
     */
    public function scopeNotExpired($query)
    {
        return $query->where('expires_at', '>', Carbon::now());
    }

    /**
     * Scope pour les codes non utilisés
     */
    public function scopeNotUsed($query)
    {
        return $query->where('is_used', false);
    }

    /**
     * Scope pour les codes valides
     */
    public function scopeValid($query)
    {
        return $query->notExpired()->notUsed();
    }
}
