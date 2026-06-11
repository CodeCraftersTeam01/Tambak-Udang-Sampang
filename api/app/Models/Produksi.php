<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Produksi extends Model
{
    protected $table = 'produksis';

    protected $fillable = [
        'tanggal_pemasangan_benor',
        'ukuran_benor',
        'kolam_id',
    ];

    protected $casts = [
        'tanggal_pemasangan_benor' => 'date:Y-m-d',
    ];

    /**
     * Relasi ke Kolam
     */
    public function kolam()
    {
        return $this->belongsTo(Kolam::class);
    }

    /**
     * Hitung usia benur dalam hari dari tanggal pemasangan
     */
    public function getUsiaBenurAttribute(): int
    {
        return (int) \Carbon\Carbon::now()->diffInDays($this->tanggal_pemasangan_benor);
    }
}
