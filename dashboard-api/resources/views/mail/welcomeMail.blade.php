@extends('mail.layout')

@section('mail-title', 'Bienvenue — Voltigex')

@section('mail-body')
    <h1>Bienvenue chez Voltigex</h1>
    <p class="greeting">Bonjour {{ trim(($mailData['prenom'] ?? '').' '.($mailData['nom'] ?? '')) ?: 'cher client' }},</p>
    <p class="intro-text">Votre demande d'ouverture de compte a bien été enregistrée. Référence client : <strong>{{ $mailData['alias'] ?? '' }}</strong>.</p>
    <div class="info-box">
        <p><i class="fas fa-hourglass-half"></i> Votre dossier est en cours d'examen par notre équipe. Vous recevrez un email dès que votre compte sera activé.</p>
    </div>
    <p class="intro-text">Merci de votre confiance.</p>
@endsection
