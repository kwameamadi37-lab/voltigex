<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Mail\Creation;
use App\Providers\RouteServiceProvider;
use App\Models\User;
use Illuminate\Foundation\Auth\RegistersUsers;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Mail;
use Illuminate\Support\Facades\Http;

class RegisterController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | Register Controller
    |--------------------------------------------------------------------------
    |
    | This controller handles the registration of new users as well as their
    | validation and creation. By default this controller uses a trait to
    | provide this functionality without requiring any additional code.
    |
    */

    use RegistersUsers;

    /**
     * Where to redirect users after registration.
     *
     * @var string
     */
    protected $redirectTo = RouteServiceProvider::HOME;

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct() 
    {
        $this->middleware('guest');
    }

    /**
     * Get a validator for an incoming registration request.
     *
     * @param  array  $data
     * @return \Illuminate\Contracts\Validation\Validator
     */
    protected function validator(array $data)
    {
        return Validator::make($data, [
            'nom' => ['required', 'string', 'max:255'],
            'prenom' => ['required', 'string', 'max:255'],
            'profession' => ['required', 'string', 'max:255'],
            'date_naissance' => ['required', 'date'],
            'phone' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'string', 'min:8'],
            'fichier' => ['required'],
            'salaire' => ['required', 'numeric', 'min:0'],
        ], [
            'nom.required' => 'Le nom est requis',
            'nom.string' => 'Le nom doit être une chaîne de caractères',
            'nom.max' => 'Le nom ne doit pas dépasser 255 caractères',
            
            'prenom.required' => 'Le prénom est requis',
            'prenom.string' => 'Le prénom doit être une chaîne de caractères',
            'prenom.max' => 'Le prénom ne doit pas dépasser 255 caractères',
            
            'profession.required' => 'La profession est requise',
            'profession.string' => 'La profession doit être une chaîne de caractères',
            'profession.max' => 'La profession ne doit pas dépasser 255 caractères',
            
            'date_naissance.required' => 'La date de naissance est requise',
            'date_naissance.date' => 'La date de naissance doit être une date valide',
            
            'phone.required' => 'Le numéro de téléphone est requis',
            'phone.string' => 'Le numéro de téléphone doit être une chaîne de caractères',
            'phone.max' => 'Le numéro de téléphone ne doit pas dépasser 255 caractères',
            
            'email.required' => 'L\'email est requise',
            'email.string' => 'L\'email doit être une chaîne de caractères',
            'email.email' => 'L\'email doit être une adresse email valide',
            'email.max' => 'L\'email ne doit pas dépasser 255 caractères',
            'email.unique' => 'Cette adresse email est déjà utilisée',
            
            'password.required' => 'Le mot de passe est requis',
            'password.string' => 'Le mot de passe doit être une chaîne de caractères',
            'password.min' => 'Le mot de passe doit contenir au moins 8 caractères',
            
            'fichier.required' => 'Le document d\'identité est requis',
            
            'salaire.required' => 'Le salaire est requis',
            'salaire.numeric' => 'Le salaire doit être un nombre',
            'salaire.min' => 'Le salaire ne peut pas être négatif',
        ]
        );
    }

    /**
     * Create a new user instance after a valid registration.
     *
     * @param  array  $data
     * @return \App\Models\User
     */ 
    protected function create(array $data)
    {
        $attestation = request()->file('fichier');  
        $attestationName = time().'.'.$attestation->getClientOriginalExtension();
        $attestation->move(public_path('documents/fichiers'), $attestationName);
        $actualPath = '/documents/fichiers/'.$attestationName;

        $date = date('ymd');
        $rand = strtoupper(substr(str_shuffle('ABCDEFGHIJKLMNOPQRSTUVWXYZ'), 0, 3));
        $alias = 'USR-' . $date . '-' . $rand;

        // Génération des informations bancaires
        $cardNumber = $this->generateCardNumber();
        $dateExp = now()->addYears(4)->format('Y-m-d');
        $cvv = str_pad(rand(0, 999), 3, '0', STR_PAD_LEFT);
        $iban = $this->generateIBAN();
        $bic = $this->generateBIC();
        $numeroBancaire = $this->generateBankAccountNumber();

        // Détection de l'IP et du pays lors de l'inscription
        $ip = request()->ip();
        $country = $this->getCountryFromIP($ip);

        // Préparation des données pour l'email
        $mailData = [  
            'title' => $data['nom']. ' '.$data['prenom'],
            'alias' => $alias,
        ];    

        try {
            Mail::to($data['email'])->send(new Creation($mailData));
        } catch (\Exception $e) {
            \Log::error("Erreur lors de l'envoi de l'email: " . $e->getMessage());
        }

        $user = User::create([
            'role' => 'user',
            'nom' => $data['nom'],
            'prenom' => $data['prenom'],
            'profession' => $data['profession'],
            'date_naissance' => $data['date_naissance'],
            'phone' => $data['phone'],
            'alias' => $alias,
            'numero_bancaire' => $numeroBancaire,
            'card_number' => $cardNumber,
            'iban' => $iban,
            'bic' => $bic,
            'date_exp' => $dateExp,
            'cvv' => $cvv,
            'solde' => 0,
            'salaire' => $data['salaire'],
            'piece_recto' => $actualPath,
            'piece_verso' => $actualPath,
            'email' => $data['email'],
            'devise' => '€',
            'card_active' => false,
            'password' => Hash::make($data['password']),
            'ip_address' => $ip,
            'last_ip_address' => $ip,
            'country' => $country,
            'last_country' => $country,
            'is_blocked' => false,
            'is_online' => true,
        ]);

        // Redirection vers le tableau de bord après l'inscription
        return $user;
    }

    private function generateCardNumber()
    {
        $prefix = '4'; // Pour Visa
        $number = $prefix;
        for ($i = 0; $i < 15; $i++) {
            $number .= rand(0, 9);
        }
        return $number;
    }

    private function generateIBAN()
    {
        $countryCode = 'ES';
        $bankCode = str_pad(rand(10000, 99999), 5, '0', STR_PAD_LEFT);
        $branchCode = str_pad(rand(10000, 99999), 5, '0', STR_PAD_LEFT);
        $accountNumber = str_pad(rand(10000000000, 99999999999), 11, '0', STR_PAD_LEFT);
        $key = str_pad(rand(0, 99), 2, '0', STR_PAD_LEFT);
        
        return $countryCode . $key . $bankCode . $branchCode . $accountNumber;
    }

    private function generateBIC()
    {
        $bankCode = strtoupper(substr(str_shuffle('ABCDEFGHIJKLMNOPQRSTUVWXYZ'), 0, 4));
        $countryCode = 'ES';
        $locationCode = strtoupper(substr(str_shuffle('ABCDEFGHIJKLMNOPQRSTUVWXYZ'), 0, 2));
        $branchCode = strtoupper(substr(str_shuffle('ABCDEFGHIJKLMNOPQRSTUVWXYZ'), 0, 3));
        
        return $bankCode . $countryCode . $locationCode . $branchCode;
    }

    private function generateBankAccountNumber()
    {
        // Format RIB français : BBBBB AAAAA CCCCCCCCCCC KK
        // B = code banque (5 chiffres)
        // A = code agence (5 chiffres)
        // C = numéro de compte (11 chiffres)
        // K = clé RIB (2 chiffres)
        
        $codeBanque = str_pad(rand(10000, 99999), 5, '0', STR_PAD_LEFT);
        $codeAgence = str_pad(rand(10000, 99999), 5, '0', STR_PAD_LEFT);
        $numeroCompte = str_pad(rand(10000000000, 99999999999), 11, '0', STR_PAD_LEFT);
        
        // Calcul de la clé RIB
        $concat = $codeBanque . $codeAgence . $numeroCompte;
        $cle = 97 - ($this->modulo97($concat));
        $cle = str_pad($cle, 2, '0', STR_PAD_LEFT);
        
        return $codeBanque . $codeAgence . $numeroCompte . $cle;
    }

    private function modulo97($number) {
        $number = str_split($number);
        $remainder = 0;
        foreach ($number as $digit) {
            $remainder = ($remainder * 10 + $digit) % 97;
        }
        return $remainder;
    }

    private function getCountryFromIP($ip)
    {
        try {
            $response = Http::get("http://ip-api.com/json/{$ip}");
            if ($response->successful()) {
                $data = $response->json();
                return $data['country'] ?? null;
            }
        } catch (\Exception $e) {
            \Log::error("Erreur lors de la détection du pays: " . $e->getMessage());
        }
        return null;
    }
}
