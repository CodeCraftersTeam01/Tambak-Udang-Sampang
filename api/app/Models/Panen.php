<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Panen extends Model
{
    protected $table = 'panens';

    protected $fillable = [
        'tanggal_panen',
        'jumlah_panen_kg',
        'jenis_panen',
        'kolam_id',
        'shrimp_size',
        'sale_price',
    ];

    protected $casts = [
        'tanggal_panen'   => 'date:Y-m-d',
        'jumlah_panen_kg' => 'float',
        'sale_price'      => 'float',
    ];

    /**
     * Relasi ke Kolam
     */
    public function kolam()
    {
        return $this->belongsTo(Kolam::class);
    }
}
