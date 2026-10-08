<?php

namespace App\Jobs;

use App\Models\Message;
use App\Models\User;
use App\Models\UserFcmToken;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Exception\MessagingException;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Laravel\Firebase\Facades\Firebase;

class SendChatMessageNotification implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public Message $message,
        public User $recipient
    ) {
    }

    public function handle(): void
    {
        
        $tokens = UserFcmToken::where('user_id', $this->recipient->id)
            ->pluck('fcm_token')
            ->filter()
            ->values()
            ->all();

        if (empty($tokens)) {
            return;
        }

        $sender = $this->message->user()->first();
        if (! $sender) {
            return;
        }

        $title = trim(($sender->nom ?? '') . ' ' . ($sender->prenom ?? ''));
        if ($title === '') {
            $title = $sender->alias ?? $sender->email ?? ('Utilisateur #' . $sender->id);
        }

        $body = $this->message->type === 'media'
            ? 'Photo 📷'
            : (trim((string) ($this->message->content ?? '')) ?: 'Nouveau message');

            
        try {
            $notification = Notification::create($title, $body);
            $senderPhoto = $sender->profilePhotoPublicUrl();

            $data = [
                'conversation_id' => (string) $this->message->conversation_id,
                'senderName' => $title,
                'senderImage' => $senderPhoto ?? '',
                'senderRole' => (string) ($sender->role ?? 'user'),
            ];

            $cloudMessage = CloudMessage::new()
                ->withNotification($notification)
                ->withData($data);

            $report = Firebase::messaging()->sendMulticast($cloudMessage, $tokens);

            // Log::info('Rapport envoi FCM', [
            //     'succes' => $report->successes()->count(),
            //     'echecs' => $report->failures()->count(),
            //     'tokens_cibles' => count($tokens),
            // ]);

            $invalidTokens = array_values(array_unique(array_merge(
                $report->unknownTokens(),
                $report->invalidTokens()
            )));

            if (! empty($invalidTokens)) {
                UserFcmToken::whereIn('fcm_token', $invalidTokens)->delete();
            }

            foreach ($report->failures()->getItems() as $failure) {

                // Afficher les causes de l'échec
                // Log::info('Raison de l\'échec FCM: ' . $failure->error()->getMessage());
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
                'conversation_id' => $this->message->conversation_id,
                'sender_id' => $sender->id,
                'recipient_id' => $this->recipient->id,
                'error' => $e->getMessage(),
            ]);
        } catch (\Throwable $e) {
            Log::error('Erreur envoi notification push FCM', [
                'conversation_id' => $this->message->conversation_id,
                'sender_id' => $sender->id,
                'recipient_id' => $this->recipient->id,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
