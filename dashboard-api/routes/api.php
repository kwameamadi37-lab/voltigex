<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthApiController;
use App\Http\Controllers\AppController;
use App\Http\Controllers\UtilisateurController;
use App\Http\Controllers\VirementController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\UserFcmTokenController;
use App\Http\Controllers\Api\PublicConfigController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::get('/public/app-config', [PublicConfigController::class, 'show']);

// Routes utilitaires (protégées : l'app mobile envoie le token Sanctum)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user-info/{id}', [AppController::class, 'getUserInfo']);
    Route::get('/user-account/{id}/status', [AppController::class, 'getAccountStatus']);
    Route::post('/user/{id}/card/activate', [AppController::class, 'activateCard']);
});

// Routes d'authentification publiques
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthApiController::class, 'register']);
    Route::post('/register/photo', [AuthApiController::class, 'uploadPhoto']);
    Route::post('/verify', [AuthApiController::class, 'verify']);
    Route::post('/resend-code', [AuthApiController::class, 'resendCode']);
    Route::post('/login', [AuthApiController::class, 'login']);
    Route::post('/mobile-login', [AppController::class, 'mobileLogin']);
});

// Routes d'authentification protégées
Route::middleware('auth:sanctum')->prefix('auth')->group(function () {
    Route::post('/logout', [AuthApiController::class, 'logout']);
    Route::post('/logout-all', [AuthApiController::class, 'logoutAll']);
});


// Routes utilisateur protégées
Route::middleware('auth:sanctum')->prefix('user')->group(function () {
    Route::get('/', [UtilisateurController::class, 'me']);
    // Profil (web / legacy)
    Route::put('/profile', [UtilisateurController::class, 'profilstore']);
    Route::put('/contact', [UtilisateurController::class, 'updateContact']);
    Route::put('/identity', [UtilisateurController::class, 'updateIdentity']);
    Route::put('/address', [UtilisateurController::class, 'updateAddress']);
    Route::put('/password', [UtilisateurController::class, 'updatepassword']);
    
    // Notifications
    Route::get('/notifications', [UtilisateurController::class, 'notifications']);
    Route::post('/notifications/{id}/read', [UtilisateurController::class, 'markNotificationAsRead']);
    Route::post('/notifications/mark-all-read', [UtilisateurController::class, 'markAllNotificationsAsRead']);
    Route::get('/notifications/count', [UtilisateurController::class, 'getUnreadNotificationsCount']);
    Route::get('/notifications/recent', [UtilisateurController::class, 'getRecentNotifications']);
    Route::post('/fcm-token', [UserFcmTokenController::class, 'store']);
    
    // Historique et données utilisateur
    Route::get('/dashboard', [UtilisateurController::class, 'carte']); // virements + historiques
    Route::get('/transactions', [UtilisateurController::class, 'transactionsHistoriques']);
    Route::get('/virements', [UtilisateurController::class, 'virements']);

    Route::get('/card-details', [AppController::class, 'getCardDetailsForMobile']);
    Route::post('/card/freeze', [AppController::class, 'freezeCard']);
    Route::delete('/card', [AppController::class, 'deleteCard']);
});

// Routes virements protégées
Route::middleware('auth:sanctum')->prefix('virements')->group(function () {
    Route::post('/', [VirementController::class, 'virementstore']);
    Route::get('/{id}/progress', [UtilisateurController::class, 'virementProgress'])->name('virement.progress');
    Route::get('/progress/{id}', [UtilisateurController::class, 'virementProgress']);
    Route::post('/{id}/confirm', [UtilisateurController::class, 'confirmVirement']);
});

// Route activation carte protégée
Route::middleware('auth:sanctum')->prefix('card')->group(function () {
    Route::post('/activate', [VirementController::class, 'activationStore']);
});


// Routes de chat protégées (support / messagerie)
Route::middleware('auth:sanctum')->prefix('chat')->group(function () {
    Route::get('/users/contacts', [ChatController::class, 'listContactsForChat']);
    Route::get('/users/search', [ChatController::class, 'searchUsersForChat']);
    Route::post('/messages/create-and-send', [ChatController::class, 'createConversationAndSendMessage']);
    Route::get('/conversations', [ChatController::class, 'getConversations']);
    Route::get('/conversations/with-support', [ChatController::class, 'getSupportConversation']);
    Route::get('/conversations/with-user/{user}', [ChatController::class, 'getOrCreateConversationWithUser']);
    Route::get('/conversations/{conversation}', [ChatController::class, 'getMessages']);
    Route::patch('/conversations/{conversation}/read', [ChatController::class, 'markConversationRead']);
    Route::post('/conversations/{conversation}/typing', [ChatController::class, 'broadcastTyping']);
    Route::post('/messages', [ChatController::class, 'sendMessage']);
    Route::post('/messages/upload', [ChatController::class, 'uploadMedia']);
});


//******************Here all functiuns you need for your mobile interface */

// --- 1-Connexion d'un utilisateur mobile ---
