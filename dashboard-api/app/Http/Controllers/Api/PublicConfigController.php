<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SiteSetting;

class PublicConfigController extends Controller
{
    public function show()
    {
        return response()->json([
            'success' => true,
            'data' => SiteSetting::publicConfig(),
        ]);
    }
}
