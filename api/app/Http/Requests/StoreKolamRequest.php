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
            'pemilik' => 'nullable|integer|exists:users,id',
            'nama_kolam' => 'required|string|max:255|unique:kolams,nama_kolam',
            'id_mqtt' => 'required|string|max:255',
            'luas' => 'required|numeric',
            'detail_udang' => 'required|string',
            'lat' => 'required|numeric',
            'long' => 'required|numeric',
            'status' => 'required',
            'relays' => 'required|array',
            'relays.*' => 'required|string',
            'image_file' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:10240',
        ];
    }
}
