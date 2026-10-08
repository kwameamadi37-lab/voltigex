<?php

namespace App\Jobs;

use App\Models\Message;
use App\Models\User;
use Illuminate\Bus\Queueable;
use App\Services\ChatPushNotificationService;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\SerializesModels;

class SendChatMessageNotification
{
    use Dispatchable, Queueable, SerializesModels;

    public function __construct(
        public Message $message,
        public User $recipient
    ) {
    }

    public function handle(ChatPushNotificationService $push): void
    {
        $push->send($this->message, $this->recipient);
    }
}
