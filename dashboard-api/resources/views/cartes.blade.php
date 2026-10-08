<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cartes Bancaires | Voltigex</title>
    <meta name="description" content="Découvrez nos cartes bancaires premium : Gold, Diamond et Platinum">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="shortcut icon" type="image/x-icon" href="{{ config('app.favicon') }}">
    <style>
        .fade-in { opacity: 0; transform: translateY(20px); transition: all 0.6s ease; }
        .fade-in.visible { opacity: 1; transform: translateY(0); }
        .card-hover { transition: transform 0.3s ease, box-shadow 0.3s ease; }
        .card-hover:hover { transform: translateY(-8px); box-shadow: 0 20px 40px -10px rgba(0, 0, 0, 0.15); }
        .card-gradient-gold { background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%); }
        .card-gradient-diamond { background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%); }
        .card-gradient-platinum { background: linear-gradient(135deg, #64748b 0%, #475569 100%); }
    </style>
</head>
<body class="bg-white">

    @include('layouts/headerglobal')

    <!-- Hero Section -->
    <section class="bg-gradient-to-r from-primary to-[#082054] text-white py-20">
        <div class="container mx-auto px-4">
            <div class="max-w-3xl mx-auto text-center fade-in">
                <span class="inline-block text-primary bg-secondary px-4 py-1 rounded-full text-sm font-medium mb-4">Nos cartes bancaires</span>
                <h1 class="text-4xl md:text-5xl font-bold mb-6">Choisissez la carte qui correspond à votre style de vie</h1>
                <p class="text-xl opacity-90">
                    Des cartes premium avec des avantages exclusifs et une sécurité renforcée pour toutes vos transactions.
                </p>
            </div>
        </div>
    </section>

    <!-- Cards Section -->
    <section class="py-20 bg-gray-50">
        <div class="container mx-auto px-4">
            <div class="grid md:grid-cols-3 gap-8 max-w-7xl mx-auto">
                
                <!-- Gold Card -->
                <div class="bg-white rounded-2xl shadow-lg overflow-hidden card-hover fade-in">
                    <div class="card-gradient-gold p-8 text-white relative overflow-hidden">
                        <div class="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16"></div>
                        <div class="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full -ml-12 -mb-12"></div>
                        <div class="relative z-10">
                            <div class="flex justify-between items-start mb-6">
                                <div>
                                    <h3 class="text-2xl font-bold mb-2">Gold</h3>
                                    <p class="text-white/90 text-sm">Carte Premium</p>
                                </div>
                                <div class="w-12 h-12 bg-white/20 rounded-lg flex items-center justify-center">
                                    <i class="fas fa-gem text-2xl"></i>
                                </div>
                            </div>
                            <div class="mb-6">
                                <div class="text-3xl font-bold mb-1">**** **** **** 1234</div>
                                <div class="text-sm opacity-90">VALID THRU 12/25</div>
                            </div>
                            <div class="flex items-center justify-between">
                                <div class="text-sm font-medium">JOHN DOE</div>
                                <div class="flex items-center">
                                    <div class="w-8 h-8 bg-white/20 rounded mr-2"></div>
                                    <div class="w-8 h-8 bg-white/20 rounded"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="p-8">
                        <div class="mb-6">
                            <h4 class="text-xl font-bold text-gray-900 mb-4">Avantages inclus</h4>
                            <ul class="space-y-3">
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Cashback de 2% sur tous les achats</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Assurance voyage incluse</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Accès aux salons VIP aéroports</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Assistance 24/7 dédiée</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Plafond de retrait : 5 000€/jour</span>
                                </li>
                            </ul>
                        </div>
                        <div class="border-t border-gray-200 pt-6 mb-6">
                            <div class="flex items-baseline justify-between mb-2">
                                <span class="text-gray-600">Frais annuels</span>
                                <span class="text-2xl font-bold text-gray-900">650€</span>
                            </div>
                            <p class="text-sm text-gray-500">Première année offerte</p>
                        </div>
                    </div>
                </div>

                <!-- Diamond Card -->
                <div class="bg-white rounded-2xl shadow-lg overflow-hidden card-hover fade-in border-2 border-primary">
                    <div class="relative">
                        <div class="absolute top-4 right-4 z-20 bg-secondary text-primary px-3 py-1 rounded-full text-xs font-bold">
                            POPULAIRE
                        </div>
                    </div>
                    <div class="card-gradient-diamond p-8 text-white relative overflow-hidden">
                        <div class="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16"></div>
                        <div class="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full -ml-12 -mb-12"></div>
                        <div class="relative z-10">
                            <div class="flex justify-between items-start mb-6">
                                <div>
                                    <h3 class="text-2xl font-bold mb-2">Diamond</h3>
                                    <p class="text-white/90 text-sm">Carte Exclusive</p>
                                </div>
                                <div class="w-12 h-12 bg-white/20 rounded-lg flex items-center justify-center">
                                    <i class="fas fa-crown text-2xl"></i>
                                </div>
                            </div>
                            <div class="mb-6">
                                <div class="text-3xl font-bold mb-1">**** **** **** 5678</div>
                                <div class="text-sm opacity-90">VALID THRU 12/25</div>
                            </div>
                            <div class="flex items-center justify-between">
                                <div class="text-sm font-medium">JOHN DOE</div>
                                <div class="flex items-center">
                                    <div class="w-8 h-8 bg-white/20 rounded mr-2"></div>
                                    <div class="w-8 h-8 bg-white/20 rounded"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="p-8">
                        <div class="mb-6">
                            <h4 class="text-xl font-bold text-gray-900 mb-4">Avantages inclus</h4>
                            <ul class="space-y-3">
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Cashback de 3% sur tous les achats</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Assurance voyage premium incluse</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Accès illimité aux salons VIP</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Concierge personnel 24/7</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Plafond de retrait : 10 000€/jour</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Programme de récompenses exclusif</span>
                                </li>
                            </ul>
                        </div>
                        <div class="border-t border-gray-200 pt-6 mb-6">
                            <div class="flex items-baseline justify-between mb-2">
                                <span class="text-gray-600">Frais annuels</span>
                                <span class="text-2xl font-bold text-gray-900">1500€</span>
                            </div>
                            <p class="text-sm text-gray-500">Première année offerte</p>
                        </div>
                    </div>
                </div>

                <!-- Platinum Card -->
                <div class="bg-white rounded-2xl shadow-lg overflow-hidden card-hover fade-in">
                    <div class="card-gradient-platinum p-8 text-white relative overflow-hidden">
                        <div class="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16"></div>
                        <div class="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full -ml-12 -mb-12"></div>
                        <div class="relative z-10">
                            <div class="flex justify-between items-start mb-6">
                                <div>
                                    <h3 class="text-2xl font-bold mb-2">Platinum</h3>
                                    <p class="text-white/90 text-sm">Carte Élite</p>
                                </div>
                                <div class="w-12 h-12 bg-white/20 rounded-lg flex items-center justify-center">
                                    <i class="fas fa-star text-2xl"></i>
                                </div>
                            </div>
                            <div class="mb-6">
                                <div class="text-3xl font-bold mb-1">**** **** **** 9012</div>
                                <div class="text-sm opacity-90">VALID THRU 12/25</div>
                            </div>
                            <div class="flex items-center justify-between">
                                <div class="text-sm font-medium">JOHN DOE</div>
                                <div class="flex items-center">
                                    <div class="w-8 h-8 bg-white/20 rounded mr-2"></div>
                                    <div class="w-8 h-8 bg-white/20 rounded"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="p-8">
                        <div class="mb-6">
                            <h4 class="text-xl font-bold text-gray-900 mb-4">Avantages inclus</h4>
                            <ul class="space-y-3">
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Cashback de 1.5% sur tous les achats</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Assurance voyage standard incluse</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Accès aux salons VIP (limité)</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Support client prioritaire</span>
                                </li>
                                <li class="flex items-start">
                                    <i class="fas fa-check-circle text-primary mr-3 mt-1"></i>
                                    <span class="text-gray-600">Plafond de retrait : 3 000€/jour</span>
                                </li>
                            </ul>
                        </div>
                        <div class="border-t border-gray-200 pt-6 mb-6">
                            <div class="flex items-baseline justify-between mb-2">
                                <span class="text-gray-600">Frais annuels</span>
                                <span class="text-2xl font-bold text-gray-900">3500€</span>
                            </div>
                            <p class="text-sm text-gray-500">Première année offerte</p>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </section>

    <!-- Features Comparison Section -->
    <section class="py-20 bg-white">
        <div class="container mx-auto px-4">
            <div class="max-w-4xl mx-auto fade-in">
                <div class="text-center mb-12">
                    <span class="inline-block text-primary bg-secondary px-4 py-1 rounded-full text-sm font-medium mb-4">Comparaison</span>
                    <h2 class="text-3xl md:text-4xl font-bold mb-6">Comparez nos cartes</h2>
                    <p class="text-lg text-gray-600">Trouvez la carte qui correspond le mieux à vos besoins</p>
                </div>
                
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead>
                            <tr class="border-b-2 border-gray-200">
                                <th class="text-left py-4 px-4 font-bold text-gray-900">Caractéristiques</th>
                                <th class="text-center py-4 px-4 font-bold text-gray-900">Platinum</th>
                                <th class="text-center py-4 px-4 font-bold text-primary">Gold</th>
                                <th class="text-center py-4 px-4 font-bold text-primary">Diamond</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                            <tr>
                                <td class="py-4 px-4 text-gray-600">Cashback</td>
                                <td class="py-4 px-4 text-center">1.5%</td>
                                <td class="py-4 px-4 text-center font-semibold">2%</td>
                                <td class="py-4 px-4 text-center font-semibold">3%</td>
                            </tr>
                            <tr class="bg-gray-50">
                                <td class="py-4 px-4 text-gray-600">Plafond retrait/jour</td>
                                <td class="py-4 px-4 text-center">3 000€</td>
                                <td class="py-4 px-4 text-center font-semibold">5 000€</td>
                                <td class="py-4 px-4 text-center font-semibold">10 000€</td>
                            </tr>
                            <tr>
                                <td class="py-4 px-4 text-gray-600">Assurance voyage</td>
                                <td class="py-4 px-4 text-center">Standard</td>
                                <td class="py-4 px-4 text-center font-semibold">Incluse</td>
                                <td class="py-4 px-4 text-center font-semibold">Premium</td>
                            </tr>
                            <tr class="bg-gray-50">
                                <td class="py-4 px-4 text-gray-600">Salons VIP</td>
                                <td class="py-4 px-4 text-center">Limité</td>
                                <td class="py-4 px-4 text-center font-semibold">Inclus</td>
                                <td class="py-4 px-4 text-center font-semibold">Illimité</td>
                            </tr>
                            <tr>
                                <td class="py-4 px-4 text-gray-600">Support client</td>
                                <td class="py-4 px-4 text-center">Prioritaire</td>
                                <td class="py-4 px-4 text-center font-semibold">24/7 Dédié</td>
                                <td class="py-4 px-4 text-center font-semibold">Concierge 24/7</td>
                            </tr>
                            <tr class="bg-gray-50">
                                <td class="py-4 px-4 text-gray-600">Frais annuels</td>
                                <td class="py-4 px-4 text-center">3500€</td>
                                <td class="py-4 px-4 text-center font-semibold">650€</td>
                                <td class="py-4 px-4 text-center font-semibold">1500€</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </section>


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
    <script src="bank/js/main.js"></script>
</body>
</html>

