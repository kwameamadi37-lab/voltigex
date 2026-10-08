<?php

use App\Models\SiteSetting;
use Illuminate\Support\Facades\Storage;

if (! function_exists('site_setting')) {
    function site_setting(string $key, ?string $default = null): ?string
    {
        return SiteSetting::get($key, $default);
    }
}

if (! function_exists('document_public_url')) {
    /**
     * URL publique d'un fichier stocké (storage/app/public, public/, ou URL absolue).
     */
    function document_public_url(?string $path): ?string
    {
        if ($path === null) {
            return null;
        }
        $path = trim($path);
        if ($path === '') {
            return null;
        }
        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            return $path;
        }
        if (str_starts_with($path, '/')) {
            return url($path);
        }
        if (Storage::disk('public')->exists($path)) {
            return url('/storage/'.ltrim($path, '/'));
        }

        return url('/storage/'.ltrim($path, '/'));
    }
}
