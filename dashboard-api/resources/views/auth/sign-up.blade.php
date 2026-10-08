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
        .step-line {
            height: 2px;
            transition: all 0.3s ease;
        }
        .step-line.completed {
            background-color: #10b981;
        }
        .step-line.pending {
            background-color: #e5e7eb;
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
        #video-preview, #capture-preview {
            width: 100%;
            max-width: 500px;
            border-radius: 8px;
            margin: 20px auto;
            display: block;
        }
        .file-upload-area {
            border: 2px dashed #cbd5e1;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            transition: all 0.3s ease;
            cursor: pointer;
            min-height: 120px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        .file-upload-area:hover {
            border-color: #1e3a8a;
            background-color: #f8fafc;
        }
        .file-upload-area.dragover {
            border-color: #1e3a8a;
            background-color: #eff6ff;
        }
    </style>
</head>

<body class="bg-gray-50">
    <!-- Header -->
    @include('layouts/headerglobal')
    
    <!-- Main Content -->
    <div class="container mx-auto px-4 py-10 md:py-16">
        <div class="max-w-4xl mx-auto">
            <!-- Registration Card -->
            <div class="bg-white rounded-xl shadow-lg p-8">
                <!-- Progress Steps -->
                <div class="flex justify-center mb-8">
                    <div class="flex items-center space-x-4">
                        <div class="step-indicator active" id="step-1-indicator">1</div>
                        <div class="step-line w-16 pending" id="step-1-line"></div>
                        <div class="step-indicator pending" id="step-2-indicator">2</div>
                        <div class="step-line w-16 pending" id="step-2-line"></div>
                        <div class="step-indicator pending" id="step-3-indicator">3</div>
                    </div>
                </div>

                <!-- Step Labels -->
                <div class="flex justify-between text-sm text-gray-600 mb-8 px-4">
                    <span class="text-center">Informations</span>
                    <span class="text-center">Photo carte</span>
                    <span class="text-center">Confirmation</span>
                </div>

                <!-- Alert Messages -->
                <div id="alert-container"></div>
                
                <!-- Step 1: Registration Form -->
                <div class="step-content active" id="step-1">
                    <div class="text-left mb-6">
                        <h2 class="text-2xl font-bold text-gray-900 mb-2">Informations personnelles</h2>
                        <p class="text-gray-600">Remplissez vos informations pour créer votre compte</p>
                    </div>
                    
                    <form id="registration-form" class="space-y-6" enctype="multipart/form-data" novalidate>
                        @csrf
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <!-- Nom -->
                            <div>
                                <label for="nom" class="block text-sm font-medium text-gray-700 mb-2">Nom *</label>
                                <input type="text" id="nom" name="nom" 
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                                    placeholder="Votre nom" required>
                                <div class="invalid-feedback" id="nom-error"></div>
                            </div>
                            
                            <!-- Prénom -->
                            <div>
                                <label for="prenom" class="block text-sm font-medium text-gray-700 mb-2">Prénom *</label>
                                <input type="text" id="prenom" name="prenom" 
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                                    placeholder="Votre prénom" required>
                                <div class="invalid-feedback" id="prenom-error"></div>
                            </div>
                            
                            <!-- Email -->
                            <div>
                                <label for="email" class="block text-sm font-medium text-gray-700 mb-2">Adresse email *</label>
                                <input type="email" id="email" name="email" 
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                                    placeholder="votre@email.com" required>
                                <div class="invalid-feedback" id="email-error"></div>
                            </div>
                            
                            <!-- Téléphone -->
                            <div>
                                <label for="phone" class="block text-sm font-medium text-gray-700 mb-2">Téléphone *</label>
                                <div class="flex">
                                    <select id="country-code" name="country_code" 
                                        class="px-3 py-2 border border-gray-300 rounded-l-md bg-gray-50 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent text-sm">
                                        <option value="+33" data-flag="🇫🇷">+33 FR</option>
                                        <option value="+1" data-flag="🇺🇸">+1 US</option>
                                        <option value="+44" data-flag="🇬🇧">+44 UK</option>
                                        <option value="+49" data-flag="🇩🇪">+49 DE</option>
                                        <option value="+39" data-flag="🇮🇹">+39 IT</option>
                                        <option value="+34" data-flag="🇪🇸">+34 ES</option>
                                        <option value="+32" data-flag="🇧🇪">+32 BE</option>
                                        <option value="+41" data-flag="🇨🇭">+41 CH</option>
                                        <option value="+212" data-flag="🇲🇦">+212 MA</option>
                                        <option value="+225" data-flag="🇨🇮">+225 CI</option>
                                        <option value="+229" data-flag="🇧🇯">+229 BJ</option>
                                        <option value="+226" data-flag="🇧🇫">+226 BF</option>
                                        <option value="+221" data-flag="🇸🇳">+221 SN</option>
                                        <option value="+228" data-flag="🇹🇬">+228 TG</option>
                                    </select>
                                    <input type="tel" id="phone" name="phone" 
                                        class="flex-1 px-3 py-2 border border-l-0 border-gray-300 rounded-r-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                                        placeholder="6 12 34 56 78" required>
                                </div>
                                <div class="invalid-feedback" id="phone-error"></div>
                            </div>
                            
                            <!-- Pièce d'identité -->
                            <div>
                                <label for="piece_identite" class="block text-sm font-medium text-gray-700 mb-2">Pièce d'identité *</label>
                                <div class="file-upload-area" onclick="document.getElementById('piece_identite').click()">
                                    <i class="fas fa-cloud-upload-alt text-2xl text-gray-400 mb-1"></i>
                                    <p class="text-sm text-gray-600 mb-0">Cliquez pour télécharger</p>
                                    <p class="text-xs text-gray-500">PDF, JPG, PNG (max 5MB)</p>
                                    <input type="file" id="piece_identite" name="piece_identite" accept=".pdf,.jpg,.jpeg,.png" class="hidden" required>
                                </div>
                                <div id="piece_identite-name" class="mt-2 text-sm text-gray-600"></div>
                                <div class="invalid-feedback" id="piece_identite-error"></div>
                            </div>
                            
                            <!-- Avis d'imposition -->
                            <div>
                                <label for="avis_imposition" class="block text-sm font-medium text-gray-700 mb-2">Avis d'imposition *</label>
                                <div class="file-upload-area" onclick="document.getElementById('avis_imposition').click()">
                                    <i class="fas fa-file-pdf text-2xl text-gray-400 mb-1"></i>
                                    <p class="text-sm text-gray-600 mb-0">Cliquez pour télécharger</p>
                                    <p class="text-xs text-gray-500">PDF, JPG, PNG (max 5MB)</p>
                                    <input type="file" id="avis_imposition" name="avis_imposition" accept=".pdf,.jpg,.jpeg,.png" class="hidden" required>
                                </div>
                                <div id="avis_imposition-name" class="mt-2 text-sm text-gray-600"></div>
                                <div class="invalid-feedback" id="avis_imposition-error"></div>
                            </div>
                        </div>
                        
                        <!-- Password Field -->
                        <div>
                            <label for="password" class="block text-sm font-medium text-gray-700 mb-2">Mot de passe *</label>
                            <div class="relative">
                                <input type="password" id="password" name="password" 
                                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent pr-10"
                                    placeholder="Minimum 8 caractères" required>
                                <button type="button" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500" onclick="togglePassword('password')">
                                    <i class="fas fa-eye" id="password-icon"></i>
                                </button>
                            </div>
                            <div class="invalid-feedback" id="password-error"></div>
                            <p class="text-sm text-gray-500 mt-1">Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial</p>
                        </div>
                        
                        <!-- Terms and Conditions -->
                        <div class="flex items-start">
                            <input type="checkbox" id="terms" name="terms" class="mt-1 h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded" required>
                            <label for="terms" class="ml-2 text-sm text-gray-700">
                                J'accepte les <a href="{{ route('condition') }}" class="text-primary hover:underline" target="_blank">conditions d'utilisation</a> 
                                et la <a href="{{ route('confidentialite') }}" class="text-primary hover:underline" target="_blank">politique de confidentialité</a>
                            </label>
                        </div>
                        
                        <!-- Submit Button -->
                        <button type="submit" class="w-full bg-primary text-white py-3 px-4 rounded-md hover:bg-primary-dark transition-colors font-medium">
                            <span id="register-btn-text">Continuer</span>
                            <span id="register-btn-loading" class="hidden">
                                <span class="loading-spinner mr-2"></span>
                                Enregistrement...
                            </span>
                        </button>
                    </form>
                </div>

                <!-- Step 2: Photo de la carte d'identité -->
                <div class="step-content" id="step-2">
                    <div class="text-center mb-6">
                        <h2 class="text-2xl font-bold text-gray-900 mb-2">Photo de votre carte d'identité</h2>
                        <p class="text-gray-600">Prenez une photo claire de votre carte d'identité</p>
                    </div>
                    
                    <div class="space-y-6">
                        <div class="bg-blue-50 border border-blue-200 rounded-lg p-6">
                            <div class="flex items-start">
                                <i class="fas fa-info-circle text-blue-600 text-xl mr-3 mt-1"></i>
                                <div>
                                    <h3 class="font-semibold text-blue-900 mb-2">Instructions importantes</h3>
                                    <ul class="text-sm text-blue-800 space-y-1 list-disc list-inside">
                                        <li>Assurez-vous que la carte est bien visible et lisible</li>
                                        <li>Évitez les reflets et les ombres</li>
                                        <li>Placez la carte sur un fond clair</li>
                                        <li>La photo doit être nette et de bonne qualité</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Video Preview -->
                        <div id="camera-container" class="hidden">
                            <video id="video-preview" autoplay playsinline></video>
                            <canvas id="canvas" class="hidden"></canvas>
                            <button type="button" id="switch-camera-btn" onclick="switchCamera()" class="mt-3 w-full bg-gray-200 text-gray-700 py-2 px-4 rounded-md hover:bg-gray-300 transition-colors font-medium text-sm" title="Basculer caméra avant / arrière">
                                <i class="fas fa-sync-alt mr-2"></i>
                                <span id="switch-camera-label">Passer à la caméra arrière</span>
                            </button>
                        </div>
                        
                        <!-- Capture Preview -->
                        <div id="capture-container" class="hidden">
                            <img id="capture-preview" alt="Photo capturée">
                        </div>
                        
                        <!-- Buttons -->
                        <div class="flex flex-col gap-4">
                            <button type="button" id="start-camera-btn" onclick="startCamera()" class="w-full bg-primary text-white py-3 px-4 rounded-md hover:bg-primary-dark transition-colors font-medium">
                                <i class="fas fa-camera mr-2"></i>
                                Démarrer la caméra
                            </button>
                            
                            <button type="button" id="capture-btn" onclick="capturePhoto()" class="w-full bg-secondary text-primary py-3 px-4 rounded-md hover:bg-yellow-300 transition-colors font-medium hidden">
                                <i class="fas fa-camera-retro mr-2"></i>
                                Prendre la photo
                            </button>
                            
                            <button type="button" id="retake-btn" onclick="retakePhoto()" class="w-full bg-gray-200 text-gray-700 py-3 px-4 rounded-md hover:bg-gray-300 transition-colors font-medium hidden">
                                <i class="fas fa-redo mr-2"></i>
                                Reprendre la photo
                            </button>
                            
                            <button type="button" id="submit-photo-btn" onclick="submitPhoto()" class="w-full bg-success text-white py-3 px-4 rounded-md hover:bg-green-600 transition-colors font-medium hidden">
                                <i class="fas fa-check mr-2"></i>
                                Valider cette photo
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Step 3: Success -->
                <div class="step-content" id="step-3">
                    <div class="text-center">
                        <div class="w-20 h-20 bg-success rounded-full flex items-center justify-center mx-auto mb-6">
                            <i class="fas fa-check text-white text-3xl"></i>
                        </div>
                        <h2 class="text-3xl font-bold text-gray-900 mb-4">Inscription réussie !</h2>
                        <p class="text-gray-600 mb-6 text-lg">
                            Votre demande d'inscription a été enregistrée avec succès.
                        </p>
                        
                        <div class="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-6">
                            <div class="flex items-start">
                                <i class="fas fa-envelope text-blue-600 text-xl mr-3 mt-1"></i>
                                <div class="text-left">
                                    <h3 class="font-semibold text-blue-900 mb-2">Email de confirmation</h3>
                                    <p class="text-sm text-blue-800">
                                        Vous allez recevoir un email de confirmation dans quelques instants. 
                                        Votre compte sera activé après validation par notre équipe d'administration.
                                    </p>
                                </div>
                            </div>
                        </div>
                        
                        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-6 mb-6">
                            <div class="flex items-start">
                                <i class="fas fa-clock text-yellow-600 text-xl mr-3 mt-1"></i>
                                <div class="text-left">
                                    <h3 class="font-semibold text-yellow-900 mb-2">Statut du compte</h3>
                                    <p class="text-sm text-yellow-800">
                                        Votre compte est actuellement <strong>inactif</strong>. 
                                        Il sera activé après vérification de vos documents par notre équipe.
                                    </p>
                                </div>
                            </div>
                        </div>
                        
                        <div class="space-y-4">
                            <a href="/login" class="block w-full bg-primary text-white py-3 px-4 rounded-md hover:bg-primary-dark transition-colors font-medium">
                                <i class="fas fa-sign-in-alt mr-2"></i>
                                Se connecter
                            </a>
                            <a href="/" class="block w-full bg-gray-100 text-gray-700 py-3 px-4 rounded-md hover:bg-gray-200 transition-colors font-medium">
                                Retour à l'accueil
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        let currentStep = 1;
        let stream = null;
        let capturedPhoto = null;
        let currentFacingMode = 'user'; // 'user' = selfie (avant), 'environment' = arrière
        const maxFileSize = 5 * 1024 * 1024; // 5MB

        // File upload handlers
        document.getElementById('piece_identite').addEventListener('change', function(e) {
            handleFileSelect(e.target, 'piece_identite-name');
        });

        document.getElementById('avis_imposition').addEventListener('change', function(e) {
            handleFileSelect(e.target, 'avis_imposition-name');
        });

        function handleFileSelect(input, nameElementId) {
            const file = input.files[0];
            if (file) {
                if (file.size > maxFileSize) {
                    showAlert('error', 'Le fichier est trop volumineux. Taille maximale : 5MB');
                    input.value = '';
                    return;
                }
                document.getElementById(nameElementId).textContent = `Fichier sélectionné : ${file.name}`;
            }
        }

        // Stocker les données de l'étape 1
        let step1Data = null;

        // Form submission - Étape 1 : Validation uniquement
        document.getElementById('registration-form').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            
            // Ajouter le code pays au numéro de téléphone
            const countryCode = document.getElementById('country-code').value;
            const phoneNumber = formData.get('phone');
            // Enlever les espaces du numéro et combiner avec le code pays
            const fullPhone = countryCode + ' ' + phoneNumber.replace(/\s+/g, '');
            formData.set('phone', fullPhone);
            
            const submitBtn = document.querySelector('#register-btn-text').parentElement;
            const loadingBtn = document.getElementById('register-btn-loading');
            
            submitBtn.classList.add('hidden');
            loadingBtn.classList.remove('hidden');
            
            try {
                const response = await fetch('/api/auth/register', {
                    method: 'POST',
                    headers: {
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                    },
                    body: formData
                });
                
                const data = await response.json();
                
                if (response.ok && data.success) {
                    // Stocker les données de l'étape 1 pour l'étape 2
                    step1Data = formData;
                    goToStep(2);
                } else {
                    showAlert('error', data.message || 'Veuillez corriger les erreurs dans le formulaire');
                    if (data.errors) {
                        displayErrors(data.errors);
                    }
                }
            } catch (error) {
                showAlert('error', 'Une erreur est survenue. Veuillez réessayer.');
                console.error('Error:', error);
            } finally {
                submitBtn.classList.remove('hidden');
                loadingBtn.classList.add('hidden');
            }
        });

        // Camera functions — par défaut caméra avant (selfie), avec option de basculer
        function startCamera() {
            startCameraWithFacing(currentFacingMode);
        }

        function startCameraWithFacing(facingMode) {
            if (stream) {
                stream.getTracks().forEach(track => track.stop());
                stream = null;
            }
            const constraints = { video: { facingMode: facingMode } };
            navigator.mediaDevices.getUserMedia(constraints)
                .then(function(mediaStream) {
                    stream = mediaStream;
                    const video = document.getElementById('video-preview');
                    video.srcObject = stream;
                    document.getElementById('camera-container').classList.remove('hidden');
                    document.getElementById('start-camera-btn').classList.add('hidden');
                    document.getElementById('capture-btn').classList.remove('hidden');
                    updateSwitchCameraLabel();
                })
                .catch(function(err) {
                    // Sur desktop ou si seule la caméra arrière existe, réessayer avec l'autre
                    if (facingMode === 'user') {
                        currentFacingMode = 'environment';
                        startCameraWithFacing('environment');
                        return;
                    }
                    if (facingMode === 'environment') {
                        currentFacingMode = 'user';
                        startCameraWithFacing('user');
                        return;
                    }
                    showAlert('error', 'Impossible d\'accéder à la caméra. Veuillez autoriser l\'accès.');
                    console.error('Error accessing camera:', err);
                });
        }

        function updateSwitchCameraLabel() {
            const label = document.getElementById('switch-camera-label');
            if (label) label.textContent = currentFacingMode === 'user' ? 'Passer à la caméra arrière' : 'Passer à la caméra selfie';
        }

        function switchCamera() {
            currentFacingMode = currentFacingMode === 'user' ? 'environment' : 'user';
            startCameraWithFacing(currentFacingMode);
        }

        function capturePhoto() {
            const video = document.getElementById('video-preview');
            const canvas = document.getElementById('canvas');
            const ctx = canvas.getContext('2d');
            
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            ctx.drawImage(video, 0, 0);
            
            capturedPhoto = canvas.toDataURL('image/jpeg');
            
            // Stop camera
            if (stream) {
                stream.getTracks().forEach(track => track.stop());
                stream = null;
            }
            
            // Show preview
            document.getElementById('camera-container').classList.add('hidden');
            document.getElementById('capture-container').classList.remove('hidden');
            document.getElementById('capture-preview').src = capturedPhoto;
            
            document.getElementById('capture-btn').classList.add('hidden');
            document.getElementById('retake-btn').classList.remove('hidden');
            document.getElementById('submit-photo-btn').classList.remove('hidden');
        }

        function retakePhoto() {
            document.getElementById('capture-container').classList.add('hidden');
            document.getElementById('retake-btn').classList.add('hidden');
            document.getElementById('submit-photo-btn').classList.add('hidden');
            startCamera();
        }

        async function submitPhoto() {
            if (!capturedPhoto || !step1Data) {
                showAlert('error', 'Photo ou données manquantes. Veuillez recommencer depuis le début.');
                return;
            }
            
            // Convert base64 to blob
            const blob = await fetch(capturedPhoto).then(r => r.blob());
            
            // Créer un nouveau FormData avec TOUTES les données (étape 1 + photo étape 2)
            const formData = new FormData();
            
            // Ajouter toutes les données de l'étape 1
            for (const [key, value] of step1Data.entries()) {
                if (key !== 'photo_carte_identite') { // Ne pas ajouter la photo si elle existe déjà
                    formData.append(key, value);
                }
            }
            
            // Ajouter la photo de l'étape 2
            formData.append('photo_carte_identite', blob, 'carte_identite.jpg');
            
            // Afficher un loader
            const submitBtn = document.getElementById('submit-photo-btn');
            const originalText = submitBtn.innerHTML;
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<span class="loading-spinner mr-2"></span> Enregistrement en cours...';
            
            try {
                const response = await fetch('/api/auth/register/photo', {
                    method: 'POST',
                    headers: {
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                    },
                    body: formData
                });
                
                const data = await response.json();
                
                if (response.ok && data.success) {
                    goToStep(3);
                } else {
                    showAlert('error', data.message || 'Erreur lors de l\'enregistrement. Veuillez réessayer.');
                    if (data.errors) {
                        displayErrors(data.errors);
                    }
                }
            } catch (error) {
                showAlert('error', 'Une erreur est survenue. Veuillez réessayer.');
                console.error('Error:', error);
            } finally {
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalText;
            }
        }

        function goToStep(step) {
            // Hide all steps
            document.querySelectorAll('.step-content').forEach(el => el.classList.remove('active'));
            
            // Show current step
            document.getElementById(`step-${step}`).classList.add('active');
            
            // Update indicators
            for (let i = 1; i <= 3; i++) {
                const indicator = document.getElementById(`step-${i}-indicator`);
                const line = document.getElementById(`step-${i}-line`);
                
                if (i < step) {
                    indicator.classList.remove('active', 'pending');
                    indicator.classList.add('completed');
                    if (line) {
                        line.classList.remove('pending');
                        line.classList.add('completed');
                    }
                } else if (i === step) {
                    indicator.classList.remove('pending', 'completed');
                    indicator.classList.add('active');
                } else {
                    indicator.classList.remove('active', 'completed');
                    indicator.classList.add('pending');
                    if (line) {
                        line.classList.remove('completed');
                        line.classList.add('pending');
                    }
                }
            }
            
            currentStep = step;
        }

        function togglePassword(fieldId) {
            const field = document.getElementById(fieldId);
            const icon = document.getElementById(`${fieldId}-icon`);
            if (field.type === 'password') {
                field.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                field.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }

        function showAlert(type, message) {
            const container = document.getElementById('alert-container');
            const alert = document.createElement('div');
            alert.className = `alert alert-${type}`;
            alert.innerHTML = `
                <i class="fas fa-${type === 'error' ? 'exclamation-circle' : 'check-circle'}"></i>
                <span>${message}</span>
            `;
            container.innerHTML = '';
            container.appendChild(alert);
            
            setTimeout(() => {
                alert.remove();
            }, 5000);
        }

        function displayErrors(errors) {
            Object.keys(errors).forEach(field => {
                const input = document.getElementById(field);
                const errorDiv = document.getElementById(`${field}-error`);
                if (input) {
                    input.classList.add('is-invalid');
                }
                if (errorDiv) {
                    errorDiv.textContent = errors[field][0];
                }
            });
        }
    </script>
</body>
</html>
