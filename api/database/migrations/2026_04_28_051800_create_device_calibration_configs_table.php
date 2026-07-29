<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('device_calibration_configs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('device_id')->constrained('devices')->cascadeOnDelete();
            $table->foreignId('pond_id')->nullable()->constrained('kolams')->nullOnDelete();
            $table->decimal('ph_slope', 8, 4)->default(3.5);
            $table->decimal('ph_offset', 8, 4)->default(1.9);
            $table->decimal('do_scale', 8, 4)->default(0.5);
            $table->decimal('do_offset', 8, 4)->default(0);
            $table->decimal('tds_scale', 8, 4)->default(1);
            $table->decimal('tds_offset', 8, 4)->default(0);
            $table->decimal('suhu_offset', 8, 4)->default(0);
            $table->integer('revision')->default(1);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('device_calibration_configs');
    }
};
