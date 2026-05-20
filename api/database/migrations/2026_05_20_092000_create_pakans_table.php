<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePakansTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('pakans', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('nama_pakan');
            $table->decimal('jumlah_perminggu_kg', 8, 2)->default(0)->comment('Jumlah per minggu dalam KG');
            $table->unsignedBigInteger('kolam_id');
            $table->foreign('kolam_id')->references('id')->on('kolams')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('pakans');
    }
}
