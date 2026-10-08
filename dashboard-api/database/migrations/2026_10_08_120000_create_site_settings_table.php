<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('site_settings', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->text('value')->nullable();
            $table->timestamps();
        });

        $now = now();
        $defaults = [
            'contact_email' => 'contact@voltigex.com',
            'support_email' => 'support@voltigex.com',
            'contact_phone' => '+33 1 23 45 67 89',
            'default_locale' => 'fr',
            'opening_hours' => "Lundi – Vendredi : 9h00 – 18h00\nSamedi : 9h00 – 12h00\nDimanche : fermé",
            'app_play_store_url' => 'https://play.google.com/store/apps/details?id=com.mybank.app',
            'app_qr_code_path' => '',
            'legal_privacy_url' => '/politique-confidentialite',
            'legal_terms_url' => '/condition-utilisation',
            'legal_security_url' => '/politique-securite',
            'legal_privacy_pdf' => '',
            'legal_terms_pdf' => '',
            'legal_security_pdf' => '',
            'mail_from_name' => 'Voltigex',
            'mail_from_address' => 'contact@voltigex.com',
            'brand_website_url' => 'https://voltigex.com',
        ];

        foreach ($defaults as $key => $value) {
            DB::table('site_settings')->insert([
                'key' => $key,
                'value' => $value,
                'created_at' => $now,
                'updated_at' => $now,
            ]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('site_settings');
    }
};
