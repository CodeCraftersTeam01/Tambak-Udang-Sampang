<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pakan extends Model
{
    protected $table = 'pakans';

    protected $fillable = [
        'nama_pakan',
        'jumlah_perminggu_kg',
        'kolam_id',
    ];

    protected $casts = [
        'jumlah_perminggu_kg' => 'float',
    ];

    /**
     * Relasi ke Kolam
     */
    public function kolam()
    {
        return $this->belongsTo(Kolam::class);
    }
}
