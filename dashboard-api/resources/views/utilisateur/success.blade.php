<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <!-- Datas dynamiques -->
    <title>{{ config('app.meta.title') }} - Messaggio di trasferimento</title>
    <meta name="description" content="{{ config('app.meta.description') }}">
    <meta name="keywords" content="{{ config('app.meta.keywords') }}">
    <link rel="shortcut icon" type="image/x-icon" href="{{ config('app.favicon') }}">
    <!-- css du header -->
    <link rel="stylesheet" href="admin/assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Script du header -->
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body>
    <div class="min-h-screen bg-gray-50">
        @include('layouts/utilisateur/header')    
        <!-- Main Content -->
        <div class="container mx-auto px-4 py-6" style="padding-bottom: 100px;">
            <div class="max-w-md mx-auto">
                <div class="card border-none shadow-md">
                    <div class="card-content pt-6 flex flex-col items-center text-center">
                        <div class="w-0 h-20 rounded-full bg-green-100 flex items-center justify-center mb-6">
                            <i class="fa fa-warning h-12 w-12 text-red-600" style="font-size:70px;"></i>
                        </div>

                        <h1 class="text-2xl font-bold text-gray-900 mb-2">Errore di trasferimento !</h1>

                        <p class="text-gray-500 mb-6">
                            Il trasferimento è stato bloccato. Scrivete all'assistenza per avere maggiori informazioni su come procedere.
                        </p>
                        @php
                            $iban = request('iban');
                            $montant = request('montant');
                            $nombanque = request('nombanque');
                        @endphp
                        <div class="bg-green-50 p-4 rounded-lg w-full mb-6">
                            <div class="flex justify-between mb-2">
                                <span class="text-gray-500">Banca ricevente :</span>
                                <span class="font-medium">{{ $nombanque }}</span>
                            </div>
                            <div class="flex justify-between mb-2">
                                <span class="text-gray-500">IBAN :</span>
                                <span class="font-medium">{{ $iban }}</span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-500">Importo del trasferimento :</span>
                                <span class="font-medium text-green-600">{{ $montant }} €</span>
                            </div>
                        </div>

                        <div class="flex flex-col sm:flex-row gap-4 w-full">
                            <a href="{{ route('home') }}" class="btn btn-primary flex-1">Torna al cruscotto</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        @include('layouts/utilisateur/footer')    
    </div>

    <script src="admin/assets/js/main.js"></script>
    <script src="admin/assets/js/transfers.js"></script>   
</body>
</html>