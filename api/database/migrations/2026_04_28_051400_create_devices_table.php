<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('devices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pond_id')->nullable()->constrained('kolams')->nullOnDelete();
            $table->string('device_code', 50)->unique();
            $table->string('name', 150);
            $table->string('device_type', 50)->default('sensor_node');
            $table->string('brand', 100)->nullable();
            $table->string('model', 100)->nullable();
            $table->string('serial_number', 100)->nullable();
            $table->string('mqtt_topic', 255)->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->string('location_note', 255)->nullable();
            $table->enum('status', ['active', 'inactive', 'maintenance'])->default('active');
            $table->timestamp('last_seen_at')->nullable();
            $table->timestamp('installed_at')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('devices');
    }
};
