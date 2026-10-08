<?php

namespace App\Mail\Concerns;

trait UsesBrandedMailFrom
{
    protected function brandedFromAddress(): string
    {
        return site_setting('mail_from_address', config('mail.from.address')) ?? 'contact@voltigex.com';
    }

    protected function brandedFromName(): string
    {
        return site_setting('mail_from_name', config('mail.from.name', 'Voltigex')) ?? 'Voltigex';
    }
}
