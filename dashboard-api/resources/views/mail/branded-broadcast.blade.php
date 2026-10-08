@extends('mail.layout')

@section('mail-title', $subjectLine)

@section('mail-body')
    @if($recipientName)
        <p class="greeting">Bonjour {{ $recipientName }},</p>
    @endif
    <div class="intro-text">{!! $bodyHtml !!}</div>
    <p class="intro-text" style="margin-top: 24px;">Cordialement,<br><strong>L'équipe {{ site_setting('mail_from_name', 'Voltigex') }}</strong></p>
@endsection
