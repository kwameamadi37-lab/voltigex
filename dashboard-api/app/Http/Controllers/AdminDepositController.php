<?php

namespace App\Http\Controllers;

use App\Mail\Creditation;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;

class AdminDepositController extends Controller
{
    /** @return array<string, string> */
    public static function depositTypeLabels(): array
    {
        return [
            'activation_carte' => 'Activation carte',
            'credit_manuel' => 'Crédit manuel',
            'remboursement' => 'Remboursement',
            'autre' => 'Autre',
        ];
    }

    public function create()
    {
        $users = User::query()
            ->where('role', 'user')
            ->orderBy('nom')
            ->orderBy('prenom')
            ->get(['id', 'nom', 'prenom', 'email', 'devise']);

        $depositTypes = self::depositTypeLabels();

        return view('admin.deposits', compact('users', 'depositTypes'));
    }

    public function store(Request $request)
    {
        $types = array_keys(self::depositTypeLabels());

        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'deposit_type' => 'required|string|in:'.implode(',', $types),
            'montant' => 'required|numeric|min:0.01',
            'libelle' => 'nullable|string|max:200',
        ]);

        $user = User::query()->whereKey($validated['user_id'])->where('role', 'user')->first();
        if (! $user) {
            return redirect()->back()->withInput()->with('error', 'Client introuvable.');
        }

        $labels = self::depositTypeLabels();
        $typeKey = $validated['deposit_type'];
        $typeLabel = $labels[$typeKey] ?? $typeKey;
        if ($typeKey === 'autre' && ! empty(trim($validated['libelle'] ?? ''))) {
            $typeLabel = trim($validated['libelle']);
        }

        $montant = (float) $validated['montant'];
        $titre = $typeLabel.' — '.$user->nom.' '.$user->prenom;

        try {
            DB::beginTransaction();

            $user->solde = (float) $user->solde + $montant;
            $user->save();

            DB::table('historiques')->insert([
                'type' => 'depot',
                'titre' => $titre,
                'date_transaction' => now(),
                'montant' => $montant,
                'user_id' => $user->id,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            DB::table('notifications')->insert([
                'user_id' => $user->id,
                'type' => 'depot',
                'titre' => 'Dépôt sur votre compte',
                'message' => "Votre compte a été crédité de {$montant} ".($user->devise ?? '€')." ({$typeLabel}).",
                'icon' => 'fa fa-money',
                'icon_color' => 'text-green-500',
                'is_read' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            DB::commit();

            $mailData = [
                'title' => $user->nom.' '.$user->prenom,
                'montant' => $montant,
                'devise' => $user->devise ?? '€',
            ];
            if (filter_var($user->email, FILTER_VALIDATE_EMAIL)) {
                Mail::to($user->email)->send(new Creditation($mailData));
            }

            return redirect()->route('admin.deposits')->with(
                'message',
                "Dépôt enregistré : {$montant} ".($user->devise ?? '€')." pour {$user->prenom} {$user->nom} ({$typeLabel})."
            );
        } catch (\Throwable $e) {
            DB::rollBack();

            return redirect()->back()->withInput()->with(
                'error',
                'Erreur lors de l’enregistrement du dépôt.'
            );
        }
    }
}
