<!-- Auth Helper Script -->
<script src="/assets/js/auth-helper.js"></script>

<style>
    .admin-nav-link-active {
        color: #1e3a8a !important;
        font-weight: 600;
    }
</style>

<div class="collapse navbar-collapse" id="sidebarCollapse">
    <ul class="navbar-nav">
      <li class="nav-item">
        <a class="nav-link {{ request()->routeIs('admin.virements') ? 'admin-nav-link-active' : '' }}" href="{{ route('admin.virements') }}" role="button" aria-expanded="false" aria-controls="sidebar-projects">
          <i class="bi bi-speedometer2"></i> Tableau de bord
        </a>
      </li>           
      <li class="nav-item">
        <a class="nav-link {{ request()->routeIs('utilisateur') ? 'admin-nav-link-active' : '' }}" href="{{ route('utilisateur') }}" role="button" aria-expanded="false" aria-controls="sidebar-clients">
          <i class="bi bi-people"></i> Clients
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link {{ request()->routeIs('admin.support') ? 'admin-nav-link-active' : '' }}" href="{{ route('admin.support') }}" role="button" aria-expanded="false" aria-controls="sidebar-support">
          <i class="bi bi-chat-dots"></i> Chat
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link {{ request()->routeIs('admin.settings*') ? 'admin-nav-link-active' : '' }}" href="{{ route('admin.settings') }}">
          <i class="bi bi-gear"></i> Paramètres
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link {{ request()->routeIs('admin.compose-mail*') ? 'admin-nav-link-active' : '' }}" href="{{ route('admin.compose-mail') }}">
          <i class="bi bi-envelope"></i> Emails
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link {{ request()->routeIs('adminprofil') ? 'admin-nav-link-active' : '' }}" href="{{ route('adminprofil') }}" role="button" aria-expanded="false" aria-controls="sidebar-profil">
          <i class="bi bi-person"></i> Profil
        </a>
      </li>
      <li class="nav-item">
        <button style="cursor: pointer;" onclick="AuthHelper.logout()" class="nav-link" role="button" aria-expanded="false" aria-controls="sidebar-logout"  >
          <i class="bi bi-lock"></i> Déconnexion
        </button>
      </li>      
    </ul>  
</div>