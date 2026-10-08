<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('user_fcm_tokens', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            // VARCHAR (pas TEXT) : MySQL ne peut pas indexer une colonne TEXT en entier dans une contrainte UNIQUE composite sans préfixe (errno 150).
            // Les tokens FCM tiennent largement en dessous de 512 caractères.
            $table->string('fcm_token', 512);
            $table->enum('device_type', ['android', 'ios', 'web'])->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'fcm_token']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_fcm_tokens');
    }
};
