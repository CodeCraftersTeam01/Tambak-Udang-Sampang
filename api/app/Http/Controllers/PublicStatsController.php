<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use App\Models\Kolam;
use App\Models\Panen;
use App\Models\Pakan;

class PublicStatsController extends Controller
{
    public function index()
    {
        try {
            // 1. Total Kolam
            $totalKolam = Kolam::count();

            // 2. Total Panen (kg)
            $totalPanen = Panen::sum('jumlah_panen_kg');

            // 3. Total Pakan (kg)
            $totalPakan = Pakan::sum('jumlah_perminggu_kg');

            // 4. Latest Readings of active pond (e.g. first active pond)
            $firstPond = Kolam::first();
            $latestReadings = [];
            
            if ($firstPond) {
                $rows = DB::select("
                    SELECT
                        st.code,
                        st.name,
                        sr.value,
                        sr.unit
                    FROM sensors s
                    JOIN sensor_types st ON st.id = s.sensor_type_id
                    JOIN devices d ON d.id = s.device_id
                    JOIN sensor_readings sr ON sr.sensor_id = s.id
                    WHERE d.pond_id = ?
                    AND sr.id = (
                        SELECT sr2.id
                        FROM sensor_readings sr2
                        WHERE sr2.sensor_id = s.id
                        ORDER BY sr2.recorded_at DESC, sr2.id DESC
                        LIMIT 1
                    )
                    ORDER BY st.id ASC
                ", [$firstPond->id]);

                $latestReadings = array_map(function ($row) {
                    return [
                        'code' => $row->code,
                        'name' => $row->name,
                        'value' => (float) $row->value,
                        'unit' => $row->unit,
                    ];
                }, $rows);
            }

            return response()->json([
                'status' => 'success',
                'data' => [
                    'total_kolam' => $totalKolam,
                    'total_panen_kg' => (float) $totalPanen,
                    'total_pakan_kg' => (float) $totalPakan,
                    'latest_readings' => $latestReadings,
                    'monitoring_pond_name' => $firstPond->nama_kolam ?? 'Kolam',
                ]
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
