<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class KolamResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function toArray($request)
    {
        $deviceId = \Illuminate\Support\Facades\DB::table('devices')
            ->where('pond_id', $this->id)
            ->value('id');

        return [
            'id' => $this->id,
            // Indonesian keys (for legacy support)
            'pemilik' => $this->pemilik,
            'nama_kolam' => $this->nama_kolam,
            'mqtt_id' => $this->mqtt_id,
            'lat' => $this->lat,
            'long' => $this->long,
            'status' => $this->status,
            'status_label' => $this->status == '1' ? 'Aktif' : 'Tidak Aktif',
            'status_siklus' => $this->status_siklus,
            'luas_kolam' => $this->luas_kolam,
            'detail_udang' => $this->detail_udang,
            'tanggal_tebar' => $this->tanggal_tebar,
            'doc' => $this->doc,
            'image_path' => $this->image_path,
            'image_url' => $this->image_path ? url($this->image_path) : null,
            'relays' => $this->whenLoaded('relays'),
            
            // English keys (for Master Spec compatibility)
            'farm_id' => $this->pemilik,
            'name' => $this->nama_kolam,
            'device_id' => $deviceId,
            'latitude' => $this->lat ? (float) $this->lat : null,
            'longitude' => $this->long ? (float) $this->long : null,
            'area' => $this->luas_kolam ? (float) $this->luas_kolam : null,
            'status_english' => $this->status == '1' ? 'active' : 'inactive',
            'status_siklus' => $this->status_siklus,
            'shrimp_detail' => $this->detail_udang,
            'doc' => $this->doc,
            
            'created_at' => $this->created_at ? $this->created_at->toDateTimeString() : null,
            'updated_at' => $this->updated_at ? $this->updated_at->toDateTimeString() : null,
            'deleted_at' => $this->deleted_at ? $this->deleted_at->toDateTimeString() : null,
        ];
    }
}
