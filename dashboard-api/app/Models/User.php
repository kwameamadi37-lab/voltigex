<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Mail\ResetPasswordMail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'role',
        'nom',
        'prenom',
        'phone',
        'alias',
        'numero_bancaire',
        'card_number',
        'iban',
        'bic',
        'date_exp',
        'cvv',
        'solde',
        'piece_identite',
        'avis_imposition',
        'photo_carte_identite',
        'account_status',
        'email',
        'devise',
        'card_active',
        'card_attente',
        'card_frozen',
        'card_amount',
        'card_type',
        'ip_address',
        'last_ip_address',
        'country',
        'address_line',
        'city',
        'postal_code',
        'date_naissance',
        'birth_date',
        'nationalite',
        'numero_identification',
        'last_country',
        'is_blocked',
        'is_online',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'cvv',
        'card_number',
        'numero_bancaire',
        'iban',
        'bic',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'phone_verified_at' => 'datetime',
        'date_exp' => 'date',
        'date_naissance' => 'date',
        'birth_date' => 'date',
        'solde' => 'decimal:2',
        'card_amount' => 'decimal:2',
        'card_active' => 'boolean',
        'card_attente' => 'boolean',
        'card_frozen' => 'boolean',
        'is_blocked' => 'boolean',
        'is_online' => 'boolean',
        'account_status' => 'integer',
    ];

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    public function unreadNotifications()
    {
        return $this->notifications()->unread();
    }

    public function unreadNotificationsCount()
    {
        return $this->unreadNotifications()->count();
    }

    /**
     * Relation avec les vérifications
     */
    public function verifications()
    {
        return $this->hasMany(UserVerification::class);
    }

    /**
     * Vérifier si l'utilisateur est complètement vérifié (email + téléphone)
     */
    public function isVerified()
    {
        return !is_null($this->email_verified_at) && 
               !is_null($this->phone_verified_at);
    }

    /**
     * Vérifier si l'email et le téléphone sont vérifiés (sans KYC)
     */
    public function isEmailAndPhoneVerified()
    {
        return !is_null($this->email_verified_at) && !is_null($this->phone_verified_at);
    }

    /**
     * Vérifier si l'email est vérifié
     */
    public function isEmailVerified()
    {
        return !is_null($this->email_verified_at);
    }

    /**
     * Vérifier si le téléphone est vérifié
     */
    public function isPhoneVerified()
    {
        return !is_null($this->phone_verified_at);
    }

    /**
     * Marquer l'email comme vérifié
     */
    public function markEmailAsVerified()
    {
        $this->update(['email_verified_at' => now()]);
    }

    /**
     * Marquer le téléphone comme vérifié
     */
    public function markPhoneAsVerified()
    {
        $this->update(['phone_verified_at' => now()]);
    }

    /**
     * Relation avec les documents
     */
    public function documents()
    {
        return $this->hasMany(UserDocument::class);
    }

    /**
     * Conversations où l'utilisateur est en position 1.
     */
    public function conversationsAsUserOne()
    {
        return $this->hasMany(Conversation::class, 'user_one_id');
    }

    /**
     * Conversations où l'utilisateur est en position 2.
     */
    public function conversationsAsUserTwo()
    {
        return $this->hasMany(Conversation::class, 'user_two_id');
    }

    /**
     * Toutes les conversations de l'utilisateur (query builder).
     */
    public function allConversations()
    {
        return Conversation::where('user_one_id', $this->id)
            ->orWhere('user_two_id', $this->id);
    }

    /**
     * Contacts de l'utilisateur (autres utilisateurs liés via la table contacts).
     */
    public function contacts()
    {
        return $this->belongsToMany(User::class, 'contacts', 'user_id', 'contact_id')
            ->withTimestamps();
    }

    public function fcmTokens()
    {
        return $this->hasMany(UserFcmToken::class);
    }

    /**
     * URL publique de la photo de profil (disque `public`), ou null.
     */
    public function profilePhotoPublicUrl(): ?string
    {
        $relative = $this->profile_photo_url ?? null;
        if ($relative === null || $relative === '') {
            return null;
        }
        $relative = ltrim((string) $relative, '/');

        return Storage::disk('public')->url($relative);
    }

    /**
     * Notification de reset mot de passe (charte Voltigex, plus le template Laravel par défaut).
     */
    public function sendPasswordResetNotification($token): void
    {
        $url = url(route('password.reset', [
            'token' => $token,
            'email' => $this->getEmailForPasswordReset(),
        ], false));

        Mail::to($this->email)->send(new ResetPasswordMail($this, $url));
    }

}

