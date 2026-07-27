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
        return [
            'id' => $this->id,
            'pemilik' => $this->pemilik,
            'nama_kolam' => $this->nama_kolam,
            'mqtt_id' => $this->mqtt_id,
            'lat' => $this->lat,
            'long' => $this->long,
            'status' => $this->status,
            'status_label' => $this->status == '1' ? 'Aktif' : 'Tidak Aktif',
            'luas_kolam' => $this->luas_kolam,
            'detail_udang' => $this->detail_udang,
            'relays' => $this->whenLoaded('relays'),
            'created_at' => $this->created_at ? $this->created_at->toDateTimeString() : null,
            'updated_at' => $this->updated_at ? $this->updated_at->toDateTimeString() : null,
            'deleted_at' => $this->deleted_at ? $this->deleted_at->toDateTimeString() : null,
        ];
    }
}
