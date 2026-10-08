<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Services | Voltigex</title>
    <meta name="description" content="Découvrez nos services bancaires innovants pour particuliers et professionnels">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="shortcut icon" type="image/x-icon" href="{{ config('app.favicon') }}">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .fade-in { opacity: 0; transform: translateY(20px); transition: all 0.6s ease; }
        .fade-in.visible { opacity: 1; transform: translateY(0); }
        .card-hover { transition: transform 0.3s ease, box-shadow 0.3s ease; }
        .card-hover:hover { transform: translateY(-5px); box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1); }
        .tab-content { display: none; }
        .tab-content.active { display: block; }
        .tab-button.active { background-color: #1e3a8a; color: white; }
    </style>
</head>
<body class="bg-white">
   @include('layouts/headerglobal')

    <!-- Hero Section -->
    <section class="bg-gradient-to-r from-primary to-[#082054] text-white py-20">
        <div class="container mx-auto px-4">
            <div class="max-w-3xl mx-auto text-center fade-in">
                <h1 class="text-4xl md:text-5xl font-bold mb-6">Nos services bancaires</h1>
                <p class="text-xl opacity-90 mb-8">
                    Découvrez notre gamme complète de services bancaires innovants conçus pour simplifier votre vie financière.
                </p>                
            </div>
        </div>
    </section>

    <!-- Services List -->
    <section class="py-20 bg-white">
        <div class="container mx-auto px-4">
            <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                <!-- Service 1 -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden card-hover fade-in">
                    <div class="h-48 overflow-hidden">
                        <img src="https://images.unsplash.com/photo-1563013544-824ae1b704d3?q=80&w=500&auto=format&fit=crop" 
                             alt="Banque Mobile" 
                             class="w-full h-full object-cover">
                    </div>
                    <div class="p-6">
                        <div class="bg-blue-50 text-blue-600 p-3 rounded-lg inline-block mb-4">
                            <i class="fas fa-mobile-alt text-xl"></i>
                        </div>
                        <h3 class="text-2xl font-bold mb-3">Banque Mobile</h3>
                        <p class="text-gray-600 mb-4">
                            Gérez vos comptes, effectuez des virements et payez vos factures depuis notre application mobile intuitive.
                        </p>
                        <div class="mb-6">
                            <h4 class="font-semibold mb-2">Caractéristiques principales :</h4>
                            <ul class="space-y-2">
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Application disponible sur iOS et Android</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Virements instantanés 24/7</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Gestion des cartes en temps réel</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Catégorisation automatique des dépenses</span>
                                </li>
                            </ul>
                        </div>
                        <a href="" class="w-full bg-primary text-white px-4 py-2 rounded-md hover:bg-primary-dark transition-colors inline-block text-center">
                           Ouvrir un compte <i class="fas fa-chevron-right ml-1"></i>
                       </a>
                    </div>
                </div>

                <!-- Service 2 -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden card-hover fade-in">
                    <div class="h-48 overflow-hidden">
                        <img src="https://images.unsplash.com/photo-1556742502-ec7c0e9f34b1?q=80&w=500&auto=format&fit=crop" 
                             alt="Cartes Intelligentes" 
                             class="w-full h-full object-cover">
                    </div>
                    <div class="p-6">
                        <div class="bg-green-50 text-green-600 p-3 rounded-lg inline-block mb-4">
                            <i class="fas fa-credit-card text-xl"></i>
                        </div>
                        <h3 class="text-2xl font-bold mb-3">Cartes Intelligentes</h3>
                        <p class="text-gray-600 mb-4">
                            Des cartes bancaires qui s'adaptent à vos besoins avec contrôle des dépenses et sécurité renforcée.
                        </p>
                        <div class="mb-6">
                            <h4 class="font-semibold mb-2">Caractéristiques principales :</h4>
                            <ul class="space-y-2">
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Cartes physiques et virtuelles</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Personnalisation des plafonds en temps réel</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Paiements sans contact et mobiles</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Assurances et garanties incluses</span>
                                </li>
                            </ul>
                        </div>
                        <a href="/sign-up" class="w-full bg-primary text-white px-4 py-2 rounded-md hover:bg-primary-dark transition-colors inline-block text-center">
                            Ouvrir un compte <i class="fas fa-chevron-right ml-1"></i>
                        </a>
                    </div>
                </div>

                <!-- Service 3 -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden card-hover fade-in">
                    <div class="h-48 overflow-hidden">
                        <img src="https://images.unsplash.com/photo-1563986768494-4dee2763ff3f?q=80&w=500&auto=format&fit=crop" 
                             alt="Sécurité Avancée" 
                             class="w-full h-full object-cover">
                    </div>
                    <div class="p-6">
                        <div class="bg-purple-50 text-purple-600 p-3 rounded-lg inline-block mb-4">
                            <i class="fas fa-shield-alt text-xl"></i>
                        </div>
                        <h3 class="text-2xl font-bold mb-3">Sécurité Avancée</h3>
                        <p class="text-gray-600 mb-4">
                            Protection de vos données et de vos transactions avec authentification biométrique et surveillance 24/7.
                        </p>
                        <div class="mb-6">
                            <h4 class="font-semibold mb-2">Caractéristiques principales :</h4>
                            <ul class="space-y-2">
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Authentification biométrique</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Surveillance des transactions en temps réel</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Alertes de sécurité personnalisables</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Protection contre la fraude</span>
                                </li>
                            </ul>
                        </div>
                        <a href="/sign-up" class="w-full bg-primary text-white px-4 py-2 rounded-md hover:bg-primary-dark transition-colors inline-block text-center">
                           Ouvrir un compte <i class="fas fa-chevron-right ml-1"></i>
                       </a>
                    </div>
                </div>

                <!-- Service 4 -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden card-hover fade-in">
                    <div class="h-48 overflow-hidden">
                        <img src="https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?q=80&w=500&auto=format&fit=crop" 
                             alt="Épargne Intelligente" 
                             class="w-full h-full object-cover">
                    </div>
                    <div class="p-6">
                        <div class="bg-orange-50 text-orange-600 p-3 rounded-lg inline-block mb-4">
                            <i class="fas fa-piggy-bank text-xl"></i>
                        </div>
                        <h3 class="text-2xl font-bold mb-3">Épargne Intelligente</h3>
                        <p class="text-gray-600 mb-4">
                            Solutions d'épargne automatique et personnalisée pour atteindre vos objectifs financiers.
                        </p>
                        <div class="mb-6">
                            <h4 class="font-semibold mb-2">Caractéristiques principales :</h4>
                            <ul class="space-y-2">
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Épargne automatique basée sur vos habitudes</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Objectifs d'épargne personnalisables</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Comptes rémunérés compétitifs</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Analyse et conseils d'épargne</span>
                                </li>
                            </ul>
                        </div>
                        <a href="/sign-up" class="w-full bg-primary text-white px-4 py-2 rounded-md hover:bg-primary-dark transition-colors inline-block text-center">
                           Ouvrir un compte <i class="fas fa-chevron-right ml-1"></i>
                       </a>
                    </div>
                </div>

                <!-- Service 5 -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden card-hover fade-in">
                    <div class="h-48 overflow-hidden">
                        <img src="https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=500&auto=format&fit=crop" 
                             alt="Services Professionnels" 
                             class="w-full h-full object-cover">
                    </div>
                    <div class="p-6">
                        <div class="bg-red-50 text-red-600 p-3 rounded-lg inline-block mb-4">
                            <i class="fas fa-briefcase text-xl"></i>
                        </div>
                        <h3 class="text-2xl font-bold mb-3">Services Professionnels</h3>
                        <p class="text-gray-600 mb-4">
                            Solutions dédiées aux entrepreneurs, freelances et entreprises pour optimiser leur gestion financière.
                        </p>
                        <div class="mb-6">
                            <h4 class="font-semibold mb-2">Caractéristiques principales :</h4>
                            <ul class="space-y-2">
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Comptes professionnels sans frais cachés</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Intégration avec les logiciels de comptabilité</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Cartes professionnelles avec contrôle des dépenses</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Support dédié aux professionnels</span>
                                </li>
                            </ul>
                        </div>
                        <a href="/sign-up" class="w-full bg-primary text-white px-4 py-2 rounded-md hover:bg-primary-dark transition-colors inline-block text-center">
                           Ouvrir un compte <i class="fas fa-chevron-right ml-1"></i>
                       </a>
                    </div>
                </div>

                <!-- Service 6 -->
                <div class="bg-white rounded-xl shadow-lg overflow-hidden card-hover fade-in">
                    <div class="h-48 overflow-hidden">
                        <img src="https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?q=80&w=500&auto=format&fit=crop" 
                             alt="Investissements" 
                             class="w-full h-full object-cover">
                    </div>
                    <div class="p-6">
                        <div class="bg-indigo-50 text-indigo-600 p-3 rounded-lg inline-block mb-4">
                            <i class="fas fa-chart-line text-xl"></i>
                        </div>
                        <h3 class="text-2xl font-bold mb-3">Investissements</h3>
                        <p class="text-gray-600 mb-4">
                            Plateforme d'investissement accessible avec conseils personnalisés et frais transparents.
                        </p>
                        <div class="mb-6">
                            <h4 class="font-semibold mb-2">Caractéristiques principales :</h4>
                            <ul class="space-y-2">
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Investissement à partir de 1€</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Portefeuilles diversifiés et personnalisés</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Frais transparents et compétitifs</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Conseils d'investissement automatisés</span>
                                </li>
                            </ul>
                        </div>
                        <a href="/sign-up" class="w-full bg-primary text-white px-4 py-2 rounded-md hover:bg-primary-dark transition-colors inline-block text-center">
                           Ouvrir un compte <i class="fas fa-chevron-right ml-1"></i>
                       </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Client Types -->
    <section class="py-20 bg-gray-50">
        <div class="container mx-auto px-4">
            <div class="text-center max-w-3xl mx-auto mb-16 fade-in">
                <span class="text-sm font-medium text-primary bg-primary/10 px-4 py-1 rounded-full">Solutions adaptées</span>
                <h2 class="text-3xl md:text-4xl font-bold mt-4 mb-6">Des services pour tous les profils</h2>
                <p class="text-lg text-gray-600">
                    Que vous soyez un particulier, un professionnel ou une entreprise, nous avons des solutions adaptées à vos besoins.
                </p>
            </div>

            <div class="max-w-5xl mx-auto">
                <!-- Tab Navigation -->
                <div class="flex justify-center mb-8">
                    <div class="bg-gray-200 rounded-lg p-1 flex">
                        <button class="tab-button active px-6 py-2 rounded-md transition-colors" data-tab="personal">Particuliers</button>
                        <button class="tab-button px-6 py-2 rounded-md transition-colors" data-tab="professional">Professionnels</button>
                        <button class="tab-button px-6 py-2 rounded-md transition-colors" data-tab="business">Entreprises</button>
                    </div>
                </div>

                <!-- Tab Content -->
                <div id="personal" class="tab-content active bg-white p-8 rounded-xl shadow-md">
                    <div class="grid md:grid-cols-2 gap-8 items-center">
                        <div>
                            <h3 class="text-2xl font-bold mb-4">Services pour particuliers</h3>
                            <p class="text-gray-600 mb-6">
                                Des solutions bancaires complètes pour gérer votre argent au quotidien, épargner et préparer votre avenir.
                            </p>
                            <ul class="space-y-3 mb-6">
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Compte courant sans frais cachés</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Cartes bancaires adaptées à vos besoins</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Épargne automatique et intelligente</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Application mobile intuitive</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Support client 7j/7</span>
                                </li>
                            </ul>
                            <a href="#" class="bg-primary text-white px-6 py-2 rounded-md hover:bg-primary-dark transition-colors">
                                Découvrir nos offres
                            </a>
                        </div>
                        <div class="relative">
                            <img src="https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?q=80&w=500&auto=format&fit=crop" 
                                 alt="Services pour particuliers" 
                                 class="rounded-lg shadow-lg w-full">
                        </div>
                    </div>
                </div>

                <div id="professional" class="tab-content bg-white p-8 rounded-xl shadow-md">
                    <div class="grid md:grid-cols-2 gap-8 items-center">
                        <div>
                            <h3 class="text-2xl font-bold mb-4">Services pour professionnels</h3>
                            <p class="text-gray-600 mb-6">
                                Des solutions adaptées aux besoins des entrepreneurs, freelances et professions libérales.
                            </p>
                            <ul class="space-y-3 mb-6">
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Compte professionnel sans frais mensuels</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Cartes business avec contrôle des dépenses</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Intégration avec les logiciels de comptabilité</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Gestion simplifiée des notes de frais</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Conseiller dédié pour les professionnels</span>
                                </li>
                            </ul>
                            <a href="{{ route('services') }}" class="bg-primary text-white px-6 py-2 rounded-md hover:bg-primary-dark transition-colors">
                                Découvrir nos offres
                            </a>
                        </div>
                        <div class="relative">
                            <img src="https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=500&auto=format&fit=crop" 
                                 alt="Services pour professionnels" 
                                 class="rounded-lg shadow-lg w-full">
                        </div>
                    </div>
                </div>

                <div id="business" class="tab-content bg-white p-8 rounded-xl shadow-md">
                    <div class="grid md:grid-cols-2 gap-8 items-center">
                        <div>
                            <h3 class="text-2xl font-bold mb-4">Services pour entreprises</h3>
                            <p class="text-gray-600 mb-6">
                                Des solutions complètes pour optimiser la gestion financière de votre entreprise, quelle que soit sa taille.
                            </p>
                            <ul class="space-y-3 mb-6">
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Comptes multi-devises et cartes corporate</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Gestion des accès et des droits pour votre équipe</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>API bancaire pour intégration à vos systèmes</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Solutions de paiement pour votre activité</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-2 mt-1"></i>
                                    <span>Accompagnement personnalisé par des experts</span>
                                </li>
                            </ul>
                            <a href="{{ route('services') }}" class="bg-primary text-white px-6 py-2 rounded-md hover:bg-primary-dark transition-colors">
                                Découvrir nos offres
                            </a>
                        </div>
                        <div class="relative">
                            <img src="https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=500&auto=format&fit=crop" 
                                 alt="Services pour entreprises" 
                                 class="rounded-lg shadow-lg w-full">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="py-16 bg-white">
        <div class="container mx-auto px-4">
            <div class="max-w-4xl mx-auto bg-gradient-to-r from-primary to-primary-dark text-white rounded-xl shadow-lg overflow-hidden">
                <div class="grid md:grid-cols-5">
                    <div class="md:col-span-3 p-8 md:p-12">
                        <h2 class="text-2xl font-bold mb-4">Besoin d'un conseil personnalisé ?</h2>
                        <p class="mb-6">
                            Nos conseillers sont à votre disposition pour vous aider à choisir les services les plus adaptés à votre situation.
                        </p>
                        <a href="{{ route('contact') }}" class="bg-secondary text-primary px-6 py-2 rounded-md font-semibold hover:bg-yellow-300 transition-colors">
                            Contacter un conseiller
                        </a>
                    </div>
                    <div class="hidden md:block md:col-span-2 relative">
                        <img src="bank/images/bk-2.jpeg" 
                             alt="Conseiller financier" 
                             class="w-full h-full object-cover">
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    @include('layouts/footerglobal')

    <script>
      tailwind.config = {
          theme: {
              extend: {
                  colors: {
                      primary: {
                          DEFAULT: '#1e3a8a',
                          dark: '#1e40af'
                      },
                      secondary: '#fbbf24'
                  }
              }
          }
      }
  </script>
    <script src="bank/js/main.js"></script>
    <script>
        // Tab functionality
        document.addEventListener('DOMContentLoaded', function() {
            const tabButtons = document.querySelectorAll('.tab-button');
            const tabContents = document.querySelectorAll('.tab-content');

            tabButtons.forEach(button => {
                button.addEventListener('click', () => {
                    const targetTab = button.getAttribute('data-tab');

                    // Remove active class from all buttons and contents
                    tabButtons.forEach(btn => btn.classList.remove('active'));
                    tabContents.forEach(content => content.classList.remove('active'));

                    // Add active class to clicked button and corresponding content
                    button.classList.add('active');
                    document.getElementById(targetTab).classList.add('active');
                });
            });
        });
    </script>
</body>
</html>
