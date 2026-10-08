@extends('mail.layout')

@section('mail-title', 'Compte activé — Voltigex')

@section('mail-body')
    <h1>Votre compte est activé</h1>
    <p class="greeting">Cher(e) {{ $mailData['title'] ?? 'client' }},</p>
    <p class="intro-text">Nous sommes ravis de vous confirmer que votre compte Voltigex a été validé et activé avec succès.</p>
    <p class="intro-text">Pour accéder à votre espace bancaire, connectez-vous via l'application mobile Voltigex :</p>
    <ul class="intro-text" style="padding-left: 20px;">
        <li>Téléchargez l'application (QR code sur le site ou store).</li>
        <li>Connectez-vous avec vos identifiants.</li>
    </ul>
    <div class="info-box">
        <p><i class="fas fa-mobile-alt"></i> L'accès client se fait uniquement via l'application mobile.</p>
    </div>
    <p class="intro-text">Besoin d'aide ? <a href="mailto:{{ site_setting('contact_email') }}">{{ site_setting('contact_email') }}</a></p>
@endsection
