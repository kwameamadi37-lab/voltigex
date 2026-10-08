<?php

namespace App\Http\Controllers;

use App\Mail\Contact;
use App\Mail\ContactAdminMail;
use App\Mail\ContactConfirmation;
use App\Mail\Finance;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator; 
use Illuminate\Support\Facades\DB;

class GlobalController extends Controller
{
    public function about(){
        return view('about');
    }

    public function credits(){
        return view('credits');
    }

    public function services(){
        return view('services');
    }

    public function cartes(){
        $cardCatalog = collect(\App\Support\CardCatalog::all())->keyBy('key');

        return view('cartes', compact('cardCatalog'));
    }       

    public function contact(){
        return view('contact');
    }

    public function contactstore(Request $request)
    {
        // Valider les champs avec messages personnalisés
        $validated = $request->validate([
            'firstName' => 'required|string|max:255',
            'lastName' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'phone' => 'required|string|max:20',
            'subject' => 'required|string|max:255',
            'message' => 'required|string|min:10|max:5000',
        ], [
            'firstName.required' => 'Le prénom est requis.',
            'lastName.required' => 'Le nom est requis.',
            'email.required' => 'L\'email est requis.',
            'email.email' => 'L\'email doit être valide.',
            'phone.required' => 'Le numéro de téléphone est requis.',
            'subject.required' => 'Le sujet est requis.',
            'message.required' => 'Le message est requis.',
            'message.min' => 'Le message doit contenir au moins 10 caractères.',
            'message.max' => 'Le message ne doit pas dépasser 5000 caractères.',
        ]);

        // Définir les labels des sujets
        $subjectLabels = [
            'information' => 'Demande d\'information',
            'account' => 'Ouverture de compte',
            'support' => 'Support technique',
            'complaint' => 'Réclamation',
            'other' => 'Autre',
        ];

        // Préparer les données pour l'envoi de l'email à l'admin
        $adminMailData = [
            'firstName' => $request->input('firstName'),
            'lastName' => $request->input('lastName'),
            'email' => $request->input('email'),
            'phone' => $request->input('phone'),
            'subject' => $request->input('subject'),
            'subject_label' => $subjectLabels[$request->input('subject')] ?? $request->input('subject'),
            'message' => $request->input('message'),
            'date' => now()->format('d/m/Y à H:i'),
        ];

        // Préparer les données pour l'email de confirmation au client
        $clientMailData = [
            'firstName' => $request->input('firstName'),
            'lastName' => $request->input('lastName'),
            'subject' => $subjectLabels[$request->input('subject')] ?? $request->input('subject'),
        ];

        try {
            // Envoyer l'email à l'admin
            $adminEmail = config('mail.admin_email');
            Mail::to($adminEmail)->send(new \App\Mail\ContactAdminMail($adminMailData));

            // Envoyer l'email de confirmation au client
            Mail::to($request->input('email'))->send(new \App\Mail\ContactConfirmation($clientMailData));

            // Retourner une réponse JSON pour le formulaire AJAX
            if ($request->expectsJson() || $request->ajax()) {
                return response()->json([
                    'success' => true,
                    'message' => 'Votre message a été envoyé avec succès. Nous vous répondrons dans les plus brefs délais.'
                ], 200);
            }

            // Rediriger avec un message de succès
            return redirect()->back()->with('success', 'Votre message a été envoyé avec succès. Nous vous répondrons dans les plus brefs délais.');

        } catch (\Exception $e) {
            \Log::error('Erreur lors de l\'envoi de l\'email de contact: ' . $e->getMessage());

            if ($request->expectsJson() || $request->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Une erreur est survenue lors de l\'envoi de votre message. Veuillez réessayer plus tard.'
                ], 500);
            }

            return redirect()->back()->with('error', 'Une erreur est survenue lors de l\'envoi de votre message. Veuillez réessayer plus tard.');
        }
    }


    public function blog(){
        return view('blog');
    }

    public function politique(){
        return view('politique');
    }

    public function terme(){
        return view('terme');
    }

    //**************politiques */
    public function pret(){
        return view('politiques/pret');
    }

    public function condition(){
        return view('politiques/condition');
    }

    public function confidentialite(){
        return view('politiques/confidentialite');
    }

    public function securite(){
        return view('politiques/securite');
    }

}
