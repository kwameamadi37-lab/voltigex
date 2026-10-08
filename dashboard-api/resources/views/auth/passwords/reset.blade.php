<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nouveau mot de passe | Voltigex</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: { DEFAULT: '#1e3a8a', dark: '#1e40af' },
                    }
                }
            }
        }
    </script>
    <style>
        .invalid-feedback { color: #dc3545; font-size: 0.875rem; margin-top: 0.25rem; display: block; }
        .is-invalid { border-color: #dc3545 !important; }
    </style>
</head>
<body class="bg-gray-50">
    @include('layouts/headerglobal')

    <div class="container mx-auto px-4 py-10">
        <div class="flex justify-center">
            <div class="w-full max-w-md bg-white rounded-xl shadow-lg p-8">
                <div class="flex justify-center mb-6">
                    <img src="{{ asset('bank/images/favicon.png') }}" alt="Voltigex" class="w-20 h-20 rounded-full">
                </div>
                <h2 class="text-2xl font-bold text-gray-900 mb-2">Nouveau mot de passe</h2>
                <p class="text-gray-600 mb-6">Choisissez un mot de passe sécurisé pour votre compte.</p>

                <form method="POST" action="{{ route('password.update') }}" class="space-y-5" id="passwordForm">
                    @csrf
                    <input type="hidden" name="token" value="{{ $token }}">

                    <input type="hidden" name="email" value="{{ $email ?? old('email') }}">

                    <div>
                        <label for="password" class="block text-sm font-medium text-gray-700 mb-2">Mot de passe</label>
                        <div class="relative">
                            <input id="password" type="password" name="password" required autocomplete="new-password"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary pr-10 @error('password') is-invalid @enderror">
                            <button type="button" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500" onclick="togglePassword('password', 'password-icon')">
                                <i class="fas fa-eye" id="password-icon"></i>
                            </button>
                        </div>
                        @error('password')
                            <span class="invalid-feedback"><strong>{{ $message }}</strong></span>
                        @enderror
                    </div>

                    <div>
                        <label for="password-confirm" class="block text-sm font-medium text-gray-700 mb-2">Confirmer le mot de passe</label>
                        <input id="password-confirm" type="password" name="password_confirmation" required autocomplete="new-password"
                            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary">
                    </div>

                    <button type="submit" class="w-full bg-primary text-white py-2.5 px-4 rounded-md hover:bg-primary-dark font-medium">
                        Enregistrer
                    </button>
                    <p class="text-center text-sm">
                        <a href="{{ route('login') }}" class="text-primary hover:underline">Retour à la connexion</a>
                    </p>
                </form>
            </div>
        </div>
    </div>

    @include('layouts/footerglobal')
    <script>
        function togglePassword(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);
            if (!input || !icon) return;
            const show = input.type === 'password';
            input.type = show ? 'text' : 'password';
            icon.classList.toggle('fa-eye', !show);
            icon.classList.toggle('fa-eye-slash', show);
        }
        document.getElementById('passwordForm')?.addEventListener('submit', function(e) {
            const a = document.getElementById('password').value;
            const b = document.getElementById('password-confirm').value;
            if (a !== b) {
                e.preventDefault();
                alert('Les mots de passe ne correspondent pas.');
            }
        });
    </script>
</body>
</html>
