<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0"> 
    <title>Voltigex |  Votre banque en ligne innovante pour particuliers et professionnels</title>
    <meta name="description" content="Solutions bancaires innovantes pour particuliers et professionnels">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="shortcut icon" style="border-radius: 50%;" type="image/x-icon" href="bank/images/favicon.png">  
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .fade-in { opacity: 0; transform: translateY(20px); transition: all 0.6s ease; }
        .fade-in.visible { opacity: 1; transform: translateY(0); }
        .card-hover { transition: transform 0.3s ease, box-shadow 0.3s ease; }
        .card-hover:hover { transform: translateY(-5px); box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1); }
    </style>
</head>
<body class="bg-white">
   @include('layouts/headerglobal')      

    <!-- Hero Section -->
    <section class="relative overflow-hidden bg-gradient-to-r from-primary to-[#082054] text-white">
        <div class="absolute inset-0 z-0">
            <div class="absolute inset-0 bg-[url('bank/images/slider_img01.jpg')] bg-cover bg-center opacity-10"></div>
        </div>
        <div class="container mx-auto px-4 py-20 md:py-15 relative z-10">
            <div class="grid md:grid-cols-2 gap-12 items-center">
                <div class="space-y-6 fade-in order-last md:order-first">
                    <span class="inline-block bg-white/20 text-white px-4 py-1 rounded-full text-sm font-medium">
                        Banque en ligne innovante
                    </span>
                    <h1 class="text-4xl md:text-5xl lg:text-6xl font-bold leading-tight">
                        Votre argent, votre contrôle
                    </h1>
                    <p class="text-lg md:text-xl opacity-90 max-w-lg">
                        Une banque moderne qui s'adapte à votre style de vie. Gérez vos finances en toute simplicité, où que vous soyez.
                    </p>
                    <div class="flex flex-wrap gap-4">
                        <a href="{{ route('sign-up') }}" class="px-6 py-3 w-full md:w-auto text-center bg-secondary text-primary font-semibold rounded-full hover:bg-yellow-300 transition-colors">
                            Ouvrir un compte
                        </a>
                        <a href="{{ route('services') }}" class="px-6 py-3 border w-full md:w-auto text-center border-white/30 text-white rounded-full hover:bg-white/10 transition-colors">
                            Découvrir nos services
                        </a>
                    </div>
                </div>
                <div class="relative fade-in">
                    <img src="bank/images/banner-2.jpg" 
                         alt="Application bancaire mobile" 
                         class="rounded-2xl shadow-2xl w-full">
                    <div class="absolute -bottom-6 -left-6 bg-secondary text-black p-4 rounded-xl shadow-lg">
                        <div class="flex items-center">
                            <img  src="bank/images/certif.png" class="w-25 h-10 object-cover">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Feature Cards Section -->
    <section class="py-16 bg-gray-50">
        <div class="container mx-auto px-4">
            <div class="grid md:grid-cols-3 gap-8">
                <!-- Card 1: Sécurité maximale -->
                <div class="bg-[#1e3a8a] rounded-2xl p-8 text-white relative overflow-hidden fade-in card-hover">
                    <h3 class="text-3xl md:text-4xl font-bold mb-4">Sécurité maximale</h3>
                    <p class="text-white/90 mb-6 text-lg leading-relaxed">
                        Vos fonds sont protégés par les normes bancaires internationales les plus strictes et une technologie de pointe
                    </p>
                    <a href="{{ route('services') }}" class="text-white font-medium hover:underline inline-flex items-center group">
                        En savoir plus 
                        <i class="fas fa-arrow-right ml-2 group-hover:translate-x-1 transition-transform"></i>
                    </a>
                    <div class="absolute -bottom-8 -right-8 w-24 h-24 bg-white/10 rounded-full flex items-center justify-center">
                        <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center">
                            <i class="fas fa-shield-alt text-[#1e3a8a] text-2xl"></i>
                        </div>
                    </div>
                </div>

                <!-- Card 2: Accès 24/7 -->
                <div class="bg-[#1e3a8a] rounded-2xl p-8 text-white relative overflow-hidden fade-in card-hover">
                    <h3 class="text-3xl md:text-4xl font-bold mb-4">Accès 24/7</h3>
                    <p class="text-white/90 mb-6 text-lg leading-relaxed">
                        Gérez vos comptes et effectuez vos transactions à tout moment, où que vous soyez dans le monde
                    </p>
                    <a href="{{ route('services') }}" class="text-white font-medium hover:underline inline-flex items-center group">
                        En savoir plus 
                        <i class="fas fa-arrow-right ml-2 group-hover:translate-x-1 transition-transform"></i>
                    </a>
                    <div class="absolute -bottom-8 -right-8 w-24 h-24 bg-white/10 rounded-full flex items-center justify-center">
                        <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center">
                            <i class="fas fa-clock text-[#1e3a8a] text-2xl"></i>
                        </div>
                    </div>
                </div>

                <!-- Card 3: Support expert -->
                <div class="bg-[#1e3a8a] rounded-2xl p-8 text-white relative overflow-hidden fade-in card-hover">
                    <h3 class="text-3xl md:text-4xl font-bold mb-4">Support expert</h3>
                    <p class="text-white/90 mb-6 text-lg leading-relaxed">
                        Une équipe de conseillers bancaires dédiés à votre service pour répondre à tous vos besoins financiers
                    </p>
                    <a href="{{ route('services') }}" class="text-white font-medium hover:underline inline-flex items-center group">
                        En savoir plus 
                        <i class="fas fa-arrow-right ml-2 group-hover:translate-x-1 transition-transform"></i>
                    </a>
                    <div class="absolute -bottom-8 -right-8 w-24 h-24 bg-white/10 rounded-full flex items-center justify-center">
                        <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center">
                            <i class="fas fa-headset text-[#1e3a8a] text-2xl"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="py-20 bg-white">
        <div class="container mx-auto px-4">
            <div class="text-center max-w-3xl mx-auto mb-16 fade-in">
                <span class="text-sm font-medium text-primary bg-secondary px-4 py-1 rounded-full">Nos services</span>
                <h2 class="text-3xl md:text-4xl font-bold mt-4 mb-6">Une banque qui s'adapte à votre vie</h2>
                <p class="text-lg text-gray-600">
                    Découvrez nos solutions bancaires innovantes conçues pour simplifier votre quotidien financier.
                </p>
            </div>

            <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                <div class="bg-white p-8 rounded-xl shadow-lg card-hover fade-in">
                    <div class="bg-blue-50 text-blue-600 p-3 rounded-lg inline-block mb-4">
                        <i class="fas fa-mobile-alt text-xl"></i>
                    </div>
                    <h3 class="text-xl font-bold mb-3">Banque Mobile</h3>
                    <p class="text-gray-600 mb-4">
                        Gérez vos comptes, effectuez des virements et payez vos factures depuis notre application mobile intuitive.
                    </p>
                    <a href="{{ route('services') }}" class="text-primary font-medium hover:underline flex items-center">
                        En savoir plus <i class="fas fa-chevron-right ml-1"></i>
                    </a>
                </div>

                <div class="bg-white p-8 rounded-xl shadow-lg card-hover fade-in">
                    <div class="bg-green-50 text-green-600 p-3 rounded-lg inline-block mb-4">
                        <i class="fas fa-credit-card text-xl"></i>
                    </div>
                    <h3 class="text-xl font-bold mb-3">Cartes Intelligentes</h3>
                    <p class="text-gray-600 mb-4">
                        Des cartes bancaires qui s'adaptent à vos besoins avec contrôle des dépenses et sécurité renforcée.
                    </p>
                    <a href="{{ route('services') }}" class="text-primary font-medium hover:underline flex items-center">
                        En savoir plus <i class="fas fa-chevron-right ml-1"></i>
                    </a>
                </div>

                <div class="bg-white p-8 rounded-xl shadow-lg card-hover fade-in">
                    <div class="bg-purple-50 text-purple-600 p-3 rounded-lg inline-block mb-4">
                        <i class="fas fa-shield-alt text-xl"></i>
                    </div>
                    <h3 class="text-xl font-bold mb-3">Sécurité Avancée</h3>
                    <p class="text-gray-600 mb-4">
                        Protection de vos données et de vos transactions avec authentification biométrique et surveillance 24/7.
                    </p>
                    <a href="{{ route('services') }}" class="text-primary font-medium hover:underline flex items-center">
                        En savoir plus <i class="fas fa-chevron-right ml-1"></i>
                    </a>
                </div>

                <div class="bg-white p-8 rounded-xl shadow-lg card-hover fade-in">
                    <div class="bg-orange-50 text-orange-600 p-3 rounded-lg inline-block mb-4">
                        <i class="fas fa-piggy-bank text-xl"></i>
                    </div>
                    <h3 class="text-xl font-bold mb-3">Épargne Intelligente</h3>
                    <p class="text-gray-600 mb-4">
                        Solutions d'épargne automatique et personnalisée pour atteindre vos objectifs financiers.
                    </p>
                    <a href="{{ route('services') }}" class="text-primary font-medium hover:underline flex items-center">
                        En savoir plus <i class="fas fa-chevron-right ml-1"></i>
                    </a>
                </div>

                <div class="bg-white p-8 rounded-xl shadow-lg card-hover fade-in">
                    <div class="bg-red-50 text-red-600 p-3 rounded-lg inline-block mb-4">
                        <i class="fas fa-briefcase text-xl"></i>
                    </div>
                    <h3 class="text-xl font-bold mb-3">Services Professionnels</h3>
                    <p class="text-gray-600 mb-4">
                        Solutions dédiées aux entrepreneurs, freelances et entreprises pour optimiser leur gestion financière.
                    </p>
                    <a href="{{ route('services') }}" class="text-primary font-medium hover:underline flex items-center">
                        En savoir plus <i class="fas fa-chevron-right ml-1"></i>
                    </a>
                </div>

                <div class="bg-white p-8 rounded-xl shadow-lg card-hover fade-in">
                    <div class="bg-indigo-50 text-indigo-600 p-3 rounded-lg inline-block mb-4">
                        <i class="fas fa-chart-line text-xl"></i>
                    </div>
                    <h3 class="text-xl font-bold mb-3">Investissements</h3>
                    <p class="text-gray-600 mb-4">
                        Plateforme d'investissement accessible avec conseils personnalisés et frais transparents.
                    </p>
                    <a href="{{ route('services') }}" class="text-primary font-medium hover:underline flex items-center">
                        En savoir plus <i class="fas fa-chevron-right ml-1"></i>
                    </a>
                </div>
            </div>
        </div>
    </section>

    <section class="py-10 bg-gray-50">
        <div class="container mx-auto px-4">
            <div class="grid md:grid-cols-2 gap-12 items-center">
                <div class="order-2 md:order-2">
                    <h2 class="text-3xl md:text-4xl font-bold mt-4 mb-6">Votre banque dans votre poche</h2>
                    <div class="space-y-6">
                        <div class="flex items-start">
                            <div class="feature-icon mr-4 flex-shrink-0">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-circle-check-big h-6 w-6">
                                    <path d="M21.801 10A10 10 0 1 1 17 3.335"></path>
                                    <path d="m9 11 3 3L22 4"></path>
                                </svg>
                            </div>
                            <div>
                                <h3 class="font-bold mb-1">Gestion de comptes simplifiée</h3>
                                <p class="text-gray-600">Consultez vos soldes, historiques de transactions et relevés bancaires en temps réel.</p>
                            </div>
                        </div>
                        <div class="flex items-start">
                            <div class="feature-icon mr-4 flex-shrink-0">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-circle-check-big h-6 w-6">
                                    <path d="M21.801 10A10 10 0 1 1 17 3.335"></path>
                                    <path d="m9 11 3 3L22 4"></path>
                                </svg>
                            </div>
                            <div>
                                <h3 class="font-bold mb-1">Paiements instantanés</h3>
                                <p class="text-gray-600">Effectuez des virements entre amis ou réglez vos factures en quelques secondes.</p>
                            </div>
                        </div>
                        <div class="flex items-start">
                            <div class="feature-icon mr-4 flex-shrink-0">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-circle-check-big h-6 w-6">
                                    <path d="M21.801 10A10 10 0 1 1 17 3.335"></path>
                                    <path d="m9 11 3 3L22 4"></path>
                                </svg>
                            </div>
                            <div>
                                <h3 class="font-bold mb-1">Contrôle de vos cartes</h3>
                                <p class="text-gray-600">Gérez vos plafonds, bloquez temporairement votre carte ou créez des cartes virtuelles.</p>
                            </div>
                        </div>
                        <div class="flex items-start">
                            <div class="feature-icon mr-4 flex-shrink-0">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-circle-check-big h-6 w-6">
                                    <path d="M21.801 10A10 10 0 1 1 17 3.335"></path>
                                    <path d="m9 11 3 3L22 4"></path>
                                </svg>
                            </div>
                            <div>
                                <h3 class="font-bold mb-1">Investissements intelligents</h3>
                                <p class="text-gray-600">Investissez dans des produits financiers sécurisés avec des rendements garantis.</p>
                            </div>
                        </div>
                        <div class="flex items-start">
                            <div class="feature-icon mr-4 flex-shrink-0">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-circle-check-big h-6 w-6">
                                    <path d="M21.801 10A10 10 0 1 1 17 3.335"></path>
                                    <path d="m9 11 3 3L22 4"></path>
                                </svg>
                            </div>
                            <div>
                                <h3 class="font-bold mb-1">Assistance client</h3>
                                <p class="text-gray-600">Assistance client 24/7 pour résoudre vos questions et problèmes.</p>
                            </div>
                        </div>                        
                    </div>
                </div>
                <div class="order-1 md:order-1 flex justify-center">
                    <div class="relative">
                        <img alt="Application mobile Voltigex" class="rounded-3xl shadow-2xl border-8 border-white" style="color:transparent" srcset="bank/images/banner1.jpg" src="bank/images/banner1.jpg">
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Mobile App Section -->
    <section id="application-mobile" class="py-20 bg-gradient-to-br from-primary to-[#082054] text-white relative overflow-hidden">
        <div class="absolute inset-0 opacity-10">
            <div class="absolute inset-0" style="background-image: radial-gradient(circle at 20% 50%, white 1px, transparent 1px); background-size: 50px 50px;"></div>
        </div>
        <div class="container mx-auto px-4 relative z-10">
            <div class="grid md:grid-cols-2 gap-12 items-center max-w-6xl mx-auto">
                <div class="fade-in">
                    <span class="inline-block text-primary bg-secondary px-4 py-1 rounded-full text-sm font-medium mb-4">
                        Application Mobile
                    </span>
                    <h2 class="text-4xl md:text-5xl font-bold mb-6">
                        Téléchargez notre application mobile
                    </h2>
                    <p class="text-xl opacity-90 mb-8 leading-relaxed">
                        Les utilisateurs doivent télécharger l'application mobile pour se connecter et gérer leur compte bancaire et leurs opérations en toute simplicité.
                    </p>
                    <div class="space-y-4 mb-8">
                        <div class="flex items-center">
                            <div class="w-12 h-12 bg-secondary text-primary rounded-full flex items-center justify-center mr-4">
                                <i class="fas fa-check text-primary"></i>
                            </div>
                            <span class="text-lg">Gestion complète de votre compte</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-12 h-12 bg-secondary text-primary rounded-full flex items-center justify-center mr-4">
                                <i class="fas fa-check text-primary"></i>
                            </div>
                            <span class="text-lg">Virements et opérations bancaires</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-12 h-12 bg-secondary text-primary rounded-full flex items-center justify-center mr-4">
                                <i class="fas fa-check text-primary"></i>
                            </div>
                            <span class="text-lg">Notifications en temps réel</span>
                        </div>
                        <div class="flex items-center">
                            <div class="w-12 h-12 bg-secondary text-primary rounded-full flex items-center justify-center mr-4">
                                <i class="fas fa-check text-primary"></i>
                            </div>
                            <span class="text-lg">Sécurité renforcée</span>
                        </div>
                    </div>
                    <div class="flex flex-wrap gap-4">
                        <a href="#" class="inline-block">
                            <img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/fr-fr?size=250x83&releaseDate=1289944800" alt="Télécharger sur l'App Store" class="h-14">
                        </a>
                        <a href="#" class="inline-block">
                            <img src="https://play.google.com/intl/en_us/badges/static/images/badges/fr_badge_web_generic.png" alt="Disponible sur Google Play" class="h-14">
                        </a>
                    </div>
                </div>
                <div class="flex flex-col md:flex-row items-center gap-8 fade-in">                    
                    <!-- QR Code -->
                    <div class="flex flex-col items-center text-white">
                        @include('partials.app-qr')
                    </div>
                    <!-- Mockup Image -->
                    <div class="flex-1 flex justify-center">
                        <img src="assets/images/apk.png" 
                             alt="Mockup Application Mobile Voltigex" 
                             class="max-w-sm rounded-2xl shadow-2xl">
                    </div>
                </div>
            </div>
        </div>
    </section>


    <section class="py-10 bg-white">
        <div class="container mx-auto px-4">
          <div class="text-center max-w-3xl mx-auto mb-16">
            <span class="text-sm font-medium text-primary bg-secondary px-4 py-1 rounded-full">Comptes bancaires</span>
            <h2 class="text-3xl md:text-4xl font-bold mt-4 mb-6">Le compte bancaire qui vous correspond</h2>
            <p class="text-lg text-gray-600">Une solution adaptée à tous les profils, des étudiants aux professionnels.</p>
          </div>
          <div dir="ltr" data-orientation="horizontal" class="max-w-5xl mx-auto">
            <div data-state="active" data-orientation="horizontal" role="tabpanel" aria-labelledby="radix-«R99tqnb»-trigger-personal" id="radix-«R99tqnb»-content-personal" tabindex="0" class="mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 bg-white p-8 rounded-xl shadow-md" style="">
              <div class="grid md:grid-cols-2 gap-8 items-center">
                <div class="relative">
                    <img alt="Compte Standard" loading="lazy" width="500" height="400" decoding="async" data-nimg="1" class="rounded-lg shadow-lg" style="color:transparent" srcset="bank/images/about.jpg" src="bank/images/about.jpg">
                </div>
                <div>
                  <h3 class="text-2xl font-bold mb-4">Compte bancaire</h3>
                  <p class="text-gray-600 mb-6">Gérer votre argent au quotidien, sans frais cachés.</p>
                  <ul class="space-y-3 mb-6">
                    <li class="flex items-start"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-circle-check-big h-5 w-5 text-primary mr-2 mt-0.5">
                        <path d="M21.801 10A10 10 0 1 1 17 3.335"></path>
                        <path d="m9 11 3 3L22 4"></path>
                      </svg><span>Carte bancaire internationale incluse</span></li>
                    <li class="flex items-start"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-circle-check-big h-5 w-5 text-primary mr-2 mt-0.5">
                        <path d="M21.801 10A10 10 0 1 1 17 3.335"></path>
                        <path d="m9 11 3 3L22 4"></path>
                      </svg><span>Virements instantanés gratuits</span></li>
                    <li class="flex items-start"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-circle-check-big h-5 w-5 text-primary mr-2 mt-0.5">
                        <path d="M21.801 10A10 10 0 1 1 17 3.335"></path>
                        <path d="m9 11 3 3L22 4"></path>
                      </svg><span>Application mobile intuitive</span></li>
                    <li class="flex items-start"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-circle-check-big h-5 w-5 text-primary mr-2 mt-0.5">
                        <path d="M21.801 10A10 10 0 1 1 17 3.335"></path>
                        <path d="m9 11 3 3L22 4"></path>
                      </svg><span>Alertes de dépenses personnalisables</span></li>
                  </ul>
                  <div class="flex items-baseline mb-6"><span class="text-3xl font-bold">0€</span><span class="text-gray-600 ml-2">/ mois</span></div>
                </div>                
              </div>
            </div>
            <div data-state="inactive" data-orientation="horizontal" role="tabpanel" aria-labelledby="radix-«R99tqnb»-trigger-premium" hidden="" id="radix-«R99tqnb»-content-premium" tabindex="0" class="mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 bg-white p-8 rounded-xl shadow-md"></div>
            <div data-state="inactive" data-orientation="horizontal" role="tabpanel" aria-labelledby="radix-«R99tqnb»-trigger-business" hidden="" id="radix-«R99tqnb»-content-business" tabindex="0" class="mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 bg-white p-8 rounded-xl shadow-md"></div>
          </div>
        </div>
    </section>

    <!-- 3 Steps Process Section -->
    <section class="py-20 bg-white">
        <div class="container mx-auto px-4">
            <div class="text-center max-w-3xl mx-auto mb-16 fade-in">
                <span class="inline-block text-primary bg-secondary px-4 py-1 rounded-full text-sm font-medium mb-4">Notre processus simple</span>
                <h2 class="text-3xl md:text-4xl font-bold mt-4 mb-6">
                    Ouvrir un compte en <span class="text-secondary">3 étapes</span>
                </h2>
            </div>

            <div class="grid md:grid-cols-3 gap-8 max-w-6xl mx-auto">
                <!-- Step 1 -->
                <div class=" border-2 border-primary rounded-xl p-8 relative fade-in card-hover" style="border-width: 1.5px;">
                    <div class="flex justify-center mb-6">
                        <div class="w-16 h-16 bg-primary rounded-lg flex items-center justify-center">
                            <i class="fas fa-file-alt text-white text-2xl"></i>
                        </div>
                    </div>
                    <h3 class="text-xl font-bold text-primary mb-4 text-center">1. Inscrivez-vous</h3>
                    <p class="text-gray-700 leading-relaxed">
                        Créez votre compte en quelques minutes via notre plateforme sécurisée avec vérification d'identité simplifiée.
                    </p>
                    <div class="absolute -bottom-6 left-1/2 transform -translate-x-1/2 w-12 h-12 bg-white border-2 border-primary rounded-full flex items-center justify-center" style="border-width: 1.5px;">
                        <span class="text-primary font-bold text-lg">01</span>
                    </div>
                </div>

                <!-- Step 2 -->
                <div class=" border-2 border-primary rounded-xl p-8 relative fade-in card-hover" style="border-width: 1.5px;">
                    <div class="flex justify-center mb-6">
                        <div class="w-16 h-16 bg-primary rounded-lg flex items-center justify-center">
                            <i class="fas fa-envelope text-white text-2xl"></i>
                        </div>
                    </div>
                    <h3 class="text-xl font-bold text-primary mb-4 text-center">2. Recevez la confirmation</h3>
                    <p class="text-gray-700 leading-relaxed">
                        Vous recevrez un email de confirmation avec vos identifiants et les instructions pour activer votre compte. Vérifiez dans vos spams au besoin.
                    </p>
                    <div class="absolute -bottom-6 left-1/2 transform -translate-x-1/2 w-12 h-12 bg-white border-2 border-primary rounded-full flex items-center justify-center" style="border-width: 1.5px;">
                        <span class="text-primary font-bold text-lg">02</span>
                    </div>
                </div>

                <!-- Step 3 -->
                <div class="border-2 border-primary rounded-xl p-8 relative fade-in card-hover" style="border-width: 1.5px;">
                    <div class="flex justify-center mb-6">
                        <div class="w-16 h-16 bg-primary rounded-lg flex items-center justify-center">
                            <i class="fas fa-user-shield text-white text-2xl"></i>
                        </div>
                    </div>
                    <h3 class="text-xl font-bold text-primary mb-4 text-center">3. Accédez à votre espace administration</h3>
                    <p class="text-gray-700 leading-relaxed">
                        Connectez-vous avec vos identifiants pour accéder à votre espace client en ligne.
                    </p>
                    <div class="absolute -bottom-6 left-1/2 transform -translate-x-1/2 w-12 h-12 bg-white border-2 border-primary rounded-full flex items-center justify-center" style="border-width: 1.5px;">
                        <span class="text-primary font-bold text-lg">03</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- FAQ Section -->
    <section class="py-20 bg-gray-50">
        <div class="container mx-auto px-4">
            <div class="grid md:grid-cols-4 gap-8 max-w-7xl mx-auto">
                <!-- Sidebar -->
                <div class="md:col-span-1">
                    <div class="sticky top-8">
                        <span class="text-sm font-medium text-primary block mb-2">Questions fréquentes</span>
                        <h2 class="text-2xl md:text-3xl font-bold text-primary mb-8">
                            Réponses à vos <span class="italic">questions</span>
                        </h2>
                        <nav class="space-y-2">
                            <a href="#general" class="flex items-center p-3 bg-green-50 text-primary rounded-lg hover:bg-green-100 transition-colors">
                                <i class="fas fa-home text-primary mr-3"></i>
                                <span class="font-medium">Questions générales</span>
                            </a>
                            <a href="#community" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-gray-100 transition-colors">
                                <i class="fas fa-users text-primary mr-3"></i>
                                <span>Communauté</span>
                            </a>
                            <a href="#support" class="flex items-center p-3 text-gray-700 rounded-lg hover:bg-gray-100 transition-colors">
                                <i class="fas fa-comments text-primary mr-3"></i>
                                <span>Support</span>
                            </a>
                        </nav>
                    </div>
                </div>

                <!-- FAQ Content -->
                <div class="md:col-span-3 space-y-4">
                    <!-- FAQ Item 1 -->
                    <div class="bg-white rounded-xl shadow-md p-6 fade-in faq-item">
                        <div class="flex items-center justify-between cursor-pointer" onclick="toggleFaq(this)">
                            <h3 class="text-lg font-semibold text-gray-800">Comment ouvrir un compte bancaire chez Voltigex ?</h3>
                            <i class="fas fa-chevron-down text-primary faq-icon transition-transform"></i>
                        </div>
                        <div class="faq-content hidden mt-4">
                            <p class="text-gray-600 leading-relaxed">
                                Pour ouvrir un compte chez Voltigex, vous devez d'abord vous inscrire via notre site web. Après l'inscription, vous recevrez un email de bienvenue contenant un lien de téléchargement de l'application mobile ou un QR code. Une fois l'application téléchargée, vous pourrez vous connecter et gérer votre compte bancaire. Notez que les utilisateurs ne se connectent pas sur le web, mais uniquement via l'application mobile.
                            </p>
                        </div>
                    </div>

                    <!-- FAQ Item 2 -->
                    <div class="bg-white rounded-xl shadow-md p-6 fade-in faq-item">
                        <div class="flex items-center justify-between cursor-pointer" onclick="toggleFaq(this)">
                            <h3 class="text-lg font-semibold text-gray-800">Quels sont les frais bancaires appliqués ?</h3>
                            <i class="fas fa-chevron-down text-primary faq-icon transition-transform"></i>
                        </div>
                        <div class="faq-content hidden mt-4">
                            <p class="text-gray-600 leading-relaxed">
                                Voltigex propose une tarification transparente et compétitive. Les frais varient selon le type de compte et les services choisis. Les comptes courants de base sont généralement sans frais de tenue de compte, tandis que les comptes premium offrent des avantages supplémentaires. Les frais de transaction internationale sont compétitifs et varient selon le montant et la destination. Consultez notre grille tarifaire détaillée ou contactez notre service client pour plus d'informations.
                            </p>
                        </div>
                    </div>

                    <!-- FAQ Item 3 -->
                    <div class="bg-white rounded-xl shadow-md p-6 fade-in faq-item">
                        <div class="flex items-center justify-between cursor-pointer" onclick="toggleFaq(this)">
                            <h3 class="text-lg font-semibold text-gray-800">Comment sécuriser mon compte en ligne ?</h3>
                            <i class="fas fa-chevron-down text-primary faq-icon transition-transform"></i>
                        </div>
                        <div class="faq-content hidden mt-4">
                            <p class="text-gray-600 leading-relaxed">
                                La sécurité de votre compte est notre priorité. Nous utilisons l'authentification à deux facteurs, le cryptage de bout en bout, et des notifications en temps réel pour toutes les transactions. Assurez-vous d'utiliser un mot de passe fort, d'activer l'authentification biométrique si disponible, et de ne jamais partager vos identifiants. Toutes les transactions sont protégées par les normes bancaires internationales les plus strictes.
                            </p>
                        </div>
                    </div>

                    <!-- FAQ Item 4 -->
                    <div class="bg-white rounded-xl shadow-md p-6 fade-in faq-item">
                        <div class="flex items-center justify-between cursor-pointer" onclick="toggleFaq(this)">
                            <h3 class="text-lg font-semibold text-gray-800">Quels services bancaires sont disponibles à l'international ?</h3>
                            <i class="fas fa-chevron-down text-primary faq-icon transition-transform"></i>
                        </div>
                        <div class="faq-content hidden mt-4">
                            <p class="text-gray-600 leading-relaxed">
                                Voltigex opère dans plus de 45 pays à travers le monde. Nos services internationaux incluent les virements internationaux rapides et sécurisés vers plus de 150 pays, les cartes bancaires internationales, la gestion multi-devises, et l'accès à votre compte depuis n'importe où dans le monde via notre application mobile. Tous ces services sont accessibles directement depuis votre application mobile.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Anti-Fraud Section -->
    <section class="py-20 bg-gradient-to-br from-primary via-primary to-[#082054] text-white relative overflow-hidden">
        <div class="absolute inset-0 opacity-5">
            <div class="absolute inset-0" style="background-image: url('data:image/svg+xml,%3Csvg width=\"60\" height=\"60\" viewBox=\"0 0 60 60\" xmlns=\"http://www.w3.org/2000/svg\"%3E%3Cg fill=\"none\" fill-rule=\"evenodd\"%3E%3Cg fill=\"%23ffffff\" fill-opacity=\"1\"%3E%3Cpath d=\"M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z\"/%3E%3C/g%3E%3C/g%3E%3C/svg%3E');"></div>
        </div>
        <div class="container mx-auto px-4 relative z-10">
            <div class="grid md:grid-cols-2 gap-12 items-center max-w-6xl mx-auto">
                <div class="fade-in">
                    <span class="inline-block bg-white/20 text-white px-4 py-1 rounded-full text-sm font-medium mb-4">
                        Sécurité & Protection
                    </span>
                    <h2 class="text-4xl md:text-5xl font-bold mb-6">
                        Nous luttons contre l'arnaque
                    </h2>
                    <p class="text-xl opacity-90 mb-8 leading-relaxed">
                        Chez Voltigex, votre sécurité est notre priorité absolue. Nous utilisons des méthodes sophistiquées et des technologies de pointe pour assurer la qualité, la sécurité et la protection de vos transactions.
                    </p>
                    <div class="space-y-6">
                        <div class="flex items-start">
                            <div class="w-14 h-14 bg-secondary rounded-xl flex items-center justify-center mr-4 flex-shrink-0">
                                <i class="fas fa-shield-alt text-white text-2xl"></i>
                            </div>
                            <div>
                                <h3 class="text-xl font-bold mb-2">Détection avancée des fraudes</h3>
                                <p class="text-white/80 leading-relaxed">
                                    Notre système d'intelligence artificielle analyse en temps réel toutes les transactions pour détecter et prévenir les tentatives d'arnaque avant qu'elles ne se produisent.
                                </p>
                            </div>
                        </div>
                        <div class="flex items-start">
                            <div class="w-14 h-14 bg-secondary rounded-xl flex items-center justify-center mr-4 flex-shrink-0">
                                <i class="fas fa-lock text-white text-2xl"></i>
                            </div>
                            <div>
                                <h3 class="text-xl font-bold mb-2">Cryptage de niveau bancaire</h3>
                                <p class="text-white/80 leading-relaxed">
                                    Toutes vos données sont protégées par un cryptage AES-256, le même standard utilisé par les institutions financières les plus sécurisées au monde.
                                </p>
                            </div>
                        </div>
                        <div class="flex items-start">
                            <div class="w-14 h-14 bg-secondary rounded-xl flex items-center justify-center mr-4 flex-shrink-0">
                                <i class="fas fa-eye text-white text-2xl"></i>
                            </div>
                            <div>
                                <h3 class="text-xl font-bold mb-2">Surveillance 24/7</h3>
                                <p class="text-white/80 leading-relaxed">
                                    Notre équipe de sécurité surveille votre compte 24 heures sur 24, 7 jours sur 7, pour détecter toute activité suspecte et vous protéger contre les arnaques.
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="fade-in">
                    <div class="relative">
                        <div class="absolute inset-0 bg-white/10 rounded-3xl transform rotate-6"></div>
                        <div class="relative bg-white/5 backdrop-blur-sm rounded-3xl p-8 border border-white/20">
                            <div class="grid grid-cols-2 gap-6 mb-6">
                                <div class="bg-white/10 rounded-xl p-6 text-center">
                                    <div class="text-4xl font-bold mb-2">99.9%</div>
                                    <p class="text-white/80 text-sm">Taux de détection</p>
                                </div>
                                <div class="bg-white/10 rounded-xl p-6 text-center">
                                    <div class="text-4xl font-bold mb-2">24/7</div>
                                    <p class="text-white/80 text-sm">Surveillance</p>
                                </div>
                                <div class="bg-white/10 rounded-xl p-6 text-center">
                                    <div class="text-4xl font-bold mb-2">0</div>
                                    <p class="text-white/80 text-sm">Incidents majeurs</p>
                                </div>
                                <div class="bg-white/10 rounded-xl p-6 text-center">
                                    <div class="text-4xl font-bold mb-2">256</div>
                                    <p class="text-white/80 text-sm">Bits de cryptage</p>
                                </div>
                            </div>
                            <img src="assets/images/fraude.jpg" alt="Sécurité bancaire" class="rounded-xl shadow-2xl w-full">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Testimonials Section -->
    <section class="py-20 bg-white">
        <div class="container mx-auto px-4">
            <div class="text-center max-w-3xl mx-auto mb-16 fade-in">
                <span class="inline-block text-primary bg-secondary px-4 py-1 rounded-full text-sm font-medium mb-4">Témoignages clients</span>
                <h2 class="text-3xl md:text-4xl font-bold mt-4 mb-6">
                    Ce que nos clients disent de <span class="italic">Voltigex</span>
                </h2>
            </div>

            <div class="relative max-w-6xl mx-auto mb-12">
                <!-- Carousel Container -->
                <div class="overflow-hidden">
                    <div id="testimonials-carousel" class="flex transition-transform duration-500 ease-in-out">
                        <!-- Testimonial 1 -->
                        <div class="min-w-full md:min-w-[calc(33.333%-2rem)] px-4">
                            <div class="bg-white rounded-xl shadow-lg p-8 relative overflow-hidden card-hover h-full">
                                <div class="absolute bottom-0 right-0 text-9xl text-green-50 font-bold opacity-20" style="font-family: serif;">C</div>
                                <div class="flex items-center mb-4">
                                    <div class="w-16 h-16 rounded-full bg-primary border-4 border-primary overflow-hidden mr-4">
                                        <img src="bank/images/users/01.png" alt="">
                                    </div>
                                    <div>
                                        <h4 class="font-bold text-gray-800">Jean Frangister</h4>
                                        <p class="text-sm text-gray-600">CEO, TechStart International</p>
                                    </div>
                                </div>
                                <blockquote class="text-primary font-bold text-lg mb-4">
                                    "Virements internationaux rapides et sécurisés"
                                </blockquote>
                                <p class="text-gray-600 leading-relaxed">
                                    En tant qu'entreprise internationale, nous avons besoin de transférer des fonds rapidement. Voltigex nous permet d'effectuer des virements dans plus de 150 pays en quelques heures seulement. Un service irréprochable !
                                </p>
                            </div>
                        </div>

                        <!-- Testimonial 2 -->
                        <div class="min-w-full md:min-w-[calc(33.333%-2rem)] px-4">
                            <div class="bg-white rounded-xl shadow-lg p-8 relative overflow-hidden card-hover h-full">
                                <div class="absolute bottom-0 right-0 text-9xl text-green-50 font-bold opacity-20" style="font-family: serif;">C</div>
                                <div class="flex items-center mb-4">
                                    <div class="w-16 h-16 rounded-full bg-primary border-4 border-primary overflow-hidden mr-4">
                                        <img src="bank/images/users/02.png" alt="">
                                    </div>
                                    <div>
                                        <h4 class="font-bold text-gray-800">John Erstand</h4>
                                        <p class="text-sm text-gray-600">Entrepreneuse</p>
                                    </div>
                                </div>
                                <blockquote class="text-primary font-bold text-lg mb-4">
                                    "Conseil en investissement de qualité"
                                </blockquote>
                                <p class="text-gray-600 leading-relaxed">
                                    Les conseillers de Voltigex m'ont aidée à structurer mon portefeuille d'investissements. Leur expertise et leur approche personnalisée m'ont permis d'optimiser mes rendements tout en minimisant les risques.
                                </p>
                            </div>
                        </div>

                        <!-- Testimonial 3 -->
                        <div class="min-w-full md:min-w-[calc(33.333%-2rem)] px-4">
                            <div class="bg-white rounded-xl shadow-lg p-8 relative overflow-hidden card-hover h-full">
                                <div class="absolute bottom-0 right-0 text-9xl text-green-50 font-bold opacity-20" style="font-family: serif;">C</div>
                                <div class="flex items-center mb-4">
                                    <div class="w-16 h-16 rounded-full bg-primary border-4 border-primary overflow-hidden mr-4">
                                        <img src="bank/images/users/03.png" alt="">
                                    </div>
                                    <div>
                                        <h4 class="font-bold text-gray-800">Marie Hillstag</h4>
                                        <p class="text-sm text-gray-600">Directeur Commercial</p>
                                    </div>
                                </div>
                                <blockquote class="text-primary font-bold text-lg mb-4">
                                    "Plateforme digitale intuitive"
                                </blockquote>
                                <p class="text-gray-600 leading-relaxed">
                                    L'interface en ligne de Voltigex est vraiment bien conçue. Je peux gérer tous mes comptes, effectuer des transactions et suivre mes investissements depuis n'importe où dans le monde. C'est un gain de temps considérable.
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="flex items-center justify-between max-w-6xl mx-auto">
                <div class="flex items-center">
                    <img src="https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png" alt="Google" class="h-6 mr-3">
                    <div class="flex items-center">
                        <div class="flex text-yellow-400 mr-2">
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                            <i class="fas fa-star"></i>
                        </div>
                        <span class="text-gray-700 font-medium">4.8 </span>
                    </div>
                </div>
                <div class="flex gap-2">
                    <button id="testimonial-prev" class="w-10 h-10 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors">
                        <i class="fas fa-chevron-left text-gray-700"></i>
                    </button>
                    <button id="testimonial-next" class="w-10 h-10 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors">
                        <i class="fas fa-chevron-right text-gray-700"></i>
                    </button>
                </div>
            </div>
        </div>
    </section>

    <!-- Stats Section -->
    <section class="py-20 bg-gradient-to-r from-primary to-[#082054] text-white">
        <div class="container mx-auto px-4">
            <div class="grid grid-cols-2 md:grid-cols-4 gap-8 text-center" style="opacity: 1;">
                <div class="flex flex-col items-center" style="opacity: 1; transform: none;">
                    <div class="bg-secondary p-4 rounded-full mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-award h-8 w-8">
                            <path d="m15.477 12.89 1.515 8.526a.5.5 0 0 1-.81.47l-3.58-2.687a1 1 0 0 0-1.197 0l-3.586 2.686a.5.5 0 0 1-.81-.469l1.514-8.526"></path>
                            <circle cx="12" cy="8" r="6"></circle>
                        </svg>
                    </div>
                    <h3 class="text-3xl md:text-4xl font-bold mb-2">15+</h3>
                    <p class="text-white/80">Années d'experience</p>
                </div>
                <div class="flex flex-col items-center" style="opacity: 1; transform: none;">
                    <div class="bg-secondary p-4 rounded-full mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-users h-8 w-8">
                            <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
                            <circle cx="9" cy="7" r="4"></circle>
                            <path d="M22 21v-2a4 4 0 0 0-3-3.87"></path>
                            <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                        </svg>
                    </div>
                    <h3 class="text-3xl md:text-4xl font-bold mb-2">1527+</h3>
                    <p class="text-white/80">Clients satisfaits</p>
                </div>
                <div class="flex flex-col items-center" style="opacity: 1; transform: none;">
                    <div class="bg-secondary p-4 rounded-full mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-shield h-8 w-8">
                            <path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"></path></svg>
                    </div>
                    <h3 class="text-3xl md:text-4xl font-bold mb-2">99.9%</h3>
                    <p class="text-white/80">Disponibilité</p>
                </div>
                <div class="flex flex-col items-center" style="opacity: 1; transform: none;">
                    <div class="bg-secondary p-4 rounded-full mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-smartphone h-8 w-8">
                            <rect width="14" height="20" x="5" y="2" rx="2" ry="2"></rect>
                            <path d="M12 18h.01"></path>
                        </svg>
                    </div>
                    <h3 class="text-3xl md:text-4xl font-bold mb-2">24/7</h3>
                    <p class="text-white/80">Support client</p>
                </div>
            </div>
        </div>
    </section>
      
    <section class="py-20 bg-white">
        <div class="container mx-auto px-4">
          <div class="text-center max-w-3xl mx-auto mb-16"><span class="text-sm font-medium text-primary bg-secondary px-4 py-1 rounded-full">Actualités</span>
            <h2 class="text-3xl md:text-4xl font-bold mt-4 mb-6">Nos derniers articles</h2>
            <p class="text-lg text-gray-600">Découvrez nos conseils et analyses pour optimiser votre gestion financière.</p>
          </div>
          <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <div class="rounded-xl border bg-card text-card-foreground overflow-hidden border-none shadow-lg hover:shadow-xl transition-all duration-300 card-hover-effect">
              <div class="relative"><img alt="Comment économiser efficacement pour votre retraite" loading="lazy" width="400" height="200" decoding="async" data-nimg="1" class="w-full h-48 object-cover" style="color:transparent" srcset="bank/images/blog-1.jpeg" src="bank/images/blog-1.jpeg">
                <div class="absolute top-4 left-4 bg-primary text-white text-xs font-medium px-2 py-1 rounded">Épargne</div>
              </div>
              <div class="p-6 pt-6">
                <p class="text-sm text-gray-500 mb-2">15 avril 2023</p>
                <h3 class="text-xl font-bold mb-2 line-clamp-2">Comment économiser efficacement pour votre retraite</h3>
                <p class="text-gray-600 mb-4 line-clamp-3">Découvrez les stratégies d&amp;apos;épargne les plus efficaces pour préparer sereinement votre retraite.</p>
              </div>
            </div>
            <div class="rounded-xl border bg-card text-card-foreground overflow-hidden border-none shadow-lg hover:shadow-xl transition-all duration-300 card-hover-effect">
              <div class="relative"><img alt="Les avantages des paiements sans contact" loading="lazy" width="400" height="200" decoding="async" data-nimg="1" class="w-full h-48 object-cover" style="color:transparent" srcset="bank/images/blog-2.webp" src="bank/images/blog-2.webp">
                <div class="absolute top-4 left-4 bg-primary text-white text-xs font-medium px-2 py-1 rounded">Paiements</div>
              </div>
              <div class="p-6 pt-6">
                <p class="text-sm text-gray-500 mb-2">28 mars 2023</p>
                <h3 class="text-xl font-bold mb-2 line-clamp-2">Les avantages des paiements sans contact</h3>
                <p class="text-gray-600 mb-4 line-clamp-3">Tout ce que vous devez savoir sur la technologie sans contact et comment elle sécurise vos paiements.</p>
              </div>
            </div>
            <div class="rounded-xl border bg-card text-card-foreground overflow-hidden border-none shadow-lg hover:shadow-xl transition-all duration-300 card-hover-effect">
              <div class="relative"><img alt="Investir en bourse : guide pour débutants" loading="lazy" width="400" height="200" decoding="async" data-nimg="1" class="w-full h-48 object-cover" style="color:transparent" srcset="bank/images/blog-3.avif" src="bank/images/blog-3.avif">
                <div class="absolute top-4 left-4 bg-primary text-white text-xs font-medium px-2 py-1 rounded">Investissement</div>
              </div>
              <div class="p-6 pt-6">
                <p class="text-sm text-gray-500 mb-2">10 mars 2023</p>
                <h3 class="text-xl font-bold mb-2 line-clamp-2">Investir en bourse : guide pour débutants</h3>
                <p class="text-gray-600 mb-4 line-clamp-3">Les bases pour commencer à investir en bourse sans risque, même avec un petit capital.</p>
              </div>
            </div>
          </div>
        </div>
    </section>

    <!-- Partners Section -->
    <section class="py-16 bg-gray-50">
        <div class="container mx-auto px-4">
            <div class="text-center max-w-3xl mx-auto mb-12 fade-in">
                <span class="inline-block text-primary bg-secondary px-4 py-1 rounded-full text-sm font-medium mb-4">Nos partenaires</span>
                <h2 class="text-3xl md:text-4xl font-bold mt-4 mb-6">
                    Ils nous font <span class="text-primary">confiance</span>
                </h2>
            </div>
            <div class="relative max-w-7xl mx-auto">
                <div class="overflow-hidden">
                    <div id="partners-carousel" class="flex transition-transform duration-500 ease-in-out">
                        <!-- Partner 1 -->
                        <div class="min-w-[200px] md:min-w-[250px] px-4 flex items-center justify-center">
                            <div class="rounded-xl p-6 h-32 flex items-center justify-center ">
                                <img src="assets/images/patner/patner-1.jpg" alt="Partner 1" class="max-h-16 object-contain grayscale hover:grayscale-0 transition-all">
                            </div>
                        </div>
                        <!-- Partner 2 -->
                        <div class="min-w-[200px] md:min-w-[250px] px-4 flex items-center justify-center">
                            <div class="rounded-xl p-6 h-32 flex items-center justify-center ">
                                <img src="assets/images/patner/patner-2.jpg" alt="Partner 2" class="max-h-16 object-contain grayscale hover:grayscale-0 transition-all">
                            </div>
                        </div>
                        <!-- Partner 3 -->
                        <div class="min-w-[200px] md:min-w-[250px] px-4 flex items-center justify-center">
                            <div class="rounded-xl p-6 h-32 flex items-center justify-center ">
                                <img src="assets/images/patner/patner-3.jpg" alt="Partner 3" class="max-h-16 object-contain grayscale hover:grayscale-0 transition-all">
                            </div>
                        </div>
                        <!-- Partner 4 -->
                        <div class="min-w-[200px] md:min-w-[250px] px-4 flex items-center justify-center">
                            <div class="rounded-xl p-6 h-32 flex items-center justify-center ">
                                <img src="assets/images/patner/patner-4.jpg" alt="Partner 4" class="max-h-16 object-contain grayscale hover:grayscale-0 transition-all">
                            </div>
                        </div>
                        <!-- Partner 5 -->
                        <div class="min-w-[200px] md:min-w-[250px] px-4 flex items-center justify-center">
                            <div class="rounded-xl p-6 h-32 flex items-center justify-center ">
                                <img src="assets/images/patner/patner-5.png" alt="Partner 5" class="max-h-16 object-contain grayscale hover:grayscale-0 transition-all">
                            </div>
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

      // FAQ Toggle Function
      function toggleFaq(element) {
          const faqItem = element.closest('.faq-item');
          const content = faqItem.querySelector('.faq-content');
          const icon = faqItem.querySelector('.faq-icon');
          const title = faqItem.querySelector('h3');
          
          const isOpen = !content.classList.contains('hidden');
          
          // Close all FAQ items
          document.querySelectorAll('.faq-item').forEach(item => {
              const itemContent = item.querySelector('.faq-content');
              const itemIcon = item.querySelector('.faq-icon');
              const itemTitle = item.querySelector('h3');
              
              itemContent.classList.add('hidden');
              itemIcon.classList.remove('rotate-180');
              itemTitle.classList.remove('text-primary');
              itemTitle.classList.add('text-gray-800');
          });
          
          // Open clicked item if it was closed
          if (isOpen) {
              content.classList.add('hidden');
              icon.classList.remove('rotate-180');
              title.classList.remove('text-primary');
              title.classList.add('text-gray-800');
          } else {
              content.classList.remove('hidden');
              icon.classList.add('rotate-180');
              title.classList.remove('text-gray-800');
              title.classList.add('text-primary');
          }
      }

      // Testimonials Carousel - Initialize when DOM is ready
      document.addEventListener('DOMContentLoaded', function() {
          let currentTestimonial = 0;
          let carouselInterval;
          const carousel = document.getElementById('testimonials-carousel');
          const testimonials = carousel ? document.querySelectorAll('#testimonials-carousel > div') : [];
          const totalTestimonials = testimonials.length;

          if (totalTestimonials === 0) return;

          function updateCarousel() {
              if (!carousel) return;
              const isMobile = window.innerWidth < 768;
              let offset;
              
              if (isMobile) {
                  offset = -currentTestimonial * 100;
              } else {
                  // On desktop, show 3 at a time
                  const cardWidth = 100 / 3; // Each card takes 33.33% of container
                  offset = -currentTestimonial * cardWidth;
              }
              
              carousel.style.transform = `translateX(${offset}%)`;
          }

          function nextTestimonial() {
              const isMobile = window.innerWidth < 768;
              if (isMobile) {
                  currentTestimonial = (currentTestimonial + 1) % totalTestimonials;
              } else {
                  // On desktop, we can scroll one card at a time
                  const maxIndex = Math.max(0, totalTestimonials - 3);
                  if (currentTestimonial < maxIndex) {
                      currentTestimonial++;
                  } else {
                      currentTestimonial = 0; // Loop back to start
                  }
              }
              updateCarousel();
          }

          function prevTestimonial() {
              const isMobile = window.innerWidth < 768;
              if (isMobile) {
                  currentTestimonial = (currentTestimonial - 1 + totalTestimonials) % totalTestimonials;
              } else {
                  if (currentTestimonial > 0) {
                      currentTestimonial--;
                  } else {
                      const maxIndex = Math.max(0, totalTestimonials - 3);
                      currentTestimonial = maxIndex; // Loop to end
                  }
              }
              updateCarousel();
          }

          const nextBtn = document.getElementById('testimonial-next');
          const prevBtn = document.getElementById('testimonial-prev');

          if (nextBtn) {
              nextBtn.addEventListener('click', () => {
                  nextTestimonial();
                  resetCarouselInterval();
              });
          }

          if (prevBtn) {
              prevBtn.addEventListener('click', () => {
                  prevTestimonial();
                  resetCarouselInterval();
              });
          }

          function resetCarouselInterval() {
              clearInterval(carouselInterval);
              carouselInterval = setInterval(nextTestimonial, 5000);
          }

          // Initialize carousel
          updateCarousel();

          // Auto-play carousel
          carouselInterval = setInterval(nextTestimonial, 5000);

      // Handle window resize
      window.addEventListener('resize', () => {
          updateCarousel();
      });

      // Partners Carousel - Auto-scroll
      document.addEventListener('DOMContentLoaded', function() {
          const partnersCarousel = document.getElementById('partners-carousel');
          if (!partnersCarousel) return;

          let partnersPosition = 0;
          const partners = partnersCarousel.querySelectorAll('div');
          const totalPartners = partners.length;
          const partnerWidth = 250; // Width of each partner card including padding
          let autoScrollInterval;

          function scrollPartners() {
              partnersPosition -= 1; // Scroll speed
              
              // Reset position when scrolled past all partners
              const maxScroll = -(totalPartners * partnerWidth - window.innerWidth);
              if (partnersPosition < maxScroll) {
                  partnersPosition = 0;
              }
              
              partnersCarousel.style.transform = `translateX(${partnersPosition}px)`;
          }

          // Start auto-scroll
          autoScrollInterval = setInterval(scrollPartners, 20);

          // Pause on hover
          partnersCarousel.addEventListener('mouseenter', () => {
              clearInterval(autoScrollInterval);
          });

          partnersCarousel.addEventListener('mouseleave', () => {
              autoScrollInterval = setInterval(scrollPartners, 20);
          });
      });
      });

      // Fade in animation on scroll
      const observerOptions = {
          threshold: 0.1,
          rootMargin: '0px 0px -50px 0px'
      };

      const observer = new IntersectionObserver((entries) => {
          entries.forEach(entry => {
              if (entry.isIntersecting) {
                  entry.target.classList.add('visible');
              }
          });
      }, observerOptions);

      document.querySelectorAll('.fade-in').forEach(el => observer.observe(el));
  </script> 
    @include('layouts/footerglobal')      
    <script src="bank/js/main.js"></script>
    <script src="bank/js/menu.js"></script>
</body>
</html>
