<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Device extends Model
{
    protected $fillable = [
        'pond_id',
        'device_code',
        'name',
        'device_type',
        'brand',
        'model',
        'serial_number',
        'mqtt_topic',
        'ip_address',
        'location_note',
        'status',
        'last_seen_at',
        'installed_at',
    ];

    protected $casts = [
        'pond_id' => 'integer',
        'last_seen_at' => 'datetime',
        'installed_at' => 'datetime',
    ];

    /**
     * Get the pond (kolam) associated with this device.
     */
    public function kolam()
    {
        return $this->belongsTo(Kolam::class, 'pond_id');
    }
}
