<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Relay extends Model
{
    protected $fillable = [
        'kolam_id',
        'nama_relay',
    ];

    public function kolam()
    {
        return $this->belongsTo(Kolam::class);
    }
}
