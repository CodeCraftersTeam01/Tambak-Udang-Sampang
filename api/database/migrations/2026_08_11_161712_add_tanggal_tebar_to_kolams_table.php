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
            $table->date('tanggal_tebar')->nullable()->after('luas_kolam');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('kolams', function (Blueprint $table) {
            $table->dropColumn('tanggal_tebar');
        });
    }
};
