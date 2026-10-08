<?php

namespace App\Events;

use App\Helpers\MessageMetadataHelper;
use App\Models\Message;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageSent implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * @var \App\Models\Message
     */
    public $message;

    /**
     * Create a new event instance.
     */
    public function __construct(Message $message)
    {
        $this->message = $message->load([
            'user',
            'conversation.userOne',
            'conversation.userTwo',
        ]);
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\PrivateChannel>
     */
    public function broadcastOn(): array
    {
        $channels = [
            new PrivateChannel('chat.' . $this->message->conversation_id),
        ];

        $conversation = $this->message->conversation;
        if ($conversation) {
            $channels[] = new PrivateChannel('chat.inbox.' . $conversation->user_one_id);
            $channels[] = new PrivateChannel('chat.inbox.' . $conversation->user_two_id);

            foreach ([$conversation->userOne, $conversation->userTwo] as $participant) {
                if ($participant && ($participant->role ?? '') === 'admin') {
                    $channels[] = new PrivateChannel('chat.admin.' . $participant->id);
                }
            }
        }

        return $channels;
    }

    /**
     * Données envoyées au frontend.
     */
    public function broadcastWith(): array
    {
        $meta = $this->message->metadata;

        return [
            'id' => $this->message->id,
            'conversation_id' => $this->message->conversation_id,
            'content' => $this->message->content,
            'type' => $this->message->type,
            'internal_type' => $this->message->internal_type,
            'media_type' => $this->message->media_type,
            'media_url' => $this->message->media_url,
            'thumbnail_url' => $this->message->thumbnail_url,
            'media_width' => $this->message->media_width,
            'media_height' => $this->message->media_height,
            'blurhash' => $this->message->blurhash,
            'metadata' => MessageMetadataHelper::forJson($meta),
            'client_id' => MessageMetadataHelper::clientId($meta),
            'sender' => [
                'id' => $this->message->user_id,
                'nom' => $this->message->user->nom ?? null,
                'prenom' => $this->message->user->prenom ?? null,
                'role' => $this->message->user->role ?? null,
            ],
            'created_at' => $this->message->created_at?->toISOString(),
        ];
    }
}
