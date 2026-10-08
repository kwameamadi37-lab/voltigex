@extends('layouts.admin.dashboard')

@section('title', 'Voltigex | Dépôts clients')

@section('content')
  <div class="card border-0 shadow-sm mb-3">
    <div class="card-body py-3 px-4">
      <h5 class="mb-0">Enregistrer un dépôt</h5>
      <p class="text-muted small mb-0">Crédite le solde client et ajoute une ligne « depot » dans l’historique mobile.</p>
    </div>
  </div>

  <div class="card border-0 shadow-sm">
    <div class="card-body p-4">
      @if(session('message'))
        <div class="alert alert-success">{{ session('message') }}</div>
      @endif
      @if(session('error'))
        <div class="alert alert-danger">{{ session('error') }}</div>
      @endif
      @if($errors->any())
        <div class="alert alert-danger">
          <ul class="mb-0">
            @foreach($errors->all() as $err)
              <li>{{ $err }}</li>
            @endforeach
          </ul>
        </div>
      @endif

      <form action="{{ route('admin.deposits.store') }}" method="POST" id="deposit-form">
        @csrf
        <div class="row g-3">
          <div class="col-md-6">
            <label for="user_id" class="form-label fw-semibold">Client</label>
            <select name="user_id" id="user_id" class="form-select" required>
              <option value="">— Choisir un client —</option>
              @foreach($users as $u)
                <option value="{{ $u->id }}" @selected(old('user_id') == $u->id)>
                  {{ $u->prenom }} {{ $u->nom }} · {{ $u->email }}
                </option>
              @endforeach
            </select>
          </div>
          <div class="col-md-6">
            <label for="deposit_type" class="form-label fw-semibold">Type de dépôt</label>
            <select name="deposit_type" id="deposit_type" class="form-select" required>
              @foreach($depositTypes as $key => $label)
                <option value="{{ $key }}" @selected(old('deposit_type') === $key)>{{ $label }}</option>
              @endforeach
            </select>
          </div>
          <div class="col-md-4">
            <label for="montant" class="form-label fw-semibold">Montant</label>
            <input type="number" name="montant" id="montant" class="form-control" step="0.01" min="0.01" required value="{{ old('montant') }}" placeholder="0,00">
          </div>
          <div class="col-md-8" id="libelle-wrap" style="display: none;">
            <label for="libelle" class="form-label fw-semibold">Libellé personnalisé</label>
            <input type="text" name="libelle" id="libelle" class="form-control" maxlength="200" value="{{ old('libelle') }}" placeholder="Ex. Frais dossier">
          </div>
        </div>
        <div class="mt-4 text-end">
          <button type="submit" class="btn btn-primary">
            <i class="bi bi-plus-circle me-1"></i> Valider le dépôt
          </button>
        </div>
      </form>
    </div>
  </div>
@endsection

@push('scripts')
<script>
  (function () {
    const typeSelect = document.getElementById('deposit_type');
    const libelleWrap = document.getElementById('libelle-wrap');
    function syncLibelle() {
      libelleWrap.style.display = typeSelect.value === 'autre' ? 'block' : 'none';
    }
    typeSelect.addEventListener('change', syncLibelle);
    syncLibelle();
  })();
</script>
@endpush
