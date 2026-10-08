<?php

use App\Models\SiteSetting;
use App\Support\CardCatalog;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('site_settings')) {
            return;
        }

        $exists = DB::table('site_settings')->where('key', CardCatalog::SETTING_KEY)->exists();
        if (! $exists) {
            $now = now();
            DB::table('site_settings')->insert([
                'key' => CardCatalog::SETTING_KEY,
                'value' => json_encode(CardCatalog::defaults(), JSON_UNESCAPED_UNICODE),
                'created_at' => $now,
                'updated_at' => $now,
            ]);
            SiteSetting::flushCache();

            return;
        }

        SiteSetting::set(
            CardCatalog::SETTING_KEY,
            json_encode(CardCatalog::all(), JSON_UNESCAPED_UNICODE)
        );
        SiteSetting::flushCache();
    }

    public function down(): void
    {
        // no-op
    }
};
