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
        Schema::dropIfExists('sensor_thresholds');

        Schema::create('sensor_thresholds', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pond_id')->constrained('kolams')->cascadeOnDelete();
            $table->string('sensor_type'); // ph, do, Suhu, tds, water_level
            $table->integer('doc_start');
            $table->integer('doc_end')->nullable(); // nullable for infinity / open-ended
            $table->decimal('min_value', 10, 2)->nullable();
            $table->decimal('max_value', 10, 2)->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sensor_thresholds');

        Schema::create('sensor_thresholds', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sensor_type_id')->constrained('sensor_types')->cascadeOnDelete();
            $table->foreignId('pond_id')->constrained('kolams')->cascadeOnDelete();
            $table->decimal('min_value', 10, 2)->nullable();
            $table->decimal('max_value', 10, 2)->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }
};
