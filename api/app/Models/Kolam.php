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
        'lat',
        'long',
        'status',
    ];
}
