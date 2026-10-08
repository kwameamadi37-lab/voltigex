<?php

namespace App\Http\Controllers;

use App\Models\SiteSetting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AdminSiteSettingsController extends Controller
{
    public function edit()
    {
        $settings = SiteSetting::allCached();

        return view('admin.settings', compact('settings'));
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'contact_email' => 'required|email|max:255',
            'support_email' => 'required|email|max:255',
            'contact_phone' => 'required|string|max:50',
            'default_locale' => 'required|string|max:10',
            'opening_hours' => 'nullable|string|max:2000',
            'app_play_store_url' => 'nullable|url|max:500',
            'legal_privacy_url' => 'nullable|string|max:500',
            'legal_terms_url' => 'nullable|string|max:500',
            'legal_security_url' => 'nullable|string|max:500',
            'mail_from_name' => 'required|string|max:100',
            'mail_from_address' => 'required|email|max:255',
            'brand_website_url' => 'nullable|url|max:500',
            'app_qr_code' => 'nullable|image|max:4096',
            'legal_privacy_pdf' => 'nullable|file|mimes:pdf|max:10240',
            'legal_terms_pdf' => 'nullable|file|mimes:pdf|max:10240',
            'legal_security_pdf' => 'nullable|file|mimes:pdf|max:10240',
        ]);

        foreach ([
            'contact_email', 'support_email', 'contact_phone', 'default_locale',
            'opening_hours', 'app_play_store_url', 'legal_privacy_url', 'legal_terms_url',
            'legal_security_url', 'mail_from_name', 'mail_from_address', 'brand_website_url',
        ] as $key) {
            SiteSetting::set($key, $validated[$key] ?? '');
        }

        if ($request->hasFile('app_qr_code')) {
            $path = $request->file('app_qr_code')->store('site', 'public');
            SiteSetting::set('app_qr_code_path', $path);
        }

        foreach (['legal_privacy_pdf', 'legal_terms_pdf', 'legal_security_pdf'] as $fileKey) {
            if ($request->hasFile($fileKey)) {
                $path = $request->file($fileKey)->store('legal', 'public');
                SiteSetting::set($fileKey, $path);
            }
        }

        SiteSetting::flushCache();

        return redirect()->route('admin.settings')->with('message', 'Paramètres enregistrés.');
    }
}
