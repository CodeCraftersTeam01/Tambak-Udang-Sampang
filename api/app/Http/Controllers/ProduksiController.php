<?php

namespace App\Http\Controllers;

use App\Models\Produksi;
use Illuminate\Http\Request;

class ProduksiController extends Controller
{
    public function publicUsiaBenur()
    {
        // Ambil produksi terbaru dari setiap kolam
        $data = Produksi::with('kolam')->orderBy('tanggal_pemasangan_benor', 'desc')->take(6)->get()->map(function ($p) {
            return [
                'kolam' => $p->kolam->nama_kolam ?? 'Unknown',
                'usia_benur' => $p->usia_benur,
                'ukuran_benor' => $p->ukuran_benor,
            ];
        });
        return response()->json(['message' => 'Success', 'data' => $data], 200);
    }

    public function index()
    {
        $data = Produksi::with('kolam')->get()->map(function ($p) {
            return array_merge($p->toArray(), [
                'usia_benur' => $p->usia_benur,
            ]);
        });

        return response()->json(['message' => 'Success', 'data' => $data], 200);
    }

    public function store(Request $request)
    {
        $this->validate($request, [
            'tanggal_pemasangan_benor' => 'required|date',
            'ukuran_benor'             => 'required|string|max:100',
            'kolam_id'                 => 'required|exists:kolams,id',
        ]);

        $produksi = Produksi::create($request->only(['tanggal_pemasangan_benor', 'ukuran_benor', 'kolam_id']));
        $produksi->load('kolam');

        return response()->json([
            'message' => 'Produksi berhasil ditambahkan',
            'data'    => array_merge($produksi->toArray(), ['usia_benur' => $produksi->usia_benur]),
        ], 201);
    }

    public function show($id)
    {
        $produksi = Produksi::with('kolam')->find($id);
        if (!$produksi) {
            return response()->json(['message' => 'Produksi tidak ditemukan'], 404);
        }
        return response()->json([
            'message' => 'Success',
            'data'    => array_merge($produksi->toArray(), ['usia_benur' => $produksi->usia_benur]),
        ]);
    }

    public function update(Request $request, $id)
    {
        $produksi = Produksi::find($id);
        if (!$produksi) {
            return response()->json(['message' => 'Produksi tidak ditemukan'], 404);
        }

        $this->validate($request, [
            'tanggal_pemasangan_benor' => 'sometimes|date',
            'ukuran_benor'             => 'sometimes|string|max:100',
            'kolam_id'                 => 'sometimes|exists:kolams,id',
        ]);

        $produksi->update($request->only(['tanggal_pemasangan_benor', 'ukuran_benor', 'kolam_id']));
        $produksi->load('kolam');

        return response()->json([
            'message' => 'Produksi berhasil diperbarui',
            'data'    => array_merge($produksi->toArray(), ['usia_benur' => $produksi->usia_benur]),
        ]);
    }

    public function destroy($id)
    {
        $produksi = Produksi::find($id);
        if (!$produksi) {
            return response()->json(['message' => 'Produksi tidak ditemukan'], 404);
        }
        $produksi->delete();
        return response()->json(['message' => 'Produksi berhasil dihapus']);
    }
}
