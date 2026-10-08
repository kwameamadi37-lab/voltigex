<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Voltigex | Mentions Légales</title>
    <meta name="description" content="Mentions légales du site Voltigex - Informations sur l'éditeur, l'hébergeur et les conditions d'utilisation">
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
                    <h1 class="text-4xl md:text-5xl font-bold mb-6">Mentions Légales</h1>
                <p class="text-xl opacity-90 mb-8">
                    Consultez les mentions légales de nos services.
                </p>
            </div>
        </div>
    </section>
    <!-- Content -->
    <div class="container mx-auto px-4 py-12">
        <div class="max-w-4xl mx-auto">
            <div class="bg-white rounded-lg shadow-lg p-8">
                <div class="mb-8">
                    <h1 class="text-3xl font-bold text-gray-900 mb-4">Mentions Légales</h1>
                    <p class="text-gray-600">Dernière mise à jour : 1er janvier 2024</p>
                </div>

                <div class="prose max-w-none">
                    <h2 class="text-2xl font-bold text-gray-900 mb-4">1. Informations légales</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Conformément aux dispositions de la loi n° 2004-575 du 21 juin 2004 pour la confiance en l'économie numérique, il est précisé aux utilisateurs du site Voltigex l'identité des différents intervenants dans le cadre de sa réalisation et de son suivi.
                    </p>
                    
                    <h3 class="text-xl font-semibold text-gray-900 mb-3">Éditeur du site</h3>
                    <ul class="list-none mb-4 text-gray-700 space-y-2">
                        <li><strong>Raison sociale :</strong> Voltigex</li>
                        <li><strong>Forme juridique :</strong> Société par Actions Simplifiée (SAS)</li>
                        <li><strong>Capital social :</strong> 10 000 000 €</li>
                        <li><strong>Siège social :</strong> 123 Avenue des Champs-Élysées, 75008 Paris, France</li>
                        <li><strong>SIRET :</strong> 123 456 789 00012</li>
                        <li><strong>RCS :</strong> Paris B 123 456 789</li>
                        <li><strong>Téléphone :</strong> +33 1 23 45 67 89</li>
                        <li><strong>Email :</strong> contact@Voltigex.com</li>
                        <li><strong>Directeur de publication :</strong> [Nom du directeur]</li>
                    </ul>

                    <h3 class="text-xl font-semibold text-gray-900 mb-3">Hébergeur du site</h3>
                    <ul class="list-none mb-6 text-gray-700 space-y-2">
                        <li><strong>Nom :</strong> [Nom de l'hébergeur]</li>
                        <li><strong>Adresse :</strong> [Adresse de l'hébergeur]</li>
                        <li><strong>Téléphone :</strong> [Téléphone de l'hébergeur]</li>
                        <li><strong>Site web :</strong> [URL de l'hébergeur]</li>
                    </ul>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">2. Propriété intellectuelle</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        L'ensemble de ce site relève de la législation française et internationale sur le droit d'auteur et la propriété intellectuelle. Tous les droits de reproduction sont réservés, y compris pour les documents téléchargeables et les représentations iconographiques et photographiques.
                    </p>
                    <p class="mb-6 text-gray-700 leading-relaxed">
                        La reproduction de tout ou partie de ce site sur un support électronique quel qu'il soit est formellement interdite sauf autorisation expresse du directeur de la publication. La reproduction des textes de ce site sur un support papier est autorisée, notamment dans un cadre pédagogique, sous réserve du respect des trois conditions suivantes :
                    </p>
                    <ul class="list-disc list-inside mb-6 text-gray-700 space-y-2">
                        <li>Gratuité de la diffusion</li>
                        <li>Respect de l'intégrité des documents reproduits (pas de modification ni altération)</li>
                        <li>Citation claire et lisible de la source sous la forme : "Document issu du site Voltigex.com - Droits de reproduction réservés et limités"</li>
                    </ul>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">3. Protection des données personnelles</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Conformément à la loi "Informatique et Libertés" du 6 janvier 1978 modifiée et au Règlement Général sur la Protection des Données (RGPD), vous disposez d'un droit d'accès, de rectification, de suppression et d'opposition aux données personnelles vous concernant.
                    </p>
                    <p class="mb-6 text-gray-700 leading-relaxed">
                        Pour exercer ce droit, vous pouvez nous contacter à l'adresse suivante : <a href="mailto:contact@Voltigex.com" class="text-primary hover:underline">contact@Voltigex.com</a> ou consulter notre <a href="{{ route('confidentialite') }}" class="text-primary hover:underline">Politique de Confidentialité</a>.
                    </p>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">4. Cookies</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Le site Voltigex.com utilise des cookies pour améliorer l'expérience utilisateur et analyser le trafic du site. En continuant à naviguer sur ce site, vous acceptez l'utilisation de cookies conformément à notre politique de cookies.
                    </p>
                    <p class="mb-6 text-gray-700 leading-relaxed">
                        Vous pouvez configurer votre navigateur pour refuser les cookies, mais certaines fonctionnalités du site peuvent ne plus être accessibles.
                    </p>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">5. Responsabilité</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Les informations contenues sur ce site sont aussi précises que possible et le site est périodiquement remis à jour, mais peut toutefois contenir des inexactitudes, des omissions ou des lacunes.
                    </p>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Voltigex ne pourra être tenu responsable des dommages directs et indirects causés au matériel de l'utilisateur, lors de l'accès au site Voltigex.com, et résultant soit de l'utilisation d'un matériel ne répondant pas aux spécifications indiquées, soit de l'apparition d'un bug ou d'une incompatibilité.
                    </p>
                    <p class="mb-6 text-gray-700 leading-relaxed">
                        Voltigex ne pourra également être tenu responsable des dommages indirects consécutifs à l'utilisation du site. Des espaces interactifs (commentaires, forum) sont à la disposition des utilisateurs. Voltigex se réserve le droit de supprimer, sans mise en demeure préalable, tout contenu déposé dans cet espace qui contreviendrait à la législation applicable en France, en particulier aux dispositions relatives à la protection des données.
                    </p>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">6. Liens hypertextes</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Le site Voltigex.com peut contenir des liens hypertextes vers d'autres sites présents sur le réseau Internet. Les liens vers ces autres ressources vous font quitter le site Voltigex.com.
                    </p>
                    <p class="mb-6 text-gray-700 leading-relaxed">
                        Il est possible de créer un lien vers la page de présentation de ce site sans autorisation expresse de l'éditeur. Aucune autorisation ni demande d'information préalable ne peut être exigée par l'éditeur à l'égard d'un site qui souhaite établir un lien vers le site de l'éditeur. Il convient toutefois d'afficher ce site dans une nouvelle fenêtre du navigateur.
                    </p>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">7. Droit applicable</h2>
                    <p class="mb-6 text-gray-700 leading-relaxed">
                        Les présentes mentions légales sont régies par le droit français. En cas de litige et à défaut d'accord amiable, le litige sera porté devant les tribunaux français conformément aux règles de compétence en vigueur.
                    </p>

                    <h2 class="text-2xl font-bold text-gray-900 mb-4">8. Contact</h2>
                    <p class="mb-4 text-gray-700 leading-relaxed">
                        Pour toute question concernant les présentes mentions légales, vous pouvez nous contacter :
                    </p>
                    <ul class="list-none mb-6 text-gray-700 space-y-2">
                        <li><strong>Par email :</strong> <a href="mailto:contact@Voltigex.com" class="text-primary hover:underline">contact@Voltigex.com</a></li>
                        <li><strong>Par téléphone :</strong> +33 1 23 45 67 89</li>
                        <li><strong>Par courrier :</strong> Voltigex - 123 Avenue des Champs-Élysées, 75008 Paris, France</li>
                    </ul>

                    <div class="bg-blue-50 border-l-4 border-blue-400 p-6 mt-8">
                        <div class="flex">
                            <div class="flex-shrink-0">
                                <i class="fas fa-info-circle text-blue-400 text-xl"></i>
                            </div>
                            <div class="ml-3">
                                <p class="text-sm text-blue-700">
                                    <strong>Note importante :</strong> Ces mentions légales peuvent être modifiées à tout moment. Nous vous invitons à les consulter régulièrement pour prendre connaissance des éventuelles modifications.
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
