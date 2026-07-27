<?php

namespace App\Http\Requests;

class StoreKolamRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize()
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array
     */
    public function rules()
    {
        return [
            'pemilik' => 'required|integer|exists:users,id',
            'nama_kolam' => 'required|string|max:255|unique:kolams,nama_kolam',
            'mqtt_id' => 'nullable|string|max:255',
            'lat' => 'nullable|numeric',
            'long' => 'nullable|numeric',
            'status' => 'required|in:0,1,2',
            'luas_kolam' => 'nullable|numeric',
            'detail_udang' => 'nullable|string',
        ];
    }
}
