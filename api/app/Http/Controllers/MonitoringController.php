<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MonitoringController extends Controller
{
    public function latest(Request $request)
    {
        $pondId = (int) $request->query('pond_id', 1);

        $rows = DB::select("
            SELECT
                st.code,
                st.name,
                sr.value,
                sr.unit,
                COALESCE(th.min_value, st.normal_min) AS min,
                COALESCE(th.max_value, st.normal_max) AS max,
                sr.recorded_at,
                s.id AS sensor_id,
                s.sensor_code
            FROM sensors s
            JOIN sensor_types st ON st.id = s.sensor_type_id
            JOIN devices d ON d.id = s.device_id
            LEFT JOIN sensor_thresholds th
                ON th.sensor_type_id = st.id
                AND th.pond_id = d.pond_id
                AND th.is_active = 1
            JOIN sensor_readings sr
                ON sr.sensor_id = s.id
            WHERE d.pond_id = ?
            AND sr.id = (
                SELECT sr2.id
                FROM sensor_readings sr2
                WHERE sr2.sensor_id = s.id
                ORDER BY sr2.recorded_at DESC, sr2.id DESC
                LIMIT 1
            )
            ORDER BY st.id ASC
        ", [$pondId]);

        return response()->json([
            'success' => true,
            'data' => [
                'pond_id' => $pondId,
                'sensors' => array_map(function ($row) {
                    return [
                        'code' => $row->code,
                        'name' => $row->name,
                        'value' => (float) $row->value,
                        'unit' => $row->unit,
                        'min' => $row->min !== null ? (float) $row->min : null,
                        'max' => $row->max !== null ? (float) $row->max : null,
                        'recorded_at' => $row->recorded_at,
                        'sensor_id' => (int) $row->sensor_id,
                        'sensor_code' => $row->sensor_code,
                    ];
                }, $rows),
            ],
        ]);
    }
}
