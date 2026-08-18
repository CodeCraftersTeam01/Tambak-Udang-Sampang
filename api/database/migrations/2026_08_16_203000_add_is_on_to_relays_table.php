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
        Schema::table('relays', function (Blueprint $table) {
            $table->boolean('is_on')->default(false)->after('nama_relay');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('relays', function (Blueprint $table) {
            $table->dropColumn('is_on');
        });
    }
};
