<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Messages d'une conversation (chat Wori migré).
     */
    public function up(): void
    {
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('conversation_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('type', 10)->default('text'); // 'text' | 'media'
            $table->string('internal_type')->nullable(); // ex: 'virement_confirmed', 'security_alert'
            $table->text('content')->nullable();
            $table->string('media_type', 20)->nullable();
            $table->text('media_url')->nullable();
            $table->text('thumbnail_url')->nullable();
            $table->unsignedInteger('media_width')->nullable();
            $table->unsignedInteger('media_height')->nullable();
            $table->string('blurhash')->nullable();
            $table->json('metadata')->nullable();
            $table->boolean('is_read')->default(false);
            $table->boolean('is_pinned')->default(false);
            $table->boolean('is_deleted')->default(false);
            $table->timestamps();

            $table->index(['conversation_id', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
