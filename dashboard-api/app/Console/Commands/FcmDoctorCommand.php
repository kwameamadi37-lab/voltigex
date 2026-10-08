<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Kreait\Laravel\Firebase\Facades\Firebase;

class FcmDoctorCommand extends Command
{
    protected $signature = 'fcm:doctor';

    protected $description = 'Vérifie la configuration Firebase Admin (FCM push chat)';

    public function handle(): int
    {
        $relative = env('FIREBASE_CREDENTIALS') ?: env('GOOGLE_APPLICATION_CREDENTIALS');
        if (! is_string($relative) || trim($relative) === '') {
            $this->error('FIREBASE_CREDENTIALS (ou GOOGLE_APPLICATION_CREDENTIALS) non défini dans .env');

            return self::FAILURE;
        }

        $path = str_starts_with($relative, '/') || str_contains($relative, ':\\')
            ? $relative
            : base_path($relative);

        if (! is_readable($path)) {
            $this->error("Fichier compte de service introuvable : {$path}");
            $this->line('Téléchargez-le depuis Firebase Console → Paramètres du projet → Comptes de service → Générer une nouvelle clé privée.');
            $this->line('Enregistrez-le sous : storage/app/firebase-service-account.json');

            return self::FAILURE;
        }

        $json = json_decode((string) file_get_contents($path), true);
        $projectId = is_array($json) ? ($json['project_id'] ?? null) : null;
        $this->info("Credentials OK (project_id: ".($projectId ?: '?').')');

        try {
            Firebase::messaging();
            $this->info('Firebase Messaging initialisé avec succès.');

            return self::SUCCESS;
        } catch (\Throwable $e) {
            $this->error('Échec initialisation Firebase : '.$e->getMessage());

            return self::FAILURE;
        }
    }
}
