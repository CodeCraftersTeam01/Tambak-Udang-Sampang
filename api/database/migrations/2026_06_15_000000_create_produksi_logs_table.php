<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProduksiLogsTable extends Migration
{
    public function up()
    {
        Schema::create('produksi_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('kolam_id');
            $table->decimal('suhu', 5, 2)->nullable();
            $table->decimal('ph', 5, 2)->nullable();
            $table->decimal('do', 5, 2)->nullable();
            $table->decimal('kekeruhan', 5, 2)->nullable();
            $table->decimal('pakan_kg', 8, 2);
            $table->decimal('mbw_gram', 8, 2);
            $table->integer('mortality_ekor');
            $table->timestamps();

            $table->foreign('kolam_id')->references('id')->on('kolams')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('produksi_logs');
    }
}
