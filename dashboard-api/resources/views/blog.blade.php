<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FinancePro | Solutions de prêts professionnels</title>
    <meta name="description" content="Solutions de financement sur mesure pour les professionnels et entreprises">
    <!-- Tailwind CSS via CDN -->
    <script src="assets/js/tailwind.js"></script>
    <script src="assets/js/menu.js"></script>
    <link rel="stylesheet" href="assets/css/styles.css">
    <link rel="stylesheet" href="assets/css/styles-1.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" integrity="sha512-Evv84Mr4kqVGRNSgIGL/F/aIDqQb7xQ2vcrdIwxfjThSH8CSR7PBEakCr51Ck+w+/U6swU2Im1vVX0SVk9ABhg==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
   @include('layouts.headerglobal')
    <!-- Hero Section -->
    <section class="bg-gradient-to-r from-primary to-blue-800 text-white py-10">
        <div class="container mx-auto px-4">
            <div class="max-w-3xl mx-auto text-center">
                <h1 class="text-4xl md:text-5xl font-bold mb-6">Blog & Actualités</h1>
                <p class="text-xl opacity-90 mb-8">
                    Découvrez nos articles et conseils sur le financement professionnel, la gestion d'entreprise et les tendances du marché.
                </p>                
            </div>
        </div>
    </section>

    <!-- Blog Content -->
    <section class="bg-white py-10">
        <div class="container">
            <div class="blog-layout">
                <div class="blog-main"> 
                    <div class="mb-8">
                        <h1 class="text-lg md:text-4xl text-primary" style="font-weight: 800;">Nos Actualités</h1>
                        <p>Parcourez tous nos articles pour etre au coutants des nouvelles actualités</p>
                    </div>
                    <div class="blog-grid grid-col-1 md:grid-cols-3">
                        <div class="blog-card fade-in" data-category="financement" style="animation-delay: 0.1s">
                            <div class="blog-image">
                                <img src="https://images.unsplash.com/photo-1554224155-6726b3ff858f?q=80&w=600&auto=format&fit=crop" alt="Comment choisir le bon financement pour votre entreprise">
                                <span class="blog-category">Financement</span>
                            </div>
                            <div class="blog-content">
                                <span class="blog-date">12 mai 2023</span>
                                <h3>Comment choisir le bon financement pour votre entreprise</h3>
                                <p>Découvrez les critères essentiels pour sélectionner la solution de financement la plus adaptée à votre projet d'entreprise et maximiser vos chances de succès.</p>
                                <a href="#" class="blog-link">Lire l'article →</a>
                            </div>
                        </div>
                        
                        <div class="blog-card fade-in" data-category="financement" style="animation-delay: 0.2s">
                            <div class="blog-image">
                                <img src="https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=600&auto=format&fit=crop" alt="Les avantages du crédit-bail pour votre équipement professionnel">
                                <span class="blog-category">Financement</span>
                            </div>
                            <div class="blog-content">
                                <span class="blog-date">28 avril 2023</span>
                                <h3>Les avantages du crédit-bail pour votre équipement professionnel</h3>
                                <p>Le crédit-bail offre une alternative intéressante à l'achat direct. Découvrez pourquoi cette solution séduit de plus en plus d'entreprises.</p>
                                <a href="#" class="blog-link">Lire l'article →</a>
                            </div>
                        </div>
                        <div class="blog-card fade-in" data-category="gestion" style="animation-delay: 0.3s">
                            <div class="blog-image">
                                <img src="https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=600&auto=format&fit=crop" alt="5 erreurs à éviter lors d'une demande de prêt professionnel">
                                <span class="blog-category">Conseils</span>
                            </div>
                            <div class="blog-content">
                                <span class="blog-date">15 avril 2023</span>
                                <h3>5 erreurs à éviter lors d'une demande de prêt professionnel</h3>
                                <p>Maximisez vos chances d'obtenir un financement en évitant ces pièges courants qui peuvent compromettre votre dossier.</p>
                                <a href="#" class="blog-link">Lire l'article →</a>
                            </div>
                        </div>
                        <div class="blog-card fade-in" data-category="fiscalite" style="animation-delay: 0.4s">
                            <div class="blog-image">
                                <img src="https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?q=80&w=600&auto=format&fit=crop" alt="Réforme fiscale 2023 : impacts sur le financement des entreprises">
                                <span class="blog-category">Fiscalité</span>
                            </div>
                            <div class="blog-content">
                                <span class="blog-date">2 avril 2023</span>
                                <h3>Réforme fiscale 2023 : impacts sur le financement des entreprises</h3>
                                <p>Analyse des principales mesures fisc ales de l'année et leurs conséquences sur les stratégies de financement des entreprises.</p>
                                <a href="#" class="blog-link">Lire l'article →</a>
                            </div>
                        </div>
                        <div class="blog-card fade-in" data-category="tendances" style="animation-delay: 0.5s">
                            <div class="blog-image">
                                <img src="https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=600&auto=format&fit=crop" alt="Financement participatif : une alternative crédible pour les PME ?">
                                <span class="blog-category">Tendances</span>
                            </div>
                            <div class="blog-content">
                                <span class="blog-date">20 mars 2023</span>
                                <h3>Financement participatif : une alternative crédible pour les PME ?</h3>
                                <p>Le crowdfunding connaît un essor important. Est-il adapté à tous les projets d'entreprise ? Analyse et retours d'expérience.</p>
                                <a href="#" class="blog-link">Lire l'article →</a>
                            </div>
                        </div>
                        <div class="blog-card fade-in" data-category="gestion" style="animation-delay: 0.6s">
                            <div class="blog-image">
                                <img src="https://images.unsplash.com/photo-1579532537598-459ecdaf39cc?q=80&w=600&auto=format&fit=crop" alt="Comment optimiser la gestion de trésorerie de votre entreprise">
                                <span class="blog-category">Gestion</span>
                            </div>
                            <div class="blog-content">
                                <span class="blog-date">5 mars 2023</span>
                                <h3>Comment optimiser la gestion de trésorerie de votre entreprise</h3>
                                <p>Conseils pratiques et stratégies efficaces pour améliorer la gestion de votre trésorerie et éviter les tensions financières.</p>
                                <a href="#" class="blog-link">Lire l'article →</a>
                            </div>
                        </div>
                    </div>
                </div>               
                
            </div>
        </div>
    </section>



    <!-- Footer -->
    @include('layouts.footerglobal')

    <script src="assets/js/main.js"></script>
    <script src="assets/js/loan-calculator.js"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#0a296b',
                        'primary-dark': '#1e3a8a',
                        secondary: '#ffc800',
                    },
                    fontFamily: {
                        'inter': ['Inter', 'sans-serif'],
                    }
                }
            }
        }
    </script>    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
</body>
</html>
