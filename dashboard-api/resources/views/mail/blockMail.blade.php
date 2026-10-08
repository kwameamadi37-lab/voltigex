@extends('mail.layout')

@section('mail-title', 'Compte suspendu — Voltigex')

@section('mail-body')
    <h1>Compte suspendu</h1>
    <p class="greeting">Bonjour {{ $mailData['client'] ?? '' }},</p>
    <p class="intro-text">Votre compte Voltigex a été temporairement suspendu pour des raisons de sécurité ou de conformité.</p>
    <div class="info-box">
        <p><i class="fas fa-headset"></i> Contactez le support : {{ site_setting('support_email') }}</p>
    </div>
@endsection
