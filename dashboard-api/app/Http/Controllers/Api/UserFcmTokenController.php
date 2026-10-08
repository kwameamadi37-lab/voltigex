<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserFcmToken;
use Illuminate\Http\Request;

class UserFcmTokenController extends Controller
{
    public function store(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'fcm_token' => ['required', 'string'],
            'device_type' => ['nullable', 'in:android,ios,web'],
        ]);

        $token = UserFcmToken::updateOrCreate(
            [
                'user_id' => $user->id,
                'fcm_token' => $validated['fcm_token'],
            ],
            [
                'device_type' => $validated['device_type'] ?? null,
            ]
        );

        return response()->json([
            'ok' => true,
            'id' => $token->id,
        ], 201);
    }
}
