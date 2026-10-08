<?php

namespace App\Http\Controllers;
use App\Models\Virement;
use Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class UtilisateurController extends Controller
{
    public function carte(Request $request){
        $virements=DB::table('virements')->where('user_id', Auth()->User()->id)->orderByDesc('created_at')->get();  
        $historiques=DB::table('historiques')->where('user_id', Auth()->User()->id)->orderByDesc('date_transaction')->get();
        
        if ($request->expectsJson() || $request->is('api/*')) {
            return response()->json([
                'success' => true,
                'data' => [
                    'virements' => $virements,
                    'historiques' => $historiques
                ]
            ]);
        }
        
        return view('utilisateur.carte',compact('virements','historiques'));
    }

    /**
     * Historique paginé pour l’app mobile (ORDER BY created_at DESC, pas de cache côté Flutter).
     * Query params: limit (défaut 25), offset (défaut 0).
     */
    public function transactionsHistoriques(Request $request)
    {
        $userId = auth()->id();
        $limit = min(max((int) $request->query('limit', 25), 1), 100);
        $offset = max((int) $request->query('offset', 0), 0);

        $total = DB::table('historiques')->where('user_id', $userId)->count();

        $historiques = DB::table('historiques')
            ->where('user_id', $userId)
            ->orderByDesc('created_at')
            ->offset($offset)
            ->limit($limit)
            ->get();

        $userVirements = DB::table('virements')
            ->where('user_id', $userId)
            ->get();

        $historiques = $historiques->map(function ($h) use ($userVirements) {
            $row = (array) $h;
            if ($this->historiqueLooksLikeVirement($h)) {
                $match = $this->matchVirementForHistorique($userVirements, $h);
                if ($match !== null) {
                    $row['pourcentage'] = $match->pourcentage;
                    $row['virement_statut'] = $match->statut;
                }
            }

            return (object) $row;
        });

        $hasMore = ($offset + $historiques->count()) < $total;

        $devise = DB::table('users')->where('id', $userId)->value('devise');
        if ($devise === null || $devise === '') {
            $devise = '€';
        }

        return response()->json([
            'success' => true,
            'data' => [
                'historiques' => $historiques,
                'has_more' => $hasMore,
                'total' => $total,
                'devise' => $devise,
            ],
        ]);
    }

    public function profil(){
        return view('utilisateur.profil');
    }

    public function parametre(){
        return view('utilisateur.parametre');
    }


    public function profilstore(Request $request){
        $validator = Validator::make($request->all(), [
            'nom' => 'required|string|max:255',
            'prenom' => 'required|string|max:255',
            'phone' => 'required|string|max:20',
        ], [
            'nom.required' => 'Le nom est requis.',
            'nom.max' => 'Le nom ne doit pas dépasser 255 caractères.',
        
            'prenom.required' => 'Le prénom est requis.',
            'prenom.max' => 'Le prénom ne doit pas dépasser 255 caractères.',
        
            'phone.required' => 'Le numéro de téléphone est requis.',
            'phone.max' => 'Le numéro de téléphone ne doit pas dépasser 20 caractères.',
        ]
        );

        if ($validator->fails()) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Erreurs de validation',
                    'errors' => $validator->errors()
                ], 422);
            }
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        try {
            DB::table('users')->where('id', Auth()->User()->id)->update([
                'nom' => $request->nom,
                'prenom' => $request->prenom,
                'phone' => $request->phone,
            ]);

            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => true,
                    'message' => 'Vos informations ont été mises à jour avec succès.'
                ], 200);
            }

            return redirect()->back()->with('message', 'Vos informations ont été mises à jour avec succès.');
        } catch (\Exception $e) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Une erreur s\'est produite lors de la mise à jour de vos informations.',
                    'error' => $e->getMessage()
                ], 500);
            }
            return redirect()->back()
                ->with('error', 'Une erreur s\'est produite lors de la mise à jour de vos informations.')
                ->withInput();
        }
    }

    public function updatepassword(Request $request){
        $validator = Validator::make($request->all(), [
            'oldpass' => 'required|string',
            'newpass' => [
                'required',
                'string',
                'min:8',
                'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).+$/',
            ],
            'confpass' => 'required|same:newpass',
        ], [
            'oldpass.required' => 'Le mot de passe actuel est requis.',
            'newpass.required' => 'Le nouveau mot de passe est requis.',
            'newpass.min' => 'Le nouveau mot de passe doit contenir au moins 8 caractères.',
            'newpass.regex' => 'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial.',
            'confpass.required' => 'La confirmation du mot de passe est requise.',
            'confpass.same' => 'Les mots de passe ne correspondent pas.',
        ]
        );

        if ($validator->fails()) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Erreurs de validation',
                    'errors' => $validator->errors()
                ], 422);
            }
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        $current_user = auth()->user();
        
        if (!Hash::check($request->oldpass, $current_user->password)) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Le mot de passe actuel est incorrect.'
                ], 401);
            }
            return redirect()->back()
                ->with('error', 'Le mot de passe actuel est incorrect.')
                ->withInput();
        }

        try {
            $current_user->update([
                'password' => Hash::make($request->newpass)
            ]);

            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => true,
                    'message' => 'Votre mot de passe a été modifié avec succès.'
                ], 200);
            }

            return redirect()->back()->with('message', 'Votre mot de passe a été modifié avec succès.');
        } catch (\Exception $e) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Une erreur s\'est produite lors de la modification du mot de passe.',
                    'error' => $e->getMessage()
                ], 500);
            }
            return redirect()->back()
                ->with('error', 'Une erreur s\'est produite lors de la modification du mot de passe.')
                ->withInput();
        }
    }

    /**
     * Profil complet pour l’app mobile (GET /api/user).
     */
    public function me(Request $request)
    {
        $u = $request->user();
        $birth = $u->birth_date ?? $u->date_naissance;

        return response()->json([
            'id' => $u->id,
            'email' => $u->email,
            'phone' => $u->phone,
            'nom' => $u->nom,
            'prenom' => $u->prenom,
            'first_name' => $u->prenom,
            'last_name' => $u->nom,
            'alias' => $u->alias,
            'role' => $u->role,
            'profile_photo_url' => $u->profilePhotoPublicUrl(),
            'email_verified' => $u->isEmailVerified(),
            'phone_verified' => $u->isPhoneVerified(),
            'country' => $u->country,
            'city' => $u->city,
            'postal_code' => $u->postal_code,
            'address_line' => $u->address_line,
            'address' => $u->address_line,
            'date_naissance' => $u->date_naissance?->format('Y-m-d'),
            'birth_date' => $birth?->format('Y-m-d'),
            'nationalite' => $u->nationalite,
            'numero_identification' => $u->numero_identification,
        ]);
    }

    /**
     * Coordonnées : email + téléphone (PUT /api/user/contact).
     */
    public function updateContact(Request $request)
    {
        $userId = auth()->id();
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|max:255|unique:users,email,'.$userId,
            'phone' => 'required|string|max:30',
        ], [
            'email.required' => 'L’adresse e-mail est requise.',
            'email.email' => 'L’adresse e-mail n’est pas valide.',
            'email.unique' => 'Cette adresse e-mail est déjà utilisée.',
            'phone.required' => 'Le numéro de téléphone est requis.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreurs de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            DB::table('users')->where('id', $userId)->update([
                'email' => $request->email,
                'phone' => $request->phone,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Coordonnées mises à jour.',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Impossible de mettre à jour les coordonnées.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Données d’identité (PUT /api/user/identity).
     */
    public function updateIdentity(Request $request)
    {
        $nom = $request->input('last_name', $request->input('nom'));
        $prenom = $request->input('first_name', $request->input('prenom'));
        $birthProvided = $request->has('birth_date') || $request->has('date_naissance');
        $birth = $request->input('birth_date', $request->input('date_naissance'));

        $validator = Validator::make([
            'nom' => $nom,
            'prenom' => $prenom,
            'birth_date' => $birth,
            'nationalite' => $request->nationalite,
            'numero_identification' => $request->numero_identification,
        ], [
            'nom' => 'required|string|max:255',
            'prenom' => 'required|string|max:255',
            'birth_date' => 'nullable|date',
            'nationalite' => 'nullable|string|max:128',
            'numero_identification' => 'nullable|string|max:64',
        ], [
            'nom.required' => 'Le nom est requis.',
            'prenom.required' => 'Le prénom est requis.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreurs de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $payload = [
                'nom' => $nom,
                'prenom' => $prenom,
                'nationalite' => $request->nationalite,
                'numero_identification' => $request->numero_identification,
            ];

            if ($birthProvided) {
                if ($birth !== null && $birth !== '') {
                    $payload['birth_date'] = $birth;
                    $payload['date_naissance'] = $birth;
                } else {
                    $payload['birth_date'] = null;
                    $payload['date_naissance'] = null;
                }
            }

            DB::table('users')->where('id', auth()->id())->update($payload);

            return response()->json([
                'success' => true,
                'message' => 'Profil mis à jour.',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Impossible de mettre à jour le profil.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Adresse postale (PUT /api/user/address).
     */
    public function updateAddress(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'address_line' => 'required|string|max:500',
            'city' => 'required|string|max:255',
            'postal_code' => 'required|string|max:32',
            'country' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreurs de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            DB::table('users')->where('id', auth()->id())->update([
                'address_line' => $request->address_line,
                'city' => $request->city,
                'postal_code' => $request->postal_code,
                'country' => $request->country,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Adresse enregistrée.',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Impossible d’enregistrer l’adresse.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function notifications(Request $request)
    {
        $notifications = auth()->user()->notifications()
            ->recent()
            ->paginate(10);

        if ($request->expectsJson() || $request->is('api/*')) {
            return response()->json([
                'success' => true,
                'data' => $notifications
            ]);
        }

        return view('utilisateur.notifications', compact('notifications'));
    }

    public function markNotificationAsRead($id)
    {
        $notification = auth()->user()->notifications()->findOrFail($id);
        $notification->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'unread_count' => auth()->user()->unreadNotificationsCount()
        ]);
    }

    public function markAllNotificationsAsRead()
    {
        auth()->user()->notifications()->unread()->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'unread_count' => 0
        ]);
    }

    public function getUnreadNotificationsCount()
    {
        return response()->json([
            'count' => auth()->user()->unreadNotificationsCount()
        ]);
    }

    public function getRecentNotifications()
    {
        $notifications = auth()->user()->notifications()
            ->recent()
            ->take(3)
            ->get();

        return response()->json([
            'notifications' => $notifications
        ]);
    }

    public function virements(Request $request)
    {
        $userId = Auth()->User()->id;

        if ($request->expectsJson() || $request->is('api/*')) {
            // Mobile : 25 par défaut, pagination via ?page= pour « Voir plus ».
            $perPage = (int) $request->query('per_page', 25);
            $perPage = min(max($perPage, 1), 100);
            $virements = Virement::where('user_id', $userId)
                ->orderByDesc('created_at')
                ->paginate($perPage);

            return response()->json([
                'success' => true,
                'data' => $virements,
            ]);
        }

        $virements = Virement::where('user_id', $userId)
            ->orderByDesc('created_at')
            ->paginate(5);

        return view('utilisateur.virements', compact('virements'));
    }

    public function finalisation($id)
    {
        $virement = Virement::findOrFail($id);
        return view('utilisateur.finalisation', compact('virement'));
    }

    public function virementProgress(Request $request, $id)
    {
        // Vérifier que l'utilisateur est authentifié
        if (!auth()->check()) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Veuillez vous connecter pour accéder à cette page.'
                ], 401);
            }
            return redirect()->route('login')->with('error', 'Veuillez vous connecter pour accéder à cette page.');
        }
        
        $virement = Virement::findOrFail($id);
        
        // S'assurer que l'utilisateur est propriétaire du virement
        // Comparer en convertissant en int pour éviter les problèmes de type
        $virementUserId = (int)$virement->user_id;
        $currentUserId = (int)auth()->id();
        
        if ($virementUserId !== $currentUserId) {
            \Log::error("Tentative d'accès non autorisé au virement {$id}. User ID virement: {$virementUserId}, User ID actuel: {$currentUserId}");
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Accès non autorisé. Ce virement ne vous appartient pas.',
                    'slug' => $virement->slug,
                ], 403);
            }
            abort(403, 'Accès non autorisé. Ce virement ne vous appartient pas.');
        }
        
        if ($request->expectsJson() || $request->is('api/*')) {
            return response()->json([
                'success' => true,
                'data' => $virement
            ]);
        }
        
        return view('utilisateur.virement-progress', compact('virement'));
    }
    

    public function confirmVirement(Request $request, $id)
    {
        $virement = Virement::findOrFail($id);
        
        // Vérifier que l'utilisateur est propriétaire du virement
        // Comparer en convertissant en int pour éviter les problèmes de type
        if ((int)$virement->user_id !== (int)auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Accès non autorisé',
                'slug' => $virement->slug,
            ], 403);
        }
        
        // Verify confirmation code
        if ($request->code !== $virement->code) {
            return response()->json([
                'success' => false,
                'message' => 'Code de confirmation invalide',
                'slug' => $virement->slug,
            ], 422);
        }

        // Update progress percentage selon la séquence : 45 -> 60 -> 89 -> 95 -> 99
        $currentProgress = (int)$virement->pourcentage;
        $newProgress = 60; // Par défaut

        if ($currentProgress === 45) {
            $newProgress = 60;
        } else if ($currentProgress === 60) {
            $newProgress = 89;
        } else if ($currentProgress === 89) {
            $newProgress = 95;
        } else if ($currentProgress === 95) {
            $newProgress = 99;
        } else {
            $newProgress = $currentProgress; // Garder le même si déjà à 99% ou autre
        }

        // Generate new confirmation code (toujours générer un code, même à 99%)
        $newCode = strtoupper('VTG-' . substr(mt_rand(100000, 999999), 0, 6));

        $virement->update([
            'pourcentage' => $newProgress,
            'statut' => $newProgress >= 99 ? 'termine' : 'en_cours',
            'code' => $newCode
        ]);

        return response()->json([
            'success' => true,
            'progress' => $newProgress,
            'montant' => $virement->montant,
            'slug' => $virement->slug,
            'redirect_url' => "/virement-finalisation-success?montant=" .$virement->montant,
        ]);
    }

    public function success()
    {
        return view('utilisateur.success');
    }

    public function virementSuccess()
    {
        return view('utilisateur.success-code');
    }

    private function historiqueLooksLikeVirement(object $h): bool
    {
        $title = mb_strtolower((string) ($h->titre ?? ''));

        return str_contains($title, 'virement vers')
            || str_contains($title, 'transfert');
    }

    /**
     * @param  \Illuminate\Support\Collection<int, object>  $virements
     */
    private function matchVirementForHistorique($virements, object $h): ?object
    {
        $amount = $this->normalizeHistoriqueAmount($h->montant ?? 0);
        if ($amount <= 0) {
            return null;
        }

        $candidates = $virements->filter(function ($v) use ($amount) {
            return abs($this->normalizeHistoriqueAmount($v->montant ?? 0) - $amount) < 0.01;
        });

        if ($candidates->isEmpty()) {
            return null;
        }

        $hTs = strtotime((string) ($h->created_at ?? $h->date_transaction ?? ''));
        if ($hTs === false) {
            return $candidates->sortByDesc('created_at')->first();
        }

        return $candidates->sortBy(function ($v) use ($hTs) {
            $vTs = strtotime((string) ($v->created_at ?? ''));
            if ($vTs === false) {
                return PHP_INT_MAX;
            }

            return abs($vTs - $hTs);
        })->first();
    }

    private function normalizeHistoriqueAmount(mixed $montant): float
    {
        if (is_numeric($montant)) {
            return (float) $montant;
        }
        $s = preg_replace('/[^\d.,-]/', '', (string) $montant) ?? '';
        $s = str_replace(',', '.', $s);

        return (float) $s;
    }

}
