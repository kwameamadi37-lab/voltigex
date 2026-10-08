<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Inscription | Voltigex</title>
    <meta name="description" content="Créez votre compte Voltigex en quelques étapes simples">
    
    <!-- CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <!-- Tailwind Configuration -->
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: {
                            DEFAULT: '#1e3a8a',
                            dark: '#1e40af',
                            light: '#3b82f6'
                        },
                        secondary: '#fbbf24',
                        success: '#10b981',
                        error: '#ef4444',
                        warning: '#f59e0b'
                    }
                }
            }
        }
    </script>
    
    <!-- Custom Styles -->
    <style>
        .step-content { display: none; }
        .step-content.active { display: block; }
        .step-indicator {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        .step-indicator.active {
            background-color: #1e3a8a;
            color: white;
        }
        .step-indicator.completed {
            background-color: #10b981;
            color: white;
        }
        .step-indicator.pending {
            background-color: #e5e7eb;
            color: #6b7280;
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
        .invalid-feedback {
            color: #dc2626;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }
        .is-invalid {
            border-color: #dc2626 !important;
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
        .code-input {
            letter-spacing: 0.5em;
            text-align: center;
            font-family: 'Courier New', monospace;
            font-size: 1.5rem;
        }
    </style>
</head>

<body class="bg-gray-50">
    <!-- Header -->
    @include('layouts/headerglobal')
    
    <!-- Main Content -->
    <div class="container mx-auto px-4 py-10 md:py-10">
        <div class="flex flex-col md:flex-row items-center justify-center gap-12">
            <div class="w-full max-w-lg">
                <!-- Registration Card -->
                <div class="bg-white rounded-xl shadow-lg p-8">
                    <!-- Progress Steps -->
                    <div class="flex justify-center mb-8">
                        <div class="flex items-center space-x-4">
                            <div class="step-indicator active" id="step-1-indicator">1</div>
                            <div class="w-8 h-0.5 bg-gray-300" id="step-1-line"></div>
                            <div class="step-indicator pending" id="step-2-indicator">2</div>
                            <div class="w-8 h-0.5 bg-gray-300" id="step-2-line"></div>
                            <div class="step-indicator pending" id="step-3-indicator">3</div>
                        </div>
                    </div>

                    <!-- Step Labels -->
                    <div class="flex justify-between text-sm text-gray-600 mb-8">
                        <span class="text-center">Informations</span>
                        <span class="text-center">Vérification</span>
                        <span class="text-center">Terminé</span>
                    </div>

                    <!-- Alert Messages -->
                    <div id="alert-container"></div>
                    
                    <!-- Step 1: Registration Form -->
                    <div class="step-content active" id="step-1">
                        <div class="text-left mb-6">
                            <h2 class="text-2xl font-bold text-gray-900 mb-2">Créer votre compte</h2>
                            <p class="text-gray-600">Entrez vos informations pour commencer votre inscription</p>
                        </div>
                        
                        <form id="registration-form" class="space-y-6" novalidate>
                            @csrf
                            <!-- Email Field -->
                            <div>
                                <label for="email" class="block text-sm font-medium text-gray-700 mb-2">Adresse email</label>
                                <input type="email" id="email" name="email" 
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                                    placeholder="votre@email.com" required>
                                <div class="invalid-feedback" id="email-error"></div>
                            </div>
                            
                            <!-- Phone Field with Country Selector -->
                            <div>
                                <label for="phone" class="block text-sm font-medium text-gray-700 mb-2">Numéro de téléphone</label>
                                <div class="flex">
                                    <!-- Country Code Selector -->
                                    <div class="relative">
                                        <button type="button" id="country-selector" class="flex items-center px-3 py-2 border border-gray-300 rounded-l-md bg-gray-50 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent">
                                            <img id="country-flag" src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMTgiIHZpZXdCb3g9IjAgMCAyNCAxOCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjI0IiBoZWlnaHQ9IjE4IiBmaWxsPSIjRkZGMDAwIi8+CjxyZWN0IHdpZHRoPSIyNCIgaGVpZ2h0PSI2IiBmaWxsPSIjMDAwMDAwIi8+CjxyZWN0IHk9IjEyIiB3aWR0aD0iMjQiIGhlaWdodD0iNiIgZmlsbD0iIzAwMDAwMCIvPgo8L3N2Zz4K" alt="FR" class="w-6 h-4 rounded-sm mr-2">
                                            <span id="country-code">+33</span>
                                            <i class="fas fa-chevron-down ml-2 text-gray-500"></i>
                                        </button>
                                        
                                        <!-- Country Dropdown -->
                                        <div id="country-dropdown" class="absolute z-50 mt-1 w-80 bg-white border border-gray-300 rounded-md shadow-lg hidden">
                                            <div class="p-3 border-b border-gray-200">
                                                <input type="text" id="country-search" placeholder="Rechercher un pays..." 
                                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary">
                                            </div>
                                            <div class="max-h-60 overflow-y-auto">
                                                <div id="country-list" class="py-1">
                                                    <!-- Countries will be populated by JavaScript -->
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <!-- Phone Number Input -->
                                    <input type="tel" id="phone" name="phone" 
                                        class="flex-1 px-3 py-2 border border-l-0 border-gray-300 rounded-r-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                                        placeholder="6 12 34 56 78" required>
                                </div>
                                <div class="invalid-feedback" id="phone-error"></div>
                                <p class="text-sm text-gray-500 mt-1">Format: sans le 0 initial</p>
                            </div>
                            
                            <!-- Password Field -->
                            <div>
                                <label for="password" class="block text-sm font-medium text-gray-700 mb-2">Mot de passe</label>
                                <div class="relative">
                                    <input type="password" id="password" name="password" 
                                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent pr-10"
                                        placeholder="Minimum 8 caractères" required>
                                    <button type="button" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500" onclick="togglePassword('password')">
                                        <i class="fas fa-eye" id="password-icon"></i>
                                    </button>
                                </div>
                                <div class="invalid-feedback" id="password-error"></div>
                            </div>
                            
                            <!-- Terms and Conditions -->
                            <div class="flex items-start">
                                <input type="checkbox" id="terms" name="terms" class="mt-1 h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded" required>
                                <label for="terms" class="ml-2 text-sm text-gray-700">
                                    J'accepte les <a href="#" class="text-primary hover:underline">conditions d'utilisation</a> 
                                    et la <a href="#" class="text-primary hover:underline">politique de confidentialité</a>
                                </label>
                            </div>
                            
                            <!-- Submit Button -->
                            <button type="submit" class="w-full bg-primary text-white py-3 px-4 rounded-md hover:bg-primary-dark transition-colors font-medium">
                                <span id="register-btn-text">Créer mon compte</span>
                                <span id="register-btn-loading" class="hidden">
                                    <span class="loading-spinner mr-2"></span>
                                    Création en cours...
                                </span>
                            </button>
                        </form>
                    </div>

                    <!-- Step 2: Verification -->
                    <div class="step-content" id="step-2">
                        <div class="text-left mb-6">
                            <h2 class="text-2xl font-bold text-gray-900 mb-2">Vérification</h2>
                            <p class="text-gray-600">Entrez le code de vérification envoyé par email et SMS</p>
                        </div>
                        
                        <form id="verification-form" class="space-y-6" novalidate>
                            <!-- Verification Code -->
                            <div>
                                <label for="verification-code" class="block text-sm font-medium text-gray-700 mb-2">Code de vérification</label>
                                <input type="text" id="verification-code" name="code" 
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent code-input"
                                    placeholder="123456" maxlength="6" required>
                                <div class="invalid-feedback" id="code-error"></div>
                                <p class="text-sm text-gray-500 mt-2">
                                    Le code expire dans <span id="countdown">10:00</span>
                                </p>
                            </div>
                            
                            <!-- Resend Code -->
                            <div class="text-center">
                                <button type="button" id="resend-btn" class="text-sm text-primary hover:underline disabled:text-gray-400" disabled>
                                    Renvoyer le code
                                </button>
                            </div>
                            
                            <!-- Submit Button -->
                            <button type="submit" class="w-full bg-primary text-white py-3 px-4 rounded-md hover:bg-primary-dark transition-colors font-medium">
                                <span id="verify-btn-text">Vérifier le code</span>
                                <span id="verify-btn-loading" class="hidden">
                                    <span class="loading-spinner mr-2"></span>
                                    Vérification...
                                </span>
                            </button>
                        </form>
                    </div>

                    <!-- Step 3: Account Created -->
                    <div class="step-content" id="step-3">
                        <div class="text-center">
                            <div class="w-16 h-16 bg-primary rounded-full flex items-center justify-center mx-auto mb-6">
                                <i class="fas fa-user-check text-white text-2xl"></i>
                            </div>
                            <h2 class="text-2xl font-bold text-gray-900 mb-2">Compte créé avec succès !</h2>
                            <p class="text-gray-600 mb-4">Votre compte Voltigex a été créé et votre email/téléphone sont vérifiés.</p>
                            
                            <div class="space-y-4">
                                <button onclick="goToLogin()" class="w-full bg-primary text-white py-3 px-4 rounded-md hover:bg-primary-dark transition-colors font-medium">
                                    <i class="fas fa-sign-in-alt mr-2"></i>
                                    Se connecter
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Footer -->
    @include('layouts/footerglobal')

    <!-- JavaScript -->
    <script>
        let currentStep = 1;
        let userEmail = '';
        let countdownInterval = null;
        let resendCooldown = 0;

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

        // Show alert message
        function showAlert(message, type = 'info') {
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
            }, 5000);
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

        // Go to step
        function goToStep(step) {
            // Hide all steps
            document.querySelectorAll('.step-content').forEach(el => el.classList.remove('active'));
            
            // Show current step
            document.getElementById(`step-${step}`).classList.add('active');
            
            // Update step indicators
            for (let i = 1; i <= 3; i++) {
                const indicator = document.getElementById(`step-${i}-indicator`);
                const line = document.getElementById(`step-${i}-line`);
                
                if (i < step) {
                    indicator.className = 'step-indicator completed';
                    if (line) line.className = 'w-8 h-0.5 bg-success';
                } else if (i === step) {
                    indicator.className = 'step-indicator active';
                    if (line) line.className = 'w-8 h-0.5 bg-gray-300';
                } else {
                    indicator.className = 'step-indicator pending';
                    if (line) line.className = 'w-8 h-0.5 bg-gray-300';
                }
            }
            
            currentStep = step;
        }

        // Start countdown
        function startCountdown() {
            let timeLeft = 600; // 10 minutes in seconds
            
            countdownInterval = setInterval(() => {
                const minutes = Math.floor(timeLeft / 60);
                const seconds = timeLeft % 60;
                
                document.getElementById('countdown').textContent = 
                    `${minutes}:${seconds.toString().padStart(2, '0')}`;
                
                if (timeLeft <= 0) {
                    clearInterval(countdownInterval);
                    document.getElementById('countdown').textContent = 'Expiré';
                    showAlert('Le code de vérification a expiré. Veuillez en demander un nouveau.', 'error');
                }
                
                timeLeft--;
            }, 1000);
        }

        // Start resend cooldown
        function startResendCooldown() {
            resendCooldown = 60; // 60 seconds
            const resendBtn = document.getElementById('resend-btn');
            resendBtn.disabled = true;
            
            const cooldownInterval = setInterval(() => {
                resendBtn.textContent = `Renvoyer le code (${resendCooldown}s)`;
                resendCooldown--;
                
                if (resendCooldown < 0) {
                    clearInterval(cooldownInterval);
                    resendBtn.textContent = 'Renvoyer le code';
                    resendBtn.disabled = false;
                }
            }, 1000);
        }

        // Registration form submission
        document.getElementById('registration-form').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            clearErrors();
            
            const formData = new FormData(this);
            const phoneNumber = formData.get('phone').replace(/\D/g, ''); // Remove formatting
            const fullPhoneNumber = selectedCountry.dialCode + phoneNumber;
            
            const data = {
                email: formData.get('email'),
                phone: fullPhoneNumber,
                password: formData.get('password')
            };
            
            // Basic validation
            if (!data.email || !data.phone || !data.password) {
                showAlert('Veuillez remplir tous les champs.', 'error');
                return;
            }
            
            if (!document.getElementById('terms').checked) {
                showAlert('Veuillez accepter les conditions d\'utilisation.', 'error');
                return;
            }
            
            // Show loading state
            document.getElementById('register-btn-text').classList.add('hidden');
            document.getElementById('register-btn-loading').classList.remove('hidden');
            
            try {
                const response = await fetch('/api/auth/register', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify(data)
                });
                
                const result = await response.json();
                
                if (result.success) {
                    userEmail = data.email;
                    showAlert(result.message, 'success');
                    goToStep(2);
                    startCountdown();
                    startResendCooldown();
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
                document.getElementById('register-btn-text').classList.remove('hidden');
                document.getElementById('register-btn-loading').classList.add('hidden');
            }
        });

        // Verification form submission
        document.getElementById('verification-form').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            clearErrors();
            
            const code = document.getElementById('verification-code').value;
            
            if (!code || code.length !== 6) {
                showFieldError('verification-code', 'Le code doit contenir exactement 6 chiffres.');
                return;
            }
            
            // Show loading state
            document.getElementById('verify-btn-text').classList.add('hidden');
            document.getElementById('verify-btn-loading').classList.remove('hidden');
            
            try {
                const response = await fetch('/api/auth/verify', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({
                        email: userEmail,
                        code: code
                    })
                });
                
                const result = await response.json();
                
                if (result.success) {
                    clearInterval(countdownInterval);
                    
                    // Store user data for KYC process
                    if (result.data && result.data.user_id) {
                        localStorage.setItem('user_data', JSON.stringify({
                            id: result.data.user_id,
                            email: userEmail,
                            email_verified: result.data.email_verified,
                            phone_verified: result.data.phone_verified,
                            email_and_phone_verified: result.data.email_and_phone_verified,
                        }));
                    }
                    
                    showAlert(result.message, 'success');
                    goToStep(3);
                } else {
                    showFieldError('verification-code', result.message);
                }
                
            } catch (error) {
                showAlert('Erreur de connexion. Veuillez réessayer.', 'error');
            } finally {
                // Hide loading state
                document.getElementById('verify-btn-text').classList.remove('hidden');
                document.getElementById('verify-btn-loading').classList.add('hidden');
            }
        });

        // Resend code
        document.getElementById('resend-btn').addEventListener('click', async function() {
            if (resendCooldown > 0) return;
            
            this.disabled = true;
            this.textContent = 'Envoi en cours...';
            
            try {
                const response = await fetch('/api/auth/resend-code', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({
                        email: userEmail        
                    })
                });
                
                const result = await response.json();
                
                if (result.success) {
                    showAlert(result.message, 'success');
                    startResendCooldown();
                    startCountdown();
                } else {
                    showAlert(result.message || 'Erreur lors du renvoi du code.', 'error');
                    this.disabled = false;
                    this.textContent = 'Renvoyer le code';
                }
            } catch (error) {
                showAlert('Erreur de connexion. Veuillez réessayer.', 'error');
                this.disabled = false;
                this.textContent = 'Renvoyer le code';
            }
        });

        // Navigation functions
        function goToLogin() {
            window.location.href = '/login';
        }

        function goToDashboard() {
            window.location.href = '/mybank';
        }


        // Country data
        const countries = [
            { code: 'FR', name: 'France', dialCode: '+33', flag: '🇫🇷' },
            { code: 'BE', name: 'Belgique', dialCode: '+32', flag: '🇧🇪' },
            { code: 'CH', name: 'Suisse', dialCode: '+41', flag: '🇨🇭' },
            { code: 'DE', name: 'Allemagne', dialCode: '+49', flag: '🇩🇪' },
            { code: 'ES', name: 'Espagne', dialCode: '+34', flag: '🇪🇸' },
            { code: 'IT', name: 'Italie', dialCode: '+39', flag: '🇮🇹' },
            { code: 'GB', name: 'Royaume-Uni', dialCode: '+44', flag: '🇬🇧' },
            { code: 'US', name: 'États-Unis', dialCode: '+1', flag: '🇺🇸' },
            { code: 'CA', name: 'Canada', dialCode: '+1', flag: '🇨🇦' },
            { code: 'BJ', name: 'Bénin', dialCode: '+229', flag: '🇧🇯' }
        ];

        let selectedCountry = countries[0]; // France par défaut

        // Initialize country selector
        function initCountrySelector() {
            const countryList = document.getElementById('country-list');
            const countrySearch = document.getElementById('country-search');
            const countryDropdown = document.getElementById('country-dropdown');
            const countrySelector = document.getElementById('country-selector');

            // Populate country list
            function populateCountryList(countriesToShow = countries) {
                countryList.innerHTML = countriesToShow.map(country => `
                    <button type="button" class="w-full px-3 py-2 text-left hover:bg-gray-100 flex items-center country-option" data-code="${country.code}">
                        <span class="text-lg mr-3">${country.flag}</span>
                        <span class="flex-1">${country.name}</span>
                        <span class="text-gray-500">${country.dialCode}</span>
                    </button>
                `).join('');
            }

            // Show dropdown
            countrySelector.addEventListener('click', function(e) {
                e.stopPropagation();
                countryDropdown.classList.toggle('hidden');
                if (!countryDropdown.classList.contains('hidden')) {
                    countrySearch.focus();
                }
            });

            // Hide dropdown when clicking outside
            document.addEventListener('click', function(e) {
                if (!countrySelector.contains(e.target) && !countryDropdown.contains(e.target)) {
                    countryDropdown.classList.add('hidden');
                }
            });

            // Country search
            countrySearch.addEventListener('input', function(e) {
                const searchTerm = e.target.value.toLowerCase();
                const filteredCountries = countries.filter(country => 
                    country.name.toLowerCase().includes(searchTerm) ||
                    country.dialCode.includes(searchTerm) ||
                    country.code.toLowerCase().includes(searchTerm)
                );
                populateCountryList(filteredCountries);
            });

            // Country selection
            countryList.addEventListener('click', function(e) {
                const countryOption = e.target.closest('.country-option');
                if (countryOption) {
                    const countryCode = countryOption.dataset.code;
                    selectedCountry = countries.find(c => c.code === countryCode);
                    
                    // Update UI
                    document.getElementById('country-code').textContent = selectedCountry.dialCode;
                    document.getElementById('country-flag').alt = selectedCountry.code;
                    
                    // Update placeholder based on country
                    const phoneInput = document.getElementById('phone');
                    if (selectedCountry.code === 'FR') {
                        phoneInput.placeholder = '6 12 34 56 78';
                    } else if (selectedCountry.code === 'US' || selectedCountry.code === 'CA') {
                        phoneInput.placeholder = '555 123 4567';
                    } else if (selectedCountry.code === 'BJ') {
                        phoneInput.placeholder = '97 12 34 56';
                    } else {
                        phoneInput.placeholder = 'Numéro de téléphone';
                    }
                    
                    countryDropdown.classList.add('hidden');
                }
            });

            // Initialize
            populateCountryList();
        }

        // Auto-format phone number based on country
        function formatPhoneNumber(value, countryCode) {
            let cleaned = value.replace(/\D/g, '');
            
            if (countryCode === 'FR') {
                // Format français: 6 12 34 56 78
                if (cleaned.length > 0) {
                    cleaned = cleaned.replace(/(\d{1})(\d{2})(\d{2})(\d{2})(\d{2})/, '$1 $2 $3 $4 $5');
                }
            } else if (countryCode === 'US' || countryCode === 'CA') {
                // Format américain: (555) 123-4567
                if (cleaned.length > 0) {
                    cleaned = cleaned.replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3');
                }
            } else if (countryCode === 'GB') {
                // Format britannique: 7700 900123
                if (cleaned.length > 0) {
                    cleaned = cleaned.replace(/(\d{4})(\d{6})/, '$1 $2');
                }
            } else if (countryCode === 'BJ') {
                // Format béninois: 97 12 34 56
                if (cleaned.length > 0) {
                    cleaned = cleaned.replace(/(\d{2})(\d{2})(\d{2})(\d{2})/, '$1 $2 $3 $4');
                }
            }
            
            return cleaned;
        }

        // Initialize country selector when page loads
        document.addEventListener('DOMContentLoaded', function() {
            initCountrySelector();
            
            // Phone number formatting
            document.getElementById('phone').addEventListener('input', function(e) {
                const formatted = formatPhoneNumber(e.target.value, selectedCountry.code);
                e.target.value = formatted;
            });
        });

        // Auto-format verification code
        document.getElementById('verification-code').addEventListener('input', function(e) {
            e.target.value = e.target.value.replace(/\D/g, '').substring(0, 6);
        });
    </script>
</body>
</html>
