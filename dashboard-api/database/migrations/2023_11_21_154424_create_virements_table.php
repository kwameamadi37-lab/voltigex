<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('virements', function (Blueprint $table) {
            $table->id();
            $table->string('nom');
            $table->string('prenom');
            $table->string('nombanque');
            $table->string('titulairebanque');
            $table->string('iban');
            $table->string('bic')->nullable();
            $table->string('montant');
            $table->string('pourcentage')->default('60');
            $table->string('statut')->default('En traitement');
            $table->string('code');
            $table->integer('user_id');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('virements');
    }
};
