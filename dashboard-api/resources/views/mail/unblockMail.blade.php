@extends('mail.layout')

@section('mail-title', 'Compte réactivé — Voltigex')

@section('mail-body')
    <h1>Compte réactivé</h1>
    <p class="greeting">Bonjour {{ $mailData['client'] ?? '' }},</p>
    <p class="intro-text">Bonne nouvelle : votre compte Voltigex est à nouveau actif. Vous pouvez vous connecter via l'application mobile.</p>
@endsection
