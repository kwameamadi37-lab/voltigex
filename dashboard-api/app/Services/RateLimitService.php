<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserVerification;
use Carbon\Carbon;
use Illuminate\Support\Facades\Cache;

class RateLimitService
{
    /**
     * Vérifier si un utilisateur peut envoyer un nouveau code de vérification
     *
     * @param User $user
     * @param string $type
     * @return array
     */
    public static function canSendVerificationCode(User $user, string $type = 'email')
    {
        $cacheKey = "verification_limit_{$user->id}_{$type}";
        $attempts = Cache::get($cacheKey, []);
        
        // Filtrer les tentatives des dernières 60 minutes
        $recentAttempts = array_filter($attempts, function($timestamp) {
            return Carbon::parse($timestamp)->gt(Carbon::now()->subHour());
        });
        
        if (count($recentAttempts) >= 3) {
            $nextAllowed = Carbon::parse(max($recentAttempts))->addHour();
            return [
                'allowed' => false,
                'message' => 'Limite de renvoi atteinte. Réessayez dans ' . $nextAllowed->diffForHumans(),
                'retry_after' => $nextAllowed->diffInSeconds()
            ];
        }
        
        return ['allowed' => true];
    }
    
    /**
     * Enregistrer une tentative d'envoi de code
     *
     * @param User $user
     * @param string $type
     */
    public static function recordVerificationAttempt(User $user, string $type = 'email')
    {
        $cacheKey = "verification_limit_{$user->id}_{$type}";
        $attempts = Cache::get($cacheKey, []);
        
        $attempts[] = Carbon::now()->toISOString();
        
        // Garder seulement les 10 dernières tentatives
        $attempts = array_slice($attempts, -10);
        
        Cache::put($cacheKey, $attempts, 3600); // Cache pour 1 heure
    }
    
    /**
     * Vérifier si un utilisateur peut se connecter
     *
     * @param string $email
     * @param string $ip
     * @return array
     */
    public static function canLogin(string $email, string $ip)
    {
        $emailKey = "login_limit_email_{$email}";
        $ipKey = "login_limit_ip_{$ip}";
        
        $emailAttempts = Cache::get($emailKey, 0);
        $ipAttempts = Cache::get($ipKey, 0);
        
        // Limite par email : 5 tentatives par heure
        if ($emailAttempts >= 5) {
            return [
                'allowed' => false,
                'message' => 'Trop de tentatives de connexion. Réessayez dans 1 heure.',
                'type' => 'email_limit'
            ];
        }
        
        // Limite par IP : 20 tentatives par heure
        if ($ipAttempts >= 20) {
            return [
                'allowed' => false,
                'message' => 'Trop de tentatives de connexion depuis cette adresse IP.',
                'type' => 'ip_limit'
            ];
        }
        
        return ['allowed' => true];
    }
    
    /**
     * Enregistrer une tentative de connexion échouée
     *
     * @param string $email
     * @param string $ip
     */
    public static function recordFailedLogin(string $email, string $ip)
    {
        $emailKey = "login_limit_email_{$email}";
        $ipKey = "login_limit_ip_{$ip}";
        
        Cache::increment($emailKey);
        Cache::increment($ipKey);
        
        // Expiration après 1 heure
        Cache::put($emailKey, Cache::get($emailKey), 3600);
        Cache::put($ipKey, Cache::get($ipKey), 3600);
    }
    
    /**
     * Réinitialiser les compteurs après une connexion réussie
     *
     * @param string $email
     * @param string $ip
     */
    public static function resetLoginAttempts(string $email, string $ip)
    {
        $emailKey = "login_limit_email_{$email}";
        $ipKey = "login_limit_ip_{$ip}";
        
        Cache::forget($emailKey);
        Cache::forget($ipKey);
    }
    
    /**
     * Obtenir les statistiques de limitation pour un utilisateur
     *
     * @param User $user
     * @return array
     */
    public static function getUserRateLimitStats(User $user)
    {
        $emailKey = "verification_limit_{$user->id}_email";
        $phoneKey = "verification_limit_{$user->id}_phone";
        
        $emailAttempts = Cache::get($emailKey, []);
        $phoneAttempts = Cache::get($phoneKey, []);
        
        return [
            'email_attempts_last_hour' => count(array_filter($emailAttempts, function($timestamp) {
                return Carbon::parse($timestamp)->gt(Carbon::now()->subHour());
            })),
            'phone_attempts_last_hour' => count(array_filter($phoneAttempts, function($timestamp) {
                return Carbon::parse($timestamp)->gt(Carbon::now()->subHour());
            })),
            'email_can_send' => self::canSendVerificationCode($user, 'email')['allowed'],
            'phone_can_send' => self::canSendVerificationCode($user, 'phone')['allowed']
        ];
    }
}
