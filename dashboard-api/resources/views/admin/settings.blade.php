@extends('layouts.admin.dashboard')

@section('title', 'Voltigex | Paramètres du site')

@section('content')
  <div class="card">
    <div class="card-header border-bottom">
      <h5 class="mb-0">Paramètres du site & application</h5>
    </div>
    <div class="card-body">
      <form action="{{ route('admin.settings.update') }}" method="POST" enctype="multipart/form-data">
        @csrf
        @method('PUT')

        <h6 class="text-muted text-uppercase ls-wide mb-3">Contact & emails</h6>
        <div class="row g-3 mb-4">
          <div class="col-md-6">
            <label class="form-label">Email contact</label>
            <input type="email" name="contact_email" class="form-control" value="{{ old('contact_email', $settings['contact_email'] ?? '') }}" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Email support</label>
            <input type="email" name="support_email" class="form-control" value="{{ old('support_email', $settings['support_email'] ?? '') }}" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Téléphone</label>
            <input type="text" name="contact_phone" class="form-control" value="{{ old('contact_phone', $settings['contact_phone'] ?? '') }}" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Langue par défaut</label>
            <select name="default_locale" class="form-select">
              @foreach(['fr' => 'Français', 'en' => 'English', 'de' => 'Deutsch', 'es' => 'Español', 'it' => 'Italiano'] as $code => $label)
                <option value="{{ $code }}" @selected(old('default_locale', $settings['default_locale'] ?? 'fr') === $code)>{{ $label }}</option>
              @endforeach
            </select>
          </div>
          <div class="col-12">
            <label class="form-label">Horaires d'ouverture</label>
            <textarea name="opening_hours" class="form-control" rows="4">{{ old('opening_hours', $settings['opening_hours'] ?? '') }}</textarea>
          </div>
          <div class="col-md-6">
            <label class="form-label">Nom expéditeur emails</label>
            <input type="text" name="mail_from_name" class="form-control" value="{{ old('mail_from_name', $settings['mail_from_name'] ?? '') }}" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Adresse expéditeur emails</label>
            <input type="email" name="mail_from_address" class="form-control" value="{{ old('mail_from_address', $settings['mail_from_address'] ?? '') }}" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Site web (URL)</label>
            <input type="url" name="brand_website_url" class="form-control" value="{{ old('brand_website_url', $settings['brand_website_url'] ?? '') }}">
          </div>
        </div>

        <h6 class="text-muted text-uppercase ls-wide mb-3">Application mobile</h6>
        <div class="row g-3 mb-4">
          <div class="col-md-8">
            <label class="form-label">Lien Google Play / Store</label>
            <input type="url" name="app_play_store_url" class="form-control" value="{{ old('app_play_store_url', $settings['app_play_store_url'] ?? '') }}">
          </div>
          <div class="col-md-4">
            <label class="form-label">QR code (image)</label>
            <input type="file" name="app_qr_code" class="form-control" accept="image/*">
            @if(!empty($settings['app_qr_code_path']))
              <img src="{{ document_public_url($settings['app_qr_code_path']) }}" alt="QR" class="mt-2 rounded border" style="max-height:120px">
            @endif
          </div>
        </div>

        <h6 class="text-muted text-uppercase ls-wide mb-3">Documents légaux (mobile & site)</h6>
        <p class="text-muted small mb-3">URLs des pages web et PDF téléchargeables dans l'application.</p>
        <div class="row g-3 mb-4">
          @foreach([
            'privacy' => ['url' => 'legal_privacy_url', 'pdf' => 'legal_privacy_pdf', 'label' => 'Confidentialité'],
            'terms' => ['url' => 'legal_terms_url', 'pdf' => 'legal_terms_pdf', 'label' => 'Conditions d\'utilisation'],
            'security' => ['url' => 'legal_security_url', 'pdf' => 'legal_security_pdf', 'label' => 'Sécurité'],
          ] as $fields)
            <div class="col-12"><strong>{{ $fields['label'] }}</strong></div>
            <div class="col-md-6">
              <label class="form-label">URL page</label>
              <input type="text" name="{{ $fields['url'] }}" class="form-control" placeholder="/politique-confidentialite" value="{{ old($fields['url'], $settings[$fields['url']] ?? '') }}">
            </div>
            <div class="col-md-6">
              <label class="form-label">PDF</label>
              <input type="file" name="{{ $fields['pdf'] }}" class="form-control" accept="application/pdf">
              @if(!empty($settings[$fields['pdf']]))
                <a href="{{ document_public_url($settings[$fields['pdf']]) }}" target="_blank" class="small d-inline-block mt-1">Voir le PDF actuel</a>
              @endif
            </div>
          @endforeach
        </div>

        <h6 class="text-muted text-uppercase ls-wide mb-3">Catalogue cartes (application)</h6>
        <p class="text-muted small mb-3">Libellés et visuels des cartes Gold, Diamond et Platinum. Les images remplacent les assets par défaut dans l’app mobile si renseignées.</p>
        <div class="row g-4 mb-4">
          @foreach($cardCatalog as $card)
            @php($key = $card['key'])
            <div class="col-12">
              <div class="border rounded p-3">
                <div class="d-flex align-items-center justify-content-between mb-3">
                  <strong class="text-uppercase">{{ $key }}</strong>
                  <div class="form-check form-switch mb-0">
                    <input class="form-check-input" type="checkbox" role="switch" name="card_{{ $key }}_enabled" value="1" id="card_{{ $key }}_enabled" @checked(!empty($card['enabled']))>
                    <label class="form-check-label" for="card_{{ $key }}_enabled">Proposée à l’activation</label>
                  </div>
                </div>
                <div class="row g-3">
                  <div class="col-md-4">
                    <label class="form-label">Libellé (FR)</label>
                    <input type="text" name="card_{{ $key }}_label_fr" class="form-control" value="{{ old('card_'.$key.'_label_fr', $card['label_fr'] ?? '') }}">
                  </div>
                  <div class="col-md-4">
                    <label class="form-label">Libellé (EN)</label>
                    <input type="text" name="card_{{ $key }}_label_en" class="form-control" value="{{ old('card_'.$key.'_label_en', $card['label_en'] ?? '') }}">
                  </div>
                  <div class="col-md-4">
                    <label class="form-label">Libellé (DE)</label>
                    <input type="text" name="card_{{ $key }}_label_de" class="form-control" value="{{ old('card_'.$key.'_label_de', $card['label_de'] ?? '') }}">
                  </div>
                  <div class="col-md-4">
                    <label class="form-label">Montant (€)</label>
                    <input type="number" step="0.01" min="0" name="card_{{ $key }}_amount" class="form-control" value="{{ old('card_'.$key.'_amount', $card['amount'] ?? 0) }}">
                    <span class="text-muted small">Solde / frais affichés et crédité à l’activation</span>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label">Image carte (PNG/JPG)</label>
                    <input type="file" name="card_{{ $key }}_image" class="form-control" accept="image/*">
                    @if(!empty($card['image_path']))
                      <img src="{{ document_public_url($card['image_path']) }}" alt="{{ $key }}" class="mt-2 rounded border" style="max-height:80px">
                    @endif
                  </div>
                </div>
              </div>
            </div>
          @endforeach
        </div>

        <button type="submit" class="btn btn-primary">
          <i class="bi bi-save"></i> Enregistrer
        </button>
      </form>
    </div>
  </div>
@endsection
