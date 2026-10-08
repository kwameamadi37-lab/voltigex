<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Voltigex | Votre banque en ligne</title>
    <meta name="description" content="Solutions bancaires innovantes pour particuliers et professionnels">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="shortcut icon" type="image/x-icon" href="{{ config('app.favicon') }}">
    <style>
        .fade-in { opacity: 0; transform: translateY(20px); transition: all 0.6s ease; }
        .fade-in.visible { opacity: 1; transform: translateY(0); }
        .card-hover { transition: transform 0.3s ease, box-shadow 0.3s ease; }
        .card-hover:hover { transform: translateY(-5px); box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1); }
    </style>
</head>
<body class="bg-white">

    <!-- Navigation -->
    @include('layouts/headerglobal')      

        <!-- Hero Section -->
    <section class="bg-gradient-to-r from-primary to-[#082054] text-white py-20">
        <div class="container mx-auto px-4">
            <div class="max-w-3xl mx-auto text-center fade-in">
                <h1 class="text-4xl md:text-5xl font-bold mb-6">À propos de nous</h1>
                <p class="text-xl opacity-90 mb-8">
                    Découvrez qui nous sommes et pourquoi nous sommes la meilleure banque internationale.
                </p>
            </div>
        </div>
    </section>

    <!-- Hero Section -->
    <section class="py-20 bg-white">
        <div class="container mx-auto px-4">
            <div class="max-w-7xl mx-auto">
                <!-- Top Left Link -->
                <div class="mb-8 fade-in">
                    <a href="#" class="text-sm font-medium text-primary hover:underline">// En savoir plus sur nous</a>
                </div>

                <div class="grid md:grid-cols-2 gap-12 items-start mb-12">
                    <!-- Left Side - Image with Badge -->
                    <div class="relative fade-in">
                        <div class="relative">
                            <img src="bank/images/banner.jpg" 
                                 alt="Équipe Voltigex" 
                                 class="rounded-xl shadow-xl w-full h-auto object-cover">
                            <!-- Badge circulaire sur l'image - toujours visible -->
                            <div class="absolute bottom-8 right-8 bg-white rounded-full p-0 shadow-2xl flex flex-col items-center min-w-[140px] z-10 border-4 border-primary/20">
                                <img src="bank/images/favicon.png" alt="Voltigex" class="w-40 h-40 rounded-full">                               
                            </div>
                        </div>
                    </div>

                    <!-- Right Side - Content -->
                    <div class="fade-in">
                        <h1 class="text-4xl md:text-5xl lg:text-6xl font-bold text-gray-900 mb-6 leading-tight">
                            Le choix que vous faites aujourd'hui façonne votre <span class="italic text-primary">réussite</span> demain
                        </h1>
                        <p class="text-lg text-gray-600 mb-8 leading-relaxed">
                            CACBanq est une banque internationale qui offre des services bancaires complets et sécurisés depuis plus de 30 ans. Nous combinons l'expertise traditionnelle avec l'innovation technologique pour servir nos clients dans plus de 45 pays.
                        </p>

                        <!-- Statistics -->
                        <div class="grid grid-cols-2 gap-8">
                            <div>
                                <div class="text-6xl font-bold text-primary mb-2">98%</div>
                                <p class="text-gray-600 text-base">Clients satisfaits et fidèles</p>
                            </div>
                            <div>
                                <div class="text-6xl font-bold text-primary mb-2">250k</div>
                                <p class="text-gray-600 text-base">Clients dans 45 pays</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Mission & Vision Section -->
    <section class="py-20 bg-white">
        <div class="container mx-auto px-4">
            <div class="grid md:grid-cols-2 gap-0 mb-20">
                <!-- Notre Mission -->
                <div class="bg-primary text-white p-12 fade-in">
                    <h2 class="text-4xl md:text-5xl font-bold mb-8 text-center">Notre mission</h2>
                    <div class="grid md:grid-cols-2 gap-8">
                        <div>
                            <h3 class="text-xl font-bold mb-4">Ce que nous faisons</h3>
                            <p class="text-white/90 leading-relaxed">
                                Nous offrons des services bancaires internationaux complets : comptes, investissements, crédits et solutions de paiement sécurisées.
                            </p>
                        </div>
                        <div>
                            <h3 class="text-xl font-bold mb-4">Pourquoi nous existons</h3>
                            <p class="text-white/90 leading-relaxed">
                                Faciliter l'accès aux services bancaires internationaux de qualité pour tous, en combinant sécurité, innovation et expertise.
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Notre Vision -->
                <div class="bg-secondary text-gray-900 p-12 fade-in">
                    <h2 class="text-4xl md:text-5xl font-bold mb-8 text-center">Notre vision</h2>
                    <div>
                        <h3 class="text-xl font-bold mb-4">Où voulons-nous être à l'avenir</h3>
                        <p class="text-gray-700 leading-relaxed">
                            Devenir la banque internationale de référence, reconnue pour son excellence, son innovation et son engagement.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Notre Fierté Section -->
            <div class="bg-white relative overflow-hidden fade-in">
                <div class="absolute bottom-0 right-0 opacity-5">
                    <svg width="600" height="400" viewBox="0 0 600 400" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="100" cy="100" r="2" fill="currentColor"/>
                        <circle cx="200" cy="150" r="2" fill="currentColor"/>
                        <circle cx="300" cy="100" r="2" fill="currentColor"/>
                        <circle cx="400" cy="200" r="2" fill="currentColor"/>
                        <circle cx="500" cy="150" r="2" fill="currentColor"/>
                        <circle cx="150" cy="250" r="2" fill="currentColor"/>
                        <circle cx="250" cy="300" r="2" fill="currentColor"/>
                        <circle cx="350" cy="250" r="2" fill="currentColor"/>
                        <circle cx="450" cy="300" r="2" fill="currentColor"/>
                    </svg>
                </div>
            </div>
        </div>
    </section>


    <!-- Our Values -->
    <section class="py-20 bg-white">
        <div class="container mx-auto px-4">
            <div class="text-center max-w-3xl mx-auto mb-16 fade-in">
                <span class="text-sm font-medium text-primary bg-primary/10 px-4 py-1 rounded-full">Nos valeurs</span>
                <h2 class="text-3xl md:text-4xl font-bold mt-4 mb-6">Ce qui nous définit</h2>
                <p class="text-lg text-gray-600">
                    Nos valeurs guident chacune de nos actions et nous permettent d'offrir un service d'excellence à nos clients.
                </p>
            </div>

            <div class="grid md:grid-cols-3 gap-8">
                <div class="bg-white rounded-xl shadow-lg overflow-hidden card-hover fade-in">
                    <div class="h-48 overflow-hidden">
                        <img src="https://images.unsplash.com/photo-1573164713988-8665fc963095?q=80&w=400&auto=format&fit=crop" 
                             alt="Transparence" 
                             class="w-full h-full object-cover">
                    </div>
                    <div class="p-6">
                        <h3 class="text-xl font-bold mb-3">Transparence</h3>
                        <p class="text-gray-600">
                            Nous croyons en une relation de confiance basée sur la transparence totale. Pas de frais cachés, pas de petits caractères difficiles à comprendre.
                        </p>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-lg overflow-hidden card-hover fade-in">
                    <div class="h-48 overflow-hidden">
                        <img src="https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?q=80&w=400&auto=format&fit=crop" 
                             alt="Innovation" 
                             class="w-full h-full object-cover">
                    </div>
                    <div class="p-6">
                        <h3 class="text-xl font-bold mb-3">Innovation</h3>
                        <p class="text-gray-600">
                            Nous repoussons constamment les limites de ce qu'une banque peut offrir, en développant des solutions qui simplifient réellement la vie de nos clients.
                        </p>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-lg overflow-hidden card-hover fade-in">
                    <div class="h-48 overflow-hidden">
                        <img src="https://images.unsplash.com/photo-1434626881859-194d67b2b86f?q=80&w=400&auto=format&fit=crop" 
                             alt="Accessibilité" 
                             class="w-full h-full object-cover">
                    </div>
                    <div class="p-6">
                        <h3 class="text-xl font-bold mb-3">Accessibilité</h3>
                        <p class="text-gray-600">
                            Nous rendons les services financiers accessibles à tous, quels que soient leur situation ou leur niveau de connaissances financières.
                        </p>
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
</body>
</html>
