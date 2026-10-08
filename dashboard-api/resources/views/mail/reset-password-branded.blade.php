@extends('mail.layout')

@section('mail-title', 'Réinitialisation de mot de passe — Voltigex')

@section('mail-body')
    <h1>Réinitialisation de mot de passe</h1>
    <p class="greeting">Bonjour {{ trim($user->prenom.' '.$user->nom) ?: $user->email }},</p>
    <p class="intro-text">Vous avez demandé à réinitialiser le mot de passe de votre compte Voltigex. Cliquez sur le bouton ci-dessous pour en choisir un nouveau.</p>
    <div class="info-box">
        <p><i class="fas fa-clock"></i> Ce lien expire dans {{ config('auth.passwords.'.config('auth.defaults.passwords').'.expire', 60) }} minutes.</p>
    </div>
    <p style="text-align: center; margin: 28px 0;">
        <a href="{{ $resetUrl }}" class="btn-primary">Réinitialiser mon mot de passe</a>
    </p>
    <p class="intro-text">Si vous n'êtes pas à l'origine de cette demande, ignorez cet email — votre mot de passe restera inchangé.</p>
    <p class="intro-text" style="margin-top: 20px;">Cordialement,<br><strong>L'équipe {{ site_setting('mail_from_name', 'Voltigex') }}</strong></p>
@endsection
