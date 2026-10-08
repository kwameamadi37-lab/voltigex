<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    private function generateSlug(): string
    {
        $alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
        do {
            $a = '';
            for ($i = 0; $i < 4; $i++) {
                $a .= $alphabet[random_int(0, strlen($alphabet) - 1)];
            }
            $b = '';
            for ($i = 0; $i < 4; $i++) {
                $b .= $alphabet[random_int(0, strlen($alphabet) - 1)];
            }
            $slug = $a.'-'.$b;
        } while (DB::table('virements')->where('slug', $slug)->exists());

        return $slug;
    }

    public function up(): void
    {
        Schema::table('virements', function (Blueprint $table) {
            $table->string('slug', 16)->nullable()->unique()->after('id');
        });

        foreach (DB::table('virements')->orderBy('id')->get() as $row) {
            if (! empty($row->slug)) {
                continue;
            }
            DB::table('virements')->where('id', $row->id)->update([
                'slug' => $this->generateSlug(),
            ]);
        }
    }

    public function down(): void
    {
        Schema::table('virements', function (Blueprint $table) {
            $table->dropUnique(['slug']);
            $table->dropColumn('slug');
        });
    }
};
