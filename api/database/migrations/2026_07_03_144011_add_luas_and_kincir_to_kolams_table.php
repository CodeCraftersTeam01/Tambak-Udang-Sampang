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
        Schema::table('kolams', function (Blueprint $table) {
            $table->decimal('luas_kolam', 8, 2)->nullable();
            $table->string('detail_udang')->nullable();
            $table->integer('jumlah_kincir')->default(0);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('kolams', function (Blueprint $table) {
            $table->dropColumn(['luas_kolam', 'detail_udang', 'jumlah_kincir']);
        });
    }
};
