<?php

namespace App\Services;

use App\Models\Message;
use App\Models\User;
use App\Models\UserFcmToken;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Exception\MessagingException;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Laravel\Firebase\Facades\Firebase;

/**
 * Envoi FCM immédiat (hors file d’attente) pour ne pas dépendre de `queue:work`.
 */
class ChatPushNotificationService
{
    public function send(Message $message, User $recipient): void
    {
        // Notifications mobile : clients uniquement (support admin sur le web).
        if (strtolower((string) ($recipient->role ?? '')) === 'admin') {
            return;
        }

        $tokens = UserFcmToken::where('user_id', $recipient->id)
            ->pluck('fcm_token')
            ->filter()
            ->values()
            ->all();

        if (empty($tokens)) {
            Log::info('FCM ignoré : aucun token enregistré pour le destinataire', [
                'recipient_id' => $recipient->id,
                'conversation_id' => $message->conversation_id,
            ]);

            return;
        }

        $credentialsPath = $this->resolveCredentialsPath();
        if ($credentialsPath === null || ! is_readable($credentialsPath)) {
            Log::error('FCM impossible : fichier Firebase Admin manquant ou illisible', [
                'expected_path' => $credentialsPath ?? base_path((string) env('FIREBASE_CREDENTIALS', '')),
                'recipient_id' => $recipient->id,
            ]);

            return;
        }

        $sender = $message->user()->first();
        if (! $sender) {
            return;
        }

        $title = trim(($sender->nom ?? '') . ' ' . ($sender->prenom ?? ''));
        if ($title === '') {
            $title = $sender->alias ?? $sender->email ?? ('Utilisateur #' . $sender->id);
        }

        $body = $message->type === 'media'
            ? 'Photo 📷'
            : (trim((string) ($message->content ?? '')) ?: 'Nouveau message');

        try {
            $notification = Notification::create($title, $body);
            $senderPhoto = $sender->profilePhotoPublicUrl();

            $data = [
                'conversation_id' => (string) $message->conversation_id,
                'message_id' => (string) $message->id,
                'sender_id' => (string) $sender->id,
                'senderName' => $title,
                'senderImage' => $senderPhoto ?? '',
                'senderRole' => (string) ($sender->role ?? 'user'),
                'content' => $body,
            ];

            $cloudMessage = CloudMessage::new()
                ->withNotification($notification)
                ->withData($data);

            $report = Firebase::messaging()->sendMulticast($cloudMessage, $tokens);

            Log::info('FCM multicast chat', [
                'conversation_id' => $message->conversation_id,
                'recipient_id' => $recipient->id,
                'tokens' => count($tokens),
                'success' => $report->successes()->count(),
                'failure' => $report->failures()->count(),
            ]);

            $invalidTokens = array_values(array_unique(array_merge(
                $report->unknownTokens(),
                $report->invalidTokens()
            )));

            if (! empty($invalidTokens)) {
                UserFcmToken::whereIn('fcm_token', $invalidTokens)->delete();
            }

            foreach ($report->failures()->getItems() as $failure) {
                $error = $failure->error();
                if (! $error instanceof MessagingException) {
                    continue;
                }

                $token = $failure->target()->value();
                if ($failure->messageWasSentToUnknownToken() || $failure->messageTargetWasInvalid()) {
                    UserFcmToken::where('fcm_token', $token)->delete();
                }
            }
        } catch (MessagingException $e) {
            Log::error('Erreur MessagingException lors de l\'envoi FCM', [
                'conversation_id' => $message->conversation_id,
                'sender_id' => $sender->id,
                'recipient_id' => $recipient->id,
                'error' => $e->getMessage(),
            ]);
        } catch (\Throwable $e) {
            Log::error('Erreur envoi notification push FCM', [
                'conversation_id' => $message->conversation_id,
                'sender_id' => $sender->id,
                'recipient_id' => $recipient->id,
                'error' => $e->getMessage(),
            ]);
        }
    }

    private function resolveCredentialsPath(): ?string
    {
        $credentials = env('FIREBASE_CREDENTIALS') ?: env('GOOGLE_APPLICATION_CREDENTIALS');
        if (! is_string($credentials) || trim($credentials) === '') {
            return null;
        }

        $credentials = trim($credentials);
        if (str_starts_with($credentials, '{')) {
            return null;
        }

        $isAbsolute = str_starts_with($credentials, '/') || str_contains($credentials, ':\\');

        return $isAbsolute ? $credentials : base_path($credentials);
    }
}
