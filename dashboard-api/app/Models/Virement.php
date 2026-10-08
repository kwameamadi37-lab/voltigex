<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Virement extends Model
{
    use HasFactory;

    protected $fillable = [
        'slug',
        'nom',
        'prenom',
        'iban',
        'bic',
        'code',
        'pourcentage',
        'numerobancaire',
        'titulairebanque',
        'nombanque',
        'statut',
        'montant',
        'user_id',
    ];

    /**
     * Identifiant support public unique, format XXXX-XXXX (sans 0/O et 1/I ambigus).
     */
    public static function generateUniquePublicSlug(): string
    {
        $alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
        do {
            $a = $b = '';
            for ($i = 0; $i < 4; $i++) {
                $a .= $alphabet[random_int(0, strlen($alphabet) - 1)];
            }
            for ($i = 0; $i < 4; $i++) {
                $b .= $alphabet[random_int(0, strlen($alphabet) - 1)];
            }
            $slug = $a.'-'.$b;
        } while (static::where('slug', $slug)->exists());

        return $slug;
    }
}
