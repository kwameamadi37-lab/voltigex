<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ config('app.meta.title') }} - Tableau d'administration</title>
    <link rel="stylesheet" href="myadmin/assets/css/style.css">
    <link rel="stylesheet" href="myadmin/assets/css/carousel.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <script src="https://cdn.jsdelivr.net/npm/lucide@latest/dist/umd/lucide.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
    <link rel="shortcut icon" type="image/x-icon" href="{{ config('app.favicon') }}">
    
    <!-- Auth Helper Script -->
    <script src="/assets/js/auth-helper.js"></script>
</head>
<body>
    <div class="app-container">
        <!-- Header -->
        @include('layouts.utilisateur.header')
        <!-- Main Content -->
        <main class="main-content">
            <div class="hero-section">
                <h1 class="hero-title">Bonjour <span id="user-name">Client</span></h1>
                <p class="hero-subtitle" id="user-email">Client@gmail.com</p>
                <div class="balance-card">
                    <div class="balance-info">
                        <div class="card-icon">
                            <img width="50" src="myadmin/assets/images/credit-card-gold.png" alt="Carte bancaire">
                        </div>
                        <div class="balance-details">
                            <p class="balance-label">SOLDE DISPONIBILE</p>
                            <p class="balance-amount" id="balance-amount">
                                €0.00
                            </p>
                        </div>
                    </div>
                    <button id="toggle-balance" class="toggle-balance-btn">
                        <i data-lucide="eye-off"></i>
                    </button>
                </div>
            </div>

            <div class="content-section">
                <h2 class="section-title">Nos services les plus utilisés</h2>
                <div class="services-grid">
                    <a href="{{ route('virements') }}" class="service-card">
                        <div class="service-icon">
                            <i data-lucide="arrow-down-circle"></i>
                        </div>
                        <p class="service-name">Virements</p>
                    </a>
                    <a href="#" class="service-card">
                        <div class="service-icon">
                            <i data-lucide="receipt"></i>
                        </div>
                        <p class="service-name">Factures</p>
                    </a>
                    <a href="{{ route('virementcreate') }}" class="service-card">
                        <div class="service-icon">
                            <i data-lucide="arrow-up-circle"></i>
                        </div>
                        <p class="service-name">Retrait</p>
                    </a>
                    <a href="#" class="service-card">
                        <div class="service-icon">
                            <i data-lucide="trending-up"></i>
                        </div>
                        <p class="service-name">Statistiques</p>
                    </a>
                    <a href="{{ route('carte') }}" class="service-card">
                        <div class="service-icon">
                            <i data-lucide="wallet"></i>
                        </div>
                        <p class="service-name">Cartes</p>
                    </a>
                    <a href="{{ route('parametre') }}" class="service-card">
                        <div class="service-icon">
                            <i data-lucide="shield"></i>
                        </div>
                        <p class="service-name">Sécurité</p>
                    </a>
                </div>

                <div class="promo-card">
                    <div class="promo-info">
                        <div class="promo-icon">
                            <i data-lucide="credit-card"></i>
                        </div>
                        <div class="promo-details">
                            <p class="promo-title">FinexB Days!</p>
                            <p class="promo-subtitle">Profitez de nos offres spéciales</p>
                        </div>
                    </div>                    
                    <span data-lucide="chevron-right" class="promo-arrow mobile-only"></span>
                    <a href="#" class="promo-btn desktop-only">                        
                        <span>Découvrir les offres</span>
                    </a>
                </div>

                <div class="suggested-section">
                    <div class="section-header">
                        <h2 class="section-title">Suggérés pour vous</h2>
                    </div>

                    <!-- Mobile Carousel -->
                    <div class="carousel-container mobile-only">
                        <div class="carousel-items">
                            <div class="carousel-item" style="background-image: url('myadmin/assets/images/savings-account.png')">
                                <p class="carousel-item-title">Épargne</p>
                            </div>
                            <div class="carousel-item" style="background-image: url('myadmin/assets/images/diversified-investment-portfolio.png')">
                                <p class="carousel-item-title">Investissements</p>
                            </div>
                            <div class="carousel-item" style="background-image: url('myadmin/assets/images/insurance-services.png')">
                                <p class="carousel-item-title">Assurances</p>
                            </div>
                            <div class="carousel-item" style="background-image: url('myadmin/assets/images/placeholder-credit.jpg')">
                                <p class="carousel-item-title">Crédits</p>
                            </div>
                        </div>
                    </div>

                    <!-- Desktop Grid -->
                    <div class="suggested-grid desktop-only">
                        <a href="#" class="suggested-card">
                            <div class="suggested-image" style="background-image: url('myadmin/assets/images/grid-1.webp')"></div>
                            <div class="suggested-content">
                                <h3 class="suggested-title">Épargne</h3>
                                <p class="suggested-description">Faites fructifier votre argent avec nos solutions d'épargne</p>
                                <div class="suggested-link">
                                    <span>En savoir plus</span>
                                    <i data-lucide="chevron-right"></i>
                                </div>
                            </div>
                        </a>
                        <a href="#" class="suggested-card">
                            <div class="suggested-image" style="background-image: url('myadmin/assets/images/grid-2.webp')"></div>
                            <div class="suggested-content">
                                <h3 class="suggested-title">Investissements</h3>
                                <p class="suggested-description">Diversifiez votre portefeuille avec nos produits d'investissement</p>
                                <div class="suggested-link">
                                    <span>En savoir plus</span>
                                    <i data-lucide="chevron-right"></i>
                                </div>
                            </div>
                        </a>
                        <a href="#" class="suggested-card">
                            <div class="suggested-image" style="background-image: url('myadmin/assets/images/grid-3.jpg')"></div>
                            <div class="suggested-content">
                                <h3 class="suggested-title">Assurances</h3>
                                <p class="suggested-description">Protégez ce qui compte avec nos offres d'assurance</p>
                                <div class="suggested-link">
                                    <span>En savoir plus</span>
                                    <i data-lucide="chevron-right"></i>
                                </div>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </main>
        @include('layouts.utilisateur.footer')
    </div>

    <script src="myadmin/assets/js/main.js"></script>
    <script src="myadmin/assets/js/index.js"></script>
    
    <!-- User Data Loading -->
    <script>
        // Load user data on page load
        document.addEventListener('DOMContentLoaded', function() {
            // If using API authentication, load user data
            if (typeof AuthHelper !== 'undefined' && AuthHelper.isAuthenticated()) {
                const user = AuthHelper.getUserData();
                
                // Update user information in the UI
                if (user) {
                    document.getElementById('user-name').textContent = user.alias || user.email;
                    document.getElementById('user-email').textContent = user.email;
                }
                
                // Load user balance and other data via API
                loadUserData();
            } else {
                // If not authenticated, redirect to login
                window.location.href = '/login';
            }
        });
        
        // Load user data via API
        async function loadUserData() {
            try {
                const response = await AuthHelper.apiRequest('/api/user');
                if (response && response.ok) {
                    const userData = await response.json();
                    
                    // Update balance (you can add more fields as needed)
                    // For now, we'll keep it simple
                    console.log('User data loaded:', userData);
                }
            } catch (error) {
                console.error('Error loading user data:', error);
            }
        }
    </script>
</body>
</html>
