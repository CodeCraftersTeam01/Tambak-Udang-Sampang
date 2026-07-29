<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('sensor_readings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sensor_id')->constrained('sensors')->cascadeOnDelete();
            $table->foreignId('pond_id')->nullable()->constrained('kolams')->cascadeOnDelete();
            $table->decimal('value', 12, 4);
            $table->string('unit', 30)->nullable();
            $table->timestamp('recorded_at');
            $table->timestamps();

            $table->index(['sensor_id', 'recorded_at']);
            $table->index(['pond_id', 'recorded_at']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('sensor_readings');
    }
};
