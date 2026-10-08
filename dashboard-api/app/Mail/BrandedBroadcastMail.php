<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class BrandedBroadcastMail extends Mailable
{
    use Concerns\UsesBrandedMailFrom, Queueable, SerializesModels;

    public function __construct(
        public string $subjectLine,
        public string $bodyHtml,
        public ?string $recipientName = null,
    ) {}

    public function build()
    {
        return $this->from($this->brandedFromAddress(), $this->brandedFromName())
            ->subject($this->subjectLine)
            ->view('mail.branded-broadcast');
    }
}
