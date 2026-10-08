<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class UserDocument extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'document_type',
        'file_path',
        'file_name',
        'original_name',
        'file_size',
        'mime_type',
        'upload_status',
        'rejection_reason',
        'metadata',
        'uploaded_at',
        'processed_at'
    ];

    protected $casts = [
        'metadata' => 'array',
        'uploaded_at' => 'datetime',
        'processed_at' => 'datetime',
    ];

    /**
     * Relation avec l'utilisateur
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Obtenir l'URL publique du document
     */
    public function getUrlAttribute()
    {
        return Storage::url($this->file_path);
    }

    /**
     * Vérifier si le document est approuvé
     */
    public function isApproved()
    {
        return $this->upload_status === 'approved';
    }

    /**
     * Vérifier si le document est rejeté
     */
    public function isRejected()
    {
        return $this->upload_status === 'rejected';
    }

    /**
     * Vérifier si le document est en cours de traitement
     */
    public function isProcessing()
    {
        return $this->upload_status === 'processing';
    }

    /**
     * Marquer comme approuvé
     */
    public function markAsApproved()
    {
        $this->update([
            'upload_status' => 'approved',
            'processed_at' => now()
        ]);
    }

    /**
     * Marquer comme rejeté
     */
    public function markAsRejected($reason = null)
    {
        $this->update([
            'upload_status' => 'rejected',
            'rejection_reason' => $reason,
            'processed_at' => now()
        ]);
    }

    /**
     * Marquer comme en cours de traitement
     */
    public function markAsProcessing()
    {
        $this->update(['upload_status' => 'processing']);
    }

    /**
     * Obtenir le type de document lisible
     */
    public function getDocumentTypeLabelAttribute()
    {
        $labels = [
            'cni_recto' => 'Carte d\'identité (recto)',
            'cni_verso' => 'Carte d\'identité (verso)',
            'passeport' => 'Passeport',
            'permis_conduire' => 'Permis de conduire',
            'justificatif_domicile' => 'Justificatif de domicile',
            'avis_imposition' => 'Avis d\'imposition',
            'bulletin_salaire' => 'Bulletin de salaire',
            'rib' => 'RIB',
            'selfie' => 'Photo de profil',
            'selfie_with_document' => 'Selfie avec document'
        ];

        return $labels[$this->document_type] ?? $this->document_type;
    }

    /**
     * Scope pour les documents approuvés
     */
    public function scopeApproved($query)
    {
        return $query->where('upload_status', 'approved');
    }

    /**
     * Scope pour les documents rejetés
     */
    public function scopeRejected($query)
    {
        return $query->where('upload_status', 'rejected');
    }

    /**
     * Scope pour les documents en attente
     */
    public function scopePending($query)
    {
        return $query->where('upload_status', 'pending');
    }

    /**
     * Scope pour un type de document spécifique
     */
    public function scopeOfType($query, $type)
    {
        return $query->where('document_type', $type);
    }
}
