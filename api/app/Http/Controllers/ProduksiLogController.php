<?php

namespace App\Http\Controllers;

use App\Models\ProduksiLog;
use Illuminate\Http\Request;

class ProduksiLogController extends Controller
{
    public function store(Request $request)
    {
        $this->validate($request, [
            'kolam_id'       => 'required|exists:kolams,id',
            'suhu'           => 'nullable|numeric',
            'ph'             => 'nullable|numeric',
            'do'             => 'nullable|numeric',
            'tds'            => 'nullable|numeric',
            'pakan_kg'       => 'required|numeric',
            'mbw_gram'       => 'required|numeric',
            'mortality_ekor' => 'required|integer',
        ]);

        $log = ProduksiLog::create($request->all());

        return response()->json([
            'message' => 'Log harian berhasil disimpan',
            'data'    => $log
        ], 201);
    }

    public function index($kolam_id)
    {
        $logs = ProduksiLog::with('kolam')->where('kolam_id', $kolam_id)->orderBy('created_at', 'asc')->get();
        return response()->json([
            'message' => 'Success',
            'data'    => $logs
        ]);
    }
}
