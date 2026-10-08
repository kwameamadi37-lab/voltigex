<!doctype html>
<html lang="en" data-theme="light">  
<head>  
  <meta charset="UTF-8"> 
  <meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
  <meta name="color-scheme" content="dark light">
  <title>Voltigexs |   Liste des utilisateurs</title>
  <link rel="stylesheet" type="text/css" href="gourou/css/main.css">
  <link rel="icon" href="{{ asset('assets/img/favicon.png') }}" type="image/x-icon">
  <link rel="stylesheet" type="text/css" href="gourou/css/utilities.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <script defer="defer" data-domain="webpixels.works" src="https://plausible.io/js/script.js">
  </script>
  @php
    use Illuminate\Support\Facades\Storage;
  @endphp
</head>

<body>
  <div class="d-flex flex-column flex-lg-row h-lg-full bg-surface-secondary">
    <nav class="navbar show navbar-vertical h-lg-screen navbar-expand-lg px-0 py-3 navbar-light bg-white border-bottom border-bottom-lg-0 border-end-lg scrollbar" id="sidebar">
      <div class="container-fluid">
        <button class="navbar-toggler ms-n2" type="button" data-bs-toggle="collapse" data-bs-target="#sidebarCollapse" aria-controls="sidebarCollapse" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon">
          </span>
        </button>
        <a href="/" class="navbar-brand d-inline-block py-lg-2 mb-lg-5 px-lg-6 me-0" href="/">
          <img style="width: 80px;height: 80px;" src="{{ asset('bank/images/favicon.png') }}" alt="Voltigexs">
        </a>
        <div class="navbar-user d-lg-none">
          <div class="dropdown">
            <a href="#" id="sidebarAvatar" role="button" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
              <div class="avatar-parent-child">
                <img alt="Photo de profil" src="{{ Auth()->User()->profil }}" class="avatar avatar- rounded-circle"> 
                <span class="avatar-child avatar-badge bg-success"></span>
              </div>
            </a>
            @include('layouts/admin/profile-dropdown')
          </div>
        </div> 
        @include('layouts/admin/header')  
      </div>
    </nav>  
    <div class="flex-lg-1 h-screen overflow-y-lg-auto">
      <nav class="navbar navbar-light position-lg-sticky top-lg-0 d-none d-lg-block overlap-10 flex-none bg-white border-bottom px-0 py-3" id="topbar">
        <div class="container-fluid">
          <div class="hstack gap-2">
          </div>  

          <div class="navbar-user d-none d-sm-block">
              <div class="hstack gap-3 ms-4">
                <div class="dropdown"><a href="/" class="nav-link px-3 text-base text-muted text-opacity-70 text-opacity-100-hover" id="dropdown-notifications" data-bs-toggle="dropdown" aria-expanded="false"></a>
                </div>
                <div class="dropdown">
                  <a class="d-flex align-items-center" href="/" role="button" data-bs-toggle="dropdown" aria-haspopup="false" aria-expanded="false">
                    <div>
                        <div class="avatar avatar-sm rounded-circle text-white"><img class="rounded-circle" alt="..." src="{{ asset('bank/images/favicon.png') }}"></div>
                    </div>
                    <div class="d-none d-sm-block ms-3"><span class="h6">{{ Auth()->User()->nom.' '.Auth()->User()->prenom }}</span></div>
                    <div class="d-none d-md-block ms-md-2"><i class="bi bi-chevron-down text-muted text-xs"></i></div>
                  </a>
                  @include('layouts/admin/profile-dropdown')
                </div>
              </div>
          </div>
        </div> 
      </nav>  
      <main class="py-6 bg-surface-secondary">
        <div class="container-fluid">
          @if (session('message'))
            <div class="alert alert-success mb-5">
               <i class="fa fa-check-circle"></i> {{ session('message') }}
            </div>
          @endif
          <div class="card">  
            <div class="card-header border-bottom">
              <h5 class="mb-0">Liste des utilisateurs</h5>  
            </div>
            <div class="table-responsive">
              <table class="table table-hover table-nowrap">
                <thead class="table-light">
                  <tr>
                    <th scope="col">Nom et prénoms</th>  
                    <th scope="col">Email</th>  
                    <th scope="col">Pays de connexion</th>  
                    <th scope="col">Téléphone</th>
                    <th scope="col">Solde</th>
                    <th scope="col">Statut compte</th>
                    <th scope="col">Documents</th>
                    <th scope="col">Action</th>   
                  </tr>
                </thead>
                <tbody>
                  @foreach ($utilisateur as $user)
                  <tr>
                    <td>{{ $user->nom.' '.$user->prenom }}</td>  
                    <td>{{ $user->email }}</td>
                    <td><i class="fas fa-exclamation-triangle text-red-600"></i> {{ $user->last_country }}</td>
                    <td>{{ $user->phone }}</td>
                    <td>{{ number_format($user->solde, 2) }} {{ $user->devise }}</td>
                    <td class="text-center">
                      @if($user->account_status == 1)
                          <span class="badge bg-success">Actif</span>
                      @else
                          <span class="badge bg-warning">Inactif</span>
                      @endif
                    </td>
                    <td>
                      <button type="button" class="btn btn-sm btn-info" data-bs-toggle="modal" data-bs-target="#documentsModal{{ $user->id }}">
                        <i class="fas fa-file-alt"></i> Voir documents
                      </button>
                    </td>
                    <td>
                      @if($user->account_status == 1)
                        <a href="{{ route('credite', $user->id) }}" class="btn btn-sm" style="background-color: rgb(16, 109, 248);color:white;">Créditer</a>
                        @if ($user->card_active == 0 && $user->card_attente)
                          <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#activateCardModal{{ $user->id }}">
                            Activer carte
                          </button>
                        @endif
                        <a href="{{ route('admin.support.start-conversation', $user->id) }}" class="btn btn-sm btn-outline-primary" title="Démarrer une conversation"><i class="bi bi-chat-dots"></i> Chat</a>
                        @if ($user->is_blocked==0)
                          <a href="{{ route('blockuser', $user->id) }}" class="btn btn-sm" style="background-color: red;color:white;">Bloquer</a>
                        @else
                          <a href="{{ route('unblockuser', $user->id) }}" class="btn btn-sm btn-primary">Débloquer</a>
                        @endif
                      @else
                        <span class="text-muted">Compte en attente de validation</span>
                        <a href="{{ route('activateuser', $user->id) }}" class="btn btn-sm btn-success">Activer compte</a>
                      @endif
                    </td> 
                  </tr>
                  @endforeach
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </main>
    </div>
  </div>

  <!-- Modals pour afficher les documents -->
  @foreach ($utilisateur as $user)
  <div class="modal fade" id="documentsModal{{ $user->id }}" tabindex="-1" aria-labelledby="documentsModalLabel{{ $user->id }}" aria-hidden="true">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="documentsModalLabel{{ $user->id }}">Documents de {{ $user->nom }} {{ $user->prenom }}</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-6">
              <h6 class="mb-2"><i class="fas fa-id-card text-primary"></i> Pièce d'identité</h6>
              @include('partials.user-document-card', ['path' => data_get($user, 'piece_identite'), 'label' => 'Pièce d\'identité'])
            </div>
            <div class="col-md-6">
              <h6 class="mb-2"><i class="fas fa-file-invoice-dollar text-success"></i> Avis d'imposition</h6>
              @include('partials.user-document-card', ['path' => data_get($user, 'avis_imposition'), 'label' => 'Avis d\'imposition'])
            </div>
            <div class="col-md-6">
              <h6 class="mb-2"><i class="fas fa-camera text-info"></i> Photo avec carte d'identité</h6>
              @include('partials.user-document-card', ['path' => data_get($user, 'photo_carte_identite'), 'label' => 'Photo CI'])
            </div>
            @if(filled(data_get($user, 'piece_recto')))
            <div class="col-md-6">
              <h6 class="mb-2"><i class="fas fa-id-card"></i> Pièce (inscription web)</h6>
              @include('partials.user-document-card', ['path' => data_get($user, 'piece_recto'), 'label' => 'Document'])
            </div>
            @endif
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Fermer</button>
        </div>
      </div>
    </div>
  </div>
  @endforeach

  @foreach ($utilisateur as $user)
    @if($user->account_status == 1 && $user->card_active == 0 && $user->card_attente)
      @php
        $cardTypeKey = strtolower((string) ($user->card_type ?? 'platinum'));
        $cardTypeLabel = \App\Support\CardCatalog::labelForType($cardTypeKey);
        $cardAmount = (float) ($user->card_amount ?? 0) > 0
            ? (float) $user->card_amount
            : \App\Support\CardCatalog::amountForType($cardTypeKey);
        $rawCardNumber = preg_replace('/\s+/', '', (string) ($user->card_number ?? ''));
        $cardNumberFormatted = $rawCardNumber !== ''
            ? trim(chunk_split($rawCardNumber, 4, ' '))
            : '—';
        $expDisplay = '—';
        if (! empty($user->date_exp)) {
            try {
                $expDisplay = \Carbon\Carbon::parse($user->date_exp)->format('m/y');
            } catch (\Throwable $e) {
                $expDisplay = (string) $user->date_exp;
            }
        }
        $holderName = trim(($user->nom ?? '').' '.($user->prenom ?? ''));
      @endphp
      <div class="modal fade" id="activateCardModal{{ $user->id }}" tabindex="-1" aria-labelledby="activateCardModalLabel{{ $user->id }}" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
          <div class="modal-content">
            <div class="modal-header bg-primary text-white">
              <h5 class="modal-title" id="activateCardModalLabel{{ $user->id }}">
                <i class="fas fa-credit-card me-2"></i>Activation carte — {{ $user->prenom }} {{ $user->nom }}
              </h5>
              <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Fermer"></button>
            </div>
            <div class="modal-body">
              <p class="text-muted small mb-3">Demande soumise par le client. Vérifiez les informations avant validation.</p>
              <dl class="row mb-0">
                <dt class="col-sm-5 text-muted">Titulaire</dt>
                <dd class="col-sm-7 fw-semibold">{{ $holderName !== '' ? $holderName : '—' }}</dd>

                <dt class="col-sm-5 text-muted">Numéro de carte</dt>
                <dd class="col-sm-7 font-monospace">{{ $cardNumberFormatted }}</dd>

                <dt class="col-sm-5 text-muted">Expiration</dt>
                <dd class="col-sm-7">{{ $expDisplay }}</dd>

                <dt class="col-sm-5 text-muted">CVV</dt>
                <dd class="col-sm-7 font-monospace">{{ filled($user->cvv) ? $user->cvv : '—' }}</dd>

                <dt class="col-sm-5 text-muted">Type de carte</dt>
                <dd class="col-sm-7">
                  <span class="badge bg-dark text-uppercase">{{ $cardTypeLabel }}</span>
                  <span class="text-muted small">({{ $cardTypeKey }})</span>
                </dd>

                <dt class="col-sm-5 text-muted">Montant (catalogue)</dt>
                <dd class="col-sm-7 fw-bold text-primary">
                  {{ number_format($cardAmount, 2, ',', ' ') }} {{ $user->devise ?? '€' }}
                </dd>
              </dl>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Annuler</button>
              <a href="{{ route('enablecard', $user->id) }}" class="btn btn-primary">
                <i class="fas fa-check me-1"></i> Confirmer l'activation
              </a>
            </div>
          </div>
        </div>
      </div>
    @endif
  @endforeach

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="gourou/js/main.js"></script>
</body>

</html>