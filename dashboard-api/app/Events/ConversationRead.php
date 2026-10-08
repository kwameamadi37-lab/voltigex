<?php

namespace App\Events;

use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * Le partenaire a marqué des messages comme lus (PATCH …/read).
 * L’expéditeur reçoit [last_read_message_id] pour déplacer l’avatar « Vu ».
 */
class ConversationRead implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public int $conversationId,
        public int $readerUserId,
        public ?int $lastReadMessageId,
    ) {
    }

    /**
     * @return array<int, \Illuminate\Broadcasting\PrivateChannel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('chat.'.$this->conversationId),
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        return [
            'conversation_id' => (string) $this->conversationId,
            'reader_user_id' => (string) $this->readerUserId,
            'last_read_message_id' => $this->lastReadMessageId !== null
                ? (string) $this->lastReadMessageId
                : null,
        ];
    }
}
