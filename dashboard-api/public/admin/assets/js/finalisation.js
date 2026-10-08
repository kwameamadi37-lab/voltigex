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
                alert('Veuillez entrer le code de confirmation');
                return;
            }

            // Afficher le modal
            modal.classList.remove('hidden');

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
                    // Mettre à jour la progression
                    const circumference = 2 * Math.PI * 54;
                    const progress = (data.progress / 100) * circumference;
                    progressCircle.style.strokeDasharray = `${progress} ${circumference}`;
                    progressText.textContent = `${data.progress}%`;

                    // Mettre à jour le statut en fonction de la progression
                    if (data.progress >= 89) {
                        progressStatus.textContent = 'Validation des informations...';
                    }
                    if (data.progress >= 96) {
                        progressStatus.textContent = 'Préparation du virement...';
                    }
                    if (data.progress >= 99) {
                        progressStatus.textContent = 'Finalisation en cours...';
                    }

                    // Réinitialiser le formulaire pour la prochaine étape
                    if (data.progress < 99) {
                        codeInput.value = '';
                        progressStatus.textContent = 'Veuillez contacter l\'administrateur pour obtenir le code de confirmation';
                    }

                    if (data.redirect) {
                        setTimeout(() => {
                            window.location.href = data.redirect;
                        }, 1000);
                    }
                } else {
                    modal.classList.add('hidden');
                    alert(data.message || 'Une erreur est survenue');
                }
            })
            .catch(error => {
                modal.classList.add('hidden');
                alert('Une erreur est survenue');
            });
        });
    }
}); 