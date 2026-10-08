<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Connexion | Voltigex</title>
    <meta name="description" content="Connectez-vous à votre compte Voltigex ou créez un nouveau compte">
    
    <!-- CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <!-- Auth Helper Script -->
    <script src="/assets/js/auth-helper.js"></script>
    
    <!-- Tailwind Configuration -->
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: {
                            DEFAULT: '#1e3a8a',
                            dark: '#1e40af'
                        },
                        secondary: '#fbbf24'
                    }
                }
            }
        }
    </script>
    
    <!-- Custom Styles -->
    <style>
        .tab-content { display: none; }
        .tab-content.active { display: block; }
        .tab-button.active { 
            background-color: #1e3a8a; 
            color: white; 
        }
        .alert-blocked {
            background-color: #fff3f3;
            border: 1px solid #ffcdd2;
            color: #d32f2f;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .alert-warning {
            background-color: #fff8e1;
            border: 1px solid #ffe082;
            color: #f57c00;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .invalid-feedback {
            color: #dc3545;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }
        .is-invalid {
            border-color: #dc3545 !important;
        }
        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .alert-success {
            background-color: #f0fdf4;
            border: 1px solid #bbf7d0;
            color: #166534;
        }
        .alert-error {
            background-color: #fef2f2;
            border: 1px solid #fecaca;
            color: #dc2626;
        }
        .alert-info {
            background-color: #eff6ff;
            border: 1px solid #bfdbfe;
            color: #1d4ed8;
        }
        .loading-spinner {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid #f3f3f3;
            border-top: 3px solid #1e3a8a;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>

<body class="bg-gray-50">
    <!-- Header -->
    @include('layouts/headerglobal')
    
    <!-- Main Content -->
    <div class="container mx-auto px-4 py-10 md:py-10">
        <div class="flex flex-col md:flex-row items-center justify-center gap-12">
            <div class="w-full max-w-md">
                <!-- Login Card -->
                <div class="bg-white rounded-xl shadow-lg p-8">
                    <!-- Alert Messages Container -->
                    <div id="alert-container"></div>
                    
                    @if(session('user_access_denied'))
                    <div id="user-access-denied-alert" class="alert-warning mb-6">
                        <i class="fas fa-exclamation-triangle text-xl"></i>
                        <div>
                            <strong class="block mb-2">Accès refusé</strong>
                            <p class="text-sm mb-3">
                                {{ session('message', 'L\'accès au site web est réservé aux administrateurs. Pour vous connecter à votre compte Voltigex, veuillez télécharger l\'application mobile puis vous connecter en scannant le QR code de connexion dans l\'application.') }}
                            </p>
                            <a href="{{ route('welcome') }}#application-mobile" class="inline-flex items-center text-sm font-semibold hover:underline">
                                <i class="fas fa-mobile-alt mr-2"></i>
                                Télécharger l'application mobile
                            </a>
                        </div>
                    </div>
                    @endif
                    
                    @if(session('account_blocked'))
                    <div class="alert-blocked mb-6">
                        <i class="fas fa-ban text-xl"></i>
                        <div>
                            <strong>Compte bloqué</strong>
                            <p class="text-sm mt-1">{{ session('account_blocked') }}</p>
                        </div>
                    </div>
                    @endif
                    
                    <div class="flex justify-center mb-6">
                        <img src="bank/images/favicon.png" alt="Voltigex" class="w-20 h-20 rounded-full">
                    </div>
                    <!-- Form Header -->
                    <div class="text-left mb-6">
                        <h2 class="text-2xl font-bold text-gray-900 mb-2">Connectez vous à votre compte</h2>
                        <p class="text-gray-600">Entrez vos identifiants pour accéder à votre espace bancaire</p>
                    </div>                            
                    
                    <!-- Login Form -->
                    <form id="login-form" class="space-y-6" novalidate>
                        <!-- Email Field -->
                        <div>
                            <label for="email" class="block text-sm font-medium text-gray-700 mb-2">Adresse email ou Identifiant</label>
                            <input type="email" id="email" name="email" 
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                                placeholder="votre@email.com" required>
                            <div class="invalid-feedback" id="email-error"></div>
                        </div>                                
                        
                        <!-- Password Field -->
                        <div>
                            <label for="password" class="block text-sm font-medium text-gray-700 mb-2">Mot de passe</label>
                            <div class="relative">
                                <input type="password" id="password" name="password" 
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent pr-10"
                                    placeholder="Votre mot de passe" required>
                                <button type="button" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500" onclick="togglePassword('password')">
                                    <i class="fas fa-eye" id="password-icon"></i>
                                </button>
                            </div>
                            <div class="invalid-feedback" id="password-error"></div>
                        </div>
                        
                        <!-- Remember Me & Forgot Password -->
                        <div class="flex items-center justify-between">
                            <div class="flex items-center">
                                <input type="checkbox" id="remember-me" class="h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded">
                                <label for="remember-me" class="ml-2 text-sm text-gray-700">Se souvenir de moi</label>
                            </div>
                            <a href="{{ route('password.request') }}" class="text-sm text-primary hover:underline">Mot de passe oublié ?</a>
                        </div>
                        
                        <!-- Submit Button -->
                        <button type="submit" class="w-full bg-primary text-white py-3 px-4 rounded-md hover:bg-primary-dark transition-colors font-medium">
                            <span id="login-btn-text">Se connecter</span>
                            <span id="login-btn-loading" class="hidden">
                                <span class="loading-spinner mr-2"></span>
                                Connexion en cours...
                            </span>
                        </button>
                    </form>
                    
                    <!-- Registration Link -->
                    <div class="text-center mt-6">
                        <p class="text-sm text-gray-600">
                            Vous n'avez pas encore de compte ?
                            <a href="/sign-up" class="text-primary hover:underline font-medium">
                                Ouvrir un compte
                            </a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Footer -->
    @include('layouts/footerglobal')

    <!-- JavaScript -->
    <script>
        // Password toggle functionality
        function togglePassword(inputId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(inputId + '-icon');
            
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.replace('fa-eye', 'fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.replace('fa-eye-slash', 'fa-eye');
            }
        }

        // Show alert message (avec durée personnalisable)
        function showAlert(message, type = 'info', duration = 5000) {
            const alertContainer = document.getElementById('alert-container');
            const alertClass = type === 'error' ? 'alert-error' : type === 'success' ? 'alert-success' : 'alert-info';
            const icon = type === 'error' ? 'fas fa-exclamation-circle' : type === 'success' ? 'fas fa-check-circle' : 'fas fa-info-circle';
            
            alertContainer.innerHTML = `
                <div class="alert ${alertClass}">
                    <i class="${icon}"></i>
                    <span>${message}</span>
                </div>
            `;
            
            // Auto-hide after 5 seconds
            setTimeout(() => {
                alertContainer.innerHTML = '';
            }, duration);
        }

        // Clear form errors
        function clearErrors() {
            document.querySelectorAll('.is-invalid').forEach(el => el.classList.remove('is-invalid'));
            document.querySelectorAll('.invalid-feedback').forEach(el => el.textContent = '');
        }

        // Show field error
        function showFieldError(fieldId, message) {
            const field = document.getElementById(fieldId);
            const errorDiv = document.getElementById(fieldId + '-error');
            
            field.classList.add('is-invalid');
            errorDiv.textContent = message;
        }

        // Login form submission
        document.addEventListener('DOMContentLoaded', function() {
            // Auto-hide server-side access denied message after 2 minutes
            const serverAlert = document.getElementById('user-access-denied-alert');
            if (serverAlert) {
                setTimeout(() => {
                    serverAlert.remove();
                }, 120000);
            }
            
            const loginForm = document.getElementById('login-form');
            
            if (loginForm) {
                loginForm.addEventListener('submit', async function(e) {
                    e.preventDefault();
                    
                    clearErrors();
                    
                    const formData = new FormData(this);
                    const data = {
                        email: formData.get('email'),
                        password: formData.get('password')
                    };
                    
                    // Basic validation
                    if (!data.email || !data.password) {
                        showAlert('Veuillez remplir tous les champs.', 'error');
                        return;
                    }
                    
                    // Show loading state
                    document.getElementById('login-btn-text').classList.add('hidden');
                    document.getElementById('login-btn-loading').classList.remove('hidden');
                    
                    try {
                        const response = await fetch('/api/auth/login', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                                'Accept': 'application/json'
                            },
                            body: JSON.stringify(data)
                        });
                        
                        const result = await response.json();
                        
                        if (result.success) {
                            const user = result.data.user;
                            
                            // Si l'utilisateur est un admin, on le connecte normalement
                            if (user && user.role === 'admin') {
                                localStorage.setItem('auth_token', result.data.token);
                                localStorage.setItem('user_data', JSON.stringify(user));
                                
                                showAlert(result.message, 'success');
                                
                                setTimeout(() => {
                                    AuthHelper.redirectBasedOnRole();
                                }, 1000);
                            } else {
                                // Rôle user ou autre: refus de connexion via le site web
                                localStorage.removeItem('auth_token');
                                localStorage.removeItem('user_data');
                                
                                showAlert(
                                    'Pour des raisons de sécurité, les clients Voltigex ne peuvent pas se connecter via le site web. ' +
                                    'Veuillez télécharger l’application mobile Voltigex, puis vous connecter en scannant le QR code de connexion dans l’application.',
                                    'error',
                                    120000
                                );
                            }
                        } else {
                            if (result.errors) {
                                Object.keys(result.errors).forEach(field => {
                                    showFieldError(field, result.errors[field][0]);
                                });
                            }
                            showAlert(result.message, 'error');
                        }
                        
                    } catch (error) {
                        showAlert('Erreur de connexion. Veuillez réessayer.', 'error');
                    } finally {
                        // Hide loading state
                        document.getElementById('login-btn-text').classList.remove('hidden');
                        document.getElementById('login-btn-loading').classList.add('hidden');
                    }
                });
            }
        });
    </script>
</body>
</html>