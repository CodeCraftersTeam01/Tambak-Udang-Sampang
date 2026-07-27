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
            $table->dropColumn('jumlah_kincir');
            $table->string('mqtt_id')->nullable()->after('nama_kolam');
        });

        Schema::create('relays', function (Blueprint $table) {
            $table->id();
            $table->foreignId('kolam_id')->constrained('kolams')->onDelete('cascade');
            $table->string('nama_relay');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('relays');
        
        Schema::table('kolams', function (Blueprint $table) {
            $table->integer('jumlah_kincir')->default(0);
            $table->dropColumn('mqtt_id');
        });
    }
};
