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
            $englishMapped = [
                'pond_id' => $p->kolam_id,
                'pond_name' => $p->kolam->nama_kolam ?? 'Unknown',
                'start_date' => $p->tanggal_pemasangan_benor ? $p->tanggal_pemasangan_benor->format('Y-m-d') : null,
                'shrimp_species' => 'Vannamei',
                'initial_density' => $p->ukuran_benor,
                'status' => 'active',
                'age_of_water_days' => $p->usia_benur,
            ];
            return array_merge($p->toArray(), [
                'usia_benur' => $p->usia_benur,
            ], $englishMapped);
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
        $p = Produksi::with('kolam')->find($id);
        if (!$p) {
            return response()->json(['message' => 'Produksi tidak ditemukan'], 404);
        }

        $englishMapped = [
            'id' => $p->id,
            'pond_id' => $p->kolam_id,
            'pond_name' => $p->kolam->nama_kolam ?? 'Unknown',
            'start_date' => $p->tanggal_pemasangan_benor ? $p->tanggal_pemasangan_benor->format('Y-m-d') : null,
            'shrimp_species' => 'Vannamei',
            'initial_density' => $p->ukuran_benor,
            'status' => 'active',
            'age_of_water_days' => $p->usia_benur,
        ];

        return response()->json([
            'message' => 'Success',
            'data'    => array_merge($p->toArray(), ['usia_benur' => $p->usia_benur], $englishMapped),
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

    /**
     * Get production management summary.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function productionSummary()
    {
        $activeCyclesCount = Produksi::count();
        $totalFeedUsed = (float) \App\Models\Pakan::sum('jumlah_perminggu_kg');
        $totalHarvest = (float) \App\Models\Panen::sum('jumlah_panen_kg');
        
        // Average MBW from latest log of each pond
        $uniquePondIds = \App\Models\ProduksiLog::distinct('kolam_id')->pluck('kolam_id');
        $latestLogsMbwSum = 0;
        $count = 0;
        foreach ($uniquePondIds as $pondId) {
            $latestLog = \App\Models\ProduksiLog::where('kolam_id', $pondId)->orderBy('created_at', 'desc')->first();
            if ($latestLog) {
                $latestLogsMbwSum += (float) $latestLog->mbw_gram;
                $count++;
            }
        }
        $averageMbw = $count > 0 ? ($latestLogsMbwSum / $count) : 0.0;

        return response()->json([
            'success' => true,
            'data' => [
                'active_cycles_count' => $activeCyclesCount,
                'total_feed_used_kg' => $totalFeedUsed,
                'total_harvest_kg' => $totalHarvest,
                'average_mbw_gram' => round($averageMbw, 2),
            ]
        ], 200);
    }
}
