<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Session;

class CheckSessionTimeout
{
    public function handle(Request $request, Closure $next)
    {
        if (Auth::check()) {
            $lastActivity = Session::get('last_activity');
            $timeout = 10 * 60; // 10 minutes en secondes

            if ($lastActivity && (time() - $lastActivity > $timeout)) {
                // Mettre à jour le statut en ligne avant la déconnexion
                Auth::user()->update(['is_online' => false]);
                
                // Déconnexion de l'utilisateur
                Auth::logout();
                Session::flush();

                // Redirection vers la page de connexion avec un message
                return redirect()->route('login')->with('session_expired', 'La sessione è scaduta a causa di una prolungata inattività. Si prega di riconnettersi.');
            }

            // Mettre à jour le timestamp de dernière activité
            Session::put('last_activity', time());
        }

        return $next($request);
    }
} 