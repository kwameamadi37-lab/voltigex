<?php

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
        if ($exists) {
            return;
        }

        $now = now();
        DB::table('site_settings')->insert([
            'key' => CardCatalog::SETTING_KEY,
            'value' => json_encode(CardCatalog::defaults(), JSON_UNESCAPED_UNICODE),
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    }

    public function down(): void
    {
        if (! Schema::hasTable('site_settings')) {
            return;
        }

        DB::table('site_settings')->where('key', CardCatalog::SETTING_KEY)->delete();
    }
};
