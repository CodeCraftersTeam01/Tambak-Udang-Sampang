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
        Schema::table('panens', function (Blueprint $table) {
            $table->string('shrimp_size')->nullable()->after('jenis_panen');
            $table->decimal('sale_price', 12, 2)->nullable()->after('shrimp_size');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('panens', function (Blueprint $table) {
            $table->dropColumn(['shrimp_size', 'sale_price']);
        });
    }
};
