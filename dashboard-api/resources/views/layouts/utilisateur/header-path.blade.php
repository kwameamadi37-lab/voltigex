<!-- Auth Helper Script -->
<script src="/assets/js/auth-helper.js"></script>

<!-- Header -->
<header class="bg-white shadow-sm border-b border-gray-200">
  <div class="container mx-auto px-4">
      <div class="flex h-16 items-center justify-between">
          <div class="flex items-center">
            <a href="{{ route('mybank') }}"><img width="100" src="../../assets/img/logo.png" alt=""></a>
          </div>

          <div class="flex items-center gap-4">
              <button id="menuToggle" class="btn-icon md:hidden">
                  <i class="fas fa-bars"></i>
                  <span class="sr-only">Menu</span>
              </button>

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
                      <div class="dropdown-header">{{ Auth()->User()->email }}</div>
                      <div class="dropdown-divider"></div>
                      <a href="{{ route('home') }}" class="dropdown-item">cruscotto</a>
                      <div class="dropdown-divider"></div>
                      <a href="{{ route('virementcreate') }}" class="dropdown-item">Trasferimento</a>
                      <div class="dropdown-divider"></div>
                      <a href="{{ route('parametre') }}" class="dropdown-item">Parametri</a>
                      <div class="dropdown-divider"></div>
                      <a class="dropdown-item" onclick="AuthHelper.logout()" style="cursor: pointer;">Disconnessione</a>
                  </div>
              </div>
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
              <li><a href="#" class="text-gray-700 hover:text-red-600" onclick="AuthHelper.logout()" style="cursor: pointer;">Disconnessione</a></li>
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
@endpush