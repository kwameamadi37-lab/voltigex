<?php

namespace App\Http\Controllers;

use App\Mail\BrandedBroadcastMail;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;

class AdminComposeMailController extends Controller
{
    public function create()
    {
        $users = User::query()
            ->where('role', 'user')
            ->orderBy('nom')
            ->orderBy('prenom')
            ->get(['id', 'nom', 'prenom', 'email']);

        return view('admin.compose-mail', compact('users'));
    }

    public function send(Request $request)
    {
        $validated = $request->validate([
            'subject' => 'required|string|max:200',
            'body' => 'required|string|max:50000',
            'audience' => 'required|in:all,single',
            'user_id' => 'required_if:audience,single|nullable|exists:users,id',
        ]);

        $subject = $validated['subject'];
        $bodyHtml = nl2br(e($validated['body']));

        $recipients = $validated['audience'] === 'all'
            ? User::query()->where('role', 'user')->whereNotNull('email')->get()
            : User::query()->whereKey($validated['user_id'])->get();

        $sent = 0;
        foreach ($recipients as $user) {
            if (! filter_var($user->email, FILTER_VALIDATE_EMAIL)) {
                continue;
            }
            $name = trim(($user->prenom ?? '').' '.($user->nom ?? ''));
            Mail::to($user->email)->send(new BrandedBroadcastMail(
                $subject,
                $bodyHtml,
                $name !== '' ? $name : null,
            ));
            $sent++;
        }

        return redirect()->route('admin.compose-mail')
            ->with('message', "Email envoyé à {$sent} destinataire(s).");
    }
}
