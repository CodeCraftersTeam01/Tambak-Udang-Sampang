<?php

namespace App\Http\Controllers;

use App\Models\Pakan;
use Illuminate\Http\Request;

class PakanController extends Controller
{
    public function index()
    {
        $data = Pakan::with('kolam')->get();
        return response()->json(['message' => 'Success', 'data' => $data], 200);
    }

    public function statistik()
    {
        // Total konsumsi pakan seluruh kolam per minggu
        $totalPerMinggu = Pakan::sum('jumlah_perminggu_kg');

        // Statistik per kolam
        $perKolam = Pakan::with('kolam')
            ->selectRaw('kolam_id, SUM(jumlah_perminggu_kg) as total_kg')
            ->groupBy('kolam_id')
            ->get()
            ->map(fn($p) => [
                'kolam_id'   => $p->kolam_id,
                'nama_kolam' => $p->kolam->nama_kolam ?? '-',
                'total_kg'   => (float) $p->total_kg,
            ]);

        return response()->json([
            'message' => 'Success',
            'data'    => [
                'total_perminggu_kg' => (float) $totalPerMinggu,
                'per_kolam'          => $perKolam,
            ],
        ]);
    }

    public function store(Request $request)
    {
        $this->validate($request, [
            'nama_pakan'          => 'required|string|max:255',
            'jumlah_perminggu_kg' => 'required|numeric|min:0',
            'kolam_id'            => 'required|exists:kolams,id',
        ]);

        $pakan = Pakan::create($request->only(['nama_pakan', 'jumlah_perminggu_kg', 'kolam_id']));
        $pakan->load('kolam');

        return response()->json(['message' => 'Pakan berhasil ditambahkan', 'data' => $pakan], 201);
    }

    public function show($id)
    {
        $pakan = Pakan::with('kolam')->find($id);
        if (!$pakan) {
            return response()->json(['message' => 'Pakan tidak ditemukan'], 404);
        }
        return response()->json(['message' => 'Success', 'data' => $pakan]);
    }

    public function update(Request $request, $id)
    {
        $pakan = Pakan::find($id);
        if (!$pakan) {
            return response()->json(['message' => 'Pakan tidak ditemukan'], 404);
        }

        $this->validate($request, [
            'nama_pakan'          => 'sometimes|string|max:255',
            'jumlah_perminggu_kg' => 'sometimes|numeric|min:0',
            'kolam_id'            => 'sometimes|exists:kolams,id',
        ]);

        $pakan->update($request->only(['nama_pakan', 'jumlah_perminggu_kg', 'kolam_id']));
        $pakan->load('kolam');

        return response()->json(['message' => 'Pakan berhasil diperbarui', 'data' => $pakan]);
    }

    public function destroy($id)
    {
        $pakan = Pakan::find($id);
        if (!$pakan) {
            return response()->json(['message' => 'Pakan tidak ditemukan'], 404);
        }
        $pakan->delete();
        return response()->json(['message' => 'Pakan berhasil dihapus']);
    }
}
