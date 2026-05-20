<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePanensTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('panens', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->date('tanggal_panen');
            $table->decimal('jumlah_panen_kg', 10, 2)->default(0);
            $table->enum('jenis_panen', ['parsial', 'total']);
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
        Schema::dropIfExists('panens');
    }
}
