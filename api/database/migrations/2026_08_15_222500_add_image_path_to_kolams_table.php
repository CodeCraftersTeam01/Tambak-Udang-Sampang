<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::table('kolams', function (Blueprint $table) {
            $table->string('image_path')->nullable()->after('detail_udang');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down()
    {
        Schema::table('kolams', function (Blueprint $table) {
            $table->dropColumn('image_path');
        });
    }
};
