<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('type'); // 'virement', 'securite', 'systeme', etc.
            $table->string('titre');
            $table->text('message');
            $table->string('icon')->nullable(); // Pour stocker l'icône FontAwesome
            $table->string('icon_color')->nullable(); // Pour stocker la couleur de l'icône
            $table->boolean('is_read')->default(false);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('notifications');
    }
}; 