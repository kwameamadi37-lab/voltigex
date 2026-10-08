<!DOCTYPE html>
<html lang="fr">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- Datas dynamiques -->
        <title>{{ config('app.meta.title') }} - Finalizzazione del trasferimento</title>
        <meta name="description" content="{{ config('app.meta.description') }}">
        <meta name="keywords" content="{{ config('app.meta.keywords') }}">
        <link rel="shortcut icon" type="image/x-icon" href="{{ config('app.favicon') }}">
        <!-- css du header -->
        <link rel="stylesheet" href="../../admin/assets/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <!-- Script du header -->
        <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
        <meta name="csrf-token" content="{{ csrf_token() }}">
    </head>
    <body>
        <div class="min-h-screen bg-gray-50">
        @include('layouts/utilisateur/header-path')    

            <!-- Main Content -->
            <div class="container mx-auto px-4 py-6" style="padding-bottom:100px;">
                <h1 class="text-2xl font-bold text-gray-900 mb-6 text-center">Finalizzare il trasferimento</h1>
                <div class="max-w-md mx-auto">
                    <div class="card border-none shadow-md">
                        <div class="card-content pt-6">
                            <form id="transferForm" class="space-y-6">                                
                                <div class="space-y-2">
                                    <label for="code" class="form-label">Codice di conferma</label>
                                    <div class="relative">
                                        <input id="code" type="text" class="form-input" placeholder="Inserire il codice di conferma" required>
                                    </div>
                                    <p class="text-sm text-gray-500 mt-1">
                                        Inserire il codice di conferma ricevuto per finalizzare il trasferimento.
                                    </p>
                                </div>                                                              
                                <button type="submit" class="btn btn-primary w-full">Finalizzare il trasferimento</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Progress Modal -->
            <div id="progressModal" class="modal hidden">
                <div class="modal-overlay"></div>
                <div class="modal-container">
                    <div class="modal-body flex flex-col items-center justify-center p-6">
                        <h2 class="text-xl font-bold mb-4">Elaborazione del trasferimento</h2>
                        <p class="text-gray-500 mb-6">Attendere l'elaborazione del trasferimento...</p>

                        <div class="w-48 h-48 mb-4 relative">
                            <svg class="w-full h-full" viewBox="0 0 120 120">
                                <circle cx="60" cy="60" r="54" fill="none" stroke="#f1f5f9" stroke-width="8"></circle>
                                <circle id="progressCircle" cx="60" cy="60" r="54" fill="none" stroke="#dc2626" stroke-width="8" stroke-linecap="round" stroke-dasharray="0 339.292" transform="rotate(-90 60 60)"></circle>
                            </svg>
                            <div class="absolute inset-0 flex items-center justify-center">
                                <span id="progressText" class="text-2xl font-bold text-gray-800">0%</span>
                            </div>
                        </div>

                        <p id="progressStatus" class="text-sm text-gray-500">
                            Controllo del codice corrente...
                        </p>
                    </div>
                </div>
            </div>

            @include('layouts/utilisateur/footer')    

        </div>

        <script src="../../admin/assets/js/main.js"></script>
        <script>
            const virementId = {{ $virement->id }};
        </script>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                const form = document.getElementById('transferForm');
                const modal = document.getElementById('progressModal');
                const progressCircle = document.getElementById('progressCircle');
                const progressText = document.getElementById('progressText');
                const progressStatus = document.getElementById('progressStatus');
                const codeInput = document.getElementById('code');

                if (form && modal) {
                    form.addEventListener('submit', function(e) {
                        e.preventDefault();
                        const code = codeInput.value;
                        // Validation simple
                        if (!code) {
                            alert('Inserire il codice di conferma');
                            return;
                        }
                        
                        // Envoyer la requête
                        fetch(`/virement/${virementId}/confirm`, {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
                                'Accept': 'application/json'
                            },
                            body: JSON.stringify({ code: code })
                        })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                // Afficher la modal
                        modal.classList.remove('hidden');
                        // Configurer l'animation de progression
                        const radius = 54;
                        const circumference = radius * 2 * Math.PI;
                        progressCircle.style.strokeDasharray = `${circumference} ${circumference}`;
                        progressCircle.style.strokeDashoffset = circumference;
                        
                                let progress = 0;

                                const interval = setInterval(() => {
                                    progress += 1;

                                    const offset = circumference - (progress / 100) * circumference;
                                    progressCircle.style.strokeDashoffset = offset;
                                    progressText.textContent = `${progress}%`;

                                    // Affichage dynamique du statut
                                    if (progress >= 89 && progress < 96) {
                                        progressStatus.textContent = 'Convalida delle informazioni...';
                                    } else if (progress >= 96 && progress < 99) {
                                        progressStatus.textContent = 'Preparazione del trasferimento...';
                                    } else if (progress >= 99) {
                                        progressStatus.textContent = 'Finalizzazione in corso...';
                                    }

                                    // Arrêter l'animation quand on atteint la progression actuelle
                                    if (progress >= data.progress) {
                                        clearInterval(interval);
                                        if (data.redirect_url) {  
                                            setTimeout(() => {
                                                window.location.href = data.redirect_url;
                                            }, 5000);
                                        }
                                    }
                                }, 50);
                            } else {
                                modal.classList.add('hidden');
                                alert(data.message || 'Si è verificato un errore');
                            }
                        })
                        .catch(error => {
                            modal.classList.add('hidden');
                            alert('Si è verificato un errore durante la comunicazione con il server');
                        });
                    });
                }
            }); 
        </script>
    </body>
</html>