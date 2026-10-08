<?php

namespace App\Helpers;

use Twilio\Rest\Client;
use Illuminate\Support\Facades\Log;

class SmsHelper
{
    /**
     * Envoyer un SMS via Twilio (pour les numéros non-africains) ou simulation (pour le Bénin)
     *
     * @param string $phoneNumber
     * @param string $message
     * @return bool
     */
    public static function sendSms($phoneNumber, $message)
    {
        // Déterminer si c'est un numéro africain (Bénin)
        $isAfricanNumber = self::isAfricanNumber($phoneNumber);
        
        // Pour les numéros africains (Bénin) ou en mode développement, simuler l'envoi
        if ($isAfricanNumber || config('app.env') === 'local' || config('app.env') === 'testing') {
            $type = $isAfricanNumber ? 'Bénin (simulé)' : 'Développement (simulé)';
            Log::info("SMS {$type} pour {$phoneNumber}: {$message}");
            return true;
        }

        // Pour les numéros non-africains, utiliser Twilio
        try {
            $accountSid = config('services.twilio.account_sid');
            $authToken = config('services.twilio.auth_token');
            $fromNumber = config('services.twilio.from_number');

            if (!$accountSid || !$authToken || !$fromNumber) {
                Log::error('Configuration Twilio manquante');
                return false;
            }

            $client = new Client($accountSid, $authToken);

            // Nettoyer le numéro de téléphone
            $cleanPhoneNumber = self::cleanPhoneNumber($phoneNumber);

            $message = $client->messages->create(
                $cleanPhoneNumber,
                [
                    'from' => $fromNumber,
                    'body' => $message
                ]
            );

            Log::info('SMS Twilio envoyé avec succès', [
                'to' => $cleanPhoneNumber,
                'message_sid' => $message->sid,
                'country' => self::getCountryFromPhone($phoneNumber)
            ]);

            return true;

        } catch (\Exception $e) {
            Log::error('Erreur lors de l\'envoi du SMS Twilio', [
                'phone' => $phoneNumber,
                'error' => $e->getMessage(),
                'country' => self::getCountryFromPhone($phoneNumber)
            ]);

            return false;
        }
    }

    /**
     * Envoyer un code de vérification par SMS
     *
     * @param string $phoneNumber
     * @param string $verificationCode
     * @return bool
     */
    public static function sendVerificationCode($phoneNumber, $verificationCode)
    {
        $message = "Votre code de vérification MyBank est : {$verificationCode}\n\nCe code expire dans 10 minutes. Ne le partagez jamais.";
        
        return self::sendSms($phoneNumber, $message);
    }

    /**
     * Nettoyer le numéro de téléphone pour Twilio
     *
     * @param string $phoneNumber
     * @return string
     */
    private static function cleanPhoneNumber($phoneNumber)
    {
        // Supprimer tous les caractères non numériques sauf le +
        $cleaned = preg_replace('/[^\d+]/', '', $phoneNumber);
        
        // Si le numéro commence par 0, le remplacer par +33
        if (strpos($cleaned, '0') === 0) {
            $cleaned = '+33' . substr($cleaned, 1);
        }
        
        // Si le numéro ne commence pas par +, ajouter +33
        if (!str_starts_with($cleaned, '+')) {
            $cleaned = '+33' . $cleaned;
        }
        
        return $cleaned;
    }

    /**
     * Valider le format du numéro de téléphone
     *
     * @param string $phoneNumber
     * @return bool
     */
    public static function isValidPhoneNumber($phoneNumber)
    {
        // Supprimer les espaces et caractères spéciaux
        $cleaned = preg_replace('/[\s\-\(\)]/', '', $phoneNumber);
        
        // Vérifier que c'est un numéro français valide
        // Format accepté : 0X XX XX XX XX ou +33 X XX XX XX XX
        $pattern = '/^(0[1-9]|(\+33[1-9]))[0-9]{8}$/';
        
        return preg_match($pattern, $cleaned);
    }

    /**
     * Déterminer si un numéro est africain (Bénin)
     *
     * @param string $phoneNumber
     * @return bool
     */
    private static function isAfricanNumber($phoneNumber)
    {
        // Supprimer tous les caractères non numériques sauf le +
        $cleaned = preg_replace('/[^\d+]/', '', $phoneNumber);
        
        // Vérifier si c'est un numéro béninois (+229)
        return str_starts_with($cleaned, '+229');
    }

    /**
     * Obtenir le pays à partir du numéro de téléphone
     *
     * @param string $phoneNumber
     * @return string
     */
    private static function getCountryFromPhone($phoneNumber)
    {
        $cleaned = preg_replace('/[^\d+]/', '', $phoneNumber);
        
        $countryCodes = [
            '+33' => 'France',
            '+32' => 'Belgique',
            '+41' => 'Suisse',
            '+49' => 'Allemagne',
            '+34' => 'Espagne',
            '+39' => 'Italie',
            '+44' => 'Royaume-Uni',
            '+1' => 'États-Unis/Canada',
            '+229' => 'Bénin'
        ];
        
        foreach ($countryCodes as $code => $country) {
            if (str_starts_with($cleaned, $code)) {
                return $country;
            }
        }
        
        return 'Inconnu';
    }
}
