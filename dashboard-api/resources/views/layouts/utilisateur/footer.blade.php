<!-- Mobile Navigation -->
<nav class="mobile-nav">
    <a href="{{ route('home') }}" class="mobile-nav-link {{ request()->routeIs('home') ? 'active' : '' }}">
        <i data-lucide="home"></i>
        <span>Home</span>
    </a>
    <a href="{{ route('carte') }}" class="mobile-nav-link {{ request()->routeIs('carte') ? 'active' : '' }}">
        <i data-lucide="credit-card"></i>
        <span>Cartes</span>
    </a>
    <a href="{{ route('virementcreate') }}" class="mobile-nav-link {{ request()->routeIs('virementcreate') ? 'active' : '' }}">
        <i data-lucide="send"></i>
        <span>Virements</span>
    </a>
    <a href="{{ route('parametre') }}" class="mobile-nav-link {{ request()->routeIs('parametre') ? 'active' : '' }}">
        <i data-lucide="user"></i>
        <span>Profil</span>
    </a>
    <a style="cursor: pointer;" onclick="AuthHelper.logout()" class="mobile-nav-link">
        <i data-lucide="log-out"></i>
        <span>Déconnexion</span>
    </a>
</nav>

{{-- <div class="fixed bottom-0 left-0 z-50 w-full h-16 bg-white border-t border-gray-200 shadow-lg">
    <div class="grid h-full max-w-lg grid-cols-4 mx-auto">
        <!-- Dashboard -->
        <a href="{{ route('home') }}" class="inline-flex flex-col items-center justify-center px-5 hover:bg-gray-50 group transition-colors {{ request()->routeIs('home') ? 'text-red-600' : 'text-gray-500' }}">
            <i class="fas fa-home w-6 h-6 mb-1 {{ request()->routeIs('home') ? 'text-red-600' : 'group-hover:text-red-600' }}"></i>
            <span class="text-xs {{ request()->routeIs('home') ? 'text-red-600' : 'group-hover:text-red-600' }}">Cruscotto</span>
        </a>
        
        <!-- Virements -->
        <a href="{{ route('virementcreate') }}" class="inline-flex flex-col items-center justify-center px-5 hover:bg-gray-50 group transition-colors {{ request()->routeIs('virementcreate') ? 'text-red-600' : 'text-gray-500' }}">
            <i class="fa fa-history w-6 h-6 mb-1 {{ request()->routeIs('virementcreate') ? 'text-red-600' : 'group-hover:text-red-600' }}"></i>
            <span class="text-xs {{ request()->routeIs('virementcreate') ? 'text-red-600' : 'group-hover:text-red-600' }}">Trasferimento</span>
        </a>
        
        <!-- Paramètres -->
        <a href="{{ route('parametre') }}" class="inline-flex flex-col items-center justify-center px-5 hover:bg-gray-50 group transition-colors {{ request()->routeIs('parametre') ? 'text-red-600' : 'text-gray-500' }}">
            <i class="fas fa-cog w-6 h-6 mb-1 {{ request()->routeIs('parametre') ? 'text-red-600' : 'group-hover:text-red-600' }}"></i>
            <span class="text-xs {{ request()->routeIs('parametre') ? 'text-red-600' : 'group-hover:text-red-600' }}">Parametri</span>
        </a>
        
        <!-- Logout -->
        <a class="inline-flex flex-col items-center justify-center px-5 hover:bg-gray-50 group transition-colors text-gray-500" onclick="AuthHelper.logout()" style="cursor: pointer;">
            <i class="fa fa-sign-out w-6 h-6 mb-1 group-hover:text-red-600"></i>
            <span class="text-xs group-hover:text-red-600">Disconnessione</span>
        </a>
    </div>
</div> --}}