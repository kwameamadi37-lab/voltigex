<!-- Auth Helper Script -->
<script src="/assets/js/auth-helper.js"></script>

<header class="header">
    <div class="header-left">
        <button id="sidebar-toggle" class="sidebar-toggle-btn">
            <i data-lucide="user"></i>
        </button>
        <a href="#" aria-label="Search">
            <i data-lucide="search"></i>
        </a>
    </div>
    <div class="notification-container">
        <button id="notification-btn" aria-label="Notifications" class="notification-btn">
            <i data-lucide="bell"></i>
            {{-- <span class="notification-badge">{{ auth()->user()->unreadNotificationsCount() }}</span> --}}
        </button>
        <div id="notification-dropdown" class="notification-dropdown">
            <div class="notification-header">
                <h3>Notifications</h3>
            </div>
            <div class="notification-list">
                <div class="notification-item unread">
                    <p class="notification-title">Nouveau virement reçu</p>
                    <p class="notification-message">Vous avez reçu un virement de 750,00 €</p>
                    <p class="notification-time">Il y a 2 heures</p>
                </div>
                <div class="notification-item">
                    <p class="notification-title">Paiement effectué</p>
                    <p class="notification-message">Votre paiement de 35,99 € a été traité</p>
                    <p class="notification-time">Hier</p>
                </div>
                <div class="notification-item">
                    <p class="notification-title">Offre spéciale</p>
                    <p class="notification-message">Profitez de notre offre exclusive sur les investissements</p>
                    <p class="notification-time">Il y a 2 jours</p>
                </div>
            </div>
            <div class="notification-footer">
                <a href="#">Voir toutes les notifications</a>
            </div>
        </div>
    </div>
    <a href="chat.html" class="chat-btn">
        <i data-lucide="message-square"></i>
        <span>Chat</span>
    </a>
</header>



<!-- Header -->
{{-- <header class="bg-white shadow-sm border-b border-gray-200">
  <div class="container mx-auto px-4">
      <div class="flex h-16 items-center justify-between">
          <div class="flex items-center">
            <a href="{{ route('mybank') }}"><img width="100" src="assets/img/logo.png" alt=""></a>
          </div>

          <div class="flex items-center gap-4">              

              <!-- Notification Dropdown -->
              <div class="dropdown relative">
                  <a href="{{ route('notifications') }}" class="btn-icon rounded-full relative" id="notificationDropdown" style="background-color: #cf0c05;color:white;border-radius:50px;">
                      <i class="fas fa-bell"></i>
                      <span class="sr-only">Notifiche</span>
                      <!-- Notification Badge -->
                      <span class="absolute -top-1 -right-1 bg-yellow-400 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center notification-badge">
                          {{ auth()->user()->unreadNotificationsCount() }}
                      </span>
                  </a>                  
              </div>

              <div class="dropdown">
                  <button class="btn-icon rounded-full" id="profileDropdown" style="background-color: #cf0c05;color:white;border-radius:50px;">
                      <i class="fas fa-user"></i>
                      <span class="sr-only">Profilo</span>
                  </button>
                  <div class="dropdown-menu hidden" id="profileMenu">
                      <div class="dropdown-header">{{ Auth()->User()->alias }}</div>
                      <div class="dropdown-divider"></div>
                      <a href="{{ route('home') }}" class="dropdown-item">cruscotto</a>
                      <div class="dropdown-divider"></div>
                      <a href="{{ route('virementcreate') }}" class="dropdown-item">Trasferimento</a>
                      <div class="dropdown-divider"></div>
                      <a href="{{ route('parametre') }}" class="dropdown-item">Parametri</a>
                      <div class="dropdown-divider"></div>
                      <a class="dropdown-item" onclick="event.preventDefault();
                  document.getElementById('logout-form').submit();" style="cursor: pointer;">Disconnessione</a>
                        <form id="logout-form" action="{{ route('logout') }}" method="POST" class="hidden">
                            @csrf
                        </form>
                  </div>
              </div>

              <button id="menuToggle" class="btn-icon md:hidden">
                <i class="fas fa-bars"></i>
                <span class="sr-only">Menu</span>
              </button>
          </div>
      </div>
  </div>
</header>

<!-- Mobile Menu -->
<div id="mobileMenu" class="fixed inset-0 bg-gray-900 bg-opacity-50 z-50 hidden">
  <div class="bg-white w-64 h-full">
      <div class="p-4 flex justify-between items-center border-b">
          <h2 class="font-bold">Menu</h2>
          <button id="closeMenu" class="btn-icon">
              <i class="fas fa-times"></i>
          </button>
      </div>
      <div class="p-4">
          <ul class="space-y-4">
              <li><a href="{{ route('home') }}" class="text-red-600 font-medium">Cruscotto</a></li>
              <li><a href="{{ route('virementcreate') }}" class="text-gray-700 hover:text-red-600">Trasferimento</a></li>
              <li><a href="{{ route('parametre') }}" class="text-gray-700 hover:text-red-600">Parametri</a></li>
              <li><a href="{{ route('logout') }}" class="text-gray-700 hover:text-red-600" onclick="event.preventDefault();
                  document.getElementById('logout-form').submit();">Disconnessione</a></li>
          </ul>
      </div>
  </div>
</div>

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {

    // Mettre à jour le compteur de notifications
    function updateNotificationCount() {
        fetch('/notifications/count')
            .then(response => response.json())
            .then(data => {
                const badge = document.querySelector('.notification-badge');
                if (badge) {
                    badge.textContent = data.count;
                    if (data.count === 0) {
                        badge.classList.add('hidden');
                    } else {
                        badge.classList.remove('hidden');
                    }
                }
            });
    }

    // Existing menu toggle code
    const menuToggle = document.getElementById('menuToggle');
    const mobileMenu = document.getElementById('mobileMenu');
    const closeMenu = document.getElementById('closeMenu');

    menuToggle.addEventListener('click', function() {
        mobileMenu.classList.remove('hidden');
    });

    closeMenu.addEventListener('click', function() {
        mobileMenu.classList.add('hidden');
    });
});
</script>
@endpush --}}