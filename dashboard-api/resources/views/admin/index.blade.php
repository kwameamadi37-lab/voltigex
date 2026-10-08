<!doctype html>
<html lang="en" data-theme="light">  
<head>  
  <meta charset="UTF-8"> 
  <meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
  <meta name="color-scheme" content="dark light">
  <title>Nexis | Dashboard</title>
  <link rel="icon" href="images/favicon.png" type="image/x-icon">
  <link rel="icon" href="{{ asset('assets/img/favicon.png') }}" type="image/x-icon">
  <link rel="stylesheet" type="text/css" href="gourou/css/main.css">
  <link rel="stylesheet" type="text/css" href="gourou/css/utilities.css">
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
        <a href="/" class="navbar-brand d-inline-block py-lg-2 mb-lg-5 px-lg-6 me-0" href="">
          <img style="width: 100px;" src="assets/img/logo.png" alt="Nexis">
        </a>
        <div class="navbar-user d-lg-none">
          <div class="dropdown">
            <a href="#" id="sidebarAvatar" role="button" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
              <div class="avatar-parent-child">
                <button style="background-color: #cf0c05;color:white;border-radius:50px;">
                  <i class="bi bi-person"></i>
                </button>
              </div>
            </a>
            @include('layouts/admin/profile-dropdown')
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
              <div class="dropdown"><a href="/" class="nav-link px-3 text-base text-muted text-opacity-70 text-opacity-100-hover" id="dropdown-notifications" data-bs-toggle="dropdown" aria-expanded="false"></a>
              </div>
              <div class="dropdown"><a class="d-flex align-items-center" href="/" role="button" data-bs-toggle="dropdown" aria-haspopup="false" aria-expanded="false">
                  <div>
                    <div class="avatar avatar-sm rounded-circle text-white"><img class="rounded-circle" alt="..." src="assets/img/favicon.png"></div>
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
      <header>
        <div class="container-fluid">
          <div class="border-bottom pt-6 pb-5">
            <div class="row align-items-center">
              <div class="col-sm col-12">
                <h1 class="h2 ls-tight"><span class="d-inline-block me-3">👋</span>Salut, {{ Auth()->User()->prenom }} !</h1>
              </div>
          </div>
        </div>
      </header>
      <main class="py-6 bg-surface-secondary">
        <div class="container-fluid">
          @if (session('error'))
              <div class="alert alert-danger">
                  {{ session('error') }}
              </div>
          @endif
          @if (session('message'))
              <div class="alert alert-success">
                  {{ session('message') }}   
              </div>
          @endif

          <div class="card">
            <div class="card-header border-bottom">
              <h5 class="mb-0">Liste des demandes de financement</h5>
            </div>
            <div class="table-responsive">
              <table class="table table-hover table-nowrap">
                <thead class="table-light">
                  <tr>
                    <th scope="col">Nom et prénoms</th> 
                    <th scope="col">Date de naissance</th>   
                    <th scope="col">Email</th>    
                    <th scope="col">Téléphone</th>    
                    <th scope="col">Profession</th>    
                    <th scope="col">Type de crédit</th>    
                    <th scope="col">Montant</th>    
                    <th scope="col">Durée</th>    
                  </tr>
                </thead>
                <tbody>
                  @foreach ($virement as $demande)   
                  <tr>
                    <td>{{ $demande->nom }}</td>
                    <td>{{ $demande->date_naissance }}</td>
                    <td>{{ $demande->email }}</td>
                    <td>{{ $demande->telephone }}</td>
                    <td>{{ $demande->profession }}</td>
                    <td>{{ $demande->type_credit }}</td>
                    <td>{{ number_format($demande->montant, 2) }} €</td>
                    <td>{{ $demande->duree }} mois</td>
                  </tr>
                  @endforeach
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </main>
    </div>
  </div>
  <script src="gourou/js/main.js"></script>
</body>

</html>