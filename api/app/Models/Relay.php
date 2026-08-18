<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Relay extends Model
{
    protected $fillable = [
        'kolam_id',
        'nama_relay',
        'is_on',
    ];

    protected $casts = [
        'is_on' => 'boolean',
    ];

    public function kolam()
    {
        return $this->belongsTo(Kolam::class);
    }
}
