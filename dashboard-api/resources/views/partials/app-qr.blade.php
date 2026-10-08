@php
    $playUrl = site_setting('app_play_store_url', 'https://play.google.com/store/apps/details?id=com.mybank.app');
    $qrCustom = document_public_url(site_setting('app_qr_code_path'));
    $qrSrc = $qrCustom ?: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data='.urlencode($playUrl);
@endphp
<div class="bg-white p-4 rounded-2xl shadow-lg inline-block">
    <img src="{{ $qrSrc }}" alt="QR Code application Voltigex" class="w-32 h-32 object-contain">
</div>
<p class="text-sm text-white/90 mt-2">Scannez pour télécharger l'application</p>
<a href="{{ $playUrl }}" target="_blank" rel="noopener" class="text-secondary text-sm underline mt-1 inline-block">Lien direct store</a>
