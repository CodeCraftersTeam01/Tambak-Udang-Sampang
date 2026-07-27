<?php

namespace App\Http\Requests;

class UpdateKolamRequest
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
     * @param int|null $id
     * @return array
     */
    public function rules($id = null)
    {
        return [
            'pemilik' => 'required|integer|exists:users,id',
            'nama_kolam' => 'required|string|max:255' . ($id ? '|unique:kolams,nama_kolam,' . $id : ''),
            'mqtt_id' => 'nullable|string|max:255',
            'lat' => 'nullable|numeric',
            'long' => 'nullable|numeric',
            'status' => 'required|in:0,1,2',
            'luas_kolam' => 'nullable|numeric',
            'detail_udang' => 'nullable|string',
        ];
    }
}
