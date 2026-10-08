<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('profile_photo_url')->nullable()->after('photo_carte_identite');
        });

        // Ne plus conserver d’URL « placeholder » distante éventuellement saisie à la main.
        DB::table('users')->where(function ($q) {
            $q->where('profile_photo_url', 'like', '%picsum.photos%')
                ->orWhere('profile_photo_url', 'like', '%placeholder%');
        })->update(['profile_photo_url' => null]);
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('profile_photo_url');
        });
    }
};
