<!-- Footer -->
<footer class="bg-gradient-to-r from-primary to-[#082054] text-white relative">
    <div class="container mx-auto px-4 py-12">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-8">
            <!-- Company Information -->
            <div>
                <div class="mb-4">
                    <img src="bank/images/favicon.png" alt="Voltigex" class="w-20 h-20 rounded-full">
                </div>
                <p class="text-white/90 leading-relaxed">
                    Voltigex est votre partenaire de confiance pour tous vos besoins bancaires internationaux.
                </p>               
            </div>
            
            <!-- Liens rapides -->
            <div>
                <h3 class="text-lg font-bold mb-4">Liens rapides</h3>
                <ul class="space-y-2">
                    <li class="flex items-center">
                        <span class="w-1.5 h-1.5 bg-white rounded-full mr-3"></span>
                        <a href="/" class="text-white hover:text-secondary transition-colors">Accueil</a>
                    </li>
                    <li class="flex items-center">
                        <span class="w-1.5 h-1.5 bg-white rounded-full mr-3"></span>
                        <a href="{{ route('about') }}" class="text-white hover:text-secondary transition-colors">À propos de nous</a>
                    </li>
                    <li class="flex items-center">
                        <span class="w-1.5 h-1.5 bg-white rounded-full mr-3"></span>
                        <a href="{{ route('services') }}" class="text-white hover:text-secondary transition-colors">Paiements et services</a>
                    </li>
                    <li class="flex items-center">
                        <span class="w-1.5 h-1.5 bg-white rounded-full mr-3"></span>
                        <a href="{{ route('contact') }}" class="text-white hover:text-secondary transition-colors">Contactez-nous</a>
                    </li>
                </ul>
            </div>
            
            <!-- Nos politiques -->
            <div>
                <h3 class="text-lg font-bold mb-4">Légales</h3>
                <ul class="space-y-2">
                    <li class="flex items-center">
                        <span class="w-1.5 h-1.5 bg-white rounded-full mr-3"></span>
                        <a href="{{ route('pret') }}" class="text-white hover:text-secondary transition-colors">Mentions légales</a>
                    </li>
                    <li class="flex items-center">
                        <span class="w-1.5 h-1.5 bg-white rounded-full mr-3"></span>
                        <a href="{{ route('confidentialite') }}" class="text-white hover:text-secondary transition-colors">Politique de confidentialité</a>
                    </li>
                    <li class="flex items-center">
                        <span class="w-1.5 h-1.5 bg-white rounded-full mr-3"></span>
                        <a href="{{ route('condition') }}" class="text-white hover:text-secondary transition-colors">Conditions d'utilisation</a>
                    </li>
                    <li class="flex items-center">
                        <span class="w-1.5 h-1.5 bg-white rounded-full mr-3"></span>
                        <a href="{{ route('securite') }}" class="text-white hover:text-secondary transition-colors">Politique de sécurité</a>
                    </li>
                </ul>
            </div>
            
            <!-- Contactez-nous -->
            <div>
                <h3 class="text-lg font-bold mb-4">Contactez-nous</h3>
                <ul class="space-y-3">
                    <li class="flex items-start">
                        <i class="fas fa-envelope mr-3 mt-1 text-white"></i>
                        <a href="mailto:{{ site_setting('contact_email', 'contact@voltigex.com') }}" class="text-white hover:underline">{{ site_setting('contact_email', 'contact@voltigex.com') }}</a>
                    </li>
                    <li class="flex items-start">
                        <i class="fas fa-phone mr-3 mt-1 text-white"></i>
                        <span class="text-white">{{ site_setting('contact_phone', '+33 1 23 45 67 89') }}</span>
                    </li>
                    @if(site_setting('opening_hours'))
                    <li class="flex items-start">
                        <i class="fas fa-clock mr-3 mt-1 text-white"></i>
                        <span class="text-white text-sm whitespace-pre-line">{{ site_setting('opening_hours') }}</span>
                    </li>
                    @endif
                </ul>
            </div>

            <!-- Contactez-nous -->
            <div>
                <h3 class="text-lg font-bold mb-4">Téléchargez notre application</h3>
                <ul class="space-y-3">
                    <div class="flex gap-2">
                        <div class="mb-4">
                            @include('partials.app-qr')
                        </div>
                        <div>
                            <a href="#" class="inline-block">
                                <img src="https://play.google.com/intl/en_us/badges/static/images/badges/fr_badge_web_generic.png" alt="Disponible sur Google Play" class="h-14">
                            </a>
                            <a href="#" class="inline-block">
                                <img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/fr-fr?size=250x83&releaseDate=1289944800" alt="Disponible sur Google Play" class="h-12">
                            </a>
                        </div>
                    </div>
                </ul>
            </div>
        </div>
        
        <!-- Copyright -->
        <div class="border-t border-white/20 mt-8 pt-8 text-center text-sm">
            <p class="text-white">
                Voltigex S.A.S. Via Privata Nino Bonnet, 6/A, 20154 - Milano P.Iva: 06529501006 | © 1990 <span class="text-secondary">Voltigex</span>. Tous droits réservés.
            </p>
        </div>
    </div>
    
 </footer>
 
 <script>
     // Scroll to Top Button (protégé si le bouton n'existe pas sur la page)
     document.addEventListener('DOMContentLoaded', function() {
         const scrollButton = document.getElementById('scroll-to-top');
         
         // Si le bouton n'est pas présent sur cette page, on ne fait rien
         if (!scrollButton) {
             return;
         }
         
         // Show/hide button based on scroll position
         window.addEventListener('scroll', function() {
             if (window.pageYOffset > 300) {
                 scrollButton.classList.remove('opacity-0', 'pointer-events-none');
                 scrollButton.classList.add('opacity-100');
             } else {
                 scrollButton.classList.add('opacity-0', 'pointer-events-none');
                 scrollButton.classList.remove('opacity-100');
             }
         });
         
         // Scroll to top on click
         scrollButton.addEventListener('click', function() {
             window.scrollTo({
                 top: 0,
                 behavior: 'smooth'
             });
         });
     });
 </script>