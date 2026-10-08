<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Address;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class VerifyCodeMail extends Mailable
{
    use Queueable, SerializesModels;

    public $verificationCode;
    public $userEmail;

    /**
     * Create a new message instance.
     *
     * @return void
     */
    public function __construct($verificationCode, $userEmail = null)
    {
        $this->verificationCode = $verificationCode;
        $this->userEmail = $userEmail;
    }

    /**
     * Get the message envelope.
     *
     * @return \Illuminate\Mail\Mailables\Envelope
     */
    public function envelope()
    {
        return new Envelope(
            from: new Address(
                site_setting('mail_from_address', config('mail.from.address')),
                site_setting('mail_from_name', config('mail.from.name', 'Voltigex')),
            ),
            subject: 'Code de vérification Voltigex',
        );
    }

    /**
     * Get the message content definition.
     *
     * @return \Illuminate\Mail\Mailables\Content
     */
    public function content()
    {
        return new Content(
            view: 'mail.verify-code',
            with: [
                'verificationCode' => $this->verificationCode,
                'userEmail' => $this->userEmail,
            ]
        );
    }

    /**
     * Get the attachments for the message.
     *
     * @return array
     */
    public function attachments()
    {
        return [];
    }
}
