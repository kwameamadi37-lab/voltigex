<!doctype html>
<html lang="fr" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
  <meta name="color-scheme" content="dark light">
  <title>@yield('title', 'Voltigex | Admin')</title>
  <link rel="stylesheet" type="text/css" href="{{ asset('gourou/css/main.css') }}">
  <link rel="icon" href="{{ asset('assets/img/favicon.png') }}" type="image/x-icon">
  <link rel="stylesheet" type="text/css" href="{{ asset('gourou/css/utilities.css') }}">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  @stack('styles')
</head>
<body>
  <div class="d-flex flex-column flex-lg-row h-lg-full bg-surface-secondary">
    <nav class="navbar show navbar-vertical h-lg-screen navbar-expand-lg px-0 py-3 navbar-light bg-white border-bottom border-bottom-lg-0 border-end-lg scrollbar" id="sidebar">
      <div class="container-fluid">
        <button class="navbar-toggler ms-n2" type="button" data-bs-toggle="collapse" data-bs-target="#sidebarCollapse" aria-controls="sidebarCollapse" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>
        <a href="/" class="navbar-brand d-inline-block py-lg-2 mb-lg-5 px-lg-6 me-0">
          <img style="width: 80px;height: 80px;" src="{{ asset('bank/images/favicon.png') }}" alt="Voltigex">
        </a>
        <div class="navbar-user d-lg-none">
          <div class="dropdown">
            <a href="#" id="sidebarAvatar" role="button" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
              <div class="avatar-parent-child">
                <img alt="Photo de profil" src="{{ asset('bank/images/favicon.png') }}" class="avatar avatar- rounded-circle">
                <span class="avatar-child avatar-badge bg-success"></span>
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
          <div class="hstack gap-2">@yield('topbar-left')</div>
          <div class="navbar-user d-none d-sm-block">
            <div class="hstack gap-3 ms-4">
              <div class="dropdown">
                <a class="d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown" aria-haspopup="false" aria-expanded="false">
                  <div>
                    <div class="avatar avatar-sm rounded-circle text-white">
                      <img class="rounded-circle" alt="..." src="{{ asset('bank/images/favicon.png') }}">
                    </div>
                  </div>
                  <div class="d-none d-sm-block ms-3">
                    <span class="h6">{{ Auth()->User()->nom.' '.Auth()->User()->prenom }}</span>
                  </div>
                  <div class="d-none d-md-block ms-md-2">
                    <i class="bi bi-chevron-down text-muted text-xs"></i>
                  </div>
                </a>
                @include('layouts/admin/profile-dropdown')
              </div>
            </div>
          </div>
        </div>
      </nav>
      <main class="py-6 bg-surface-secondary">
        <div class="container-fluid">
          @if (session('message'))
            <div class="alert alert-success mb-4">
              <i class="fa fa-check-circle"></i> {{ session('message') }}
            </div>
          @endif
          @yield('content')
        </div>
      </main>
    </div>
  </div>
  <script src="{{ asset('gourou/js/main.js') }}"></script>
  @stack('scripts')
</body>
</html>
