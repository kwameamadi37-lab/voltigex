@extends('mail.layout')

@section('mail-title', 'Code de vérification — Voltigex')

@push('mail-styles')
<style>
    .verification-code {
        font-size: 32px;
        font-weight: 700;
        letter-spacing: 8px;
        color: #082054;
        text-align: center;
        padding: 16px;
        background: #f0f9ff;
        border-radius: 8px;
        margin: 20px 0;
    }
</style>
@endpush

@section('mail-body')
    <h1>Code de vérification</h1>
    <p class="greeting">Bonjour,</p>
    <p class="intro-text">Utilisez le code ci-dessous pour finaliser votre inscription Voltigex :</p>
    <div class="verification-code">{{ $verificationCode }}</div>
    <div class="info-box">
        <p><i class="fas fa-clock"></i> Ce code expire dans 10 minutes. Ne le communiquez à personne.</p>
    </div>
    <p class="intro-text">Si vous n'avez pas demandé ce code, ignorez cet email.</p>
@endsection
