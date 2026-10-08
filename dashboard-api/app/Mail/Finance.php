<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class Finance extends Mailable
{
    use Queueable, SerializesModels;

    public $mailData;

    public function __construct($mailData)
    {
        $this->mailData = $mailData;
    }

    public function build()
    {
        return $this->from('contact@voltigex.com', 'Voltigex')
                    ->subject('Nouvelle demande de crédit - Voltigex')
                    ->view('mail.finance');
    }
} 