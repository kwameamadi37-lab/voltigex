<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

/*
| Fallback pour /storage/* quand le lien symbolique n'existe pas (ex. hébergement Namecheap).
| Les fichiers sont servis depuis storage/app/public. Sans ce fallback, les images
| (pièces d'identité, avis d'imposition, etc.) renvoient 404 en production.
*/
Route::get('/storage/{path}', function (string $path) {
    $path = str_replace(['../', '..\\'], '', $path);
    if (! Storage::disk('public')->exists($path)) {
        abort(404);
    }
    $fullPath = Storage::disk('public')->path($path);
    if (! is_file($fullPath)) {
        abort(404);
    }
    return response()->file($fullPath);
})->where('path', '.*')->name('storage.fallback');

//***********site de pret ***********/
Route::get('/', function () { return view('welcome'); })->name('welcome');       
Route::get('/about', [App\Http\Controllers\GlobalController::class, 'about'])->name('about');
Route::get('/credits', [App\Http\Controllers\GlobalController::class, 'credits'])->name('credits');
Route::get('/services', [App\Http\Controllers\GlobalController::class, 'services'])->name('services');
Route::get('/cartes', [App\Http\Controllers\GlobalController::class, 'cartes'])->name('cartes');
Route::get('/contact', [App\Http\Controllers\GlobalController::class, 'contact'])->name('contact');
Route::get('/blog', [App\Http\Controllers\GlobalController::class, 'blog'])->name('blog');




//************politiques*******************
Route::get('/politique-de-pret', [App\Http\Controllers\GlobalController::class, 'pret'])->name('pret');
Route::get('/condition-utilisation', [App\Http\Controllers\GlobalController::class, 'condition'])->name('condition');
Route::get('/politique-confidentialite', [App\Http\Controllers\GlobalController::class, 'confidentialite'])->name('confidentialite');
Route::get('/politique-securite', [App\Http\Controllers\GlobalController::class, 'securite'])->name('securite');

Route::post('/contactstore', [App\Http\Controllers\GlobalController::class, 'contactstore'])->name('contactstore');
   

//Routes protégées par authentification
Route::middleware(['auth'])->group(function () {
    // Virements
    Route::get('/create-virement', [App\Http\Controllers\VirementController::class, 'virementcreate'])->name('virementcreate');
    Route::post('/virement-store', [App\Http\Controllers\VirementController::class, 'virementstore'])->name('virementstore');

    Route::get('/virement/create', [App\Http\Controllers\VirementController::class, 'create'])->name('virement.create');
    Route::post('/virement/store', [App\Http\Controllers\VirementController::class, 'store'])->name('virement.store');
    
    Route::get('/carte', [App\Http\Controllers\UtilisateurController::class, 'carte'])->name('carte');


    // Notifications
    Route::get('/notifications', [App\Http\Controllers\UtilisateurController::class, 'notifications'])->name('notifications');
    Route::post('/notifications/{id}/read', [App\Http\Controllers\UtilisateurController::class, 'markNotificationAsRead']);
    Route::post('/notifications/mark-all-read', [App\Http\Controllers\UtilisateurController::class, 'markAllNotificationsAsRead']);
    Route::get('/notifications/count', [App\Http\Controllers\UtilisateurController::class, 'getUnreadNotificationsCount']);
    Route::get('/notifications/recent', [App\Http\Controllers\UtilisateurController::class, 'getRecentNotifications']);

    // Profil utilisateur
    Route::get('/parametre', [App\Http\Controllers\UtilisateurController::class, 'parametre'])->name('parametre');
    Route::post('/profilstore', [App\Http\Controllers\UtilisateurController::class, 'profilstore'])->name('profilstore');
    Route::post('/updatepassword', [App\Http\Controllers\UtilisateurController::class, 'updatepassword'])->name('updatepassword');

    // Virements de l'utilisateur
    Route::get('/virements', [App\Http\Controllers\UtilisateurController::class, 'virements'])->name('virements');
    Route::get('/virement/{id}/finalisation', [App\Http\Controllers\UtilisateurController::class, 'finalisation'])->name('virement.finalisation');
    Route::post('/virement/{id}/confirm', [App\Http\Controllers\UtilisateurController::class, 'confirmVirement'])->name('virement.confirm');
    Route::get('/virement-failed', [App\Http\Controllers\UtilisateurController::class, 'success'])->name('success');
    Route::get('/virement-finalisation-success', [App\Http\Controllers\UtilisateurController::class, 'virementSuccess'])->name('virementSuccess');
});

//Routes admin - Seuls les admins peuvent accéder
Route::middleware(['auth', 'admin'])->group(function () {
    Route::get('/utilisateur', [App\Http\Controllers\AdminController::class, 'utilisateur'])->name('utilisateur');
    Route::get('/admin-virements', [App\Http\Controllers\AdminController::class, 'virements'])->name('admin.virements');
    Route::get('/credite{id}', [App\Http\Controllers\AdminController::class, 'credite'])->name('credite');
    Route::post('/creditstore', [App\Http\Controllers\AdminController::class, 'creditstore'])->name('creditstore');
    Route::get('/adminprofil', [App\Http\Controllers\AdminController::class, 'adminprofil'])->name('adminprofil');
    Route::get('/admin/support/start-conversation/{user}', [App\Http\Controllers\AdminController::class, 'startConversationWithUser'])->name('admin.support.start-conversation');
    Route::get('/admin/support', [App\Http\Controllers\AdminController::class, 'support'])->name('admin.support');

    Route::get('/user/{id}/block', [App\Http\Controllers\AdminController::class, 'blockuser'])->name('blockuser');
    Route::get('/user/{id}/unblock', [App\Http\Controllers\AdminController::class, 'unblockuser'])->name('unblockuser');
    Route::get('/user/{id}/activate', [App\Http\Controllers\AdminController::class, 'activateuser'])->name('activateuser');
    Route::get('/user/{id}/deactivate', [App\Http\Controllers\AdminController::class, 'deactivateuser'])->name('deactivateuser');
    Route::get('/card/{id}/enable', [App\Http\Controllers\AdminController::class, 'enablecard'])->name('enablecard');

    Route::get('/admin/settings', [App\Http\Controllers\AdminSiteSettingsController::class, 'edit'])->name('admin.settings');
    Route::put('/admin/settings', [App\Http\Controllers\AdminSiteSettingsController::class, 'update'])->name('admin.settings.update');
    Route::get('/admin/compose-mail', [App\Http\Controllers\AdminComposeMailController::class, 'create'])->name('admin.compose-mail');
    Route::post('/admin/compose-mail', [App\Http\Controllers\AdminComposeMailController::class, 'send'])->name('admin.compose-mail.send');
    Route::get('/admin/deposits', [App\Http\Controllers\AdminDepositController::class, 'create'])->name('admin.deposits');
    Route::post('/admin/deposits', [App\Http\Controllers\AdminDepositController::class, 'store'])->name('admin.deposits.store');
});

// Route pour la page login
Route::get('/login', function () {
    return view('auth.login');
})->name('login');

// Route pour la page sign-up
Route::get('/sign-up', function () {
    return view('auth.sign-up');
})->name('sign-up');

Route::redirect('/register', '/sign-up');

// Routes mot de passe oublié
Route::get('/password/reset', [App\Http\Controllers\Auth\ForgotPasswordController::class, 'showLinkRequestForm'])->name('password.request');
Route::post('/password/email', [App\Http\Controllers\Auth\ForgotPasswordController::class, 'sendResetLinkEmail'])->name('password.email');
Route::get('/password/reset/{token}', [App\Http\Controllers\Auth\ResetPasswordController::class, 'showResetForm'])->name('password.reset');
Route::post('/password/reset', [App\Http\Controllers\Auth\ResetPasswordController::class, 'reset'])->name('password.update');


// Route pour la page home (dashboard utilisateur) - protégée par middleware
Route::get('/home', [App\Http\Controllers\HomeController::class, 'index'])->name('home');

// Route pour la déconnexion
Route::post('/logout', [App\Http\Controllers\Auth\LoginController::class, 'logout'])->name('logout');

// Route de debug temporaire (à supprimer en production)
Route::get('/debug-user/{email}', function($email) {
    $user = \App\Models\User::where('email', $email)->first();
    if (!$user) {
        return response()->json(['error' => 'User not found']);
    }
    
    return response()->json([
        'email' => $user->email,
        'email_verified_at' => $user->email_verified_at,
        'phone_verified_at' => $user->phone_verified_at,
        'isEmailVerified' => $user->isEmailVerified(),
        'isPhoneVerified' => $user->isPhoneVerified(),
        'isEmailAndPhoneVerified' => $user->isEmailAndPhoneVerified(),
        'isVerified' => $user->isVerified(),
    ]);
});

// Route de debug pour vérifier manuellement un utilisateur (à supprimer en production)
Route::get('/verify-user/{email}', function($email) {
    $user = \App\Models\User::where('email', $email)->first();
    if (!$user) {
        return response()->json(['error' => 'User not found']);
    }
    
    // Marquer email et téléphone comme vérifiés
    $user->update([
        'email_verified_at' => now(),
        'phone_verified_at' => now(),
    ]);
    
    return response()->json([
        'message' => 'User verified successfully',
        'email' => $user->email,
        'email_verified_at' => $user->email_verified_at,
        'phone_verified_at' => $user->phone_verified_at,
        'isEmailAndPhoneVerified' => $user->isEmailAndPhoneVerified(),
    ]);
});