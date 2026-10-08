<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasColumn('users', 'birth_date')) {
            Schema::table('users', function (Blueprint $table) {
                $table->date('birth_date')->nullable();
            });
        }

        if (Schema::hasColumn('users', 'birth_date') && Schema::hasColumn('users', 'date_naissance')) {
            DB::table('users')
                ->whereNull('birth_date')
                ->whereNotNull('date_naissance')
                ->update(['birth_date' => DB::raw('date_naissance')]);
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('users', 'birth_date')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropColumn('birth_date');
            });
        }
    }
};
