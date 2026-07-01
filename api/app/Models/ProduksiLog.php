<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProduksiLog extends Model
{
    protected $table = 'produksi_logs';

    protected $fillable = [
        'kolam_id',
        'suhu',
        'ph',
        'do',
        'tds',
        'pakan_kg',
        'mbw_gram',
        'mortality_ekor'
    ];

    public function kolam()
    {
        return $this->belongsTo(Kolam::class);
    }
}
