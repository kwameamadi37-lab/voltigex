<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Voltigex | Politique de Sécurité</title>
    <meta name="description" content="Politique de sécurité d'Voltigex - Mesures de protection de vos données et transactions bancaires">
    <!-- Tailwind CSS via CDN -->
    <script src="../assets/js/tailwind.js"></script>
    <script src="../assets/js/menu.js"></script>
    <link rel="stylesheet" href="../assets/css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" integrity="sha512-Evv84Mr4kqVGRNSgIGL/F/aIDqQb7xQ2vcrdIwxfjThSH8CSR7PBEakCr51Ck+w+/U6swU2Im1vVX0SVk9ABhg==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <!-- Top Bar -->
    @include('layouts.headerglobal')
    
    <!-- Hero Section -->
    <section class="bg-gradient-to-r from-primary to-[#082054] text-white py-20">
        <div class="container mx-auto px-4">
            <div class="max-w-3xl mx-auto text-center fade-in">
                <h1 class="text-4xl md:text-5xl font-bold mb-6">Politique de Sécurité</h1>
                <p class="text-xl opacity-90 mb-8">
                    La sécurité de vos données et transactions est notre priorité absolue.
                </p>
            </div>
        </div>
    </section>

    <!-- Content -->
    <div class="container mx-auto px-4 py-12">
        <div class="max-w-4xl mx-auto">
            <div class="bg-white rounded-lg shadow-lg p-8">
                <div class="mb-8">
                    <h1 class="text-3xl font-bold text-gray-900 mb-4">Politique de Sécurité</h1>
                    <p class="text-gray-600">Dernière mise à jour : 1er janvier 2024</p>
                </div>

                <div class="prose max-w-none">
                    <h2 class="text-2xl font-bold text-gray-900 mb-4">1. Introduction</h2>
                    <p class="mb-6 text-gray-700 leading-relaxed">
                        La sécurité est la priorité absolue d'Voltigex. Cette politique décrit les mesures que nous mettons en place pour protéger vos données personnelles, vos informations bancaires et toutes vos transactions. Nous nous engageons à maintenir les plus hauts standards de sécurité conformément aux réglementations en vigueur.
                    </p>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">2. Sécurité des systèmes</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Nous utilisons des technologies de pointe pour protéger nos systèmes et infrastructures :
                    </p>
                    <ul class="list-disc list-inside mb-6 text-gray-700 space-y-2">
                        <li><strong>Chiffrement SSL/TLS :</strong> Toutes les communications entre votre navigateur et nos serveurs sont chiffrées avec des protocoles SSL/TLS de dernière génération</li>
                        <li><strong>Chiffrement des données :</strong> Vos données sensibles sont stockées de manière chiffrée avec des algorithmes AES-256</li>
                        <li><strong>Protection contre les attaques DDoS :</strong> Nos systèmes sont protégés contre les attaques par déni de service distribué</li>
                        <li><strong>Détection d'intrusion :</strong> Systèmes de surveillance et de détection des tentatives d'intrusion en temps réel</li>
                        <li><strong>Monitoring 24/7 :</strong> Surveillance continue de nos systèmes par des équipes dédiées</li>
                        <li><strong>Sauvegardes régulières :</strong> Sauvegardes automatiques quotidiennes avec stockage sécurisé et redondant</li>
                        <li><strong>Tests de pénétration :</strong> Audits de sécurité réguliers effectués par des experts externes</li>
                    </ul>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">3. Authentification et accès</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Pour accéder à votre compte, nous utilisons plusieurs mécanismes de sécurité :
                    </p>
                    <ul class="list-disc list-inside mb-4 text-gray-700 space-y-2">
                        <li><strong>Authentification à deux facteurs (2FA) :</strong> Disponible et fortement recommandée pour renforcer la sécurité de votre compte</li>
                        <li><strong>Vérification biométrique :</strong> Support de l'authentification par empreinte digitale et reconnaissance faciale sur les appareils compatibles</li>
                        <li><strong>Gestion sécurisée des mots de passe :</strong> Mots de passe stockés sous forme de hash avec algorithme bcrypt</li>
                        <li><strong>Détection de connexions suspectes :</strong> Alertes automatiques en cas de connexion depuis un nouvel appareil ou une nouvelle localisation</li>
                        <li><strong>Verrouillage automatique :</strong> Verrouillage du compte après plusieurs tentatives de connexion échouées</li>
                        <li><strong>Expiration de session :</strong> Déconnexion automatique après une période d'inactivité</li>
                    </ul>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">4. Protection des transactions</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Toutes vos transactions bancaires sont protégées par :
                    </p>
                    <ul class="list-disc list-inside mb-6 text-gray-700 space-y-2">
                        <li><strong>Vérification en temps réel :</strong> Analyse automatique de chaque transaction pour détecter les activités suspectes</li>
                        <li><strong>Alertes de sécurité :</strong> Notifications immédiates par email et SMS pour chaque transaction importante</li>
                        <li><strong>Limites de transaction :</strong> Possibilité de définir des limites quotidiennes et mensuelles pour vos opérations</li>
                        <li><strong>Protection anti-fraude :</strong> Système de détection de fraude utilisant l'intelligence artificielle et l'apprentissage automatique</li>
                        <li><strong>Validation multi-étapes :</strong> Confirmation requise pour les transactions sensibles ou importantes</li>
                        <li><strong>Historique complet :</strong> Traçabilité de toutes vos transactions avec horodatage et détails complets</li>
                    </ul>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">5. Sécurité physique</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Nos infrastructures physiques sont protégées par :
                    </p>
                    <ul class="list-disc list-inside mb-6 text-gray-700 space-y-2">
                        <li><strong>Centres de données sécurisés :</strong> Installation dans des centres de données certifiés (ISO 27001, SOC 2)</li>
                        <li><strong>Contrôles d'accès stricts :</strong> Accès restreint avec authentification biométrique et badges sécurisés</li>
                        <li><strong>Vidéosurveillance :</strong> Surveillance 24/7 de toutes les zones sensibles</li>
                        <li><strong>Protection contre les catastrophes :</strong> Redondance géographique et plans de continuité d'activité</li>
                        <li><strong>Contrôle environnemental :</strong> Systèmes de climatisation, protection incendie et alimentation électrique de secours</li>
                    </ul>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">6. Formation et sensibilisation</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Notre personnel est formé et sensibilisé à la sécurité :
                    </p>
                    <ul class="list-disc list-inside mb-6 text-gray-700 space-y-2">
                        <li><strong>Formation régulière :</strong> Sessions de formation obligatoires sur les bonnes pratiques de sécurité</li>
                        <li><strong>Tests de sécurité :</strong> Simulations d'attaques et exercices de gestion d'incidents</li>
                        <li><strong>Procédures d'urgence :</strong> Plans d'action documentés pour répondre aux incidents de sécurité</li>
                        <li><strong>Culture de sécurité :</strong> Promotion d'une culture où la sécurité est l'affaire de tous</li>
                        <li><strong>Vérifications d'antécédents :</strong> Contrôles de sécurité pour tous les employés ayant accès aux données sensibles</li>
                    </ul>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">7. Votre rôle dans la sécurité</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Pour renforcer la sécurité de votre compte, nous vous recommandons de :
                    </p>
                    <ul class="list-disc list-inside mb-4 text-gray-700 space-y-2">
                        <li><strong>Utiliser des mots de passe complexes :</strong> Combinaison de lettres majuscules, minuscules, chiffres et caractères spéciaux (minimum 12 caractères)</li>
                        <li><strong>Activer l'authentification à deux facteurs :</strong> Protection supplémentaire pour votre compte</li>
                        <li><strong>Vérifier régulièrement vos transactions :</strong> Consultez votre historique de transactions et signalez toute activité suspecte</li>
                        <li><strong>Ne jamais partager vos identifiants :</strong> Voltigex ne vous demandera jamais votre mot de passe par email ou téléphone</li>
                        <li><strong>Maintenir vos systèmes à jour :</strong> Installez les mises à jour de sécurité de votre système d'exploitation et de vos applications</li>
                        <li><strong>Utiliser des réseaux sécurisés :</strong> Évitez d'accéder à votre compte depuis des réseaux Wi-Fi publics non sécurisés</li>
                        <li><strong>Déconnecter votre session :</strong> Toujours vous déconnecter après avoir utilisé votre compte, surtout sur des appareils partagés</li>
                    </ul>

                    <div class="bg-yellow-50 border-l-4 border-yellow-400 p-6 mb-6">
                        <div class="flex">
                            <div class="flex-shrink-0">
                                <i class="fas fa-exclamation-triangle text-yellow-400 text-xl"></i>
                            </div>
                            <div class="ml-3">
                                <p class="text-sm text-yellow-700">
                                    <strong>Attention :</strong> Voltigex ne vous demandera jamais vos identifiants de connexion, votre code PIN ou vos codes de confirmation par email, SMS ou téléphone. Si vous recevez une telle demande, il s'agit probablement d'une tentative de phishing. Ne répondez pas et contactez immédiatement notre service client.
                                </p>
                            </div>
                        </div>
                    </div>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">8. Gestion des incidents de sécurité</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        En cas d'incident de sécurité, nous :
                    </p>
                    <ul class="list-disc list-inside mb-6 text-gray-700 space-y-2">
                        <li><strong>Investiguons immédiatement :</strong> Déclenchement automatique de notre équipe de réponse aux incidents</li>
                        <li><strong>Vous informons sans délai :</strong> Notification dans les plus brefs délais si vos données sont concernées</li>
                        <li><strong>Prenons les mesures nécessaires :</strong> Actions correctives immédiates pour limiter l'impact</li>
                        <li><strong>Appliquons les leçons apprises :</strong> Amélioration continue de nos systèmes basée sur les incidents</li>
                        <li><strong>Respectons les obligations légales :</strong> Déclaration aux autorités compétentes si nécessaire (CNIL, ACPR)</li>
                    </ul>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">9. Conformité réglementaire</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Voltigex est conforme aux réglementations suivantes :
                    </p>
                    <ul class="list-disc list-inside mb-6 text-gray-700 space-y-2">
                        <li><strong>RGPD :</strong> Règlement Général sur la Protection des Données (UE 2016/679)</li>
                        <li><strong>PCI DSS :</strong> Standards de sécurité pour les données de cartes de paiement</li>
                        <li><strong>ISO 27001 :</strong> Certification internationale pour la gestion de la sécurité de l'information</li>
                        <li><strong>Réglementation bancaire :</strong> Conformité aux exigences de l'ACPR (Autorité de Contrôle Prudentiel et de Résolution)</li>
                        <li><strong>Loi Informatique et Libertés :</strong> Conformité à la loi française sur la protection des données</li>
                    </ul>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">10. Contact et signalement</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Pour signaler un problème de sécurité, une activité suspecte ou pour toute question concernant la sécurité de votre compte :
                    </p>
                    <ul class="list-none mb-6 text-gray-700 space-y-2">
                        <li><strong>Email de sécurité :</strong> <a href="mailto:securite@Voltigex.com" class="text-primary hover:underline">securite@Voltigex.com</a></li>
                        <li><strong>Service client :</strong> +33 1 23 45 67 89</li>
                        <li><strong>Email général :</strong> <a href="mailto:contact@Voltigex.com" class="text-primary hover:underline">contact@Voltigex.com</a></li>
                        <li><strong>Adresse postale :</strong> Voltigex - Service Sécurité, 123 Avenue des Champs-Élysées, 75008 Paris, France</li>
                    </ul>

                    <div class="bg-blue-50 border-l-4 border-blue-400 p-6 mt-8">
                        <div class="flex">
                            <div class="flex-shrink-0">
                                <i class="fas fa-shield-alt text-blue-400 text-xl"></i>
                            </div>
                            <div class="ml-3">
                                <p class="text-sm text-blue-700">
                                    <strong>Engagement :</strong> La sécurité est un processus continu. Nous nous engageons à améliorer constamment nos mesures de sécurité et à vous tenir informés des évolutions importantes. Cette politique peut être mise à jour régulièrement pour refléter les meilleures pratiques et les nouvelles menaces.
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer -->
    @include('layouts.footerglobal')

    <script src="../assets/js/main.js"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#0a296b',
                        'primary-dark': '#1e3a8a',
                        secondary: '#ffc800',
                    },
                    fontFamily: {
                        'inter': ['Inter', 'sans-serif'],
                    }
                }
            }
        }
    </script>
</body>
</html>