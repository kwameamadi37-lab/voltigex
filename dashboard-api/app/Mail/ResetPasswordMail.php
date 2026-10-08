<?php

namespace App\Mail;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class ResetPasswordMail extends Mailable
{
    use Concerns\UsesBrandedMailFrom, Queueable, SerializesModels;

    public function __construct(
        public User $user,
        public string $resetUrl,
    ) {}

    public function build()
    {
        return $this->from($this->brandedFromAddress(), $this->brandedFromName())
            ->subject('Réinitialisation de votre mot de passe — Voltigex')
            ->view('mail.reset-password-branded');
    }
}
