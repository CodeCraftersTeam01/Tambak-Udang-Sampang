<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('sensors', function (Blueprint $table) {
            $table->id();
            $table->foreignId('device_id')->constrained('devices')->cascadeOnDelete();
            $table->foreignId('sensor_type_id')->constrained('sensor_types')->cascadeOnDelete();
            $table->string('sensor_code', 50)->nullable();
            $table->string('name', 150);
            $table->date('calibration_date')->nullable();
            $table->text('calibration_note')->nullable();
            $table->enum('status', ['active', 'inactive', 'error'])->default('active');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('sensors');
    }
};
