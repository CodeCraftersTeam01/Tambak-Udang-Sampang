<?php

namespace App\Http\Controllers;

use App\Models\Panen;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PanenController extends Controller
{
    public function index()
    {
        $data = Panen::with('kolam')->orderBy('tanggal_panen', 'desc')->get();
        return response()->json(['message' => 'Success', 'data' => $data], 200);
    }

    public function statistik()
    {
        // Total keseluruhan panen (kg)
        $totalKg = Panen::sum('jumlah_panen_kg');

        // Jumlah event panen
        $totalEvent = Panen::count();

        // Panen per bulan (12 bulan terakhir) untuk chart
        $perBulan = DB::select("
            SELECT
                DATE_FORMAT(tanggal_panen, '%Y-%m') AS bulan,
                SUM(jumlah_panen_kg) AS total_kg,
                COUNT(*) AS jumlah_event
            FROM panens
            WHERE tanggal_panen >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
            GROUP BY DATE_FORMAT(tanggal_panen, '%Y-%m')
            ORDER BY bulan ASC
        ");

        // Breakdown parsial vs total
        $breakdown = Panen::selectRaw("jenis_panen, COUNT(*) as jumlah, SUM(jumlah_panen_kg) as total_kg")
            ->groupBy('jenis_panen')
            ->get();

        // Per kolam
        $perKolam = Panen::with('kolam')
            ->selectRaw('kolam_id, SUM(jumlah_panen_kg) as total_kg, COUNT(*) as jumlah')
            ->groupBy('kolam_id')
            ->get()
            ->map(fn($p) => [
                'kolam_id'   => $p->kolam_id,
                'nama_kolam' => $p->kolam->nama_kolam ?? '-',
                'total_kg'   => (float) $p->total_kg,
                'jumlah'     => $p->jumlah,
            ]);

        return response()->json([
            'message' => 'Success',
            'data'    => [
                'total_kg'     => (float) $totalKg,
                'total_event'  => $totalEvent,
                'per_bulan'    => $perBulan,
                'breakdown'    => $breakdown,
                'per_kolam'    => $perKolam,
            ],
        ]);
    }

    public function store(Request $request)
    {
        $this->validate($request, [
            'tanggal_panen'    => 'required|date',
            'jumlah_panen_kg'  => 'required|numeric|min:0',
            'jenis_panen'      => 'required|in:parsial,total',
            'kolam_id'         => 'required|exists:kolams,id',
        ]);

        $panen = Panen::create($request->only(['tanggal_panen', 'jumlah_panen_kg', 'jenis_panen', 'kolam_id']));
        $panen->load('kolam');

        return response()->json(['message' => 'Panen berhasil ditambahkan', 'data' => $panen], 201);
    }

    public function show($id)
    {
        $panen = Panen::with('kolam')->find($id);
        if (!$panen) {
            return response()->json(['message' => 'Panen tidak ditemukan'], 404);
        }
        return response()->json(['message' => 'Success', 'data' => $panen]);
    }

    public function update(Request $request, $id)
    {
        $panen = Panen::find($id);
        if (!$panen) {
            return response()->json(['message' => 'Panen tidak ditemukan'], 404);
        }

        $this->validate($request, [
            'tanggal_panen'   => 'sometimes|date',
            'jumlah_panen_kg' => 'sometimes|numeric|min:0',
            'jenis_panen'     => 'sometimes|in:parsial,total',
            'kolam_id'        => 'sometimes|exists:kolams,id',
        ]);

        $panen->update($request->only(['tanggal_panen', 'jumlah_panen_kg', 'jenis_panen', 'kolam_id']));
        $panen->load('kolam');

        return response()->json(['message' => 'Panen berhasil diperbarui', 'data' => $panen]);
    }

    public function destroy($id)
    {
        $panen = Panen::find($id);
        if (!$panen) {
            return response()->json(['message' => 'Panen tidak ditemukan'], 404);
        }
        $panen->delete();
        return response()->json(['message' => 'Panen berhasil dihapus']);
    }
}
