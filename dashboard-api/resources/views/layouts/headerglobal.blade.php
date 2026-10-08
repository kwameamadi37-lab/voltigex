<!-- Auth Helper Script -->
<script src="/assets/js/auth-helper.js"></script>

<!-- Navigation -->
<nav class="bg-white shadow-md sticky top-0 z-50">
   <div class="container mx-auto px-4">
       <div class="flex justify-between items-center h-20">
           <div class="flex items-center">
               <a href="/" class="text-2xl font-bold text-primary">
                   <img src="bank/images/logo.png" alt="VOLTIGEX" width="180">
               </a>
           </div>
           
           <div class="hidden md:flex items-center space-x-6">
               <a href="/" class="text-black hover:text-primary transition-colors">Accueil</a>
               <a href="/about" class="text-black hover:text-primary transition-colors">Qui sommes nous</a>
               <div class="relative group">
                   <a href="/services" class="text-black hover:text-primary transition-colors flex items-center">
                       Paiements et services <i class="fas fa-chevron-down ml-1 text-xs"></i>
                   </a>
                   <div class="absolute top-full left-0 bg-white shadow-lg rounded-md py-2 w-48 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all">
                       <a href="/services" class="block px-4 py-2 text-black hover:bg-gray-100">Tous nos services</a>
                       <a href="/services" class="block px-4 py-2 text-black hover:bg-gray-100">Particuliers</a>
                       <a href="/services" class="block px-4 py-2 text-black hover:bg-gray-100">Professionnels</a>
                   </div>
               </div>
               <a href="/#application-mobile" class="text-black hover:text-primary transition-colors"> <i class="fas fa-mobile"></i> Application mobile</a>
               <a href="/cartes" class="text-black hover:text-primary transition-colors"> <i class="fas fa-credit-card"></i> Cartes bancaires</a>
               <a href="/contact" class="text-black hover:text-primary transition-colors">Contactez-nous</a>
           </div>

           <div class="hidden md:flex items-center space-x-4" id="auth-buttons">
               <!-- Login/Register buttons (shown when not authenticated) -->
               <div id="guest-buttons">
                   <a href="/login" class="px-4 py-2 font-bold border bg-secondary text-black rounded-md hover:bg-primary hover:text-white transition-colors mr-2">Connectez vous</a>
                   <a href="/sign-up" class="px-4 font-bold py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors">Ouvrir un compte</a>
               </div>
               
               <!-- Dashboard button (shown when authenticated as admin) -->
               <div id="dashboard-button" class="hidden">
                   <a href="{{ route('admin.virements') }}" class="px-4 py-2 font-bold bg-primary text-white rounded-md hover:bg-primary-dark transition-colors">
                       <i class="fas fa-tachometer-alt mr-2"></i>Dashboard
                   </a>
               </div>
           </div>

           <button class="md:hidden" id="mobile-menu-btn">
               <i class="fas fa-bars text-xl"></i>
           </button>
       </div>
   </div>

   <!-- Mobile Menu -->
   <div class="md:hidden hidden" id="mobile-menu">
       <div class="px-4 py-6 space-y-4 bg-white border-t">
           <a href="/" class="block text-lg font-medium">Accueil</a>
           <a href="/about" class="block text-lg font-medium">À propos de nous</a>
           <a href="/services" class="block text-lg font-medium">Paiements et services</a>
           <a href="/#application-mobile" class="block text-lg font-medium">Application mobile</a>
           <a href="/cartes" class="block text-lg font-medium">Cartes bancaires</a>
           <a href="/contact" class="block text-lg font-medium">Contactez-nous</a>
           
           <!-- Guest buttons (shown when not authenticated) -->
           <div id="mobile-guest-buttons" class="border-t pt-4 space-y-3">
               <a href="/login" class="block w-full text-center px-4 py-2 border border-primary text-primary rounded-md">Connectez vous</a>
               <a href="/sign-up" class="block w-full text-center px-4 py-2 bg-primary text-white rounded-md">Ouvrir un compte</a>
           </div>
           
           <!-- Dashboard button (shown when authenticated as admin) -->
           <div id="mobile-dashboard-button" class="border-t pt-4 space-y-3 hidden">
               <a href="{{ route('admin.virements') }}" class="block w-full text-center px-4 py-2 bg-primary text-white rounded-md">
                   <i class="fas fa-tachometer-alt mr-2"></i>Dashboard
               </a>
           </div>
       </div>
   </div>
</nav>

<script>
// Update header based on authentication status
document.addEventListener('DOMContentLoaded', function() {
    const guestButtons = document.getElementById('guest-buttons');
    const dashboardButton = document.getElementById('dashboard-button');
    
    // Mobile elements
    const mobileGuestButtons = document.getElementById('mobile-guest-buttons');
    const mobileDashboardButton = document.getElementById('mobile-dashboard-button');
    
    // Vérifier si l'utilisateur est authentifié (seulement les admins peuvent se connecter)
    if (AuthHelper.isAuthenticated()) {
        const userData = AuthHelper.getUserData();
        
        // Vérifier que c'est un admin
        if (userData && userData.role === 'admin') {
            // Desktop: Show dashboard button, hide guest buttons
            if (guestButtons) guestButtons.style.display = 'none';
            if (dashboardButton) {
                dashboardButton.classList.remove('hidden');
            }
            
            // Mobile: Show dashboard button, hide guest buttons
            if (mobileGuestButtons) mobileGuestButtons.style.display = 'none';
            if (mobileDashboardButton) {
                mobileDashboardButton.classList.remove('hidden');
            }
        } else {
            // Si ce n'est pas un admin, déconnecter
            AuthHelper.logout();
        }
    } else {
        // Desktop: Show guest buttons, hide dashboard button
        if (guestButtons) guestButtons.style.display = 'flex';
        if (dashboardButton) {
            dashboardButton.classList.add('hidden');
        }
        
        // Mobile: Show guest buttons, hide dashboard button
        if (mobileGuestButtons) mobileGuestButtons.style.display = 'block';
        if (mobileDashboardButton) {
            mobileDashboardButton.classList.add('hidden');
        }
    }
    
    // Mobile menu toggle functionality
    const mobileMenuBtn = document.getElementById('mobile-menu-btn');
    const mobileMenu = document.getElementById('mobile-menu');
    
    if (mobileMenuBtn && mobileMenu) {
        mobileMenuBtn.addEventListener('click', function() {
            mobileMenu.classList.toggle('hidden');
        });
    }
});
</script>