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
        Schema::table('priority_scores', function (Blueprint $table) {

            // Menyimpan hasil perhitungan SAW
            $table->decimal('saw_score', 5, 4)->nullable()->after('population_coverage');

            // Menyimpan kategori urgensi
            $table->string('urgency_level', 30)->nullable()->after('saw_score');

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('priority_scores', function (Blueprint $table) {

            $table->dropColumn([
                'saw_score',
                'urgency_level'
            ]);

        });
    }
};