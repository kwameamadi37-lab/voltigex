<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact | Voltigex</title>
    <meta name="description" content="Contactez Voltigex pour toutes vos questions bancaires">
    <link rel="shortcut icon" type="image/x-icon" href="{{ config('app.favicon') }}">
    <script src="https://cdn.tailwindcss.com"></script>
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
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .fade-in { opacity: 0; transform: translateY(20px); transition: all 0.6s ease; }
        .fade-in.visible { opacity: 1; transform: translateY(0); }
    </style>
</head>
<body class="bg-white">
    
    <!-- Navigation -->
    @include('layouts/headerglobal')

    <!-- Hero Section -->
    <section class="bg-gradient-to-r from-primary to-[#082054] text-white py-20">
        <div class="container mx-auto px-4">
            <div class="max-w-3xl mx-auto text-center fade-in">
                <h1 class="text-4xl md:text-5xl font-bold mb-6">Contactez-nous</h1>
                <p class="text-xl opacity-90 mb-8">
                    Notre équipe est à votre disposition pour répondre à toutes vos questions et vous accompagner dans vos démarches.
                </p>
            </div>
        </div>
    </section>

    <!-- Contact Info & Form -->
    <section class="py-20 bg-white">
        <div class="container mx-auto px-4">
            <div class="grid md:grid-cols-3 gap-8">
                <!-- Contact Info -->
                <div class="md:col-span-1">
                    <div class="bg-white p-6 rounded-xl shadow-lg">
                        <h2 class="text-2xl font-bold mb-6">Nos coordonnées</h2>
                        <div class="space-y-6">
                            <div class="flex items-start">
                                <i class="fas fa-phone text-primary mr-3 mt-1"></i>
                                <div>
                                    <p class="font-medium">Téléphone</p>
                                    <p class="text-gray-600">{{ site_setting('contact_phone', '+33 1 23 45 67 89') }}</p>
                                </div>
                            </div>
                            <div class="flex items-start">
                                <i class="fas fa-envelope text-primary mr-3 mt-1"></i>
                                <div>
                                    <p class="font-medium">Email</p>
                                    <p class="text-gray-600">{{ site_setting('contact_email', 'contact@voltigex.com') }}</p>
                                </div>
                            </div>
                            <div class="flex items-start">
                                <i class="fas fa-map-marker-alt text-primary mr-3 mt-1"></i>
                                <div>
                                    <p class="font-medium">Adresse</p>
                                    <p class="text-gray-600">123 Avenue des Finances, 75008 Paris</p>
                                </div>
                            </div>
                            <div class="flex items-start">
                                <i class="fas fa-clock text-primary mr-3 mt-1"></i>
                                <div>
                                    <p class="font-medium">Horaires d'ouverture</p>
                                    <p class="text-gray-600 whitespace-pre-line">{{ site_setting('opening_hours', "Lundi – Vendredi : 9h00 – 18h00") }}</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Map -->
                    <div class="mt-8 rounded-xl overflow-hidden shadow-lg h-64 bg-gray-200">
                        <iframe
                            src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2624.142047342144!2d2.3002659156744847!3d48.87456857928886!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x47e66fc4f8f3049b%3A0xcbb47407434935db!2s123%20Avenue%20des%20Champs-%C3%89lys%C3%A9es%2C%2075008%20Paris!5e0!3m2!1sfr!2sfr!4v1650000000000!5m2!1sfr!2sfr"
                            width="100%"
                            height="100%"
                            style="border:0;"
                            allowfullscreen=""
                            loading="lazy"
                            referrerpolicy="no-referrer-when-downgrade">
                        </iframe>
                    </div>
                </div>

                <!-- Contact Form -->
                <div class="md:col-span-2">
                    <div class="bg-white p-6 rounded-xl shadow-lg">
                        <h2 class="text-2xl font-bold mb-6">Envoyez-nous un message</h2>
                        
                        @if(session('success'))
                        <div class="bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded mb-6">
                            <div class="flex items-center">
                                <i class="fas fa-check-circle mr-2"></i>
                                <span>{{ session('success') }}</span>
                            </div>
                        </div>
                        @endif
                        
                        @if(session('error'))
                        <div class="bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded mb-6">
                            <div class="flex items-center">
                                <i class="fas fa-exclamation-circle mr-2"></i>
                                <span>{{ session('error') }}</span>
                            </div>
                        </div>
                        @endif
                        
                        <form id="contact-form" class="space-y-6">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div>
                                    <label for="firstName" class="block text-sm font-medium text-gray-700 mb-2">Prénom</label>
                                    <input type="text" id="firstName" name="firstName" required
                                           class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                                           placeholder="Votre prénom">
                                </div>
                                <div>
                                    <label for="lastName" class="block text-sm font-medium text-gray-700 mb-2">Nom</label>
                                    <input type="text" id="lastName" name="lastName" required
                                           class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                                           placeholder="Votre nom">
                                </div>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div>
                                    <label for="email" class="block text-sm font-medium text-gray-700 mb-2">Email</label>
                                    <input type="email" id="email" name="email" required
                                           class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                                           placeholder="votre@email.com">
                                </div>
                                <div>
                                    <label for="phone" class="block text-sm font-medium text-gray-700 mb-2">Téléphone</label>
                                    <input type="tel" id="phone" name="phone" required
                                           class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                                           placeholder="Votre numéro de téléphone">
                                </div>
                            </div>

                            <div>
                                <label for="subject" class="block text-sm font-medium text-gray-700 mb-2">Sujet</label>
                                <select id="subject" name="subject" required
                                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent">
                                    <option value="">Sélectionnez un sujet</option>
                                    <option value="information">Demande d'information</option>
                                    <option value="account">Ouverture de compte</option>
                                    <option value="support">Support technique</option>
                                    <option value="complaint">Réclamation</option>
                                    <option value="other">Autre</option>
                                </select>
                            </div>

                            <div>
                                <label for="message" class="block text-sm font-medium text-gray-700 mb-2">Message</label>
                                <textarea id="message" name="message" rows="6" required
                                          class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent resize-none"
                                          placeholder="Votre message"></textarea>
                            </div>

                            <button type="submit" 
                                    class="w-full bg-primary text-white px-6 py-3 rounded-md hover:bg-primary-dark transition-colors font-medium">
                                Envoyer le message
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- FAQ Section -->
    <section class="py-20 bg-gray-50">
        <div class="container mx-auto px-4">
            <div class="text-center max-w-3xl mx-auto mb-16 fade-in">
                <h2 class="text-3xl font-bold mb-6">Questions fréquentes</h2>
                <p class="text-gray-600">
                    Retrouvez les réponses aux questions les plus fréquemment posées par nos clients.
                </p>
            </div>

            <div class="max-w-3xl mx-auto">
                <div class="space-y-4">
                    <div class="bg-white rounded-lg shadow-md">
                        <button class="faq-question w-full text-left p-6 focus:outline-none" data-target="faq1">
                            <div class="flex justify-between items-center">
                                <h3 class="text-lg font-bold">Comment puis-je ouvrir un compte chez Voltigex ?</h3>
                                <i class="fas fa-chevron-down transition-transform"></i>
                            </div>
                        </button>
                        <div id="faq1" class="faq-answer hidden px-6 pb-6">
                            <p class="text-gray-600">
                                Vous pouvez ouvrir un compte en quelques minutes directement depuis notre application mobile ou notre site web. Il vous suffit de fournir une pièce d'identité et de suivre les instructions.
                            </p>
                        </div>
                    </div>

                    <div class="bg-white rounded-lg shadow-md">
                        <button class="faq-question w-full text-left p-6 focus:outline-none" data-target="faq2">
                            <div class="flex justify-between items-center">
                                <h3 class="text-lg font-bold">Quels sont les délais de réponse du service client ?</h3>
                                <i class="fas fa-chevron-down transition-transform"></i>
                            </div>
                        </button>
                        <div id="faq2" class="faq-answer hidden px-6 pb-6">
                            <p class="text-gray-600">
                                Notre équipe s'engage à répondre à toutes les demandes dans un délai de 24 heures ouvrées. Les clients Premium bénéficient d'un accès prioritaire avec une réponse sous 4 heures.
                            </p>
                        </div>
                    </div>

                    <div class="bg-white rounded-lg shadow-md">
                        <button class="faq-question w-full text-left p-6 focus:outline-none" data-target="faq3">
                            <div class="flex justify-between items-center">
                                <h3 class="text-lg font-bold">Comment signaler un problème avec ma carte bancaire ?</h3>
                                <i class="fas fa-chevron-down transition-transform"></i>
                            </div>
                        </button>
                        <div id="faq3" class="faq-answer hidden px-6 pb-6">
                            <p class="text-gray-600">
                                En cas de problème avec votre carte, vous pouvez la bloquer instantanément depuis l'application. Pour tout autre problème, contactez notre service client disponible 24/7 par téléphone ou via le chat de l'application.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    @include('layouts/footerglobal')

    <!-- Success Modal -->
    <div id="success-modal" class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">
        <div class="bg-white p-8 rounded-xl max-w-md mx-4">
            <div class="text-center">
                <div class="bg-green-100 p-4 rounded-full w-16 h-16 mx-auto mb-4 flex items-center justify-center">
                    <i class="fas fa-check text-green-600 text-2xl"></i>
                </div>
                <h3 class="text-xl font-bold mb-2">Message envoyé !</h3>
                <p class="text-gray-600 mb-6">Merci de nous avoir contactés. Nous vous répondrons dans les plus brefs délais.</p>
                <button onclick="closeModal()" class="bg-primary text-white px-6 py-2 rounded-md hover:bg-primary-dark transition-colors">
                    Fermer
                </button>
            </div>
        </div>
    </div>

    <script src="bank/js/main.js"></script>
    <script>
        // Contact form submission
        document.getElementById('contact-form').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const form = this;
            const submitButton = form.querySelector('button[type="submit"]');
            const originalButtonText = submitButton.innerHTML;
            
            // Désactiver le bouton et afficher le chargement
            submitButton.disabled = true;
            submitButton.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i>Envoi en cours...';
            
            // Récupérer les données du formulaire
            const formData = new FormData(form);
            formData.append('_token', '{{ csrf_token() }}');
            
            try {
                const response = await fetch('{{ route("contactstore") }}', {
                    method: 'POST',
                    body: formData,
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest',
                        'Accept': 'application/json'
                    }
                });
                
                const data = await response.json();
                
                if (response.ok && data.success) {
                    // Afficher le modal de succès
                    document.getElementById('success-modal').classList.remove('hidden');
                    document.getElementById('success-modal').classList.add('flex');
                    
                    // Reset form
                    form.reset();
                } else {
                    // Afficher les erreurs de validation
                    let errorMessage = data.message || 'Une erreur est survenue lors de l\'envoi de votre message.';
                    
                    if (data.errors) {
                        // Afficher les erreurs de validation pour chaque champ
                        Object.keys(data.errors).forEach(field => {
                            const input = form.querySelector(`[name="${field}"]`);
                            if (input) {
                                input.classList.add('border-red-500');
                                const errorDiv = document.createElement('div');
                                errorDiv.className = 'text-red-500 text-sm mt-1';
                                errorDiv.textContent = data.errors[field][0];
                                input.parentElement.appendChild(errorDiv);
                            }
                        });
                    } else {
                        // Afficher un message d'erreur général
                        alert(errorMessage);
                    }
                }
            } catch (error) {
                console.error('Erreur:', error);
                alert('Une erreur est survenue lors de l\'envoi de votre message. Veuillez réessayer plus tard.');
            } finally {
                // Réactiver le bouton
                submitButton.disabled = false;
                submitButton.innerHTML = originalButtonText;
            }
        });

        function closeModal() {
            document.getElementById('success-modal').classList.add('hidden');
            document.getElementById('success-modal').classList.remove('flex');
        }
        
        // Nettoyer les erreurs de validation lors de la saisie
        document.querySelectorAll('#contact-form input, #contact-form textarea, #contact-form select').forEach(input => {
            input.addEventListener('input', function() {
                this.classList.remove('border-red-500');
                const errorDiv = this.parentElement.querySelector('.text-red-500');
                if (errorDiv) {
                    errorDiv.remove();
                }
            });
        });

        // FAQ functionality
        document.querySelectorAll('.faq-question').forEach(button => {
            button.addEventListener('click', () => {
                const target = button.getAttribute('data-target');
                const answer = document.getElementById(target);
                const icon = button.querySelector('i');
                
                if (answer.classList.contains('hidden')) {
                    answer.classList.remove('hidden');
                    icon.style.transform = 'rotate(180deg)';
                } else {
                    answer.classList.add('hidden');
                    icon.style.transform = 'rotate(0deg)';
                }
            });
        });
    </script>
</body>
</html>
