<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FinexB - Virements</title>
    <link rel="stylesheet" href="myadmin/assets/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/lucide@latest/dist/umd/lucide.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body>
    <div class="app-container">
        @include('layouts.utilisateur.header')

        <!-- Main Content -->
        <main class="main-content">
            <div class="hero-section primary-bg">
                <h1 class="hero-title">Page de virement</h1>
            </div>
            <div class="content-section">
                <div class="transfer-container">
                    <form id="transfer-form" class="transfer-form">
                        <div class="form-section">
                            <h2 class="section-title">Effectuer votre virement</h2>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div class="form-group">
                                    <label for="beneficiary">Nom du bénéficiaire</label>
                                    <input type="text" id="beneficiary" placeholder="Nom et prénom ou raison sociale" required>
                                </div>
                                <div class="form-group">
                                    <label for="beneficiary">Nom de la banque</label>
                                    <input type="text" id="beneficiary" placeholder="Nom de la banque" required>
                                </div>
                                <div class="form-group">
                                    <label for="iban">IBAN</label>
                                    <input type="text" id="iban" placeholder="FR76 XXXX XXXX XXXX XXXX XXXX XXX" required>
                                </div>
                                <div class="form-group">
                                    <label for="bic">BIC / SWIFT</label>
                                    <input type="text" id="bic" placeholder="BNPAFRPPXXX" required>
                                </div>
                                <div class="form-group">
                                    <label for="amount">Montant</label>
                                    <div class="amount-input">
                                        <input type="number" id="amount" placeholder="0,00" required>
                                        <span class="currency-symbol">€</span>
                                    </div>
                                </div>                            
                                <div class="form-group">
                                    <label for="date">Date d'exécution</label>
                                    <input type="date" id="date" required>
                                </div>                                
                            </div>
                            <div class="form-group">
                                <label for="reason">Motif du virement</label>
                                <textarea type="text" id="reason" placeholder="Ex: Paiement facture, Remboursement, etc." rows="3" required></textarea>
                            </div>
                        </div>
                        <button type="submit" class="submit-btn">Valider le virement</button>
                    </form>

                    <div class="info-sidebar desktop-only">
                        <div class="info-card">
                            <h3 class="info-title">Informations utiles</h3><br>
                            <div class="info-item">
                                <i data-lucide="arrow-right"></i>
                                <p>Les virements sont généralement traités dans un délai de 24 à 48 heures ouvrables.</p>
                            </div>
                            <div class="info-item">
                                <i data-lucide="calendar"></i>
                                <p>Pour les virements programmés, assurez-vous d'avoir les fonds disponibles à la date prévue.</p>
                            </div>
                            <div class="info-item">
                                <i data-lucide="credit-card"></i>
                                <p>Vérifiez toujours l'IBAN du bénéficiaire avant de valider votre virement.</p>
                            </div>
                            <div class="info-item">
                                <i data-lucide="file-text"></i>
                                <p>Un reçu de virement sera disponible dans votre mail.</p>
                            </div>
                            <div class="help-box">
                                <p class="help-title">Besoin d'aide ?</p>
                                <p class="help-text">Notre service client est disponible du lundi au vendredi de 9h à 18h.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <!-- Mobile Navigation -->
        @include('layouts.utilisateur.footer')


        <!-- Processing Modal -->
        <div id="processing-modal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Traitement du virement</h3>
                    <button class="close-modal" id="close-processing-modal">
                        <i data-lucide="x"></i>
                    </button>
                </div>
                <div class="processing-content">
                    <div class="progress-container">
                        <svg class="progress-circle" viewBox="0 0 100 100">
                            <circle class="progress-background" cx="50" cy="50" r="40" fill="transparent"></circle>
                            <circle class="progress-bar" cx="50" cy="50" r="40" fill="transparent" id="progress-circle"></circle>
                            <text x="50" y="50" text-anchor="middle" alignment-baseline="middle" id="progress-text">0%</text>
                        </svg>
                    </div>
                    <p>Traitement de votre virement en cours...</p>
                    <p class="processing-note">Veuillez patienter, ne fermez pas cette fenêtre.</p>
                </div>
            </div>
        </div>
    </div>

    <script src="myadmin/assets/js/main.js"></script>
    <script src="myadmin/assets/js/virements.js"></script>
</body>
</html>


            {{-- <form id="transferForm" class="space-y-6">                              
                <div class="grid grid-cols-1 md:grid-cols-2 gap-3">                                    
                    <div class="space-y-2">
                        <label for="titulaire" class="form-label">Titolare del conto</label>
                        <input id="titulaire" name="titulaire" type="text" class="form-input" placeholder="Titolare del conto">
                    </div>
                    
                    <div class="space-y-2">
                        <label for="nombanque" class="form-label">Banca ricevente</label>
                        <input name="nombanque" id="nombanque" type="text" class="form-input" placeholder="Nome della banca">
                    </div>
                    
                    <div class="space-y-2">
                        <label for="iban" class="form-label">Numero di conto o IBAN</label>
                        <input name="iban" id="iban" type="text" class="form-input" placeholder="IT76 XXXX XXXX XXXX XXXX XXXX XXX">
                    </div>                                    
                    <div class="space-y-2">
                        <label for="montant" class="form-label">Importo (€)</label>
                        <input name="montant" id="montant" type="number" class="form-input" placeholder="2000">
                    </div>                                    
                </div>  
                <div class="flex justify-between items-center">
                    <h2>Tipo di trasferimento</h2>
                    <div class="flex gap-4">
                        <label class="inline-flex items-center">
                            <input type="radio" name="transfer_type" value="national" checked 
                                   class="form-radio" id="nationalTransfer">
                            <span class="ml-2">Nazionale</span>
                        </label>
                        <label class="inline-flex items-center">
                            <input type="radio" name="transfer_type" value="international" 
                                   class="form-radio" id="internationalTransfer">
                            <span class="ml-2">Internazionale</span>
                        </label>
                    </div>
                </div>
                <div id="swiftFieldContainer" class="space-y-1 hidden">
                    <label for="newSwift" class="form-label">Inserire il codice SWIFT/BIC (se disponibile)</label>
                    <input id="newSwift" type="text" class="form-input w-full" 
                           placeholder="ABCDEFGHXXX">
                </div>
                <div class="space-y-2">
                    <label for="message" class="form-label">Motivo del trasferimento (facoltativo)</label>
                    <textarea name="message" id="message" class="form-textarea" placeholder="Motif du virement" rows="3"></textarea>
                </div>
                
                <button type="submit" class="btn btn-primary w-full">Effettuare il trasferimento</button>
            </form>

            <!-- Progress Modal -->
            <div id="progressModal" class="modal hidden">
                <div class="modal-overlay"></div>
                <div class="modal-container">
                    <div class="modal-body flex flex-col items-center justify-center p-6">
                        <h2 class="text-xl font-bold mb-4">Elaborazione del trasferimento</h2>
                        <p class="text-gray-500 mb-6">Attendere prego...</p>

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
                            Controllo delle informazioni correnti...
                        </p>
                    </div>
                </div>
            </div>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                const nationalRadio = document.getElementById('nationalTransfer');
                const internationalRadio = document.getElementById('internationalTransfer');
                const swiftFieldContainer = document.getElementById('swiftFieldContainer');
            
                // Gestion de l'affichage du champ SWIFT
                function toggleSwiftField() {
                    swiftFieldContainer.classList.toggle('hidden', !internationalRadio.checked);
                    
                    // Option: rendre le champ obligatoire si international
                    document.getElementById('newSwift').required = internationalRadio.checked;
                }
            
                // Écouteurs d'événements
                nationalRadio.addEventListener('change', toggleSwiftField);
                internationalRadio.addEventListener('change', toggleSwiftField);
                
                // Initialisation
                toggleSwiftField();
            });
        </script>
        <script>
            document.addEventListener("DOMContentLoaded", () => {
            const transferForm = document.getElementById("transferForm")
            const progressModal = document.getElementById("progressModal")
            const progressCircle = document.getElementById("progressCircle")
            const progressText = document.getElementById("progressText")
            const progressStatus = document.getElementById("progressStatus")

            if (transferForm && progressModal) {
                transferForm.addEventListener("submit", async (e) => {
                e.preventDefault()

                const requiredFields = {
                    titulaire: "Titolare del conto",
                    nombanque: "Nome della banca",
                    iban: "IBAN",
                    montant: "Importo"
                }

                let isValid = true
                for (const [fieldId, fieldName] of Object.entries(requiredFields)) {
                    const field = document.getElementById(fieldId)
                    if (!field.value.trim()) {
                    alert(`${fieldName} è obbligatorio`)
                    isValid = false
                    break
                    }
                }

                if (!isValid) return

                const formData = new FormData(transferForm)

                try {
                    const response = await fetch("{{ route('virementstore') }}", {
                    method: "POST",
                    body: formData,
                    headers: {
                        "X-Requested-With": "XMLHttpRequest",
                        "X-CSRF-TOKEN": document.querySelector("meta[name='csrf-token']").content
                    }
                    })

                    const data = await response.json()

                    if (!response.ok) throw new Error(data.message || "Errore di trasferimento")

                    // Affiche le modal et démarre l'animation seulement si tout est OK
                    progressModal.classList.remove("hidden")

                    const radius = 54
                    const circumference = radius * 2 * Math.PI
                    progressCircle.style.strokeDasharray = `${circumference} ${circumference}`
                    progressCircle.style.strokeDashoffset = circumference

                    let progress = 0
                    const interval = setInterval(() => {
                    progress += 1
                    const offset = circumference - (progress / 100) * circumference
                    progressCircle.style.strokeDashoffset = offset
                    progressText.textContent = `${progress}%`

                    if (progress >= 60) {
                        clearInterval(interval)
                        progressStatus.textContent = "Trasferimento fallito! Reindirizzamento in corso..."

                        setTimeout(() => {
                        window.location.href = data.redirect_url;
                        }, 5000)
                    }
                    }, 50)

                } catch (error) {
                    console.error("Erreur:", error)
                    progressModal.classList.add("hidden")
                    alert(error.message || "Si è verificato un errore")
                }
                })
            }
            })
        </script> --}}
        
   
          