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
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('role')->default('user');
            $table->string('nom');
            $table->string('prenom');
            $table->string('phone')->nullable();
            $table->string('alias')->unique();
            
            // Données sensibles (devraient être chiffrées)
            $table->string('numero_bancaire')->unique();
            $table->string('card_number', 19)->unique();
            $table->string('iban')->unique();
            $table->string('bic');
            $table->date('date_exp')->nullable();
            $table->string('cvv', 4)->nullable(); // À éviter en production
            
            $table->decimal('solde', 10, 2)->default(0);
            $table->string('piece_identite')->nullable();
            $table->string('avis_imposition')->nullable();
            $table->string('photo_carte_identite')->nullable();
            $table->tinyInteger('account_status')->default(0)->comment('0=inactive, 1=active');
            $table->string('email')->unique();
            $table->string('devise')->default('€');
            $table->boolean('card_active')->default(false);
            $table->timestamp('email_verified_at')->nullable();
            $table->timestamp('phone_verified_at')->nullable();
            $table->string('password');
            
            // Adresse
            
            // Statut KYC
            $table->enum('kyc_status', ['pending', 'in_progress', 'approved', 'rejected', 'expired'])->default('pending');
            $table->timestamp('kyc_submitted_at')->nullable();
            $table->timestamp('kyc_approved_at')->nullable();
            $table->text('kyc_rejection_reason')->nullable();
        
            // Informations de suivi
            $table->string('ip_address')->nullable();
            $table->string('last_ip_address')->nullable();
            $table->string('country')->nullable();
            $table->string('last_country')->nullable();
            $table->boolean('is_blocked')->default(false);
            $table->boolean('is_online')->default(false);

            $table->rememberToken();
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
        Schema::dropIfExists('users');
    }
};
