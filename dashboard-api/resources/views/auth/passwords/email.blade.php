<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mot de passe oublié | Voltigex</title>
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
        .invalid-feedback { color: #dc3545; font-size: 0.875rem; margin-top: 0.25rem; }
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
                <h2 class="text-2xl font-bold text-gray-900 mb-2">Mot de passe oublié</h2>
                <p class="text-gray-600 mb-6">Entrez votre email pour recevoir un lien de réinitialisation.</p>

                @if (session('status'))
                    <div class="mb-4 p-4 rounded-md bg-green-50 text-green-800 border border-green-200" role="alert">
                        Vérifiez votre boîte mail : un lien de réinitialisation vient d'être envoyé.
                    </div>
                @endif

                <form method="POST" action="{{ route('password.email') }}" class="space-y-5">
                    @csrf
                    <div>
                        <label for="email" class="block text-sm font-medium text-gray-700 mb-2">Adresse email</label>
                        <input id="email" type="email" name="email" value="{{ old('email') }}"
                            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary @error('email') is-invalid @enderror"
                            placeholder="votre@email.com" autocomplete="email" autofocus required>
                        @error('email')
                            <span class="invalid-feedback"><strong>{{ $message }}</strong></span>
                        @enderror
                    </div>
                    <button type="submit" class="w-full bg-primary text-white py-2.5 px-4 rounded-md hover:bg-primary-dark font-medium">
                        Envoyer le lien
                    </button>
                    <p class="text-center text-sm">
                        <a href="{{ route('login') }}" class="text-primary hover:underline">Retour à la connexion</a>
                    </p>
                </form>
            </div>
        </div>
    </div>

    @include('layouts/footerglobal')
</body>
</html>
