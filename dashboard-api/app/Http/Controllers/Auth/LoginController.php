<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Providers\RouteServiceProvider;
use Illuminate\Foundation\Auth\AuthenticatesUsers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Lang;

class LoginController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | Login Controller
    |--------------------------------------------------------------------------
    |
    | This controller handles authenticating users for the application and
    | redirecting them to your home screen. The controller uses a trait
    | to conveniently provide its functionality to your applications.
    |
    */

    use AuthenticatesUsers;
    public function username()
    {
        return 'alias';
    }  
    /**
     * Where to redirect users after login.
     *
     * @var string
     */
    // protected $redirectTo = '/login';

    /**
     * Create a new controller instance. 
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('guest')->except('logout');
    }
    
    /**
     * Handle a login request to the application.
     *  
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse|\Illuminate\Http\Response|\Illuminate\Http\JsonResponse
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function login(Request $request)
    {
        $this->validateLogin($request);

        // Vérifier si le compte est bloqué
        $user = \App\Models\User::where('alias', $request->alias)->first();
        if ($user && $user->is_blocked) {
            return back()->with('account_blocked', 'Ce compte a été bloqué. Veuillez contacter support@voltigex.com pour plus d\'informations.');
        }

        // Refuser la connexion à tous les utilisateurs sauf les admins
        if ($user && $user->role !== 'admin') {
            return back()->with('user_access_denied', true)
                         ->with('message', 'L\'accès au site web est réservé aux administrateurs. Tous les clients doivent télécharger l\'application mobile pour se connecter et effectuer leurs transactions.');
        }

        if ($this->hasTooManyLoginAttempts($request)) {
            $this->fireLockoutEvent($request);
            return $this->sendLockoutResponse($request);
        }

        if ($this->attemptLogin($request)) {
            // Vérifier à nouveau le rôle après authentification réussie - seuls les admins sont autorisés
            $authenticatedUser = auth()->user();
            if ($authenticatedUser && $authenticatedUser->role !== 'admin') {
                $this->guard()->logout();
                return back()->with('user_access_denied', true)
                             ->with('message', 'L\'accès au site web est réservé aux administrateurs. Tous les clients doivent télécharger l\'application mobile pour se connecter et effectuer leurs transactions.');
            }
            return $this->sendLoginResponse($request);
        }

        $this->incrementLoginAttempts($request);

        return $this->sendFailedLoginResponse($request);
    }

    protected function redirectTo()
    {
        // Seuls les admins peuvent se connecter, donc toujours rediriger vers admin-virements
        return '/admin-virements';
    }

    /**
     * Get the failed login response instance.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Symfony\Component\HttpFoundation\Response
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    protected function sendFailedLoginResponse(Request $request)
    {
        throw \Illuminate\Validation\ValidationException::withMessages([
            'alias' => [trans('probleme de connexion.veuillez reesayer')],
        ]);
    }

    /**
     * Get the login lockout error message.
     *
     * @param  int  $seconds
     * @return string
     */
    protected function getLockoutErrorMessage($seconds)
    {
        return 'Trop de tentatives de connexion. Réessayer dans ' . $seconds . ' secondes.';
    }

    /**
     * The user has been authenticated.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  mixed  $user
     * @return mixed
     */
    protected function authenticated(Request $request, $user)
    {
        // Refuser la connexion à tous les utilisateurs sauf les admins - vérification après authentification
        if ($user->role !== 'admin') {
            // Déconnecter l'utilisateur immédiatement
            $this->guard()->logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();
            
            return redirect('/login')->with('user_access_denied', true)
                                   ->with('message', 'L\'accès au site web est réservé aux administrateurs. Tous les clients doivent télécharger l\'application mobile pour se connecter et effectuer leurs transactions.');
        }

        // Détection de l'IP et du pays
        $ip = $request->ip();
        $country = $this->getCountryFromIP($ip);

        // Mise à jour des informations de connexion
        $user->update([
            'last_ip_address' => $ip,
            'last_country' => $country,
            'is_online' => true
        ]);

        return redirect()->intended($this->redirectPath());
    }

    /**
     * Log the user out of the application.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function logout(Request $request)
    {
        // Mettre à jour le statut en ligne avant la déconnexion
        $user = auth()->user();
        if ($user) {
            try {
                $user->update(['is_online' => false]);
            } catch (\Exception $e) {
                // Ignorer l'erreur si l'utilisateur n'existe plus
                \Log::warning("Erreur lors de la mise à jour du statut en ligne: " . $e->getMessage());
            }
        }

        $this->guard()->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/login');
    }

    /**
     * Get country from IP address
     *
     * @param string $ip
     * @return string|null
     */
    private function getCountryFromIP($ip)
    {
        try {
            $response = Http::get("http://ip-api.com/json/{$ip}");
            if ($response->successful()) {
                $data = $response->json();
                return $data['country'] ?? null;
            }
        } catch (\Exception $e) {
            \Log::error("Erreur de détection du pays: " . $e->getMessage());
        }
        return null;
    }
}
