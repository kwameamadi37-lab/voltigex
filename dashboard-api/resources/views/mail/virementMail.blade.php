@extends('mail.layout')

@section('mail-title', 'Demande de virement — Voltigex')

@section('mail-body')
    <h1>Demande de virement enregistrée</h1>
    <p class="greeting">Chère {{ $mailData['title'] ?? 'Client' }},</p>
    <p class="intro-text">Vous venez d'effectuer une demande de virement de <strong>{{ number_format($mailData['montant'] ?? 0, 2) }} {{ $mailData['devise'] ?? '€' }}</strong>.</p>
    <div class="info-box">
        <p><i class="fas fa-info-circle"></i> Votre demande est en cours de traitement. Suivez l'avancement dans l'application mobile.</p>
    </div>
@endsection
