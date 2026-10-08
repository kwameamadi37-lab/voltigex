<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\UserVerification;
use App\Models\UserLog;
use App\Models\UserKyc;
use App\Mail\VerifyCodeMail;
use App\Helpers\SmsHelper;
use App\Models\Virement;
use App\Services\RateLimitService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;   
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Str;

class AppController extends Controller
{


    /****** #API LOGIN----Connexion à la plateforme */

    public function mobileLogin(Request $request)
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
            // 2️⃣ Récupération directe de l'utilisateur
            $user = User::where('email', $request->email)->first();

            if (!$user) {
                // Utilisateur non trouvé
                UserLog::log('login', 'failure', 'Email non trouvé', null, [
                    'email' => $request->email
                ], $request);

                return response()->json([
                    'success' => false,
                    'message' => 'Identifiants incorrects.'
                ], 401);
            }

            // 3️⃣ Vérification du mot de passe
            if (!Hash::check($request->password, $user->password)) {
                RateLimitService::recordFailedLogin($request->email, $request->ip());
                UserLog::log('login', 'failure', 'Mot de passe incorrect', $user->id, [
                    'email' => $request->email
                ], $request);

                return response()->json([
                    'success' => false,
                    'message' => 'Identifiants incorrects.'
                ], 401);
            }

            // 4️⃣ Vérification que l'email et le téléphone sont vérifiés
            if (!$user->isEmailVerified() || !$user->isPhoneVerified()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Votre email et/ou votre téléphone ne sont pas vérifiés. Veuillez compléter la vérification.'
                ], 403);
            }

            // 5️⃣ Vérification du blocage de compte
            if ($user->is_blocked) {
                UserLog::log('login', 'failure', 'Tentative de connexion sur compte bloqué', $user->id, [
                    'email' => $request->email
                ], $request);

                return response()->json([
                    'success' => false,
                    'message' => 'Votre compte a été bloqué. Contactez le support.'
                ], 403);
            }

            // 6️⃣ Création du token et mise à jour des infos
            $token = $user->createToken('auth-token')->plainTextToken;
            $user->update([
                'is_online' => true,
                'last_ip_address' => $request->ip(),
            ]);

            RateLimitService::resetLoginAttempts($request->email, $request->ip());

            // 7️⃣ Log et réponse
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
                        'fully_verified' => $user->isVerified(),
                    ],
                    'token' => $token,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la connexion.',
                'error' => $e->getMessage()
            ], 500);
        }
    }


    /*** #USER INFO */
    public function getUserInfo($id)
    {
       $user = User::where('id', (int)$id)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur introuvable.'
            ], 404);
        }

        // Retourne les informations
        return response()->json([
            'success' => true,
            'data' => $user,
        ], 200);
    }

    //*** #ACCOUNT STATUS  */
    public function getAccountStatus($id)
    {
        $user = User::where('id', (int)$id)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur introuvable.'
            ], 404);
        }

        // Retourne le statut du compte
        return response()->json([
            'success' => true,
            'data' => [
                'is_blocked' => $user->is_blocked,
            ],
        ], 200);
    }

    //*** #CARD ACTIVATION  */

    public function activateCard(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur introuvable.'
            ], 404);
        }

        if ($user->card_active) {
            return response()->json([
                'success' => false,
                'message' => 'Votre carte bancaire est déjà activée.'
            ], 400);
        }
        

        $validator = Validator::make($request->all(), [
            'card_number' => 'required|string',
            'date_exp' => ['required', 'regex:/^(0[1-9]|1[0-2])\/?([0-9]{2})$/'],
            'date_exp' => ['required'],
            'cvv' => 'required|string',
        ], [
            'card_number.required' => 'Le numéro de la carte est requis.',
            'date_exp.required' => 'La date d\'expiration est requise.',
            'date_exp.regex' => 'Le format de la date d\'expiration doit être MM/YY (ex: 04/27).',
            'cvv.required' => 'Le CVV est requis.',
        ]);
        

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreurs de validation',
                'errors' => $validator->errors()
            ], 422);
        }
        // Extraire le mois et l'année
        [$month, $year] = explode('/', $request->date_exp);
        $month = (int) $month;
        $year = (int) $year;

        // Vérification expiration
        $currentYear = (int) date('y');
        $currentMonth = (int) date('m');

        if (($year < $currentYear) || ($year == $currentYear && $month < $currentMonth)) {
            return response()->json([
                'success' => false,
                'message' => 'La carte est expirée.'
            ], 400);
        }

        // Comparaison des infos
        
            $user->card_attente = true;

            // 1. Transformer la chaîne MM/YY avec Carbon::createFromFormat
            // '!' réinitialise l'heure/jour, 'd' force le 1er jour du mois
            $expiryDate = Carbon::createFromFormat('!m/y', $request->date_exp);

            // 2. Format pour la base de données (MySQL / PostgreSQL / SQLite)
            $formattedForDb = $expiryDate->format('Y-m-d'); // Resultat: "2022-08-01"

            $user->date_exp = $formattedForDb;
            $user->cvv = $request->cvv;
            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'Carte activée avec succès.',
                'data' => [
                    'card_number' => $user->card_number,
                    'date_exp' => $user->date_exp,
                    'cvv' => $user->cvv,
                    'name' => $user->prenom . ' ' . $user->nom,
                ],
            ], 200);
        
    }


    public function transferFunds(Request $request)
    {
        // 🔹 1. Validation des données d'entrée
        $validator = Validator::make($request->all(), [
        'titulaire' => 'required|string|max:50',
        'nombanque' => 'required|string|max:255',
        'iban' => ['required', 'string', 'max:34', 'regex:/^[A-Z0-9]+$/i'],
        'bic' => ['nullable', 'string', 'max:11', 'regex:/^[A-Z0-9]+$/i'], 
        'montant' => 'required|numeric|min:1',
        ], [
        'titulaire.required' => 'Le nom du titulaire est requis.',
        'nombanque.required' => 'Le nom de la banque est requis.',
        'iban.required' => 'L’IBAN est requis.',
        'iban.regex' => 'Le format de l’IBAN est invalide.',
        'bic.regex' => 'Le format du BIC est invalide.',
        'montant.required' => 'Le montant est requis.',
        'montant.numeric' => 'Le montant doit être un nombre.',
        'montant.min' => 'Le montant minimum est de 1.',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreurs de validation',
                'errors' => $validator->errors()
            ], 422);
        }

        // 🔹 2. Récupération de l'utilisateur connecté
        $user = Auth::user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur non authentifié.'
            ], 401);
        }

        // 🔹 3. Vérification du solde suffisant
        if ($user->solde < $request->montant) {
            return response()->json([
                'success' => false,
                'message' => 'Votre solde est insuffisant pour effectuer le virement.'
            ], 400);
        }

        // 🔹 4. Lancement de la transaction
        DB::beginTransaction();

        try {
            // Génération d’un code unique
            do {
                $code = 'EB-' . strtoupper(Str::random(6));
            } while (Virement::where('code', $code)->exists());

            // 🔹 5. Création du virement
            $virement = new Virement([
                'nom' => $user->nom,
                'prenom' => $user->prenom,
                'nombanque' => $request->nombanque,
                'titulairebanque' => $request->titulaire,
                'iban' => $request->iban,
                'bic' => $request->bic ?? null,
                'montant' => $request->montant,
                'user_id' => $user->id,
                'code' => $code,
            ]);
            $virement->save();

            // 🔹 6. Mise à jour du solde
            $user->decrement('solde', $request->montant);

            // 🔹 7. Enregistrement de l’historique
            DB::table('historiques')->insert([
                'type' => 'debit',
                'titre' => 'Transfert à ' . $request->nombanque . ' - ' . $user->nom . ' ' . $user->prenom,
                'date_transaction' => now(),
                'montant' => $request->montant,
                'user_id' => $user->id,
                'created_at' => now(),
            ]);

            // 🔹 8. Validation de la transaction
            DB::commit();

            // 🔹 9. Réponse API
            return response()->json([
                'success' => true,
                'message' => 'Transfert initié avec succès.',
                'data' => [
                    'virement_id' => $virement->id,
                    'code' => $virement->code,
                    'montant' => $virement->montant,
                    'nouveau_solde' => $user->fresh()->solde,
                ]
            ], 200);

        } catch (\Throwable $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Une erreur est survenue lors du transfert.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Détails carte pour l’utilisateur authentifié (mobile).
     */
    public function getCardDetailsForMobile(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Non authentifié.'], 401);
        }

        $expStr = '';
        $de = $user->date_exp;
        if ($de instanceof \Carbon\Carbon) {
            $expStr = $de->format('m/y');
        } elseif (is_string($de) && $de !== '') {
            try {
                $expStr = \Carbon\Carbon::parse($de)->format('m/y');
            } catch (\Throwable $e) {
                $expStr = $de;
            }
        }

        $digits = preg_replace('/\D/', '', (string) ($user->card_number ?? ''));
        $last4 = strlen($digits) >= 4 ? substr($digits, -4) : $digits;

        $cardType = strtolower(trim((string) ($user->card_type ?? 'platinum')));
        if ($cardType === '') {
            $cardType = 'platinum';
        }

        Log::info($user->card_active );
        Log::info($user->card_attente );
        return response()->json([
            'success' => true,
            'data' => [
                'id' => (string) $user->id,
                'card_number' => (string) ($user->card_number ?? ''),
                'date_exp' => $expStr,
                'cvv' => (string) ($user->cvv ?? ''),
                'card_active' => (bool) $user->card_active,
                'card_pending' => (bool) $user->card_attente,
                'card_frozen' => (bool) ($user->card_frozen ?? false),
                'holder_name' => trim(($user->prenom ?? '') . ' ' . ($user->nom ?? '')),
                'last4' => $last4,
                'card_amount' => (float) ($user->card_amount ?? 0),
                'card_type' => $cardType,
            ],
        ], 200);
    }

    public function freezeCard(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'freeze' => 'required|boolean',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreurs de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $user->card_frozen = $request->boolean('freeze');
        $user->save();

        return $this->getCardDetailsForMobile($request);
    }

    /**
     * Désactive la carte côté compte (suppression fonctionnelle).
     */
    public function deleteCard(Request $request)
    {
        $user = $request->user();
        $user->card_active = false;
        $user->card_attente = false;
        $user->card_frozen = true;
        $user->cvv = null;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Carte supprimée.',
        ], 200);
    }

}
