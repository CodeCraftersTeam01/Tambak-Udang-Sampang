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
        'status_siklus',
        'luas_kolam',
        'detail_udang',
        'tanggal_tebar',
        'image_path',
    ];

    public function getDocAttribute()
    {
        if ($this->status_siklus !== 'aktif') {
            return null;
        }
        if (!$this->tanggal_tebar) {
            return null;
        }
        $now = \Carbon\Carbon::now()->startOfDay();
        $tebar = \Carbon\Carbon::parse($this->tanggal_tebar)->startOfDay();
        $diff = $tebar->diffInDays($now, false);
        return $diff < 0 ? 0 : (int) $diff;
    }

    public function relays()
    {
        return $this->hasMany(Relay::class);
    }

    public function pakans()
    {
        return $this->hasMany(Pakan::class, 'kolam_id', 'id');
    }

    public function panens()
    {
        return $this->hasMany(Panen::class, 'kolam_id', 'id');
    }

    public function produksiLogs()
    {
        return $this->hasMany(ProduksiLog::class, 'kolam_id', 'id');
    }
}
