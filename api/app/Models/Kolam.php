<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Kolam extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'id',
        'pemilik',
        'nama_kolam',
        'mqtt_id',
        'lat',
        'long',
        'status',
        'luas_kolam',
        'detail_udang',
    ];

    public function relays()
    {
        return $this->hasMany(Relay::class);
    }
}
