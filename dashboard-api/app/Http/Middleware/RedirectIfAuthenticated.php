<?php

namespace App\Http\Middleware;

use App\Mail\Authentificateur;
use App\Providers\RouteServiceProvider;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Mail;
use Illuminate\Support\Facades\DB; 

class RedirectIfAuthenticated
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @param  string|null  ...$guards
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next, $guard = null)
    {
        if (Auth::guard($guard)->check()) { 
            // Seuls les admins peuvent accéder au site web
            if(Auth::user()->role == "admin"){
                return redirect('/admin-virements');
            }
            else
            {
                // Déconnecter tous les non-admins
                Auth::logout(); 
                return redirect('login')->with('user_access_denied', true)
                                       ->with('message', 'L\'accès au site web est réservé aux administrateurs. Tous les clients doivent télécharger l\'application mobile pour se connecter et effectuer leurs transactions.');
            }
        }
        return $next($request);
    }
}
