{{-- @if(session('message'))
                                <div class="bg-green-100 border border-green-400 text-green-700 px-4 p-4 rounded relative mb-4" role="alert">
                                    <span class="block sm:inline">{{ session('message') }}</span>
                                </div>
                            @endif

                            @if(session('error'))
                                <div class="bg-red-100 border border-red-400 text-red-700 px-4 p-4 rounded relative mb-4" role="alert">
                                    <span class="block sm:inline">{{ session('error') }}</span>
                                </div>
                            @endif

                            @if($errors->any())
                                <div class="bg-red-100 border border-red-400 text-red-700 px-4 p-4 rounded relative mb-4" role="alert">
                                    <ul>
                                        @foreach($errors->all() as $error)
                                            <li>{{ $error }}</li>
                                        @endforeach
                                    </ul>
                                </div>
                            @endif
                            <form action="{{ route('profilstore') }}" method="POST" class="space-y-4">
                                @csrf                                   
                                <div class="grid grid-cols-2 gap-4">
                                    <div class="space-y-2">
                                        <label for="nom" class="form-label">Nome</label>
                                        <input name="nom" value="{{ Auth::user()->nom }}" id="nom" type="text" class="form-input">
                                    </div>

                                    <div class="space-y-2">
                                        <label for="prenom" class="form-label">Nomi</label>
                                        <input id="prenom" name="prenom" type="text" class="form-input" value="{{ Auth::user()->prenom }}">
                                    </div>
                                </div>                                    
                                <div class="grid grid-cols-2 gap-4">
                                    <div class="space-y-2">
                                        <label for="phone" class="form-label">Telefono</label>
                                        <input id="phone" type="tel" name="phone" value="{{ Auth::user()->phone }}" class="form-input">
                                    </div>

                                    <div class="space-y-2">
                                        <label for="profession" class="form-label">Professione</label>
                                        <input id="profession" type="text" name="profession" value="{{ Auth::user()->profession }}" class="form-input">
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary w-full">Salva le modifiche</button>
                            </form>
                            <form action="{{ route('updatepassword') }}" method="POST" class="space-y-4">
                                @csrf
                                <div class="space-y-2">
                                    <label for="currentPassword" class="form-label">Password attuale</label>
                                    <div class="relative">
                                        <input id="currentPassword" type="password" name="oldpass" class="form-input" placeholder="Inserire la password attuale">
                                        <button type="button" class="toggle-password absolute right-0 top-0 h-full px-3 py-2 hover:bg-transparent">
                                            <i class="fa-regular fa-eye text-gray-500"></i>
                                            <span class="sr-only">Visualizzazione della password</span>
                                        </button>
                                    </div>
                                </div>

                                <div class="space-y-2">
                                    <label for="newPassword" class="form-label">Nuova password</label>
                                    <div class="relative">
                                        <input id="newPassword" type="password" name="newpass" class="form-input" placeholder="Inserire la nuova password">
                                        <button type="button" class="toggle-password absolute right-0 top-0 h-full px-3 py-2 hover:bg-transparent">
                                            <i class="fa-regular fa-eye text-gray-500"></i>
                                            <span class="sr-only">Visualizzazione della password</span>
                                        </button>
                                    </div>
                                </div>

                                <div class="space-y-2">
                                    <label for="confirmPassword" class="form-label">Confermare la password</label>
                                    <div class="relative">
                                        <input id="confirmPassword" type="password" name="confpass" class="form-input" placeholder="Confermare la nuova password">
                                        <button type="button" class="toggle-password absolute right-0 top-0 h-full px-3 py-2 hover:bg-transparent">
                                            <i class="fa-regular fa-eye text-gray-500"></i>
                                            <span class="sr-only">Visualizzazione della password</span>
                                        </button>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary w-full">Aggiornamento della sicurezza</button>
                            </form> --}}
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FinexB - Profil</title>
    <link rel="stylesheet" href="myadmin/assets/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/lucide@latest/dist/umd/lucide.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body>
    <div class="app-container">
        <!-- Header -->
        @include('layouts.utilisateur.header')

        <!-- Main Content -->
        <main class="main-content">
            <div class="hero-section primary-bg">
                <h1 class="hero-title">Mon profil</h1>
            </div>

            <div class="content-section">
                <div class="profile-container">
                    <div class="profile-sidebar desktop-only">
                        <div class="profile-card">
                            <div class="profile-avatar">
                                <div class="avatar-letter">J</div>
                                <button class="edit-avatar-btn">
                                    <i data-lucide="edit-2"></i>
                                </button>
                            </div>
                            <h2 class="profile-name">Jean Dupont</h2>
                            <p class="profile-email">client@example.com</p>
                            <p class="profile-since">Client depuis 2023</p>
                        </div>

                        <div class="profile-nav">
                            <div class="profile-nav-header mb-2">
                                <h3>Navigation</h3>
                            </div>
                            <button class="profile-nav-link active" data-tab="personal">
                                <i data-lucide="user"></i>
                                <span>Données personnelles</span>
                            </button>
                            <button class="profile-nav-link" data-tab="security">
                                <i data-lucide="shield"></i>
                                <span>Sécurité</span>
                            </button>
                            <a href="cartes.html" class="profile-nav-link">
                                <i data-lucide="credit-card"></i>
                                <span>Mes cartes</span>
                            </a>
                        </div>
                    </div>

                    <div class="profile-content">
                        <div class="mobile-tabs mobile-only">
                            <button class="tab-btn active" data-tab="personal">Données personnelles</button>
                            <button class="tab-btn" data-tab="security">Sécurité</button>
                        </div>

                        <div id="success-message" class="success-message hidden">
                            <i data-lucide="check"></i>
                            <span id="success-text"></span>
                        </div>

                        <!-- Personal Data Tab -->
                        <div id="personal-tab" class="tab-content active">
                            <div class="form-section">
                                <h2 class="section-title">Coordonnées</h2>
                                <form id="contact-form" class="profile-form">
                                    <div class="form-group" style="margin-bottom: 10px;">
                                        <label for="phone">Numéro de téléphone</label>
                                        <input type="tel" id="phone" value="+33 6 12 34 56 78">
                                    </div>
                                    <div class="form-group" style="margin-bottom: 10px;">
                                        <label for="email">Adresse e-mail</label>
                                        <input type="email" id="email" value="client@example.com">
                                    </div>
                                    <button type="submit" class="update-btn">Mettre à jour</button>
                                </form>
                            </div>

                            <div class="form-section" style="margin-top: 10px;">
                                <h2 class="section-title">Données personnelles</h2>
                                <form id="personal-form" class="profile-form">
                                    <div class="form-group" style="margin-bottom: 10px;">
                                        <label for="fullName">Nom complet</label>
                                        <input type="text" id="fullName" value="Jean Dupont">
                                    </div>
                                    <div class="form-group" style="margin-bottom: 10px;">
                                        <label for="birthDate">Date de naissance</label>
                                        <input type="date" id="birthDate" value="1985-05-15">
                                    </div>
                                    <div class="form-group" style="margin-bottom: 10px;">
                                        <label for="nationality">Nationalité</label>
                                        <input type="text" id="nationality" value="France">
                                    </div>
                                    <div class="form-group" style="margin-bottom: 10px;">
                                        <label for="idNumber">Numéro d'identification</label>
                                        <input type="text" id="idNumber" value="JDUPNT85E15Z110Y">
                                    </div>
                                    <button type="submit" class="update-btn">Mettre à jour</button>
                                </form>
                            </div>

                            <div class="form-section" style="margin-top: 10px;">
                                <h2 class="section-title">Adresse</h2>
                                <form id="address-form" class="profile-form">
                                    <div class="form-group" style="margin-bottom: 10px;">
                                        <label for="residenceAddress">Adresse de résidence</label>
                                        <input type="text" id="residenceAddress" value="123 Rue de Paris, 75001 Paris (Paris), France">
                                    </div>
                                    <div class="form-group" style="margin-bottom: 10px;">
                                        <label for="domicileAddress">Adresse de domicile</label>
                                        <input type="text" id="domicileAddress" value="123 Rue de Paris, 75001 Paris (Paris), France">
                                    </div>
                                    <button type="submit" class="update-btn">Mettre à jour</button>
                                </form>
                            </div>
                        </div>

                        <!-- Security Tab -->
                        <div id="security-tab" class="tab-content">
                            <div class="form-section">
                                <h2 class="section-title">Modifier votre mot de passe</h2>
                                <form id="password-form" class="profile-form">
                                    <div class="form-group" style="margin-bottom: 10px;">
                                        <label for="currentPassword">Mot de passe actuel</label>
                                        <input type="password" id="currentPassword" required>
                                    </div>
                                    <div class="form-group" style="margin-bottom: 10px;">
                                        <label for="newPassword">Nouveau mot de passe</label>
                                        <input type="password" id="newPassword" required>
                                    </div>
                                    <div class="form-group" style="margin-bottom: 10px;">
                                        <label for="confirmPassword">Confirmer le nouveau mot de passe</label>
                                        <input type="password" id="confirmPassword" required>
                                    </div>
                                    <button type="submit" class="update-btn">Mettre à jour le mot de passe</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        @include('layouts.utilisateur.footer')
    </div>

    <script src="myadmin/assets/js/main.js"></script>
    <script src="myadmin/assets/js/profil.js"></script>
</body>
</html>
