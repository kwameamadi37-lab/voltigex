<div class="dropdown-menu dropdown-menu-end" aria-labelledby="sidebarAvatar">
    <a href="{{ route('admin.virements') }}" class="dropdown-item">
        <i class="bi bi-speedometer2 me-3"></i>Tableau de bord
    </a>
    <a href="{{ route('adminprofil') }}" class="dropdown-item">
        <i class="bi bi-person me-3"></i>Profil
    </a>
    <hr class="dropdown-divider">
    <button onclick="AuthHelper.logout()" class="dropdown-item w-100 text-left border-0 bg-transparent" style="cursor: pointer;">
        <i class="bi bi-lock me-3"></i>Déconnexion
    </button>
</div> 