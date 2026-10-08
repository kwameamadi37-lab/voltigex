@extends('layouts.admin.dashboard')

@section('title', 'Voltigex | Envoyer un email')

@push('styles')
<style>
  .compose-shell {
    display: grid;
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }
  @media (min-width: 992px) {
    .compose-shell { grid-template-columns: minmax(0, 1fr) 320px; }
  }
  .compose-panel {
    background: #fff;
    border-radius: 16px;
    border: 1px solid #e8ecf4;
    box-shadow: 0 8px 30px rgba(15, 23, 42, 0.06);
    overflow: hidden;
  }
  .compose-panel-head {
    background: linear-gradient(135deg, #082054 0%, #1e3a8a 55%, #2563eb 100%);
    color: #fff;
    padding: 1.25rem 1.5rem;
  }
  .compose-panel-head h2 {
    font-size: 1.125rem;
    font-weight: 600;
    margin: 0;
  }
  .compose-panel-head p {
    margin: 0.35rem 0 0;
    font-size: 0.8125rem;
    opacity: 0.88;
  }
  .compose-field {
    padding: 0.85rem 1.5rem;
    border-bottom: 1px solid #eef1f6;
    display: grid;
    grid-template-columns: 72px 1fr;
    gap: 0.75rem;
    align-items: start;
  }
  .compose-field label {
    font-size: 0.8125rem;
    font-weight: 600;
    color: #64748b;
    padding-top: 0.45rem;
    margin: 0;
  }
  .compose-field .form-control,
  .compose-field .form-select {
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    font-size: 0.9375rem;
    padding: 0.55rem 0.75rem;
  }
  .compose-field .form-control:focus,
  .compose-field .form-select:focus {
    border-color: #1e3a8a;
    box-shadow: 0 0 0 3px rgba(30, 58, 138, 0.12);
  }
  .compose-body-wrap { padding: 1rem 1.5rem 0; }
  .compose-body {
    min-height: 280px;
    border-radius: 12px;
    border: 1px solid #e2e8f0;
    font-size: 0.9375rem;
    line-height: 1.55;
    resize: vertical;
  }
  .compose-footer {
    padding: 1rem 1.5rem 1.25rem;
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    align-items: center;
    gap: 0.75rem;
  }
  .btn-compose-send {
    background: linear-gradient(135deg, #1e3a8a, #2563eb);
    border: none;
    color: #fff;
    font-weight: 600;
    padding: 0.65rem 1.35rem;
    border-radius: 999px;
    box-shadow: 0 4px 14px rgba(37, 99, 235, 0.35);
  }
  .btn-compose-send:hover { color: #fff; filter: brightness(1.05); }
  .recipient-pill {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    margin-top: 0.5rem;
    padding: 0.25rem 0.65rem;
    background: #eff6ff;
    color: #1e40af;
    border-radius: 999px;
    font-size: 0.8125rem;
    font-weight: 500;
  }
  .compose-aside {
    background: #f8fafc;
    border-radius: 16px;
    border: 1px solid #e8ecf4;
    padding: 1.25rem;
  }
  .compose-aside h3 {
    font-size: 0.875rem;
    font-weight: 700;
    color: #0f172a;
    margin-bottom: 0.75rem;
  }
  .preview-mini {
    background: #fff;
    border-radius: 12px;
    border: 1px solid #e2e8f0;
    overflow: hidden;
    font-size: 0.75rem;
  }
  .preview-mini-bar {
    height: 6px;
    background: linear-gradient(90deg, #082054, #1e3a8a, #005669);
  }
  .preview-mini-body { padding: 0.75rem; color: #475569; }
  #user-picker-row .form-select {
    max-width: 100%;
  }
</style>
@endpush

@section('content')
  <div class="card border-0 shadow-sm mb-3">
    <div class="card-body py-3 px-4">
      <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
        <div>
          <h5 class="mb-0">Messagerie clients</h5>
          <p class="text-muted small mb-0">Envoi personnalisé avec la charte Voltigex</p>
        </div>
        <span class="badge bg-primary-subtle text-primary px-3 py-2">
          <i class="bi bi-shield-check me-1"></i> Expéditeur : {{ site_setting('mail_from_name', 'Voltigex') }}
        </span>
      </div>
    </div>
  </div>

  <div class="compose-shell">
    <div class="compose-panel">
      <div class="compose-panel-head">
        <h2><i class="bi bi-pencil-square me-2"></i>Nouveau message</h2>
        <p>Sélectionnez un client, rédigez votre message et envoyez.</p>
      </div>

      <form action="{{ route('admin.compose-mail.send') }}" method="POST" id="compose-form">
        @csrf

        <div class="compose-field">
          <label for="audience">À</label>
          <div>
            <select name="audience" id="audience" class="form-select" required>
              <option value="single" @selected(old('audience', 'single') === 'single')>Un client</option>
              <option value="all" @selected(old('audience') === 'all')>Tous les clients</option>
            </select>
          </div>
        </div>

        <div class="compose-field align-items-center" id="user-picker-row">
          <label for="user_id">Client</label>
          <div>
            <select name="user_id" id="user_id" class="form-select">
              <option value="">— Choisir un client —</option>
              @foreach($users as $u)
                <option value="{{ $u->id }}" data-email="{{ $u->email }}" @selected(old('user_id') == $u->id)>
                  {{ $u->prenom }} {{ $u->nom }} · {{ $u->email }}
                </option>
              @endforeach
            </select>
            <div class="recipient-pill d-none" id="selected-email-preview">
              <i class="bi bi-envelope-at"></i>
              <span id="selected-email-text"></span>
            </div>
          </div>
        </div>

        <div class="compose-field">
          <label for="subject">Objet</label>
          <input type="text" name="subject" id="subject" class="form-control" required maxlength="200" value="{{ old('subject') }}" placeholder="Objet du message">
        </div>

        <div class="compose-body-wrap">
          <textarea name="body" id="body" class="form-control compose-body w-100" required placeholder="Bonjour,&#10;&#10;Votre message…">{{ old('body') }}</textarea>
        </div>

        <div class="compose-footer">
          <span class="text-muted small">
            <i class="bi bi-info-circle me-1"></i>
            Email HTML Voltigex (logo, contact, horaires).
          </span>
          <button type="submit" class="btn btn-compose-send">
            <i class="bi bi-send me-1"></i> Envoyer
          </button>
        </div>
      </form>
    </div>

    <aside class="compose-aside">
      <h3>Aperçu charte</h3>
      <div class="preview-mini mb-3">
        <div class="preview-mini-bar"></div>
        <div class="preview-mini-body">
          <strong style="color:#082054;display:block;margin-bottom:4px;" id="preview-subject">Objet du message</strong>
          <span id="preview-body">Le contenu apparaîtra ici…</span>
        </div>
      </div>
      <ul class="list-unstyled small text-muted mb-0">
        <li class="mb-2"><i class="bi bi-telephone me-2 text-primary"></i>{{ site_setting('contact_phone') }}</li>
        <li class="mb-2"><i class="bi bi-envelope me-2 text-primary"></i>{{ site_setting('contact_email') }}</li>
        <li><i class="bi bi-clock me-2 text-primary"></i>Horaires inclus dans le pied de page</li>
      </ul>
    </aside>
  </div>
@endsection

@push('scripts')
<script>
  (function () {
    const audience = document.getElementById('audience');
    const userRow = document.getElementById('user-picker-row');
    const userSelect = document.getElementById('user_id');
    const previewWrap = document.getElementById('selected-email-preview');
    const previewEmail = document.getElementById('selected-email-text');
    const form = document.getElementById('compose-form');
    const subject = document.getElementById('subject');
    const body = document.getElementById('body');
    const previewSubject = document.getElementById('preview-subject');
    const previewBody = document.getElementById('preview-body');

    function syncAudience() {
      const all = audience.value === 'all';
      userRow.style.display = all ? 'none' : 'grid';
      userSelect.required = !all;
      if (all) userSelect.value = '';
      syncPreview();
    }

    function syncPreview() {
      const opt = userSelect.options[userSelect.selectedIndex];
      const email = opt && opt.dataset.email;
      if (email && audience.value === 'single') {
        previewEmail.textContent = email;
        previewWrap.classList.remove('d-none');
      } else {
        previewWrap.classList.add('d-none');
      }
    }

    function syncLivePreview() {
      previewSubject.textContent = subject.value.trim() || 'Objet du message';
      const t = body.value.trim();
      previewBody.textContent = t ? (t.length > 120 ? t.slice(0, 120) + '…' : t) : 'Le contenu apparaîtra ici…';
    }

    audience.addEventListener('change', syncAudience);
    userSelect.addEventListener('change', syncPreview);
    subject.addEventListener('input', syncLivePreview);
    body.addEventListener('input', syncLivePreview);

    form.addEventListener('submit', function (e) {
      if (audience.value === 'single' && !userSelect.value) {
        e.preventDefault();
        alert('Veuillez sélectionner un client.');
      }
    });

    syncAudience();
    syncLivePreview();
  })();
</script>
@endpush
