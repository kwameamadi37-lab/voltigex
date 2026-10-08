<!doctype html>
<html lang="en" data-theme="light">

<head>  
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
  <meta name="color-scheme" content="dark light">
  <title>Nexis | Dashboard</title>
  <link rel="icon" href="{{ asset('assets/img/favicon.png') }}" type="image/x-icon">
  <link rel="stylesheet" type="text/css" href="admin/css/main.css">
  <link rel="stylesheet" type="text/css" href="admin/css/utilities.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
  <script defer="defer" data-domain="webpixels.works" src="https://plausible.io/js/script.js">
  </script>
</head> 

<body>
  <div class="d-flex flex-column flex-lg-row h-lg-full bg-surface-secondary">
    <nav class="navbar show navbar-vertical h-lg-screen navbar-expand-lg px-0 py-3 navbar-light bg-white border-bottom border-bottom-lg-0 border-end-lg scrollbar" id="sidebar">
      <div class="container-fluid">
        <button class="navbar-toggler ms-n2" type="button" data-bs-toggle="collapse" data-bs-target="#sidebarCollapse" aria-controls="sidebarCollapse" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon">
          </span>
        </button>
        <a class="navbar-brand d-inline-block py-lg-2 mb-lg-5 px-lg-6 me-0" href="index.html">
          <img src="images/Logo.png" alt="...">
        </a>
        <div class="navbar-user d-lg-none">
          <div class="dropdown">
            <a href="index.html#" id="sidebarAvatar" role="button" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
              <div class="avatar-parent-child">
                <img alt="..." src="{{ Auth()->User()->profil }}" class="avatar avatar- rounded-circle"> 
                    <span class="avatar-child avatar-badge bg-success"></span></div>
            </a>
            <div class="dropdown-menu dropdown-menu-end" aria-labelledby="sidebarAvatar">
                <a href="index.html#" class="dropdown-item">Profil</a> 
                <a href="index.html#" class="dropdown-item">Settings</a> 
                <a href="index.html#" class="dropdown-item">Billing</a>
              <hr class="dropdown-divider"><a href="index.html#" class="dropdown-item">Logout</a>
            </div>
          </div>
        </div> 
        @include('layouts/admin/header')  
      </div>
    </nav>
    <div class="flex-lg-1 h-screen overflow-y-lg-auto">
      <nav class="navbar navbar-light position-lg-sticky top-lg-0 d-none d-lg-block overlap-10 flex-none bg-white border-bottom px-0 py-3" id="topbar">
        <div class="container-fluid">
          <div class="hstack gap-2">
          </div>
  
          <div class="navbar-user d-none d-sm-block">
            <div class="hstack gap-3 ms-4">
              <div class="dropdown"><a href="index.html#" class="nav-link px-3 text-base text-muted text-opacity-70 text-opacity-100-hover" id="dropdown-notifications" data-bs-toggle="dropdown" aria-expanded="false"></a>
              </div>
              <div class="dropdown"><a class="d-flex align-items-center" href="index.html#" role="button" data-bs-toggle="dropdown" aria-haspopup="false" aria-expanded="false">
                  <div>
                    <div class="avatar avatar-sm bg-warning rounded-circle text-white"><img alt="..." src="{{ Auth()->User()->profil }}"></div>
                  </div>
                  <div class="d-none d-sm-block ms-3"><span class="h6">{{ Auth()->User()->nom.' '.Auth()->User()->prenom }}</span></div>
                  <div class="d-none d-md-block ms-md-2"><i class="bi bi-chevron-down text-muted text-xs"></i></div>
                </a>
                @include('layouts/admin/profile-dropdown')
              </div>
            </div>
          </div>
        </div> 
      </nav> 
    <div class="flex-lg-1 h-screen overflow-y-lg-auto">
      <main class="py-6 bg-surface-secondary">
        <div class="container-fluid max-w-screen-md vstack gap-5">
          <h1 class="h4 ls-tight">Formulaire de chargement de compte</h1>
          @if(session('message'))
            <p style="padding: 15px;background-color:rgb(3, 154, 1);color:white;" class="mb-0">{{ session('message') }}</p>
            @endif
          <form action="devisestore" method="post">
            @csrf 
            <div>
              Nom : {{ $utilisateur->nom }} <br>
              Prenom : {{ $utilisateur->prenom }} <br>
              Email : {{ $utilisateur->email }}<br>
            </div><br>
            <input style="display: none" type="text" name="identifiant" value="{{ $utilisateur->id }}" class="form-control" placeholder="devise"> 

            <div><label class="form-label">Devise</label> 
              <input type="text" value="{{ $utilisateur->devise }}" name="devise" class="form-control" placeholder="devise"> 
            </div><br>
            <div>
              <input type="submit" class="btn btn-primary btn-large" value="Changer la devise" > 
            </div>
          </form>

        </div>
      </main>
    </div>
  </div>
  <script src="admin/js/main.js"></script>
</body>

</html>