<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\UserVerification;
use App\Models\UserLog;
use App\Mail\VerifyCodeMail;
use App\Mail\WelcomeMail;
use App\Helpers\SmsHelper;
use App\Services\RateLimitService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;   
use Illuminate\Support\Facades\Log;

class AuthApiController extends Controller
{
    /**
     * Inscription d'un nouvel utilisateur
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function register(Request $request)
    {
        Log::info("cccccccccccccccccc");
        // Validation améliorée avec règles plus strictes
        $validator = Validator::make($request->all(), [
            'nom' => 'required|string|max:255',
            'prenom' => 'required|string|max:255',
            'email' => [
                'required',
                'email',
                'max:255',
                'unique:users,email',
                'regex:/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/'
            ],
            'phone' => [
                'required',
                'string',
                'max:20',
                'unique:users,phone'
            ],
            'password' => [
                'required',
                'string',
                'min:8',
                'max:255',
                'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/'
            ],
            'piece_identite' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
            'avis_imposition' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
        ], [
            'nom.required' => 'Le nom est requis.',
            'prenom.required' => 'Le prénom est requis.',
            'piece_identite.required' => 'La pièce d\'identité est requise.',
            'piece_identite.file' => 'La pièce d\'identité doit être un fichier.',
            'piece_identite.mimes' => 'La pièce d\'identité doit être au format PDF, JPG, JPEG ou PNG.',
            'piece_identite.max' => 'La pièce d\'identité ne doit pas dépasser 5MB.',
            'avis_imposition.required' => 'L\'avis d\'imposition est requis.',
            'avis_imposition.file' => 'L\'avis d\'imposition doit être un fichier.',
            'avis_imposition.mimes' => 'L\'avis d\'imposition doit être au format PDF, JPG, JPEG ou PNG.',
            'avis_imposition.max' => 'L\'avis d\'imposition ne doit pas dépasser 5MB.',
            'email.required' => 'L\'email est requis.',
            'email.email' => 'L\'email doit être une adresse email valide.',
            'email.max' => 'L\'email ne doit pas dépasser 255 caractères.',
            'email.unique' => 'Cet email est déjà utilisé. Veuillez utiliser un autre email.',
            'email.regex' => 'Le format de l\'email n\'est pas valide.',
            'phone.required' => 'Le numéro de téléphone est requis.',
            'phone.max' => 'Le numéro de téléphone ne doit pas dépasser 20 caractères.',
            'phone.unique' => 'Ce numéro de téléphone est déjà utilisé. Veuillez utiliser un autre numéro.',
            'password.required' => 'Le mot de passe est requis.',
            'password.min' => 'Le mot de passe doit contenir au moins 8 caractères.',
            'password.max' => 'Le mot de passe ne doit pas dépasser 255 caractères.',
            'password.regex' => 'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial (@$!%*?&).',
        ]);


        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreurs de validation',
                'errors' => $validator->errors()
            ], 422);
        }

        // Validation du format du téléphone (international)
        if (!$this->isValidInternationalPhone($request->phone)) {
            return response()->json([
                'success' => false,
                'message' => 'Le format du numéro de téléphone n\'est pas valide.',
                'errors' => ['phone' => ['Format de téléphone invalide. Utilisez le format international (ex: +33 6 12 34 56 78 ou +33712345678).']]
            ], 422);
        }

        // Validation supplémentaire du mot de passe
        if (strlen($request->password) < 8) {
            return response()->json([
                'success' => false,
                'message' => 'Le mot de passe est trop court.',
                'errors' => ['password' => ['Le mot de passe doit contenir au moins 8 caractères.']]
            ], 422);
        }

        // Vérifier si l'email existe déjà
        if (User::where('email', $request->email)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Cet email est déjà utilisé.',
                'errors' => ['email' => ['Cet email est déjà utilisé. Veuillez utiliser un autre email.']]
            ], 422);
        }

        // Vérifier si le téléphone existe déjà
        if (User::where('phone', $request->phone)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Ce numéro de téléphone est déjà utilisé.',
                'errors' => ['phone' => ['Ce numéro de téléphone est déjà utilisé. Veuillez utiliser un autre numéro.']]
            ], 422);
        }

        // Si toutes les validations passent, retourner un succès sans enregistrer
        // Les données seront enregistrées à l'étape 2 (uploadPhoto)
        return response()->json([
            'success' => true,
            'message' => 'Informations validées avec succès. Veuillez prendre une photo de votre carte d\'identité.',
            'data' => [
                'next_step' => 'photo',
                'message' => 'Prenez une photo de votre carte d\'identité pour continuer.'
            ]
        ], 200);
    }

    /**
     * Upload de la photo de la carte d'identité et enregistrement complet
     * Cette méthode enregistre TOUT en une seule fois : données étape 1 + photo étape 2
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function uploadPhoto(Request $request)
    {
        // Validation complète de toutes les données (étape 1 + étape 2)
        $validator = Validator::make($request->all(), [
            'nom' => 'required|string|max:255',
            'prenom' => 'required|string|max:255',
            'email' => [
                'required',
                'email',
                'max:255',
                'unique:users,email',
                'regex:/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/'
            ],
            'phone' => [
                'required',
                'string',
                'max:20',
                'unique:users,phone'
            ],
            'password' => [
                'required',
                'string',
                'min:8',
                'max:255',
                'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/'
            ],
            'piece_identite' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
            'avis_imposition' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
            'photo_carte_identite' => 'required|image|mimes:jpeg,jpg,png|max:5120',
        ], [
            'nom.required' => 'Le nom est requis.',
            'prenom.required' => 'Le prénom est requis.',
            'piece_identite.required' => 'La pièce d\'identité est requise.',
            'piece_identite.file' => 'La pièce d\'identité doit être un fichier.',
            'piece_identite.mimes' => 'La pièce d\'identité doit être au format PDF, JPG, JPEG ou PNG.',
            'piece_identite.max' => 'La pièce d\'identité ne doit pas dépasser 5MB.',
            'avis_imposition.required' => 'L\'avis d\'imposition est requis.',
            'avis_imposition.file' => 'L\'avis d\'imposition doit être un fichier.',
            'avis_imposition.mimes' => 'L\'avis d\'imposition doit être au format PDF, JPG, JPEG ou PNG.',
            'avis_imposition.max' => 'L\'avis d\'imposition ne doit pas dépasser 5MB.',
            'photo_carte_identite.required' => 'La photo de la carte d\'identité est requise.',
            'photo_carte_identite.image' => 'Le fichier doit être une image.',
            'photo_carte_identite.mimes' => 'L\'image doit être au format JPEG, JPG ou PNG.',
            'photo_carte_identite.max' => 'L\'image ne doit pas dépasser 5MB.',
            'email.required' => 'L\'email est requis.',
            'email.email' => 'L\'email doit être une adresse email valide.',
            'email.max' => 'L\'email ne doit pas dépasser 255 caractères.',
            'email.unique' => 'Cet email est déjà utilisé. Veuillez utiliser un autre email.',
            'email.regex' => 'Le format de l\'email n\'est pas valide.',
            'phone.required' => 'Le numéro de téléphone est requis.',
            'phone.max' => 'Le numéro de téléphone ne doit pas dépasser 20 caractères.',
            'phone.unique' => 'Ce numéro de téléphone est déjà utilisé. Veuillez utiliser un autre numéro.',
            'password.required' => 'Le mot de passe est requis.',
            'password.min' => 'Le mot de passe doit contenir au moins 8 caractères.',
            'password.max' => 'Le mot de passe ne doit pas dépasser 255 caractères.',
            'password.regex' => 'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial (@$!%*?&).',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Veuillez corriger les erreurs dans le formulaire',
                'errors' => $validator->errors()
            ], 422);
        }

        // Validation du format du téléphone
        if (!$this->isValidInternationalPhone($request->phone)) {
            return response()->json([
                'success' => false,
                'message' => 'Le format du numéro de téléphone n\'est pas valide.',
                'errors' => ['phone' => ['Format de téléphone invalide. Utilisez le format international (ex: +33 6 12 34 56 78 ou +33712345678).']]
            ], 422);
        }

        try {
            // Générer un alias unique basé sur l'email
            $alias = $this->generateUniqueAlias($request->email);

            // Upload de tous les fichiers
            $pieceIdentitePath = null;
            $avisImpositionPath = null;
            $photoPath = null;
            
            if ($request->hasFile('piece_identite')) {
                $pieceIdentitePath = $request->file('piece_identite')->store('documents/pieces_identite', 'public');
            }
            
            if ($request->hasFile('avis_imposition')) {
                $avisImpositionPath = $request->file('avis_imposition')->store('documents/avis_imposition', 'public');
            }

            if ($request->hasFile('photo_carte_identite')) {
                $photoPath = $request->file('photo_carte_identite')->store('documents/photos_carte_identite', 'public');
            }

            // Créer l'utilisateur avec account_status = 0 (inactif) - TOUT EN UNE FOIS
            $user = User::create([
                'email' => $request->email,
                'phone' => $request->phone,
                'password' => Hash::make($request->password),
                'alias' => $alias,
                'role' => 'user',
                'nom' => $request->nom,
                'prenom' => $request->prenom,
                'piece_identite' => $pieceIdentitePath,
                'avis_imposition' => $avisImpositionPath,
                'photo_carte_identite' => $photoPath,
                'account_status' => 0, // Inactif par défaut
                'numero_bancaire' => $this->generateBankNumber(),
                'card_number' => $this->generateCardNumber(),
                'iban' => $this->generateIban(),
                'bic' => 'MYBKFRPP',
            ]);

            // Envoyer l'email de bienvenue
            $mailData = [
                'nom' => $user->nom,
                'prenom' => $user->prenom,
                'email' => $user->email,
                'alias' => $user->alias,
            ];
            Mail::to($user->email)->send(new WelcomeMail($mailData));

            // Log de l'inscription complète
            UserLog::log('register', 'success', 'Compte créé avec succès (toutes les étapes)', $user->id, [
                'email' => $user->email,
                'phone' => $user->phone
            ], $request);

            return response()->json([
                'success' => true,
                'message' => 'Votre compte a été créé avec succès ! Un email de bienvenue vous a été envoyé.',
                'data' => [
                    'user_id' => $user->id,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'alias' => $user->alias,
                    'next_step' => 'success',
                    'message' => 'Votre compte est en cours de validation par notre équipe. Vous serez notifié par email une fois votre compte validé.'
                ]
            ], 201);

        } catch (\Exception $e) {
            // Log de l'erreur
            UserLog::log('register', 'failure', 'Erreur lors de la création du compte: ' . $e->getMessage(), null, [
                'error' => $e->getMessage(),
                'email' => $request->email ?? null,
                'phone' => $request->phone ?? null
            ], $request);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la création du compte. Veuillez réessayer.',
                'error' => config('app.debug') ? $e->getMessage() : 'Une erreur est survenue'
            ], 500);
        }
    }

    /**
     * Vérification du code de vérification
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function verify(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'code' => 'required|string|size:6',
        ], [
            'email.required' => 'L\'email est requis.',
            'email.email' => 'L\'email doit être valide.',
            'code.required' => 'Le code de vérification est requis.',
            'code.size' => 'Le code doit contenir exactement 6 chiffres.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreurs de validation',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Trouver l'utilisateur
            $user = User::where('email', $request->email)->first();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Utilisateur non trouvé.'
                ], 404);
            }

            // Trouver les codes de vérification valides
            $emailVerification = UserVerification::where('user_id', $user->id)
                ->where('type', 'email')
                ->where('verification_code', $request->code)
                ->valid()
                ->first();

            $phoneVerification = UserVerification::where('user_id', $user->id)
                ->where('type', 'phone')
                ->where('verification_code', $request->code)
                ->valid()
                ->first();

            if (!$emailVerification && !$phoneVerification) {
                // Incrémenter les tentatives pour tous les codes de cet utilisateur
                UserVerification::where('user_id', $user->id)
                    ->where('verification_code', $request->code)
                    ->get()
                    ->each(function($verification) {
                        $verification->incrementAttempts();
                    });

                // Log de l'échec de vérification
                UserLog::log('verify_code', 'failure', 'Code de vérification invalide', $user->id, [
                    'code' => $request->code,
                    'attempts' => $emailVerification ? $emailVerification->attempts : 0
                ], $request);

                return response()->json([
                    'success' => false,
                    'message' => 'Code de vérification invalide ou expiré.'
                ], 400);
            }

            // Vérifier si le code est en cooldown
            if ($emailVerification && $emailVerification->isInCooldown()) {
                UserLog::log('verify_code', 'failure', 'Code en période de cooldown', $user->id, [
                    'cooldown_until' => $emailVerification->cooldown_until
                ], $request);

                return response()->json([
                    'success' => false,
                    'message' => 'Trop de tentatives. Réessayez dans 15 minutes.'
                ], 429);
            }

            // Marquer les codes comme utilisés
            if ($emailVerification) {
                $emailVerification->markAsUsed();
                $user->markEmailAsVerified();
            }

            if ($phoneVerification) {
                $phoneVerification->markAsUsed();
                $user->markPhoneAsVerified();
            }

            // Log de la vérification réussie
            UserLog::log('verify_code', 'success', 'Code de vérification validé', $user->id, [
                'email_verified' => $user->isEmailVerified(),
                'phone_verified' => $user->isPhoneVerified()
            ], $request);

            return response()->json([
                'success' => true,
                'message' => 'Email et téléphone vérifiés avec succès.',
                'data' => [
                    'user_id' => $user->id,
                    'email_verified' => $user->isEmailVerified(),
                    'phone_verified' => $user->isPhoneVerified(),
                    'email_and_phone_verified' => $user->isEmailAndPhoneVerified(),
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la vérification.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Connexion de l'utilisateur
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ], [
            'email.required' => 'L\'email est requis.',
            'email.email' => 'L\'email doit être valide.',
            'password.required' => 'Le mot de passe est requis.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreurs de validation',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Vérifier les limitations de taux
            $rateLimitCheck = RateLimitService::canLogin($request->email, $request->ip());
            if (!$rateLimitCheck['allowed']) {
                UserLog::log('login', 'failure', $rateLimitCheck['message'], null, [
                    'email' => $request->email,
                    'type' => $rateLimitCheck['type']
                ], $request);

                return response()->json([
                    'success' => false,
                    'message' => $rateLimitCheck['message']
                ], 429);
            }

            // Tentative d'authentification
            if (Auth::attempt(['email' => $request->email, 'password' => $request->password])) {
                $user = Auth::user();

                // Vérifier si le compte est bloqué
                if ($user->is_blocked) {
                    UserLog::log('login', 'failure', 'Tentative de connexion sur compte bloqué', $user->id, [
                        'email' => $request->email
                    ], $request);

                    return response()->json([
                        'success' => false,
                        'message' => 'Votre compte a été bloqué. Contactez le support.'
                    ], 403);
                }

                // Créer un token Sanctum
                $token = $user->createToken('auth-token')->plainTextToken;

                // Mettre à jour les informations de connexion
                $user->update([
                    'is_online' => true,
                    'last_ip_address' => $request->ip(),
                ]);

                // Réinitialiser les compteurs de limitation
                RateLimitService::resetLoginAttempts($request->email, $request->ip());

                // Log de la connexion réussie
                UserLog::log('login', 'success', 'Connexion réussie', $user->id, [
                    'email' => $user->email,
                    'token_created' => true
                ], $request);

                return response()->json([
                    'success' => true,
                    'message' => 'Connexion réussie.',
                    'data' => [
                        'user' => [
                            'id' => $user->id,
                            'email' => $user->email,
                            'phone' => $user->phone,
                            'alias' => $user->alias,
                            'role' => $user->role,
                            'email_verified' => $user->isEmailVerified(),
                            'phone_verified' => $user->isPhoneVerified(),
                            'email_and_phone_verified' => $user->isEmailAndPhoneVerified(),
                        ],
                        'token' => $token,
                    ]
                ], 200);

            } else {
                // Enregistrer la tentative échouée
                RateLimitService::recordFailedLogin($request->email, $request->ip());

                UserLog::log('login', 'failure', 'Identifiants incorrects', null, [
                    'email' => $request->email
                ], $request);

                return response()->json([
                    'success' => false,
                    'message' => 'Identifiants incorrects.'
                ], 401);
            }

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la connexion.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Renvoyer un code de vérification
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse   
     */
    public function resendCode(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
        ], [
            'email.required' => 'L\'email est requis.',
            'email.email' => 'L\'email doit être valide.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreurs de validation',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Trouver l'utilisateur
            $user = User::where('email', $request->email)->first();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Utilisateur non trouvé.'
                ], 404);
            }

            // Vérifier les limitations de taux
            $emailLimitCheck = RateLimitService::canSendVerificationCode($user, 'email');
            $phoneLimitCheck = RateLimitService::canSendVerificationCode($user, 'phone');

            if (!$emailLimitCheck['allowed'] || !$phoneLimitCheck['allowed']) {
                UserLog::log('resend_code', 'failure', 'Limite de renvoi atteinte', $user->id, [
                    'email_limit' => !$emailLimitCheck['allowed'],
                    'phone_limit' => !$phoneLimitCheck['allowed']
                ], $request);

                return response()->json([
                    'success' => false,
                    'message' => $emailLimitCheck['message'] ?? $phoneLimitCheck['message']
                ], 429);
            }

            // Générer un nouveau code
            $verificationCode = UserVerification::generateCode();

            // Invalider les anciens codes
            UserVerification::where('user_id', $user->id)
                ->where('is_used', false)
                ->update(['is_used' => true]);

            // Créer de nouveaux codes
            UserVerification::create([
                'user_id' => $user->id,
                'email' => $user->email,
                'verification_code' => $verificationCode,
                'type' => 'email',
                'expires_at' => Carbon::now()->addMinutes(10),
            ]);

            UserVerification::create([
                'user_id' => $user->id,
                'phone' => $user->phone,
                'verification_code' => $verificationCode,
                'type' => 'phone',
                'expires_at' => Carbon::now()->addMinutes(10),
            ]);

            // Envoyer les nouveaux codes
            Mail::to($user->email)->send(new VerifyCodeMail($verificationCode, $user->email));
            SmsHelper::sendVerificationCode($user->phone, $verificationCode);

            // Enregistrer les tentatives d'envoi
            RateLimitService::recordVerificationAttempt($user, 'email');
            RateLimitService::recordVerificationAttempt($user, 'phone');

            // Log du renvoi
            UserLog::log('resend_code', 'success', 'Code de vérification renvoyé', $user->id, [
                'email' => $user->email,
                'phone' => $user->phone
            ], $request);

            return response()->json([
                'success' => true,
                'message' => 'Un nouveau code de vérification a été envoyé par email et SMS.',
            ], 200);

        } catch (\Exception $e) {
            UserLog::log('resend_code', 'failure', 'Erreur lors du renvoi: ' . $e->getMessage(), $user->id ?? null, [
                'error' => $e->getMessage(),
                'email' => $request->email
            ], $request);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du renvoi du code.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    private function generateUniqueAlias($email)
    {
        $baseAlias = explode('@', $email)[0];
        $alias = $baseAlias;
        $counter = 1;

        while (User::where('alias', $alias)->exists()) {
            $alias = $baseAlias . $counter;
            $counter++;
        }

        return $alias;
    }

    /**
     * Générer un numéro bancaire unique
     *
     * @return string
     */
    private function generateBankNumber()
    {
        do {
            $number = 'FR' . str_pad(random_int(0, 9999999999999999), 16, '0', STR_PAD_LEFT);
        } while (User::where('numero_bancaire', $number)->exists());

        return $number;
    }

    /**
     * Générer un numéro de carte unique
     *
     * @return string
     */
    private function generateCardNumber()
    {
        do {
            $number = str_pad(random_int(0, 9999999999999999), 16, '0', STR_PAD_LEFT);
        } while (User::where('card_number', $number)->exists());

        return $number;
    }

    /**
     * Générer un IBAN unique
     *
     * @return string
     */
    private function generateIban()
    {
        do {
            // Générer 20 chiffres aléatoires
            $randomDigits = '';
            for ($i = 0; $i < 20; $i++) {
                $randomDigits .= random_int(0, 9);
            }
            $iban = 'FR' . $randomDigits;
        } while (User::where('iban', $iban)->exists());

        return $iban;
    }

    /**
     * Déconnexion de l'utilisateur
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(Request $request)
    {
        try {
            $user = $request->user();
            
            if ($user) {
                // Mettre à jour le statut de connexion
                $user->update(['is_online' => false]);
                
                // Invalider explicitement le token courant Sanctum
                if ($request->user()->currentAccessToken()) {
                    $request->user()->currentAccessToken()->delete();
                }
                
                // Log de la déconnexion
                UserLog::log('logout', 'success', 'Déconnexion réussie', $user->id, [
                    'email' => $user->email
                ], $request);
                
                return response()->json([
                    'success' => true,
                    'message' => 'Déconnexion réussie.'
                ], 200);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Aucun utilisateur connecté.'
                ], 401);
            }
            
        } catch (\Exception $e) {
            UserLog::log('logout', 'failure', 'Erreur lors de la déconnexion: ' . $e->getMessage(), null, [
                'error' => $e->getMessage()
            ], $request);
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la déconnexion.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Déconnexion de tous les appareils
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logoutAll(Request $request)
    {
        try {
            $user = Auth::user();
            
            if ($user) {
                // Mettre à jour le statut de connexion
                $user->update(['is_online' => false]);
                
                // Supprimer tous les tokens de l'utilisateur
                $user->tokens()->delete();
                
                // Log de la déconnexion globale
                UserLog::log('logout_all', 'success', 'Déconnexion de tous les appareils', $user->id, [
                    'email' => $user->email,
                    'tokens_revoked' => true
                ], $request);
                
                return response()->json([
                    'success' => true,
                    'message' => 'Déconnexion de tous les appareils réussie.'
                ], 200);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Aucun utilisateur connecté.'
                ], 401);
            }
            
        } catch (\Exception $e) {
            UserLog::log('logout_all', 'failure', 'Erreur lors de la déconnexion globale: ' . $e->getMessage(), null, [
                'error' => $e->getMessage()
            ], $request);
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la déconnexion globale.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Valider un numéro de téléphone international
     */
    private function isValidInternationalPhone($phone)
    {
        // Supprimer tous les espaces et caractères spéciaux sauf le +
        $cleaned = preg_replace('/[^\d+]/', '', $phone);
        
        // Vérifier que le numéro commence par +
        if (!str_starts_with($cleaned, '+')) {
            return false;
        }
        
        // Vérifier la longueur (entre 8 et 15 chiffres après le +)
        $digits = substr($cleaned, 1);
        if (strlen($digits) < 8 || strlen($digits) > 15) {
            return false;
        }
        
        // Vérifier que tous les caractères après le + sont des chiffres
        if (!ctype_digit($digits)) {
            return false;
        }
        
        return true;
    }
}
