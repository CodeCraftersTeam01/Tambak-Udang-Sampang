<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
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

    public function down()
    {
        Schema::dropIfExists('sensor_thresholds');
    }
};
