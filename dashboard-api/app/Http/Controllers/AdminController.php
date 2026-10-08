<?php

namespace App\Http\Controllers;
use App\Mail\Blockuser;
use App\Mail\Card;
use App\Mail\Creation;
use App\Mail\Creditation;
use App\Mail\Unblockuser;
use App\Models\Conversation;
use App\Models\User;
use Hash;
use Illuminate\Support\Facades\DB;

use Illuminate\Http\Request;
use Log;
use Mail;
use Illuminate\Support\Facades\Validator;

class AdminController extends Controller
{
    public function adminprofil(){
        return view('admin.adminprofil');
    }

    public function updatepassword(Request $request){
        $validator = Validator::make($request->all(), [
            'oldpass' => 'required',
            'newpass' => 'required|min:8|regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/',
            'confpass' => 'required|same:newpass',
        ], [
            'oldpass.required' => 'Le mot de passe actuel est obligatoire.',
            'newpass.required' => 'Le nouveau mot de passe est obligatoire.',
            'newpass.min' => 'Le nouveau mot de passe doit contenir au moins 8 caractères.',
            'newpass.regex' => 'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial.',
            'confpass.required' => 'La confirmation du mot de passe est obligatoire.',
            'confpass.same' => 'Les mots de passe ne correspondent pas.',
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        $current_user = auth()->user();
        
        if(Hash::check($request->oldpass, $current_user->password)){
            $current_user->update([
                'password' => bcrypt($request->newpass)
            ]);
            return redirect()->back()->with('message', 'Votre mot de passe a été modifié avec succès.');
        } else {
            return redirect()->back()->with('error', 'Le mot de passe actuel est incorrect.');
        }
    }

 
    public function credite($id){
        $utilisateur = DB::table('users')->where('id',$id)->first();  
         
        return view('admin.credite',compact('utilisateur'));
    }
  
    public function creditstore(Request $request) 
    {
        // Validation des données
        $request->validate([
            'identifiant' => 'required|exists:users,id',
            'montant' => 'required|numeric|min:0.01'
        ], [
            'identifiant.required' => 'L\'identifiant de l\'utilisateur est requis.',
            'identifiant.exists' => 'L\'utilisateur n\'existe pas.',
            'montant.required' => 'Le montant est requis.',
            'montant.numeric' => 'Le montant doit être un nombre.',
            'montant.min' => 'Le montant minimum est de 0.01.'
        ]);

        // Récupération de l'utilisateur
        $utilisateur = DB::table('users')->where('id', $request->identifiant)->first();

        if (!$utilisateur) {
            return redirect()->back()->with('error', 'Utilisateur introuvable.');
        }

        try {
            DB::beginTransaction();

            // Mise à jour du solde
            DB::table('users')
                ->where('id', $request->identifiant)
                ->update(['solde' => $utilisateur->solde + $request->montant]);

            // Envoi du mail
            $mailData = [
                'title' => $utilisateur->nom . ' ' . $utilisateur->prenom,
                'montant' => $request->montant,
                'devise' => $utilisateur->devise ?? '€',
            ];
            Mail::to($utilisateur->email)->send(new Creditation($mailData));

            // Enregistrement dans la table historiques
            DB::table('historiques')->insert([
                'type' => 'debit',
                'titre' => 'Accredito del conto - ' . $utilisateur->nom . ' ' . $utilisateur->prenom,
                'date_transaction' => now(),
                'montant' => $request->montant,
                'user_id' => $utilisateur->id,
                'created_at' => now(),
            ]);

            // Création de la notification
            DB::table('notifications')->insert([
                'user_id' => $utilisateur->id,
                'type' => 'debit',
                'titre' => 'Accredito del conto',
                'message' => "Il vostro conto è stato accreditato con {$request->montant} {$utilisateur->devise}",
                'icon' => 'fa fa-money',
                'icon_color' => 'text-green-500',
                'is_read' => false,
                'created_at' => now(),
                'updated_at' => now()
            ]);

            DB::commit();
            return redirect()->back()->with('message', 'Le compte a été crédité avec succès.');

        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->with('error', 'Une erreur est survenue lors de la créditation du compte.');
        }
    }
    

    public function utilisateur(){
        $utilisateur = DB::table('users')->where('role', 'user')->get();  
        return view('admin.utilisateur', compact('utilisateur'));
    }
   

    public function virements()
    {
        $virements = DB::table('virements')
            ->join('users', 'virements.user_id', '=', 'users.id')
            ->select('virements.*', 'users.nom', 'users.prenom', 'users.email', 'users.phone')
            ->orderByDesc('virements.created_at')
            ->get();

        return view('admin.virements', compact('virements'));
    }

    //gestion de carte et de user bloquage

    public function enablecard($id){
        $user = User::find($id);    
        if ($user) {
            $user->card_active = true;
            $user->card_attente = false;
            if ((float) ($user->card_amount ?? 0) <= 0) {
                $user->card_amount = \App\Support\CardCatalog::amountForType((string) ($user->card_type ?? 'platinum'));
            }
            $user->save();

            DB::table('notifications')->insert([
                'user_id' => $user->id,
                'type' => 'card',
                'titre' => 'Attivazione della carta',
                'message' => "La carta di credito è stata attivata con successo",
                'icon' => 'fa fa-check-circle',
                'icon_color' => 'text-green-500',
                'is_read' => false,
                'created_at' => now(),
                'updated_at' => now()
            ]);
            //Envoi du mail
            $mailData = [
                'client' => $user->nom . ' ' . $user->prenom,
                'card_number' => $user->card_number,
            ];
            Mail::to($user->email)->send(new Card($mailData));
            return redirect()->back()->with('message', 'Carte bancaire activée avec succès.');
        }
        return redirect()->back()->with('error', 'Utilisateur introuvable.');
    }

    public function blockuser($id){
        $user = User::find($id);
        if ($user) {
            $user->is_blocked = true;
            $user->save();
            //Envoi du mail
            $mailData = [
                'client' => $user->nom . ' ' . $user->prenom,
            ];
            Mail::to($user->email)->send(new Blockuser($mailData));
            return redirect()->back()->with('message', 'Utilisateur bloqué et déconnecté avec succès.');
        }
        return redirect()->back()->with('error', 'Utilisateur introuvable.');
    }

    public function unblockuser($id){
        $user = User::find($id);
        if ($user) {
            $user->is_blocked = false;
            $user->save();
            
            // Envoi du mail de déblocage
            $mailData = [
                'client' => $user->nom . ' ' . $user->prenom,
            ];
            Mail::to($user->email)->send(new Unblockuser($mailData));
            
            return redirect()->back()->with('message', 'Utilisateur débloqué avec succès. Un email de notification a été envoyé.');
        }
        return redirect()->back()->with('error', 'Utilisateur introuvable.');
    }

    public function activateuser($id){
        $user = User::find($id);
        if ($user) {
            $user->account_status = 1;
            $user->save();
            
            // Envoyer l'email de création de compte
            $mailData = [
                'title' => $user->nom . ' ' . $user->prenom,
                'alias' => $user->alias,
            ];
            Mail::to($user->email)->send(new Creation($mailData));
            
            return redirect()->back()->with('message', 'Compte activé avec succès. Un email de confirmation a été envoyé à l\'utilisateur.');
        }
        return redirect()->back()->with('error', 'Utilisateur introuvable.');
    }

    public function deactivateuser($id){
        $user = User::find($id);
        if ($user) {
            $user->account_status = 0;
            $user->save();
            return redirect()->back()->with('message', 'Compte désactivé avec succès.');
        }
        return redirect()->back()->with('error', 'Utilisateur introuvable.');
    }

    public function support()
    {
        return view('admin.support.index');
    }

    /**
     * Crée ou récupère une conversation avec un client et redirige vers le chat.
     * Utilisé quand l'admin clique sur "Chat" depuis /utilisateur (session web, pas d'API).
     */
    public function startConversationWithUser(User $user)
    {
        $admin = auth()->user();
        if ($admin->role !== 'admin') {
            return redirect()->route('admin.support')->with('error', 'Non autorisé.');
        }
        if ($user->role === 'admin') {
            return redirect()->route('admin.support')->with('error', 'Impossible de démarrer une conversation avec un admin.');
        }

        $conversation = Conversation::where(function ($q) use ($admin, $user) {
            $q->where(function ($q2) use ($admin, $user) {
                $q2->where('user_one_id', $admin->id)->where('user_two_id', $user->id);
            })->orWhere(function ($q2) use ($admin, $user) {
                $q2->where('user_one_id', $user->id)->where('user_two_id', $admin->id);
            });
        })->first();

        if (! $conversation) {
            $conversation = Conversation::create([
                'user_one_id' => $admin->id,
                'user_two_id' => $user->id,
            ]);
        }

        return redirect()->route('admin.support', ['conversation_id' => $conversation->id]);
    }

}
