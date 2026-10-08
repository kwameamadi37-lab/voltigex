<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FinexB - Cartes</title>
    <link rel="stylesheet" href="myadmin/assets/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/lucide@latest/dist/umd/lucide.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>

</head>
<body>
    <div class="app-container">
        @include('layouts.utilisateur.header')
        <main class="main-content">
            <div class="hero-section">
                <div class="card-container">
                    <div class="credit-card">
                        <div class="credit-card-header">
                            <div class="card-logo">
                                <img src="myadmin/assets/images/b-logo.png" alt="FinexB">
                            </div>
                            <div class="card-brand">
                                <img width="100" src="myadmin/assets/images/visa-logo-generic.png" alt="VISA">
                            </div>
                        </div>
                        <p class="card-number" id="card-number">
                            @if(Auth::user()->card_active)
                                @php
                                    $cardNumber = Auth::user()->card_number;
                                    $formattedCardNumber = implode(' ', str_split($cardNumber, 4));
                                @endphp
                                {{ $formattedCardNumber }}
                            @else
                                **** **** **** ****
                            @endif
                        </p>
                        <div class="card-footer">
                            <div class="card-expiry">
                                <p class="card-label">ÉCHÉANCE</p>
                                <p class="card-value">
                                    @if(Auth::user()->card_active)
                                        {{ Auth::user()->date_exp->format('m/Y') }}
                                    @else
                                        **/**
                                    @endif
                                </p>
                            </div>
                            <div class="card-holder">
                                <p class="card-label">TITULAIRE</p>
                                <p class="card-value">
                                    @php
                                        // Formatage du nom (première lettre majuscule, reste minuscule)
                                        $nom = ucfirst(strtolower(Auth()->user()->nom));
                                        $prenoms = explode(' ', Auth()->user()->prenom);
                                                
                                        // Formatage de chaque prénom (première lettre majuscule)
                                        $prenoms = array_map(function($p) {
                                            return ucfirst(strtolower($p));
                                        }, $prenoms);
                                                
                                        if(count($prenoms) === 1) {
                                            // Cas 1: Un seul prénom
                                            echo $prenoms[0].' '.$nom;
                                        } elseif(count($prenoms) === 2) {
                                            // Cas 2: Deux prénoms
                                            echo substr($prenoms[0], 0, 1).'. '.$prenoms[1].' '.$nom;
                                        } else {
                                            // Cas 3: Trois prénoms ou plus
                                            echo substr($prenoms[0], 0, 1).'. '.substr($prenoms[1], 0, 1).'. '.$prenoms[2].' '.$nom;
                                        }
                                    @endphp
                                </p>
                            </div>
                            <button id="toggle-card-number" class="toggle-card-btn">
                                <i data-lucide="eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="balance-details">
                        <div class="balance-box">
                            <div class="balance-row">
                                <div class="balance-col">
                                    <p class="text-gray-600">SOLDE DISPONIBLE</p>
                                    <p class="balance-amount" id="available-balance" style="color: #ffc107 !important;">
                                        @if (auth()->user()->solde==0)
                                            {{ Auth()->User()->devise }} 0
                                        @else                                        
                                            {{ number_format(Auth()->User()->solde, 2, ',', '.') }} {{ Auth()->User()->devise }}
                                        @endif
                                    </p>
                                </div>
                                <div class="balance-col">
                                    <p class="text-gray-600">SOLDE COMPTABLE</p>
                                    <p class="balance-amount" id="accounting-balance" style="color: #ffc107 !important;">
                                        @if (auth()->user()->solde==0)
                                            {{ Auth()->User()->devise }} 0
                                        @else                                        
                                            {{ number_format(Auth()->User()->solde, 2, ',', '.') }} {{ Auth()->User()->devise }}
                                        @endif
                                    </p>
                                </div>
                            </div>
                            <div class="balance-actions">
                                <button id="toggle-balance" class="text-gray-600 flex gap-2">
                                    <i data-lucide="eye-off"></i>
                                    <span>Masquer solde</span>
                                </button>
                            </div>
                            <div class="balance-info">
                                <p>IBAN : {{ Auth::user()->iban }}</p>
                            </div>
                        </div>
                        <button id="activate-card" class="activate-card-btn">
                            💳
                            <span>Activer la carte</span>
                        </button>
                    </div>
                </div>
            </div>

            <div class="content-section">
                <!-- <div class="action-buttons">
                    <button class="action-btn">Virement</button>
                    <button class="action-btn">Recharger</button>
                    <button class="action-btn">Prélèvements</button>
                </div> -->

                <div class="transactions-container">
                    <div class="transactions-section">
                        <div class="section-header">
                            <h2 class="section-title">Historique des virements</h2>
                            <a href="#" class="see-all-link">
                                Voir tous <i data-lucide="chevron-right"></i>
                            </a>
                        </div>
                        @if(count($historiques)!=0)
                              @foreach ($historiques as $item)
                                @php
                                    $isCredit = $item->type === 'debit';
                                    $date = \Carbon\Carbon::parse($item->date_transaction);
                                    $today = \Carbon\Carbon::today();
                                    $yesterday = \Carbon\Carbon::yesterday();
                            
                                    if ($date->isSameDay($today)) {
                                        $formattedDate = "Aujourd'hui, " . $date->format('H:i');
                                    } elseif ($date->isSameDay($yesterday)) {
                                        $formattedDate = "Hier, " . $date->format('H:i');
                                    } else {
                                        $formattedDate = $date->format('d/m/Y H:i');
                                    }
                            
                                    $formattedMontant = number_format($item->montant, 2, ',', ' ');
                                    $sign = $isCredit ? '+' : '-';
                                    $textClass = $isCredit ? 'text-green-600' : 'text-red-600';
                                    $bgClass = $isCredit ? 'transaction-type-success' : 'transaction-type';
                                    $icon = $isCredit ? 'arrow-down' : 'arrow-up';
                                @endphp
                                <div class="transactions-list">
                                    <div class="transaction-item">
                                        <div class="transaction-info">
                                            <p class="transaction-title">{{ $item->titre }}</p>
                                            <div class="flex items-center gap-1 text-white {{ $bgClass }}">
                                                <i data-lucide="{{ $icon }}"></i>
                                            </div>
                                        </div>
                                        <div class="{{ $textClass }}">{{ $sign }} {{ $formattedMontant }} {{ Auth()->User()->devise }}</div>
                                        <p class="transaction-date">{{ $formattedDate }}</p>
                                    </div>
                                </div>
                              @endforeach
                            @else
                              <p class="text-gray-400 text-center">Nessuna operazione effettuata su questo conto.</p>
                            @endif         
                    </div>

                    <div class="card-info-section desktop-only">
                        <h2 class="section-title">Informations carte</h2>
                        <div class="card-info-box">
                            <div class="info-item">
                                <i data-lucide="credit-card"></i>
                                <div class="info-content">
                                    <p class="info-title">Carte Visa Premium</p>
                                    <p class="info-subtitle">Solde total : 
                                        @if (auth()->user()->solde==0)
                                            {{ Auth()->User()->devise }} 0
                                        @else                                        
                                            {{ number_format(Auth()->User()->solde, 2, ',', '.') }} {{ Auth()->User()->devise }}
                                        @endif
                                    </p>
                                </div>
                            </div>                            
                            <div class="info-item">
                                <i data-lucide="alert-circle"></i>
                                <div class="info-content">
                                    <p class="info-title">Sécurité</p>
                                    <p class="info-subtitle">Paiements 3D Secure activés</p>
                                </div>
                            </div>
                            <a href="#" class="manage-settings-btn">Gérer les paramètres</a>
                        </div>
                    </div>
                </div>
            </div>
        </main>
        @include('layouts.utilisateur.footer')


        <div id="activate-modal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Activer votre carte</h3>
                    <button class="close-modal" id="close-activate-modal">
                        <i data-lucide="x"></i>
                    </button>
                </div>
                <form id="activate-card-form" class="modal-form">
                    <div class="form-group">
                        <label for="cardholderName">Nom sur la carte</label>
                        <input type="text" id="cardholderName" placeholder="JEAN DUPONT" required>
                    </div>
                    <div class="form-group">
                        <label for="cardNumber">Numéro de carte</label>
                        <input type="text" id="cardNumber" placeholder="4810 0012 3456 7840" maxlength="19" required>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="expiryDate">Date d'expiration</label>
                            <input type="text" id="expiryDate" placeholder="MM/AA" maxlength="5" required>
                        </div>
                        <div class="form-group">
                            <label for="cvv">CVV</label>
                            <input type="text" id="cvv" placeholder="123" maxlength="3" required>
                        </div>
                    </div>
                    <button type="submit" class="submit-btn">Activer la carte</button>
                </form>
            </div>
        </div>

        <div id="success-modal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <button class="close-modal" id="close-success-modal">
                        <i data-lucide="x"></i>
                    </button>
                </div>
                <div class="success-content">
                    <div class="success-icon">
                        <svg xmlns="http://www.w3.org/2000/svg" class="icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                        </svg>
                    </div>
                    <h3>Carte activée avec succès</h3>
                    <p>Votre carte a été activée et est maintenant prête à être utilisée pour vos transactions.</p>
                    <button id="close-success-btn" class="close-btn">Fermer</button>
                </div>
            </div>
        </div>
    </div>

    <script src="myadmin/assets/js/main.js"></script>
    <script src="myadmin/assets/js/cartes.js"></script>
</body>
</html>
