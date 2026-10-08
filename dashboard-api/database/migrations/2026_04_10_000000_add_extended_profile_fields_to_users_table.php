<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('address_line')->nullable()->after('country');
            $table->string('city')->nullable()->after('address_line');
            $table->string('postal_code', 32)->nullable()->after('city');
            $table->date('date_naissance')->nullable()->after('postal_code');
            $table->string('nationalite', 128)->nullable()->after('date_naissance');
            $table->string('numero_identification', 64)->nullable()->after('nationalite');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'address_line',
                'city',
                'postal_code',
                'date_naissance',
                'nationalite',
                'numero_identification',
            ]);
        });
    }
};
