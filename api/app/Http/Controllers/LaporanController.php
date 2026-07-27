<?php

namespace App\Http\Controllers;

use App\Models\Kolam;
use App\Models\Panen;
use App\Models\Pakan;
use App\Models\ProduksiLog;
use Illuminate\Http\Request;

class LaporanController extends Controller
{
    public function show($kolam_id)
    {
        $kolam = Kolam::find($kolam_id);
        if (!$kolam) {
            return response()->json(['message' => 'Kolam tidak ditemukan'], 404);
        }

        $totalPakan = Pakan::where('kolam_id', $kolam_id)->sum('jumlah_perminggu_kg');
        $totalPanen = Panen::where('kolam_id', $kolam_id)->sum('jumlah_panen_kg');
        
        $latestLog = ProduksiLog::where('kolam_id', $kolam_id)->orderBy('created_at', 'desc')->first();
        $latestMbw = $latestLog ? (float)$latestLog->mbw_gram : 0.0;

        $logs = ProduksiLog::where('kolam_id', $kolam_id)->orderBy('created_at', 'asc')->get();

        return response()->json([
            'message' => 'Success',
            'data' => [
                'kolam' => [
                    'nama_kolam' => $kolam->nama_kolam,
                    'target_panen' => $kolam->target_panen,
                ],
                'summary' => [
                    'total_pakan_kg' => (float)$totalPakan,
                    'total_panen_kg' => (float)$totalPanen,
                    'latest_mbw_gram' => $latestMbw,
                ],
                'history' => $logs->map(function($log) {
                    return [
                        'tanggal' => $log->created_at->format('Y-m-d'),
                        'suhu' => (float)$log->suhu,
                        'ph' => (float)$log->ph,
                        'do' => (float)$log->do,
                        'tds' => (float)$log->tds,
                        'mbw_gram' => (float)$log->mbw_gram,
                    ];
                })
            ]
        ], 200);
    }
}
